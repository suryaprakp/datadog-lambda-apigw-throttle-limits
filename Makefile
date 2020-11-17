.PHONY: clean help
.DEFAULT: help
help:
	@echo "make lambda-function-package"
	@echo "       prepare lambda function package from source"
	@echo "make lambda-layer-package"
	@echo "       prepare lambda layer package from dependencies in requirements.txt"
	@echo "make clean"
	@echo "       clean project"

include Makefile-terraform

GIT_REV := $(shell git rev-parse --short HEAD)

ifneq ($(BUILD_NUMBER),)
BUILD_NUMBER_TAG=-$(BUILD_NUMBER)
else
BUILD_NUMBER_TAG=
endif

SOURCE_FUNC := src/datadog_apigw_metrics.py
SOURCE_LIB := lambda_layer/prepare_package.sh
LAMBDA_LAYER_DIR := python
DATADOG_PACKAGE := datadog_library_v_$(DATADOG_CURRENT_LIB_VERSION)/datadog_library.zip
LAMBDA_FUNCTION_PACKAGE := packages/datadog_apigw_metrics_lambdafunction-$(GIT_REV)$(BUILD_NUMBER_TAG).zip
LAMBDA_LAYER_PACKAGE := packages/datadog_lambda_layer_py3.7-$(GIT_REV)$(BUILD_NUMBER_TAG).zip

clobber:

clean:
	$(RM) -r packages/ lamba_layer/python/

packages:
	mkdir -p $@

$(LAMBDA_FUNCTION_PACKAGE): $(SOURCE_FUNC) | packages
	@echo ___ Preparing Lambda package by zip ___
	cd src && zip $(abspath $(LAMBDA_FUNCTION_PACKAGE)) $(notdir $(SOURCE_FUNC))
	@echo ___ Done ___

$(LAMBDA_LAYER_PACKAGE): $(SOURCE_LIB) | packages
	@echo ___ Preparing Lambda layer package by zip ___
	@echo ___ Running docker container lambci/lambda:build-python3.7 ___
	cd lambda_layer && ./prepare_package.sh 
	mv lambda_layer/dd_lambda_layer.zip $(LAMBDA_LAYER_PACKAGE)
	@echo ___ Done ___

lambda-function-package: $(LAMBDA_FUNCTION_PACKAGE)

lambda-layer-package: $(LAMBDA_LAYER_PACKAGE)

env: bin/terraform