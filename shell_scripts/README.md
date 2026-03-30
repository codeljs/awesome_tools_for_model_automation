# shell_scripts

This directory stores utility shell scripts for machine learning workflows.

## `extract_uploaded_txt.sh`

Handles portal uploads where a `.zip` package must be uploaded as a `.txt` file.

### Script purpose (important)

This script is designed for **one sub-folder export per run**:

- On each execution, it independently exports the content of the specified `sub_folder`.
- Its goal is **not** to merge or manage historical outputs across multiple runs.
- Treat each run as a standalone extraction/export operation for one target sub-folder.

### Workflow

1. Read `source_path` and `target_txt`, then rename `<target_txt>` from `.txt` to `.zip`.
2. Unzip the archive **in place** under `source_path`.
3. Read `sub_folder` and select that extracted first-level folder.
4. Export all files from the selected sub-folder into `output_path`.

### Re-run compatibility

If the script is executed a second time, `target_txt` may no longer exist (already renamed/unzipped). In this case:

- If `source_path/sub_folder` already exists, the script continues and exports files directly.
- If `.zip` exists, the script will unzip again and continue.

### Recommendation before each run

Before executing the script, it is strongly recommended to check whether `output_path` still contains files from a previous run.
Leftover files in `output_path` can cause confusion when validating current results.

### Required environment variables

- `source_path`: Directory containing the uploaded txt file.
- `target_txt`: Uploaded `.txt` file name (zip payload).
- `sub_folder`: Extracted first-level sub-folder name to export.
- `output_path`: Directory where selected files will be exported.

### Example

```bash
export source_path="/data/uploads"
export target_txt="model_package.txt"
export sub_folder="weights"
export output_path="/data/exported"

bash shell_scripts/extract_uploaded_txt.sh
```
