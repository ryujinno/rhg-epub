#!/bin/bash

set -e

RHG_URI='http://i.loveruby.net/ja/rhg/ar/RubyHackingGuide.tar.gz'
RHG_ROOT='RubyHackingGuide-20040721'

tarball="${RHG_URI##*\/}"
script_root="${PWD}"


if [[ ! -f ${tarball} ]]; then
  echo 'Download Ruby Hacking Guide'
  curl -o "${tarball}" "${RHG_URI}"
fi

echo 'Extract Ruby Hacking Guide'

tmpdir=$(mktemp -d "/tmp/rhg-epub.xxxxxx")
trap "rm -rf ${tmpdir}" exit

# Debug
#tmpdir='.'

tar zxf "${tarball}" -C "${tmpdir}"


cd "${tmpdir}/${RHG_ROOT}"


echo 'Compile all HTML'

"${script_root}/rhg-html.rb" index.html > RubyHackingGuide.html


echo 'Adjust stylesheet'

"${script_root}/rhg-css.rb" rhg.css > rhg_epub.css


echo 'Convert to EPUB'

pandoc -f html -t epub3 --epub-stylesheet rhg_epub.css -o "${script_root}/RubyHackingGuide.epub" RubyHackingGuide.html

