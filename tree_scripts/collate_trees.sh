
# Combines a folder of influenza gene trees together into a single nexus file
# input 1: folder containing trees of the form ${segment}.tre

segments=(PB2 PB1 PA HA NP NA MP NS)

echo "#NEXUS" 
echo "begin trees;"
for i in "${segments[@]}"; do 
    filename="$1/${i}.tre"
    sed -e "s/${i}//g" $filename > "tempfile"
    echo "tree $i = $(sed -E 's/EPI[0-9]+//g' tempfile | sed -E 's/\)[0-9.]*\/[0-9]+/)/g')"
done
echo "end;"
