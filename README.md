## Build

```bash
docker buildx build --platform linux/arm64 -t debian-dev --load .
```

默认构建 Neovim release tag；如需 nightly/master，可追加 `--build-arg NVIM_VERSION=master`。

## Run

```bash
docker run -it --rm --platform linux/arm64 debian-dev
```

## Run with SSH

> Password auth:

```bash
docker run -d --name debian-dev -p 2222:22 -e SSH_ROOT_PASSWORD='passwd' debian-dev
ssh root@127.0.0.1 -p 2222
```

> Key auth:

```bash
docker run -d --name debian-dev -p 2222:22 -e SSH_AUTHORIZED_KEYS="$(cat ~/.ssh/id_ed25519.pub)" debian-dev
ssh root@127.0.0.1 -p 2222
```
