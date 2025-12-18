FROM debian:bookworm-slim AS builder

RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        build-essential ca-certificates wget rsync uuid-dev \
        libapr1-dev libaprutil1-dev libserf-1-1 libserf-dev \
        libexpat1-dev libsqlite3-dev libssl-dev zlib1g-dev liblz4-dev libcrypt-dev \
        libkrb5-dev \
        pkg-config autoconf automake libtool; \
    rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    wget https://downloads.apache.org/subversion/subversion-1.14.5.tar.bz2 -O /tmp/subversion.tar.bz2; \
    tar -xjf /tmp/subversion.tar.bz2 -C /tmp; \
    cd /tmp/subversion-1.14.5; \
    ./configure --prefix=/usr --with-serf --with-lz4=yes --with-utf8proc=internal; \
    make -j"$(nproc)"; \
    make install DESTDIR=/out; \
    find /out/usr/bin /out/usr/libexec /out/usr/lib -type f \
      \( -name '*.so*' -o -perm -111 \) \
      ! -name '*.a' ! -name '*.la' \
      -print0 2>/dev/null | xargs -0 -r strip --strip-unneeded || true; \
    runtime_pkgs="libapr1 libaprutil1 libserf-1-1 libsqlite3-0 libssl3 libexpat1 zlib1g liblz4-1 libcrypt1 libuuid1 libgssapi-krb5-2 libkrb5-3 libk5crypto3 libkrb5support0 libcom-err2 libkeyutils1 libstdc++6 libgcc-s1"; \
    mkdir -p /out/opt/app/svn; \
    : > /tmp/runtime-files; \
    for pkg in $runtime_pkgs; do \
      dpkg-query -L "$pkg" | grep -E '^/(usr/)?(lib|lib64|libexec|bin|sbin)' >> /tmp/runtime-files; \
    done; \
    sort -u /tmp/runtime-files > /tmp/runtime-files.sorted; \
    rsync -a --ignore-missing-args --files-from=/tmp/runtime-files.sorted / /out; \
    for d in lib lib64 bin sbin; do \
      if [ -d "/out/$d" ]; then \
        mkdir -p "/out/usr/$d"; \
        cp -a "/out/$d/." "/out/usr/$d/"; \
        rm -rf "/out/$d"; \
      fi; \
    done; \
    rm -rf /tmp/subversion.tar.bz2 /tmp/subversion-1.14.5 /tmp/runtime-files /tmp/runtime-files.sorted

FROM debian:bookworm-slim AS runtime

ENV LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

COPY --from=builder /out/ /

COPY --from=ghcr.io/lvillis/tino:latest /sbin/tino /sbin/tino

WORKDIR /opt/app/svn

EXPOSE 3690

ENTRYPOINT ["/sbin/tino", "-s", "--"]
CMD ["/usr/bin/svnserve", "--daemon", "--foreground", "--root", "/opt/app/svn/data", "--log-file", "/dev/stdout", "--pid-file", "/run/svnserve.pid"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD sh -c '[ -e /proc/$(cat /run/svnserve.pid 2>/dev/null) ] || exit 1'
