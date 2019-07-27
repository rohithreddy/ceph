#!/usr/bin/env bash
set -ex

# run s3-tests from current directory. assume working
# ceph environment (radosgw-admin in path) and rgw on localhost:8000
# (the vstart default).

branch=$1
[ -z "$1" ] && branch=master
port=$2
[ -z "$2" ] && port=8000   # this is vstart's default

##

if [ -e CMakeCache.txt ]; then
    BIN_PATH=$PWD/bin
elif [ -e $root_path/../build/CMakeCache.txt ]; then
    cd $root_path/../build
    BIN_PATH=$PWD/bin
fi
PATH=$PATH:$BIN_PATH

dir=tmp.s3-tests.$$

# clone and bootstrap
mkdir $dir
cd $dir
git clone https://github.com/ceph/s3-tests
cd s3-tests
git checkout ceph-$branch
VIRTUALENV_PYTHON=/usr/bin/python2 ./bootstrap

S3TEST_CONF=s3tests.conf.SAMPLE virtualenv/bin/nosetests -a '!fails_on_rgw,!lifecycle_expiration,!fails_strict_rfc2616' -v

cd ../..
rm -rf $dir

echo OK.

