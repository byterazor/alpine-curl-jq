# alpine-curl-jq

## Description

This is a minimal container image built on top of [Alpine](https://alpinelinux.org/),
providing `bash`, `curl`, `jq` and `tini`.

It is intended as a small base image for CI steps and containerized scripts that need to
make HTTP requests (`curl`), process JSON (`jq`), and run `bash` commands under a proper
init process (`tini`) for signal handling and child process reaping.

The image is based on `alpine:latest` and simply installs `tini`, `bash`, `curl` and `jq`
via `apk`, so all tools are available on the `PATH`.

### Requirements

None — this is a base image, no configuration is required.

## Supported Architectures

- amd64
- arm64

## Updates

I am trying to update the image weekly as long as my private Kubernetes cluster is available.
So I do not promise anything and do **not** rely your business on this image.

## Source Repository

* https://gitea.federationhq.de/Container/alpine-curl-jq

## Project Homepage

* https://rm.geraffel.org/alpine-curl-jq

## Prebuild Images

* `docker.io/byterazor/alpine-curl-jq:latest` — https://hub.docker.com/repository/docker/byterazor/alpine-curl-jq/general

## Authors

* **Dominik Meyer** - *Initial work*

## License

This project is licensed under the MPLv2 License - see the [LICENSE](LICENSE) file for details.
