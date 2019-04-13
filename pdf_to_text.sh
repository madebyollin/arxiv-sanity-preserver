#!/usr/bin/env bash

# wrapper around pdftotext
pdf_path="$1"
txt_path="$2"
is_xml=$(file "$pdf_path" | grep -io xml)
if [ -z "$is_xml" ]; then
    pdftotext "$pdf_path" "$txt_path"
    # otherwise, ignore it, it's a paper without a pdf
fi
