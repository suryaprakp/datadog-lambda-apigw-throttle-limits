# This file should be sourced into a shell environment
#
# This script will re-export (if set) AWS credential environment
# variables to terraform environment variables. E.g. it will map AWS
# AWS_ACCESS_KEY_ID to TF_VAR_aws_access_key_id.

# Use unique variable name as this script will be sourced.
SCRIPT_DIR_AWS_CONFIG_A554A97D8979="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -n "$AWS_ACCESS_KEY_ID" ]; then
    export TF_VAR_aws_access_key_id="$AWS_ACCESS_KEY_ID"
fi

if [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
    export TF_VAR_aws_secret_access_key="$AWS_SECRET_ACCESS_KEY"
fi

if [ -n "$DATADOG_API_KEY" ]; then
    export TF_VAR_dd_api_key="$DATADOG_API_KEY"
fi

if [ -n "$DATADOG_APP_KEY" ]; then
    export TF_VAR_dd_app_key="$DATADOG_APP_KEY"
fi
 
# Disable terraform requesting variable values via user input. All
# variables should be defined in .tfvars files, or TF_VAR env
# variables. See
# https://www.terraform.io/docs/configuration/environment-variables.html
export TF_INPUT=0

# Append local bin/ to PATH
if [ -d "${SCRIPT_DIR_AWS_CONFIG_A554A97D8979}/bin" ]; then
    export PATH="${SCRIPT_DIR_AWS_CONFIG_A554A97D8979}/bin:$PATH"
fi
