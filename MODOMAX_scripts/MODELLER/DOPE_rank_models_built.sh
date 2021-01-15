#!/bin/bash
# 28/12/2020 ME

for i in *.B9999*;
do
	echo $i >> pdblist_mess
done

grep "^DOPE score" DOPE_messy.log | awk '{print $4}' > DOPE_mess
paste pdblist_mess DOPE_mess | awk -v OFS='\t' '{print $1,$2}' > DOPE_scores_mess
sort -nk2 DOPE_scores_mess > DOPE_scores.txt
rm *_mess

