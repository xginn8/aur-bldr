# aur-bldr
mkosi/Docker config for building clean Arch Linux containers for packaging

# To build:
## mkosi

1. ```bash
# mkosi
```

1. ```bash
# systemd-nspawn -bD image
```

## Docker

1. ```bash
$ docker build .
```

1. ```bash
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
1. Create build container to use as a base (monthly cron job via Travis?)
1. Some packages (`xv`, `bitbake`) use FTP to get source code, which isn't well-supported by Travis.
1. Confirm that each PKGBUILD has the appropriate hooks (like `_github_url`).
1. `bitbake` also needs git setup (releases aren't ordered properly)
