#!/usr/bin/env bash
set -e 
command -v aria2c > /dev/null
list_new_papers() {
    python3 list_new_papers.py
}
get_config_var() {
    python -c "from utils import Config; print(Config.$1)"
}


tmp_list="/tmp/papers_to_download.txt"
download_dir=$(get_config_var pdf_dir)
list_new_papers > "$tmp_list"
aria2c -i "$tmp_list" -d "$download_dir" --auto-file-renaming false
