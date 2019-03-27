#!/usr/bin/env bash
set -e
# why use python when you can use bash?
get_config_var() {
    python -c "from utils import Config; print(Config.$1)"
}

count_files() {
    # https://unix.stackexchange.com/questions/90106/whats-the-most-resource-efficient-way-to-count-how-many-files-are-in-a-director
    \ls -A "$1" | wc -l
}
export -f count_files

# make sure we have the necessary commands
command -v convert > /dev/null
command -v timeout > /dev/null
command -v parallel > /dev/null

# set up paths
export missing_thumb_path="static/missing.jpg"
export pdf_dir="data/pdf"
mkdir -p "$pdf_dir"
export thumbs_dir=$(get_config_var "thumbs_dir")
export tmp_dir=$(get_config_var "tmp_dir")
if [ -z "$thumbs_dir" ]; then
    echo "Failed to get thumbs_dir from python"
    exit 1
fi
if [ -z "$tmp_dir" ]; then
    echo "Failed to get tmp_dir from python"
    exit 1
fi

export total_files=$(count_files "$pdf_dir")
echo "Processing $total_files files from $pdf_dir..."

process_pdf() {
    p="$1"
    pdf_path="$pdf_dir/$p"
    thumb_path="$thumbs_dir/$p.jpg"
    tmp_thumb_path="$tmp_dir/${p%.pdf}"

    if [ -f "$thumb_path" ]; then
        # echo "Skipping $pdf_path, thumbnail already exists."
        return
    fi
    # if we use convert it does 2 gs calls and doesn't give us all of the flags
    # timeout 5 convert "$pdf_path[0-7]" -quality 0 -sample x156 "$tmp_thumb_path.png"
    # let's use gs directly
    timeout 15 gs -dLastPage=8 -dInterpolateControl=0 -dTextAlphaBits=4 -dGraphicsAlphaBits=2 -dNOTRANSPARENCY -dQUIET -dDEVICEWIDTHPOINTS=120 -dDEVICEHEIGHTPOINTS=156 -r72 -dFIXEDMEDIA -dFitPage -sDEVICE=png16m -o ${tmp_thumb_path}-%d.png "$pdf_path"
    # gs uses satanic indexing
    if [ ! -f "${tmp_thumb_path}-1.png" ]; then
       # conversion failed, use missing image
       cp "$missing_thumb_path" "$thumb_path" 
    else
        # conversion succeeded, make a montage
        montage -mode concatenate -quality 80 -tile x1 ${tmp_thumb_path}-*.png "$thumb_path"
        # echo "Made thumbnail for $pdf_path"
        # echo "$(count_files $thumbs_dir)/$total_files"
    fi
}

export -f process_pdf

# run the above function on all the pdfs
ls -1 "$pdf_dir" | grep pdf | parallel -j10 --bar process_pdf
