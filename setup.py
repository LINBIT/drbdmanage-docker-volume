#!/usr/bin/env python2

import os
import sys

from distutils.core import setup, Command

DP_VERSION = '0.6'

def get_version():
    return DP_VERSION

class CheckUpToDate(Command):
    description = "Check if version strings are up to date"
    user_options = []

    def initialize_options(self):
        self.cwd = None

    def finalize_options(self):
        self.cwd = os.getcwd()

    def run(self):
        version = get_version()
        try:
            with open("debian/changelog") as f:
                firstline = f.readline()
                if version not in firstline:
                    # returning false is not promoted
                    sys.exit(1)
        except IOError:
            # probably a release tarball without the debian directory but with Makefile
            return True

# used to overwrite version tag by internal build tools
# keep it, even if you don't understand it.
def get_setup_version():
    return get_version()

setup(
    name='drbdmanage-docker-volume',
    version=get_setup_version(),
    description='DRBDmanage Docker Volume Plugin',
    long_description="Drbdmanage is a daemon and a command line utility that manages DRBD\n" +
    "replicated LVM volumes across a group of machines.\n" +
    "It maintains DRBD configuration an the participating machines. It\n" +
    "creates/deletes the backing LVM volumes. It automatically places\n" +
    "the backing LVM volumes among the participating machines.\n" +
    "This provides a docker volume plugin for Drbdmanage",
    author='Roland Kammerer <roland.kammerer@linbit.com>',
    author_email='roland.kammerer@linbit.com',
    maintainer='LINBIT HA Solutions GmbH',
    maintainer_email='drbd-dev@lists.linbit.com',
    url='https://www.drbd.org',
    license='GPLv3',
    #scripts=['drbdmanage-docker-volume'],
    data_files=[
        ('/lib/systemd/system/', ['systemd/docker-drbdmanage-plugin.service',
                                  'systemd/docker-drbdmanage-plugin.socket']),
        ('/usr/libexec/docker/', ['drbdmanage-docker-volume']),
        ('/usr/share/man/man8/', ['drbdmanage-docker-volume.8.gz']),
    ],
    cmdclass={
        'versionup2date': CheckUpToDate
    }
)
