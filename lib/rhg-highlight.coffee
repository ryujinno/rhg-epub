asset_dir  = process.argv[2]
xhtml_file = process.argv[3]

jsdom = require('jsdom/lib/old-api.js')

jsdom.env
  file: xhtml_file
  scripts: [
    "#{asset_dir}/jquery.min.js",
    "#{asset_dir}/highlight.min.js",
  ]
  done: (error, window) ->
    # Highlight code
    window.hljs.configure
      languages: [ 'ruby', 'cpp' ]
    window.$('pre.emlist > code').each (i, block) ->
      window.hljs.highlightBlock(block)
    window.hljs.configure
      languages: [ 'cpp' ]
    window.$('pre.longlist > code').each (i, block) ->
      window.hljs.highlightBlock(block)

    # Remove script tags
    window.$('script').remove()

    # Convert to XHTML
    xhtml = window.document.documentElement.innerHTML
    xhtml = xhtml.replace(/(<meta\s.+?)>/g, '$1 />')
    xhtml = xhtml.replace(/(<link\s.+?)>/g, '$1 />')
    xhtml = xhtml.replace(/(<img\s.+?)>/g, '$1 />')
    xhtml = xhtml.replace(/(<col\s.+?)>/g, '$1 />')
    xhtml = xhtml.replace(/<br>/g, '<br />')

    console.log """
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops">
#{xhtml}
</html>
"""
