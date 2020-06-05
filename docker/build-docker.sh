#!/bin/bash
BUILD_DIR=$(dirname $(readlink -f $0))

TF_INSTALL="off"

function usage_exit {
  cat <<_EOS_ 1>&2
  Usage: $PROG_NAME [OPTIONS...]
  OPTIONS:
    -h, --help                  このヘルプを表示
    --tensorflow VERSION        TensorFlowのバージョンを指定（既定値：off）
_EOS_
    exit 1
}

while (( $# > 0 )); do
    if [[ $1 == "--help" ]] || [[ $1 == "-h" ]]; then
        usage_exit
    elif [[ $1 == "--tensorflow" ]]; then
        if [[ $2 == "off" ]]; then
            TF_INSTALL="off"
        else
            TF_INSTALL=$2
        fi
        shift 2
    else
        echo "無効なパラメータ: $1"
        usage_exit
    fi
done

docker build \
    -t ros2:dashing \
    --build-arg BASE_IMAGE="nvidia/opengl:1.0-glvnd-runtime-ubuntu18.04" \
    ${BUILD_DIR}/src

if [[ $? != 0 ]]; then
    echo "エラーにより中断しました．"
    exit 1
fi

if [[ ${TF_INSTALL} != "off" ]]; then
    docker build \
        -f ${BUILD_DIR}/src/Dockerfile.tensorflow \
        -t jetson/ros2:${MAJOR_VERSION,,}.${MINOR_VERSION}-dashing-tf${TF_VERSION[${TF_INSTALL}]} \
        --build-arg L4T_VERSION="${MAJOR_VERSION,,}.${MINOR_VERSION}" \
        --build-arg TENSORFLOW_WHL=${TF_FILE[${TF_INSTALL}]} \
        ${BUILD_DIR}/src
    
    if [[ $? != 0 ]]; then
        echo "エラーにより中断しました．"
        exit 1
    fi
fi