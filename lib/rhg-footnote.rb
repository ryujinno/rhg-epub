#!/usr/bin/env ruby

xhtml = File.open(ARGV[0], 'r:UTF-8') { |io| io.read }

# Footnote
i = 0
xhtml.gsub!(%r[(\\|@)footnote{(.+?)}]m) do
  i += 1
  <<XHTML
<sup>
<a epub:type="noteref" class="noteref" href="#footnote#{i}">
[#{i}]
</a>
</sup>
<aside epub:type="footnote" id="footnote#{i}">
<p>
#{$2}
</p>
</aside>
XHTML
end

puts(xhtml)

