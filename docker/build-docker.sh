#!/bin/bash
BUILD_DIR=$(dirname $(readlink -f $0))

BASE_IMAGE="nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04"

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                  このヘルプを表示
    -b, --base DOCKER_IMAGE     ベースとするイメージを指定する
                                (既定値：nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04)
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--base" ]] || [[ $1 == "-b" ]]; then
        BASE_IMAGE=$2
        shift 2
    else
        echo "無効なパラメータ: $1"
        usage_exit
    fi
done

docker build \
    -t ros2:dashing \
    --build-arg BASE_IMAGE=${BASE_IMAGE} \
    ${BUILD_DIR}/src

if [[ $? != 0 ]]; then
    echo "エラーにより中断しました．"
    exit 1
fi
