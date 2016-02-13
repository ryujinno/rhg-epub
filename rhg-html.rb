#!/usr/bin/env ruby

all_html = <<HTML
<html>
<head>
<meta http-requiv="Content-Type" content="text/html; charset=utf-8">
<meta name="author" content="青木峰郎">
<link rel="stylesheet" type="text/css" href="rhg_epub.css">
<title>Rubyソースコード完全解説</title>
</head>
<body>

<h1 class="chapter">まえがき</h1>
HTML

index = File.open(ARGV[0], 'r:iso-2022-jp:UTF-8') { |io| io.read }

index.scan(%r[<li><a href="(.*?)">(.*?)</a>]) do |filename, title|
  html = File.open(filename, 'r:iso-2022-jp:UTF-8', undef: :replace, :replace => '?') { |io| io.read }

  case filename
  when 'minimum.html'
    all_html << '<h1 class="part">第 1 部<br />「オブジェクト」</h1>'
  when 'spec.html'
    all_html << '<h1 class="part">第 2 部<br />「構文解析」</h1>'
  when 'evaluator.html'
    all_html << '<h1 class="part">第 3 部<br />「評価」</h1>'
  when 'load.html'
    all_html << '<h1 class="part">第 4 部<br />「評価器の周辺」</h1>'
  end

  # Header
  if filename == 'preface.html'
    html.sub!(%r[^.+?<body>]m, '')
  else
    html.sub!(%r[^.+?<h1>]m, '<h1 class="chapter">')
  end

  # Shift header tags
  html.gsub!(%r[<h4>(.*?)</h4>], '<h5>\1</h5>')
  html.gsub!(%r[<h3>(.*?)</h3>], '<h4>\1</h4>')
  html.gsub!(%r[<h2>(.*?)</h2>], '<h3>\1</h3>')

  # Code tags
  html.gsub!(%r[<pre.*>], '\0<code>')
  html.gsub!(%r[</pre>], '</code>\0')

  # Fix table tags
  html.gsub!(%r[<td>(?!<td>)(.*?)(<td>)], '<td>\1</td>')
  html.gsub!(%r[<td><td>], '<td></td>')

  # Convert table to description list
  if filename == 'preface.html'
    html.gsub!(%r[(<h\d>.*?</h\d>)\s*<table>]m, '\1<dl>')
    html.gsub!(%r[<tr><td>(.*?)</td><td>(.*?)</td></tr>], '<dt>\1</dt><dd>\2</dd>')
    html.gsub!(%r[</table>\s*(<h\d>.*?</h\d>)]m, '</dl>\1')
  end

  # Fix the line 1520 of module.html
  if filename == 'module.html'
    html.sub!(%r[U牙.*?S頏著]){'U牙..S頏著'}
  end

  # Footnote
  html.gsub!(%r[\\footnote{(.+?)}]m, '（\1）')
  html.gsub!(%r[@footnote{(.+?)}]m, '（\1）')

  # Footer
  html.sub!(%r[<hr>.*]m, '')

  all_html << html
end

#
# Postscript
#

all_html << '<h1 class="chapter">あとがき</h1>'

# Header
index.sub!(%r[^.+?</h1>]m, '')

# ID
index.sub!(%r[<p>\s*\$Id: index.html.*\$\s*</p>], '')

# Skip index and shift header
index.sub!(%r[<h2>目次</h2>.+?<h2>ライセンスなど</h2>]m, '<h3>ライセンスなど</h3>')

# Hearline
index.sub!(%r[<hr>], '')

# Dead link
index.sub!(%r[<p>\s*<a href.+?</a>\s*</p>]m, '')

# Footer
index.sub!(%r[</body>.*]m, '')

all_html << index

all_html << '</body></html>'

puts(all_html)

