#!/bin/bash

set -e

RHG_URI='http://i.loveruby.net/ja/rhg/ar/RubyHackingGuide.tar.gz'
RHG_ROOT='RubyHackingGuide-20040721'

tarball="${RHG_URI##*\/}"
script_root="${PWD}"
asset_dir="${script_root}/asset"
lib_dir="${script_root}/lib"


if [[ ! -f ${tarball} ]]; then
  echo 'Download Ruby Hacking Guide'
  curl -o "${tarball}" "${RHG_URI}"
fi

mkdir -p "${asset_dir}"

if [[ ! -f "${asset_dir}/jquery.min.js" ]]; then
  echo 'Download jquery'
  curl --output "${asset_dir}/jquery.min.js" "http://cdnjs.cloudflare.com/ajax/libs/jquery/2.1.3/jquery.min.js"
fi

if [[ ! -f "${asset_dir}/highlight.min.js" ]]; then
  echo 'Download highlight.js'
  curl --output "${asset_dir}/highlight.min.js" "http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/highlight.min.js"
fi

if [[ ! -f "${asset_dir}/tomorrow.min.css" ]]; then
  echo 'Download highlight.js theme'
  curl --output "${asset_dir}/tomorrow.min.css" "http://cdnjs.cloudflare.com/ajax/libs/highlight.js/9.1.0/styles/tomorrow.min.css"
fi

echo 'npm install'
npm install > /dev/null 2>&1

echo 'Extract Ruby Hacking Guide'

tmpdir=$(mktemp -d "/tmp/rhg-epub.XXXXXX")
trap "rm -rf ${tmpdir}" exit

# Debug
#tmpdir="${script_root}/tmp"
#mkdir -p "${tmpdir}"

tar zxf "${tarball}" -C "${tmpdir}"


cd "${tmpdir}/${RHG_ROOT}"


echo 'Compile all HTML'

"${lib_dir}/rhg-html.rb" index.html > RubyHackingGuide.html


echo 'Adjust stylesheet'

"${lib_dir}/rhg-css.rb" rhg.css > rhg-epub.css
cat "${asset_dir}/tomorrow.min.css" >> rhg-epub.css


echo 'Convert to EPUB'

pandoc -f html -t epub3 --epub-stylesheet rhg-epub.css -o '../tmp.epub' RubyHackingGuide.html


echo 'Expand EPUB'

mkdir -p "${tmpdir}/epub"
cd "${tmpdir}/epub"
unzip -o '../tmp.epub' > /dev/null


echo 'Highlight code'

for xhtml in ch*.xhtml; do
  mv "${xhtml}" "${xhtml}.orig"
  "${script_root}/node_modules/coffee-script/bin/coffee" "${lib_dir}/rhg-highlight.coffee" "${asset_dir}" "${xhtml}.orig" > "${xhtml}"
  rm "${xhtml}.orig"
done

echo 'Convert footnote'

for xhtml in ch*.xhtml; do
  mv "${xhtml}" "${xhtml}.orig"
  "${lib_dir}/rhg-footnote.rb" "${xhtml}.orig" > "${xhtml}"
  rm "${xhtml}.orig"
done


echo 'Compress EPUB'

zip -r "${script_root}/RubyHackingGuide.epub" . > /dev/null

