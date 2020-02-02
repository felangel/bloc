#!/bin/bash

set -ex

source scripts/retry.sh

cd $1

pub run build_runner build

cd -
