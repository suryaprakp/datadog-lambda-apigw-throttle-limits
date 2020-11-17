#!/bin/bash

export LIB_DIR="python"

rm -rf ${LIB_DIR} && mkdir -p ${LIB_DIR}

docker run --rm -v $(pwd):/foo -w /foo lambci/lambda:build-python3.7 \
    pip install -r requirements.txt -t ${LIB_DIR} 

zip -r dd_lambda_layer .

rm -rf ${LIB_DIR}