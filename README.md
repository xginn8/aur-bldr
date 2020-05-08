# aur-bldr [![Build Status](https://travis-ci.org/xginn8/aur-bldr.svg?branch=master)](https://travis-ci.org/xginn8/aur-bldr)
mkosi/Docker config for building clean Arch Linux containers for packaging

# To build:
## mkosi

```bash
# mkosi
# systemd-nspawn -bD image
```

## Docker

```bash
$ docker build .
$ docker run -e AUR_PACKAGE=name -it {{hash of build container}}
```

# To rebuild:

```bash
# mkosi --force
```

# To regenerate travis:

```bash
$ cat travis.base.yml travis.comaintainers.yml <(AUR_MAINTAINER=gin078 python aur-search.py) > .travis.yml
```

# To set up local repos:

```bash
$ local-setup.sh PLACE_TO_CLONE_TO
```

## TODO:

1. This does not work with packages that the `AUR_MAINTAINER` is a comaintainer.
+ Workaround: use the [travis.comaintainers.yml](./travis.comaintainers.yml) stub
1. Some packages (`xv`, `bitbake`) use FTP to get source code, which isn't well-supported by Travis.
1. `bitbake` also needs git setup
