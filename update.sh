#!/usr/bin/env bash
set -e
cd /root/arxiv-sanity-preserver
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
python3 fetch_papers.py
#python3 download_pdfs.py
./download_pdfs.sh
python3 parse_pdf_to_text.py
# python3 thumb_pdf.py
./thumb_pdf.sh
python3 analyze.py
python3 buildsvm.py
python3 make_cache.py
# lol why doesn't it detect the python writes sigh
touch /root/arxiv-sanity-preserver/db2.p
echo "$(date) - $(whoami)" >> /root/arxiv-sanity-preserver/update_log.txt
