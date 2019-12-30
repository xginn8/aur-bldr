#!/usr/bin/env python3

import os
import aur

print("language: minimal")
print("env:")
for i in aur.msearch(os.getenv('AUR_MAINTAINER')):
    print("- AUR_PACKAGE={}".format(i.name))
