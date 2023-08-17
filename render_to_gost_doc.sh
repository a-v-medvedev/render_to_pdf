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

lang_field=$(grep '\[meta_language\]:.*LANGUAGE:' "$1")
[ -z "$lang_field" ] && fatal "LANGUAGE field must be present in MD file as a comment."
LANGUAGE=$(echo "$lang_field" | sed 's/^\[meta_language\]:.*LANGUAGE: //')

margin_field=$(grep '\[meta_margin\]:.*MARGIN:' "$1")
[ -z "$margin_field" ] && fatal "MARGIN field must be present in MD file as a comment."
MARGIN=$(echo "$margin_field" | sed 's/^\[meta_margin\]:.*MARGIN: //')

[ -z "$TITLE" ] && fatal "TITLE variable must be set"
[ -z "$AUTHOR" ] && fatal "AUTHOR variable must be set"
[ -z "$DOC" ] && fatal "DOC variable must be set"
[ -z "$LANGUAGE" ] && fatal "LANGUAGE variable must be set"
[ -z "$MARGIN" ] && fatal "MARGIN variable must be set"

DT=$(date '+%d %b %Y')
DFN=$(date '+%d_%b_%Y')

doc=$(mktemp ${DOC}_XXXXXX.md)
gawk -f mdhack.awk ${DOC}.md > $doc 
# for opendocument (.odt): ```{=openxml}\n<text:p text:style-name="Pagebreak"/>\n```
sed -i 's!^---pagebreak[ \t]*$!```{=openxml}\n<w:p><w:r><w:br w:type="page"/></w:r></w:p>\n```!' $doc
#echo $doc

# ODT version:
# pandoc -f markdown -t odt ${doc} -M "title=$TITLE" -o ${DOC}.odt --reference-doc=./odt_gost_TEMPLATE.odt

# DOCX version:
pandoc -f markdown -t docx ${doc} -M "title=$TITLE" -o ${DOC}.docx --reference-doc=./docx_gost_TEMPLATE.docx

rm -f $doc
