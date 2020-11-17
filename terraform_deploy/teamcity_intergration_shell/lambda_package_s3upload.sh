set -e

function _require_command() {
    [ $# -eq 1 ] || exit 1
    set +e
    command -v "$1" >/dev/null 2>&1
    local status=$?
    set -e
    if [ $status -eq 0 ]; then
        return 0
    else
        >&2 echo "required command not found: $1"
        return 1
    fi
}

function _s3_object_write() {
    [ $# -eq 4 ] || exit 1
    local bucket_name="$1"
    local bucket_region="$2"
    local object_key="$3"
    local src="$4"

    if [ ! -f "$src" ]; then
        >&2 echo "object source file not found: $src"
        return 1
    fi

    aws s3api --output text --region "$bucket_region" \
        put-object \
        --bucket "$bucket_name" --key "$object_key" \
        --body "$src"
}

_require_command aws

cd packages
package_name=$(ls datadog_apigw_metrics*.zip)
echo "Found package : $package_name"
_s3_object_write "aws-lambda-packages-eun1" <region-name> "datadog-lambda-apigw-metrics/$package_name" "$package_name"