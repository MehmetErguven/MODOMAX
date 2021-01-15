#!/bin/bash
# 28/12/2020 ME

for i in *0001.pdb;
do
	echo $i >> pdblist_mess
done

sed '/.IL00000001.pdb/d' ./pdblist_mess > pdblist_edited_mess
grep "^DOPE score" DOPE_messy.log | awk '{print $4}' > DOPE_mess
paste pdblist_edited_mess DOPE_mess | awk -v OFS='\t' '{print $1,$2}' > DOPE_scores_mess
sort -nk2 DOPE_scores_mess > DOPE_scores.txt
rm *_mess

