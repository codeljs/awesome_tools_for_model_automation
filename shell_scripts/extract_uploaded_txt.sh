#!/usr/bin/env bash
set -euo pipefail

# Required environment variables:
#   source_path: directory containing uploaded file
#   target_txt: uploaded .txt filename (zip payload)
#   sub_folder: extracted first-level folder to export
#   output_path: directory to write exported files

require_env() {
  local name="$1"
  if [[ -z "${!name:-}" ]]; then
    echo "[ERROR] Missing required environment variable: ${name}" >&2
    exit 1
  fi
}

require_cmd() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    echo "[ERROR] Missing required command: ${name}" >&2
    exit 1
  fi
}

require_env "source_path"
require_env "target_txt"
require_env "sub_folder"
require_env "output_path"

require_cmd "unzip"

source_path="${source_path%/}"
input_txt="${source_path}/${target_txt}"
zip_name="${target_txt%.*}.zip"
zip_file="${source_path}/${zip_name}"
target_subdir="${source_path}/${sub_folder}"

# First run path: .txt exists -> rename + unzip in place.
if [[ -f "$input_txt" ]]; then
  if [[ "$input_txt" != "$zip_file" ]]; then
    mv "$input_txt" "$zip_file"
  fi
  echo "[INFO] Renamed upload to: $zip_file"
  unzip -oq "$zip_file" -d "$source_path"
# Subsequent run path: .txt may no longer exist.
elif [[ -d "$target_subdir" ]]; then
  echo "[INFO] target_txt not found, but extracted sub-folder already exists: $target_subdir"
# Recovery path: .zip exists but may not yet be extracted.
elif [[ -f "$zip_file" ]]; then
  echo "[INFO] target_txt not found, using existing zip file: $zip_file"
  unzip -oq "$zip_file" -d "$source_path"
else
  echo "[ERROR] Neither target txt nor zip found, and sub-folder does not exist." >&2
  echo "[ERROR] Checked: $input_txt, $zip_file, $target_subdir" >&2
  exit 1
fi

if [[ ! -d "$target_subdir" ]]; then
  echo "[ERROR] Sub-folder not found after extraction: $target_subdir" >&2
  exit 1
fi

mkdir -p "$output_path"

# Export all files/content from selected sub-folder to output_path.
cp -a "$target_subdir"/. "$output_path"/

echo "[INFO] Exported files from $target_subdir to $output_path"
