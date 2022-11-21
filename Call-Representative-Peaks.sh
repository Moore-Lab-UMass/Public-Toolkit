#!/bin/bash
#Moore Lab
#UMass Chan
#November 2022

#Generalized pipeline used in:
# (1) The ENCODE Project Consortium, Moore...Weng (2020) Nature
# (2) Moore...Weng (2022) Genome Research 

cat *peaks.bed > tmp.bed #concatenate all peaks into a file

echo -e "Sorting peaks"
sort -k1,1 -k2,2n tmp.bed > sorted #sorting peaks by chrom and start
rm -f rPeaks
num=$(wc -l sorted | awk '{print $1}') #count number of peaks

echo -e "Merging peaks..."
while [ $num -gt 0 ]
do
    echo -e "\t" $num
    bedtools merge -i sorted -c 4,6 -o collapse,collapse > merge #uses id in col 4 and score col 6
    python $scriptDir/pick-best-peak.py merge > peak-list #determines peak with highest score
    awk 'FNR==NR {x[$1];next} ($4 in x)' peak-list sorted >> rPeaks #filters for peaks with highest scores
    bedtools intersect -v -a sorted -b rPeaks > remaining #pulls out non-represented peaks
    mv remaining sorted
    num=$(wc -l sorted | awk '{print $1}') #repeats loop with remaining peaks
done

mv rPeaks Final-rPeaks.bed #final list of rPeaks
