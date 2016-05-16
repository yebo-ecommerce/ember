#!/bin/bash

APP_NAME=yebo-ember
WORKDIR=/current
CURRENT=$(pwd)
BASE_DIR=$(dirname $0)/..
AFTER_BUILD=brb
VERSION=$(cat VERSION)
OPTION=$1
VOLUMES=(
  $CURRENT:$WORKDIR
  $CURRENT/../yebo-ember/packages/auth:/tmp/node_modules/yebo-ember-auth
  $CURRENT/../yebo-ember/packages/checkouts:/tmp/node_modules/yebo-ember-checkouts
  $CURRENT/../yebo-ember/packages/core:/tmp/node_modules/yebo-ember-core
  $CURRENT/../yebo-ember/packages/storefront:/tmp/node_modules/yebo-ember-storefront
  $CURRENT/../yebo_sdk:/tmp/bower_packages/yebo_sdk
)
UP="ember server --watcher polling"
