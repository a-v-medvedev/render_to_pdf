#!/bin/bash

function fatal() {
    echo "FATAL: $1"
    exit 1
}

[ -z "$1" ] && fatal "usage: $(basename $0) file.md"
DOC=$(basename "$1" | sed 's/.md$//')

title_field=$(grep '\[meta_title\]:.*TITLE:' "$1")
[ -z "$title_field" ] && fatal "TITLE field must be present in MD file as a comment."
TITLE=$(echo "$title_field" | sed 's/^\[meta_title\]:.*TITLE: //')

author_field=$(grep '\[meta_author\]:.*AUTHOR:' "$1")
[ -z "$author_field" ] && fatal "AUTHOR field must be present in MD file as a comment."
AUTHOR=$(echo "$author_field" | sed 's/^\[meta_author\]:.*AUTHOR: //')

style_field=$(grep '\[meta_style\]:.*STYLE:' "$1")
[ -z "$style_field" ] && fatal "STYLE field must be present in MD file as a comment."
STYLE=$(echo "$style_field" | sed 's/^\[meta_style\]:.*STYLE: //')

[ -z "$TITLE" ] && fatal "TITLE variable must be set"
[ -z "$AUTHOR" ] && fatal "AUTHOR variable must be set"
[ -z "$DOC" ] && fatal "DOC variable must be set"
[ -z "$STYLE" ] && fatal "STYLE variable must be set"

DT=$(date '+%d %b %Y')
DFN=$(date '+%d_%b_%Y')

doc=$(mktemp ${DOC}_XXXXXX.md)
cat ${DOC}.md | sed 's/^---$/\&nbsp;\n\n---\n\n\&nbsp;/' > $doc
sed -i 's!^---pagebreak[ \t]*$!<div style="page-break-after: always; visibility: hidden">\n\\pagebreak\n</div>\n!' $doc 
sed -i 's!^```[a-z][a-z]*[ \t]*$!`\\smallskip`{=latex}\n&!' $doc
pandoc --pdf-engine lualatex -H make-code-footnotesize.tex --include-in-header=nohyphen.cfg --highlight-style=highlight.theme -M "title=$TITLE" -M "author=$AUTHOR" -M "date=$DT" ${doc} style_${STYLE}.yml -o ${DOC}_${DFN}.pdf
rm -f $doc
