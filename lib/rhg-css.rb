#!/usr/bin/env ruby

stylesheet = File.open(ARGV[0]) { |io| io.read }

stylesheet.gsub!(/\s*width:.*/, '')
stylesheet.gsub!(/^h4 {/, 'h5 {')
stylesheet.gsub!(/^h3 {/, 'h4 {')
stylesheet.gsub!(/^h2 {/, 'h3 {')

stylesheet += <<CSS
.title {
    color:            #fff;
    background-color: #33a;
    text-align:       center;
    font-size:        200%;
    margin-top:       0;
    margin-bottom:    1em;
    padding:          1em;
    border:           0;
    line-height:      80px;
}

.author {
    text-align:   center;
    margin:       0;
    border:       0;
    padding:      1em;
}

.part > h1 {
    color:            #fff;
    background-color: #33a;
    text-align:       center;
    font-size:        200%;
    margin-top:       0em;
    margin-bottom:    1em;
    border:           0;
    line-height:      80px;
}

dt { font-weight: bold; }
dd { margin-left: 1em; }

a.noteref { text-decoration: none; }

code {
    font-family: "Courier";
    font-size:   small;
}

h1 > code { font-size: 100%; }
h3 > code { font-size: 100%; }
h4 > code { font-size: 100%; }
h5 > code { font-size: 100%; }

pre.longlist > code.hljs { background-color: #eee; }
CSS

puts(stylesheet)

