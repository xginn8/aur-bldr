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
`$ AUR_MAINTAINER=gin078 python aur-search.py > .travis.yml`
