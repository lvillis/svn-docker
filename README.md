<div align="right">

<span style="color:#999;">🇺🇸 English</span> ·
<a href="README.zh-CN.md">🇨🇳 中文</a> &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Table of Contents ↗️

</div>

<h1 align="center"><code>svn-docker</code></h1>

<p align=center>🐳 Minimal, elegant Docker image for running Apache Subversion's svnserve.</p>

<div align="center">

[![Repo Size](https://img.shields.io/github/repo-size/lvillis/svn-docker?color=328657)](https://github.com/lvillis/svn-docker)&nbsp;
[![CI](https://github.com/lvillis/svn-docker/actions/workflows/docker-build.yaml/badge.svg)](https://github.com/lvillis/svn-docker/actions)&nbsp;
[![Say Thanks](https://img.shields.io/badge/Say%20Thanks-!-1EAEDB.svg)](mailto:lvillis@outlook.com?subject=Thanks%20for%20svn-docker!)

</div>

---

## ✨ Features

| Feature | Description |
|---|---|
| Multi-stage build | Builds Subversion from source (default 1.14.5) and copies only runtime files to a slim image to reduce final image size. |
| Small runtime image | Only runtime libraries are included to minimize image footprint. |
| Tiny init (`tino`) | Uses a minimal init (`/sbin/tino`) as PID 1 for proper signal handling and reaping. |
| Healthcheck | Verifies `svnserve` is running by checking the pid file `/run/svnserve.pid`. |
| Data persistence | Repositories are stored under `/opt/app/svn/data`; mount a host volume for persistence. |
| CI & multi-arch | GitHub Actions builds multi-architecture images and pushes to GHCR. Tags include `latest`, commit SHA and extracted Subversion version. |
| Configurable version | Change the Subversion version by editing the download URL in the `Dockerfile` (e.g. `subversion-1.14.5.tar.bz2`). |

## Usage

### Docker
```bash
docker run -d --name svn -p 3690:3690 \
	-v ./data:/opt/app/svn/data \
	--restart unless-stopped \
	ghcr.io/lvillis/svn:1.14.5
```


### Docker Compose

```bash
curl -fsSL -o docker-compose.yaml https://raw.githubusercontent.com/lvillis/svn-docker/main/deploy/compose/docker-compose.yaml
docker-compose up -d
```
