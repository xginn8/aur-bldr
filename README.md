# aur-bldr
mkosi/Docker config for building clean Arch Linux containers for packaging

# To build:
## mkosi

1. `# mkosi`
1. `# systemd-nspawn -bD image`

## Docker

1. `docker build .`
1. `docker run -e AUR_PACKAGE=name -it {{hash of build container}}`

# To rebuild:
`# mkosi --force`

# To regenerate travis:
`$ cat travis.base.yml <(AUR_MAINTAINER=gin078 python aur-search.py) > .travis.yml`

## TODO:

1. This does not work with packages that the `AUR_MAINTAINER` is a comaintainer.
+ Workaround: use the travis.comaintainers.yml stub
1. Create build container to use as a base (weekly cron job via Travis?)
1. Some packages (`xv`, `bitbake`) use FTP to get source code, which isn't well-supported by Travis.
