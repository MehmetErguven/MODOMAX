#!/bin/bash
# 28/12/2020 ME

for i in *.profile;
do
	awk -v OFS='\t' '{print $1,$42}' $i | tail -n +8 > "${i%.*}_cl.profile"
done

for j in *_cl.profile;
do
    echo -e "residue\tDOPE" | cat - $j > "${j%.*}ean.profile"
done

rm *_cl.profile

