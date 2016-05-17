#!/bin/bash

# Get configs and functions
source scripts/config.sh

# ======== Functions
run_dev () {
  docker run --rm -ti \
    -e EMBER_ENV=development \
    -w $WORKDIR \
    $(printf '\t-v %s\n' "${VOLUMES[@]}") \
    --volumes-from npmcache \
    $APP_NAME 'scripts/wrapper.sh' $@
}

run () {
  docker run --rm -ti \
    -e EMBER_ENV=development \
    -w $WORKDIR \
    -v $CURRENT:$WORKDIR \
    -p 4200:4200 -p 49152:49152 \
    $APP_NAME 'scripts/wrapper.sh' $@
}

run_prod () {
  docker run -ti --rm \
    -p 80:80 -p 433:433 \
    --volumes-from npmcache \
    $APP_NAME
}

manage_images () {
  echo "------> Remove old image docker: rmi gcr.io/yebo-project/$APP_NAME"
  docker rmi gcr.io/yebo-project/$APP_NAME

  echo "------> Remove latest image"
  docker rmi gcr.io/yebo-project/${APP_NAME}:v${VERSION}

  if [ $1 == 'create' ]; then
    echo "------> Create latest image: docker tag $APP_NAME gcr.io/yebo-project/$APP_NAME"
    docker tag $APP_NAME gcr.io/yebo-project/$APP_NAME

    echo "------> Taging latest image: docker rmi gcr.io/yebo-project/$APP_NAME:v$VERSION"
    docker tag ${APP_NAME} gcr.io/yebo-project/${APP_NAME}:v${VERSION}
  fi

  echo "------> List images: docker images | grep $APP_NAME"
  docker images | grep $APP_NAME
}

before_script() {
  mkdir -p /npmcache
  cd /npmcache

  cp /current/package.json /npmcache/package.json
  npm install
  rm /npmcache/package.json
  ln -s /npmcache/node_modules /current/node_modules

  # cp /current/bower.json /npmcache/bower.json
  # bower install --allow-root
  # rm /npmcache/bower.json
  # ln -s /npmcache/bower_components /current/bower_components

  cd $WORKDIR
}

after_script () {
  echo '-----> Remove copied folders'
  rm /current/node_modules
  # rm /current/bower_components

  echo '-----> Remove generated files'
  rm -rf /current/tmp
  rm -rf /current/dist
}

# =========== Options
if [ $OPTION == 'cache' ]; then
  echo '-----> Cache'
  docker create -v /npmcache --name npmcache busybox
  exit 1
fi

if [ $OPTION == 'build' ]; then
  echo '-----> Build'
  docker build -t $APP_NAME $BASE_DIR && $AFTER_BUILD
  exit 1
fi

if [ $OPTION == 'new-tag' ]; then
  manage_images 'create'
  exit 1
fi

if [ $OPTION == 'remove-latest' ]; then
  manage_images
  exit 1
fi

if [ $OPTION == 'remember' ]; then
  echo 'scripts/run.sh build'
  echo "docker tag $APP_NAME gcr.io/yebo-project/$APP_NAME:v$VERSION"
  echo "docker tag $APP_NAME gcr.io/yebo-project/$APP_NAME"
  echo "docker run --rm -ti -p 80:80 -p 443:443 gcr.io/yebo-project/$APP_NAME:v$VERSION"
  echo "docker images | grep $APP_NAME"
  echo "dg gcloud docker push gcr.io/yebo-project/$APP_NAME:v$VERSION"
  echo "dg kubectl rolling-update $APP_NAME --image=gcr.io/yebo-project/$APP_NAME:v$VERSION"
  exit 1
fi

if [ $OPTION == 'push-latest' ]; then
  docker run --rm -ti \
    -w /current \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v $(pwd):/current \
    --volumes-from gcloud-config gabrielcorado/gcloud \
    gcloud docker push gcr.io/yebo-project/${APP_NAME}
fi

if [ $OPTION == 'up' ]; then
  echo '-----> Up'
  run $UP
  exit 1
fi

if [ $OPTION == 'dev' ]; then
  echo '-----> Dev UP'
  run_dev $UP
  exit 1
fi

if [ $OPTION == 'prod' ]; then
  echo '-----> Prod'
  run_prod
  exit 1
fi

echo "-----> Running $@"
run_dev $@

