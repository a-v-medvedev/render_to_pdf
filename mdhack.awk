BEGIN {
    picture_started=0
    picure_ended=1
}

function bold_italic_subst() {
    if (match($0, /`/)) {
        gsub(/*/, "\\*", $0);
        gsub(/_/, "\\_", $0);
        gsub(/`/, "***", $0);
    }
}

/```/ { 
    if (picture_started==0) { 
        picture_started=1; 
        print "&nbsp;\n"; 
        print; 
        next; 
    } 
    else { 
        picture_started=0; 
        picture_ended=1; 
        print;
        next; 
    } 
}

/^Таблица [X0-9\.]* -- / {
    printf "\n&nbsp;\n\n"
    bold_italic_subst()
    printf "<p style=\"text-align: left;\">%s</p>\n", $0;
    next
}

/^Рисунок [X0-9\.]* -- / {
    if (picture_ended == 1) {
        bold_italic_subst()
        printf "<div style=\"text-align: center;\">%s</div>\n", $0;
        printf "\n&nbsp;\n\n"
        picture_ended=0
        next
    }
}

/\|.*\|[ \t]*$/ {
    if (table_started==1) {
        bold_italic_subst()
        print
        next
    } else {
        table_started=1
        bold_italic_subst()
        print
        next
    }
}

/^[^\|]*$/ {
    if (table_started == 1) {
        table_started=0
        printf "\n&nbsp;\n\n"
    }
    
}

picture_ended == 1 { 
    if (NF>1 && !match(/^[ \t]*$/, $0)) {
        picture_ended=0; 
    }
}

{ bold_italic_subst(); print }
