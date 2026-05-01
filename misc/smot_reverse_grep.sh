# Hack for handling smot reverse grep using a file as an input 
# Should probably be deleted once this is implemented in upstream

# input 1: treefile path
# input 2: file containing taxa that need to be excluded


function join_by {
    local IFS="$1";
    shift;
    echo "$*"
}

excluded_taxa=$(join_by "|" $(cat $1))
smof grep -vP "($excluded_taxa)"
