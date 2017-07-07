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
HTML

index = File.open(ARGV[0], 'r:iso-2022-jp:UTF-8') { |io| io.read }
original = index.clone

# Header
index.sub!(%r[^.*?<h1>]m, '<h1 class="chapter">')

# Shift header
index.gsub!(%r[<h3>(.*?)</h3>]m, '<h4>\1</h4>')
index.gsub!(%r[<h2>(.*?)</h2>]m, '<h3>\1</h3>')

# Dead link
index.sub!(%r[<p>\s*<a href.*?>.*?</a>\s*</p>]m, '')
index.gsub!(%r[<li><a href.*?>(.*?)</a></li>]m, '<li>\1</li>')

# Delete Hearline
index.sub!(%r[<hr>], '')

# Footer
#index.sub!(%r[</body>.*]m, '')

# Sections
index.scan(%r[(<h1 class="chapter">.*?)<h3>]m) do |section, next_section|
  all_html << section
end
# Push licence section
index.scan(%r[</h3>.*?(<h3>.*?)</body>]m) do |section, next_section|
  all_html << section
end
index.scan(%r[(<h3>.*?</h3>.*?)<h3>]m) do |section, next_section|
  all_html << section
end

#all_html << index

original.scan(%r[<li><a href="(.*?)">(.*?)</a></li>]) do |filename, title|
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
    html.sub!(%r[^.*?<body>]m, '')
    html.sub!(%r[^<h2>(.*?)</h2>]m, '<h1 class="chapter">\1</h1>')
  else
    html.sub!(%r[^.*?<h1>]m, '<h1 class="chapter">')
  end

  # Shift header tags
  html.gsub!(%r[<h4>(.*?)</h4>], '<h5>\1</h5>')
  html.gsub!(%r[<h3>(.*?)</h3>], '<h4>\1</h4>')
  html.gsub!(%r[<h2>(.*?)</h2>], '<h3>\1</h3>')

  html.gsub!(%r[<pre class="longlist">(.*?)</pre>]m) do |code|
    # Comment out line number in code
    has_line_num = false
    line_num_len = 0
    code.split("\n").each do |line|
      line.gsub(%r[^( |\d){3}\d]) do |lnum|
        has_line_num = true
        line_num_len = [line_num_len, lnum.strip.length].max
        lnum
      end
    end
    if has_line_num
      code.gsub!(%r[^( |\d){3}\d]) do |lnum|
        "/*%0#{line_num_len}s*/" % lnum.strip
      end
      code.gsub!(%r[^    ]) do
        "  %0#{line_num_len}s  " % ''
      end
    end

    # Comment out source file
    code.gsub!(%r[^\((\w+?\.[chys])\)], '/* \1 */')

    code
  end

  # Code tags
  html.gsub!(%r[<pre.*?>], '\0<code>')
  html.gsub!(%r[</pre>], '</code>\0')

  # Fix table tags
  #html.gsub!(%r[<td>(?!<td>)(.*?)(<td>)], '<td>\1</td>')
  html.gsub!(%r[<td>(.*?)(<td>)], '<td>\1</td>')
  html.gsub!(%r[<td><td>], '<td></td>')

  # Convert table to description list
  if filename == 'preface.html'
    html.gsub!(%r[(<h\d>.*?</h\d>)\s*<table>]m, '\1<dl>')
    html.gsub!(%r[<tr><td>(.*?)</td><td>(.*?)</td></tr>], '<dt>\1</dt><dd>\2</dd>')
    html.gsub!(%r[</table>\s*(<h\d>.*?</h\d>)]m, '</dl>\1')
  end

  # Fix paragraph tag
  if filename == 'preface.html'
    html.sub!(%r[^<p class="right"$], '<p class="right">')
  end


  # Fix the line 1520 of module.html
  if filename == 'module.html'
    html.sub!(%r[U牙.*?S頏著], 'U牙..S頏著')
  end

  # Footer
  html.sub!(%r[<hr>.*]m, '')

  all_html << html
end

all_html << '</body></html>'

puts(all_html)

