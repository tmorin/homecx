# homecx

> A lightweight and all-in-one solution to get easily a ready to use Continuous Integration environment.

The solution is composed of the following services:

- [laminar] : a lightweight and modular Continuous Integration service
- [webhook] : a lightweight incoming webhook server to run shell commands

The Docker image is based on Debian Buster and is shipped with:

- bash
- openssh
- git
- docker
- supervisor

An additional utility, `homecx`, is also added to the image.
The utility helps to initialize the configuration of [laminar] and [webhook] from a GIT repository.
Please refer to [homecx-dummy-config] to get more information about _configuration over GIT_ repository.

Both services [laminar] and [webhook] can be configured manually using volumes, storage bindings ....
The [laminar] home is `/data` and the location of the hooks file of [webhook] is `/data/cfg/webhook.json`.

On the other hand, the folder `/data` can be provisioned from a GIT repository using the environment variable: `HOMECX_REPOSITORY`.

About SSH, the home directory is `/data/.ssh`.
A config file is by default shipped to deactivate the host keys verification ([rootfs/data/.ssh/config]).

About networking, the [laminar] dashboard is available from the TCP port `9000`.
The [webhook] endpoint is available from the TCP port `9001`.

```bash
docker run \
    -v $(pwd)/.ssh:/data/.ssh:ro \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -p 9000:9000 \
    -p 9001:9001 \
    --env HOMECX_REPOSITORY=<a GIT repository> \
    thibaultmorin/homecx
```

[homecx-dummy-config]: https://github.com/tmorin/homecx-dummy-config
[hub.docker.com]: https://hub.docker.com/repository/docker/thibaultmorin/homecx
[laminar]: https://laminar.ohwg.net
[webhook]: https://github.com/adnanh/webhook
[rootfs/data/.ssh/config]: rootfs/data/.ssh/config
