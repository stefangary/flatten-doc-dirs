# flatten-doc-dirs
Grab all the documents in a hierarchy of directories and merge them into a single pdf.

This bash script is run:

$ ./flatten_doc_dirs.sh /full/path/of/input/directory/without/trailing/slash /full/path/of/output/directory/without/trailing/slash

If the named output directory does not yet exist, then it will be created.

Note: this routine will not work for symbolic links or with
directories that have the colon character in their name.  There
are probably other cases that will cause it to fail as well as
this has not been extensively tested.

# Dependencies

You need pdflatex installed on your system.
Since I use symbolic links (instead of copying files)
to speed things up, this program will not work
on data on volumes with filesystems that do not
support symbolic links (e.g. Linux mounting an NTFS
volume).  The way around this is to copy the file
or use some daisy chained tr commands to rename
files with unusual characters.