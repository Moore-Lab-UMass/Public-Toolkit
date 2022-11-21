#!/bin/bash
#Moore Lab
#UMass Chan
#November 2022

cat *peaks.bed > tmp.bed #concatenate all peaks into a file

echo -e "Sorting peaks"
sort -k1,1 -k2,2n tmp.bed > sorted
rm -f rPeaks
num=$(wc -l sorted | awk '{print $1}')

echo -e "Merging DHSs..."
while [ $num -gt 0 ]
do
    echo -e "\t" $num
    bedtools merge -i sorted -c 4,6 -o collapse,collapse > merge #uses id in col 4 and score col 6
    python $scriptDir/pick-best-peak.py merge > peak-list
    awk 'FNR==NR {x[$1];next} ($4 in x)' peak-list sorted >> rPeaks
    bedtools intersect -v -a sorted -b rPeaks > remaining
    mv remaining sorted
    num=$(wc -l sorted | awk '{print $1}')
done

mv rPeaks Final-rPeaks.bed
