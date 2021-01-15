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
If the organization looks correct, if you say yes, type y to proceed.
If something looks wrong, if you say no, type n to stop." yn
    case $yn in
        [Yy]* ) echo "Then lets proceed with model building!"; break;;
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
    code -- "$e" &
    cd ../
done

while true; do
    read -p "Your alignment files are ready.
The terminal is paused now, please do not close the terminal window, keep it open.
The alignment files with <.ali> extension are opened in Visual Studio Code.
Insert your chain breakers in the alignment files.
Please follow these instructions:
In the files, find the beginning of the second chain (end of the first chain).
When you select a fragment in a text, the program will simultaneously highlight the same occurrences within the file.
This means that, if you select a fragment from the start of your first chain, this guide you to the beginning of the second chain.
There has to be a hyphen (-) at the beginning of the first chain, please replace that hyphen with a slash (/).
Then click <File> at the top-left corner of the window, in the menu bar.
Then click <Save All>.
You may close the alignment files now (you do not need them opened anymore).
Finally, come back here to this terminal window.
Type y and press enter to continue with the model building steps.
If you want to stop for some reason, then type n and press enter." yn
    case $yn in
        [Yy]* ) echo "Then lets proceed with model building!"; break;;
        [Nn]* ) exit;;
        * ) echo "PLEASE ANSWER y OR n.";;
    esac
done

for j in model_*;
do
    cd $j/
    a=$(echo *.pdb)
    b=${a%.*}
    c=$(echo *_alignment.ali)
    d=${c%_*_*.*}
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_model_multi.py "$c" "$b" "$d"
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_built_model_energies.py "$d".B9999%04d.pdb > DOPE_messy.log
    rm last_delete.profile
    ~/MODOMAX_scripts/MODELLER/DOPE_rank_models_built.sh
    g=$(ls -p1 -- *.pdb | grep -v .B999900)
    h=$(ls -p1 -- *.pdb | grep -v .B999900 | sed 's/.pdb/.profile/g')
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_evaluate_model.py "$g" "$h"
    k=$(head -1 DOPE_scores.txt | awk '{print $1}')
    l=$(head -1 DOPE_scores.txt | awk '{print $1}' | sed 's/.pdb/.profile/g')
    python3 ~/MODOMAX_scripts/MODELLER/MODELLER_evaluate_model.py "$k" "$l"
    ~/MODOMAX_scripts/MODELLER/DOPE_resi_df_prep.sh
    # insert a plotting code
    # move the plots and the best structures to the results folder
    cd ../
done

cd ../
mv list_* organizer_* ./zz_etc/

