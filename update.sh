#!/usr/bin/env bash
set -e
cd /root/arxiv-sanity-preserver
python3 fetch_papers.py
#python3 download_pdfs.py
./download_pdfs.sh
python3 parse_pdf_to_text.py
# python3 thumb_pdf.py
./thumb_pdf.sh
python3 analyze.py
python3 buildsvm.py
python3 make_cache.py
echo "$(date) - $(whoami)" >> /root/arxiv-sanity-preserver/update_log.txt
