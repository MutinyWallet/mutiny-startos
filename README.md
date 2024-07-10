<p align="center">
  <img src="icon.png" alt="Project Logo" width="21%">
</p>

# Mutiny Wallet for StartOS 

[Mutiny Wallet](https://github.com/MutinyWallet/mutiny-web) is a lightning wallet that runs in the web. Unlike other lightning services on Start9, it is not a server that you run on StartOS. Instead, it is a web app that you can access from any device on your local network. This means that you can access your wallet from your phone, tablet, or laptop.

This repository creates the `s9pk` package that is installed to run `Mutiny Wallet` on [StartOS](https://github.com/Start9Labs/start-os/). Learn more about service packaging in the [Developer Docs](https://start9.com/latest/developer-docs/).

## Dependencies

Install the system dependencies below to build this project by following the instructions in the provided links. You can also find detailed steps to setup your environment in the service packaging [documentation](https://github.com/Start9Labs/service-pipeline#development-environment).

- [docker](https://docs.docker.com/get-docker)
- [docker-buildx](https://docs.docker.com/buildx/working-with-buildx/)
- [yq](https://mikefarah.gitbook.io/yq)
- [deno](https://deno.land/)
- [make](https://www.gnu.org/software/make/)
- [start-sdk](https://github.com/Start9Labs/start-os/tree/sdk/backend)

## Build environment
Prepare your StartOS build environment. In this example we are using Ubuntu 20.04.
1. Install docker
```
curl -fsSL https://get.docker.com | bash
sudo usermod -aG docker "$USER"
exec sudo su -l $USER
```
2. Set buildx as the default builder
```
docker buildx install
docker buildx create --use
```
3. Enable cross-arch emulated builds in docker
```
docker run --privileged --rm linuxkit/binfmt:v0.8
```
4. Install yq
```
sudo snap install yq
```
5. Install deno
```
sudo snap install deno
```
6. Install essentials build packages
```
sudo apt-get install -y build-essential openssl libssl-dev libc6-dev clang libclang-dev ca-certificates
```
7. Install Rust
```
curl https://sh.rustup.rs -sSf | sh
# Choose nr 1 (default install)
source $HOME/.cargo/env
```
8. Build and install start-sdk
```
cd ~/ && git clone --recursive https://github.com/Start9Labs/start-os.git --branch sdk
cd start-os/backend/
./install-sdk.sh
start-sdk init
```
Now you are ready to build the `mutiny` package!

## Cloning

Clone the project locally:

```
git clone https://github.com/MutinyWallet/mutiny-startos.git
cd mutiny-startos
git submodule update --init --recursive
```

## Building

To build the `mutiny` package for all platforms using start-sdk, run the following command:

```
make
```

To build the `mutiny` package for a single platform using start-sdk, run:

```
# for amd64
make x86
```
or
```
# for arm64
make arm
```

## Installing (on StartOS)

Run the following commands to determine successful install:
> :information_source: Change server-name.local to your Start9 server address

```
start-cli auth login
# Enter your StartOS password
start-cli --host https://server-name.local package install mutiny.s9pk
```

If you already have your `start-cli` config file setup with a default `host`, you can install simply by running:

```
make install
```

> **Tip:** You can also install the mutiny.s9pk using **Sideload Service** under the **System > Manage** section.

### Verify Install

Go to your StartOS Services page, select **Mutiny**, configure and start the service. Then, verify its interfaces are accessible.

**Done!** 
