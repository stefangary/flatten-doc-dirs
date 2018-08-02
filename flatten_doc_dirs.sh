#!/bin/bash -norc
#=============================
# This software is distributed
# under the terms of the GNU
# GPL 3.0 and any later version.
# Copyright Stefan Gary, 2018
#=============================

input_dir=$1;
output_dir=$2;
# Given an input directory, $1,
# get a list of all the subdirectories
# Note - this is just a prelimary sketch
# and this line will NOT work if there are
# symbolic links or directories with the
# ":" symbol in their names.  Also, need
# to set IFS to just new lines to avoid
# breaking up directories.
IFS=$'\n'
dir_list=`ls --ignore-backups -1 --recursive -l $input_dir | grep $input_dir | awk -F: '{print $1}'`

# Set up output directory
if [ -d $output_dir ]; then
    echo Output directory already exists, do nothing
else
    mkdir -p $output_dir
fi

# Set list of extensions
# Must use newlines to separate strings
# since I set IFS to newline, above.
ext_list="doc"$'\n'"dot"$'\n'"docx"$'\n'"odt"$'\n'"pages"

# Start a file counter so we don't overwrite
file_count=10000

# Loop over all the listed directories
for dir in $dir_list
do
    echo Working on $dir
    cd $dir

    # Delete quarantine files
    rm -f _*.*

    # Delete OSX Desktop Services Store files.
    rm -f *DS_Store
    
    for ext in $ext_list
    do
	# Convert to pdf
	soffice --convert-to pdf *.${ext}	
    done

    # LaTeX, used below does not like spaces
    # in file names.  So, while looping over
    # all the pdfs, make a temporary file for
    # input to LaTex that has no funny chars.

    # Then, put a header on all pdfs that reflects
    # the original file name as well as the
    # original directory
    pdf_list=$(ls -1 *.pdf) 
    for pdf in $pdf_list
    do
	# Link to temporary pdf without any funny characters.
	cp $pdf ./tmp.pdf
	
pdflatex <<EOF
\documentclass{article}
\usepackage[final]{pdfpages} %needed for \includepdf, below
\usepackage{fancyhdr}
\usepackage{url} %needed for \path, below
\pagestyle{fancy}
\topmargin -50pt %otherwise, overprints top of text
\headheight 18pt %allow for two lines or \Large
\oddsidemargin 0pt
\lhead{}
\chead{\large\path{$dir/$pdf}} %path deals with _ and /
\rhead{}
\rfoot{}
\lfoot{}
\cfoot{}
\begin{document}
\includepdfset{pagecommand=\thispagestyle{fancy}} %force all pages to be treated the same
\includepdf[pages=-]{tmp.pdf} %include all the pages of the input file
\end{document}

EOF

        # Clean up
        rm -f *.aux *.log
        rm -f tmp.pdf
	let file_count++
	mv -f texput.pdf $output_dir/${file_count}.pdf
    done
done

# Once all the pdfs are prepped, change to
# the output directory, merge them all, and
# then paginate.
cd $output_dir
gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=out.pdf 1*.pdf
pdflatex <<EOF
\documentclass{article}
\usepackage[final]{pdfpages}
\usepackage{fancyhdr}
\pagestyle{fancy}
\topmargin -50pt
\footskip 150pt
\headheight 18pt
\oddsidemargin 0pt
\renewcommand{\headrulewidth}{0pt} %include these to prevent header
\renewcommand{\footrulewidth}{0pt} %and footer lines from being printed.
\lhead{}
\chead{}
\rhead{}
\rfoot{}
\lfoot{}
\cfoot{\LARGE\thepage}
\begin{document}
\includepdfset{pagecommand=\thispagestyle{fancy}}
\includepdf[pages=-]{out.pdf}
\end{document}

EOF

mv texput.pdf all_merged.pdf
rm -f out.pdf
