#!/usr/bin/env python3

import os
import aur

for i in aur.msearch(os.getenv('AUR_MAINTAINER')):
    if (i.name == i.package_base):
        print("        - AUR_PACKAGE={}".format(i.name))
