#!/bin/bash

# Use these to clean the directory after testing the script:
# rm -r results runs zz_etc

# The input examples for the MODELLER python scripts:
# "XXXX" stands for the four-character PDB code,
# and "protein_name" stands for the target sequence to be modeled.

# Script name: MODELLER_align2d.py
# python3 MODELLER_align2d.py XXXX.pdb XXXX protein_name.ali protein_name protein_name-XXXX.ali protein_name-XXXX.pap

# Script name: MODELLER_model_single.py
# python3 MODELLER_model_single.py protein_name-XXXX.ali XXXX protein_name

# Script name: MODELLER_model_multi.py
# python3 MODELLER_model_multi.py protein_name-XXXX.ali XXXX protein_name

# Script name: MODELLER_built_model_energies.py
# python3 MODELLER_built_model_energies.py protein_name.B9999%04d.pdb > DOPE_messy.log

# Script name: MODELLER_loop_refine.py
# python3 MODELLER_loop_refine.py protein_name.B99990???.pdb protein_name???    (script automatically determines these two "???")

# Script name: MODELLER_loop_model_energies.py
# python3 MODELLER_loop_model_energies.py protein_name.BL%04d0001.pdb > DOPE_messy.log

# Script name: MODELLER_evaluate_model.py
# python3 MODELLER_evaluate_model.py protein_name.B99990???.pdb protein_name???.profile (script automatically determines these two "???")

# Get the list of names to be used as project subdirectory names, based on the sequence file names:
ls -p1 | grep '.ali' > list_ALI

# Using that list file, generate the project subdirectories with the desired names:
a="cat list_ALI"
eval "$a"
b=$(eval "$a")
mkdir zz_etc results runs
cd runs
echo "$b" | xargs mkdir
rename 's/^/model_/' *
rename s/".ali"/""/g *

# Generate the executable that will distribute the input sequence files to the respective subdirectories
# and then execute it within this main script:
ls -d */ > list_SUBDIR
mv list_SUBDIR ../
cd ../
sed -i -e 's/^/cp .\//' list_ALI
sed -i -e 's/^/.\/runs\//' list_SUBDIR
paste list_ALI list_SUBDIR | awk -v OFS=' ' '{print $1,$2,$3}' > organizer_ALI
echo -e '#!/bin/bash' | cat - organizer_ALI > organizer_ALI.sh
chmod +x organizer_ALI.sh
./organizer_ALI.sh

# Generate the executable that will distribute the input coordinate files to the respective subdirectories
# and then execute it within this main script:
cp list_ALI list_PDB

for i in *pdb;
do
    sed -i "s/.*/cp .\/$i/g" "list_PDB"
done

paste list_PDB list_SUBDIR | awk -v OFS=' ' '{print $1,$2,$3}' > organizer_PDB
echo -e '#!/bin/bash' | cat - organizer_PDB > organizer_PDB.sh
chmod +x organizer_PDB.sh
./organizer_PDB.sh

# Generate the loop refinement subdirectories within the subdirectories:
cd ./runs/

    for i in model_*;
    do
        cd $i/
        mkdir loop_refinement
        cd ../
    done

cd ../

# Generate the executable that will distribute the "myloop" python script to the respective subdirectories
# and then execute it within this main script:
cp list_ALI list_PY

for i in MODELLER_myloop*;
do
    sed -i "s/.*/cp .\/$i/g" "list_PY"
done

paste list_PY list_SUBDIR | awk -v OFS=' ' '{print $1,$2,$3}' > organizer_PY
sed -i 's/$/loop_refinement\//' organizer_PY
echo -e '#!/bin/bash' | cat - organizer_PY > organizer_PY.sh
chmod +x organizer_PY.sh
./organizer_PY.sh

tree

while true; do
    read -p "The tree above is how the files are organized.
Do you wish to continue?
If the organization looks correct, if you say yes, type y and then press enter to proceed.
If something looks wrong, if you say no, type n and then press enter to stop." yn
    case $yn in
        [Yy]* ) echo "Then lets proceed with the homology modeling!"; break;;
        [Nn]* ) exit;;
        * ) echo "PLEASE ANSWER y OR n.";;
    esac
done

cd ./runs/

for i in model_*;
do
    cd $i/
    a=$(echo *.pdb)
    b=${a%.*}
    c=$(echo *.ali)
    d=${c%.*}
    e=$(printf "$d"_"$b"_alignment.ali)
    f=$(printf "$d"_"$b"_alignment.pap)
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_align2d.py "$a" "$b" "$c" "$d" "$e" "$f"
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_model_single.py "$e" "$b" "$d"
    for x in *.pdb;
    do
        python ~/MODOMAX_scripts/pdbtools/pdb_chain.py -A $x > "${x%.*}_clean.pdb"
    done
    ls -p1 -- *.pdb | grep -v / | grep -v '_clean.pdb' | xargs rm -f
    rename s/"_clean"/""/g *.pdb
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_built_model_energies.py "$d".B9999%04d.pdb > DOPE_messy.log
    rm last_delete.profile
    ~/MODOMAX_scripts/MODELLER/DOPE_rank_models_built.sh
    g=$(ls -p1 -- *.pdb | grep -v .B999900)
    h=$(ls -p1 -- *.pdb | grep -v .B999900 | sed 's/.pdb/.profile/g')
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_evaluate_model.py "$g" "$h"
    ~/MODOMAX_scripts/MODELLER/DOPE_resi_df_prep.sh
    k=$(head -1 DOPE_scores.txt | awk '{print $1}')
    l=$(head -1 DOPE_scores.txt | awk '{print $1}' | sed 's/.pdb/.profile/g')
    cp "$k" ./loop_refinement/
    cd loop_refinement/
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_evaluate_model.py "$k" "$l"
    rename 's/.B999900/_/' *.pdb
    m=$(pwd)/
    n=$(echo *.pdb)
    o=${n%.*}
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_loop_refine.py "$m" "$n" "$o"
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_loop_model_energies.py "$o".BL%04d0001.pdb > DOPE_messy.log
    rm last_delete.profile
    ~/MODOMAX_scripts/MODELLER/DOPE_rank_models_loop_refined.sh
    p=$(head -1 DOPE_scores.txt | awk '{print $1}')
    r=$(head -1 DOPE_scores.txt | awk '{print $1}' | sed 's/.pdb/.profile/g')
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_evaluate_model.py "$p" "$r"
    ~/MODOMAX_scripts/MODELLER/DOPE_resi_df_prep.sh
    mv *_clean.profile ../
    cd ../
    # insert a plotting code
    # move the plots and the best structures to the results folder
    cd ../
done

cd ../
mv list_* organizer_* ./zz_etc/

