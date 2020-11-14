#!/usr/bin/env bash
set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )/.."

echo "+++ Terraform lint"

cd "$ROOT/terraform"
terraform init -backend=false
terraform validate
