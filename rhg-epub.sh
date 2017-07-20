#!/bin/bash

set -e

RHG_URI='http://i.loveruby.net/ja/rhg/ar/RubyHackingGuide.tar.gz'
RHG_ROOT='RubyHackingGuide-20040721'
RHG_COVER_IMAGE_URL='https://images-na.ssl-images-amazon.com/images/I/51MQAYG70TL._SX367_BO1,204,203,200_.jpg'

script_root="${PWD}"
asset_dir="${script_root}/asset"
lib_dir="${script_root}/lib"
tarball="${RHG_URI##*\/}"
cover_image="${script_root}/cover.jpg"

download_rhg() {

    echo 'Download Ruby Hacking Guide'
    if [[ ! -f ${tarball} ]]; then
        curl -o "${tarball}" "${RHG_URI}"
    fi
    if [[ ! -f ${cover_image} ]]; then
        curl -o "${cover_image}" "${RHG_COVER_IMAGE_URL}"
    fi
}

download_assets() {
    mkdir -p "${asset_dir}"

    echo 'Download jquery'
    if [[ ! -f "${asset_dir}/jquery.min.js" ]]; then
        curl --output "${asset_dir}/jquery.min.js" "http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"
    fi

    echo 'Download highlight.js'
    if [[ ! -f "${asset_dir}/highlight.min.js" ]]; then
        curl --output "${asset_dir}/highlight.min.js" "http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/highlight.min.js"
    fi

    echo 'Download highlight.js theme'
    if [[ ! -f "${asset_dir}/tomorrow.min.css" ]]; then
        curl --output "${asset_dir}/tomorrow.min.css" "http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/styles/tomorrow.min.css"
    fi
}

install_npm_packages() {
    echo 'Install npm packages'
    npm update > /dev/null 2>&1
}

unpack_rhg() {
    echo 'Extract Ruby Hacking Guide'

    if [[ "${#}" -gt 0 ]]; then
        # Debug
        TMP_DIR="${script_root}/tmp"
        mkdir -p "${TMP_DIR}"

    else
        TMP_DIR=$(mktemp -d "/tmp/rhg-epub.XXXXXX")
        trap "rm -rf ${TMP_DIR}" exit
    fi
    tar zxf "${tarball}" -C "${TMP_DIR}"
}

compile_html() {
    echo 'Compile all HTML'

    cd "${TMP_DIR}/${RHG_ROOT}"
    "${lib_dir}/rhg-html.rb" index.html > RubyHackingGuide.html
    cd - > /dev/null
}

adjust_stylesheet() {
    echo 'Adjust stylesheet'

    cd "${TMP_DIR}/${RHG_ROOT}"
    "${lib_dir}/rhg-css.rb" rhg.css > rhg-epub.css
    cat "${asset_dir}/tomorrow.min.css" >> rhg-epub.css
    cd - > /dev/null
}

convert_to_epub() {
    echo 'Convert to EPUB'

    TMP_EPUB_FILE="$(mktemp "${TMP_DIR}/rhg.epub-XXXXXX")"

    cd "${TMP_DIR}/${RHG_ROOT}"
    pandoc -f html -t epub3 --epub-cover-image "${cover_image}" --epub-stylesheet 'rhg-epub.css' -o "${TMP_EPUB_FILE}" 'RubyHackingGuide.html'
    cd - > /dev/null
}

expand_epub() {
    echo 'Expand EPUB'

    TMP_EPUB_DIR=$(mktemp -d "${TMP_DIR}/epub.XXXXXX")
    cd "${TMP_EPUB_DIR}"
    unzip -o "${TMP_EPUB_FILE}" > /dev/null
    cd - > /dev/null
}

highlight_code() {
    echo 'Highlight code'

    cd "${TMP_EPUB_DIR}"
    for xhtml in ch*.xhtml; do
        mv "${xhtml}" "${xhtml}.orig"
        "${script_root}/node_modules/coffee-script/bin/coffee" "${lib_dir}/rhg-highlight.coffee" "${asset_dir}" "${xhtml}.orig" > "${xhtml}"
        rm "${xhtml}.orig"
    done
    cd - > /dev/null
}

convert_footnote() {
    echo 'Convert footnote'

    cd "${TMP_EPUB_DIR}"
    for xhtml in ch*.xhtml; do
        mv "${xhtml}" "${xhtml}.orig"
        "${lib_dir}/rhg-footnote.rb" "${xhtml}.orig" > "${xhtml}"
        rm "${xhtml}.orig"
    done
    cd - > /dev/null
}

compress_epub() {
    echo 'Compress EPUB'

    cd "${TMP_EPUB_DIR}"
    zip -r "${script_root}/RubyHackingGuide.epub" . > /dev/null
    cd - > /dev/null
}

download_rhg "${@}"
download_assets "${@}"
install_npm_packages "${@}"
unpack_rhg "${@}"
compile_html "${@}"
adjust_stylesheet "${@}"
convert_to_epub "${@}"
expand_epub "${@}"
highlight_code "${@}"
convert_footnote "${@}"
compress_epub "${@}"

