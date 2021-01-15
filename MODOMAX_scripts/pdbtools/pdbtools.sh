#!/bin/bash

# The following "seds" clear:
	# ANISOU terms,
	# CONECT information, and
	# the miscellaneous lines at the beginning.
sed -i '/HEADER/d;
/TITLE/d;
/COMPND/d;
/SOURCE/d;
/KEYWDS/d;
/EXPDTA/d;
/AUTHOR/d;
/REVDAT/d;
/JRNL/d;
/REMARK/d;
/DBREF/d;
/SEQADV/d;
/SEQRES/d;
/MODRES/d;
/HET   /d;
/HETNAM/d;
/HETSYN/d;
/FORMUL/d;
/HELIX/d;
/SHEET/d;
/LINK/d;
/CISPEP/d;
/SITE/d;
/CRYST1/d;
/ORIGX1/d;
/ORIGX2/d;
/ORIGX3/d;
/SCALE1/d;
/SCALE2/d;
/SCALE3/d;
/SSBOND/d;
/ANISOU/d;
/CONECT/d;
/MASTER/d' *.pdb

# The following "sed" change MSE (selenomethionine) into MET (methionine).
sed -i '/MSE/ s/HETATM/ATOM  /' *.pdb

for i in *.pdb;
do
	python ~/MODOMAX_scripts/pdbtools/pdb_delhetatm.py $i | 
	python ~/MODOMAX_scripts/pdbtools/pdb_selaltloc.py | 
	python ~/MODOMAX_scripts/pdbtools/pdb_occ.py | 
	python ~/MODOMAX_scripts/pdbtools/pdb_chain.py -A | 
	python ~/MODOMAX_scripts/pdbtools/pdb_reres.py | 
	python ~/MODOMAX_scripts/pdbtools/pdb_reatom.py > "${i%.*}_clean.pdb"
done

# Do not erase the terminal residue information within the "TER" line. So, it is commented out:
#sed -i 's/TER.*/TER                                                                             /g' *_clean.pdb

ls -p1 -- *.pdb | grep -v / | grep -v '_clean.pdb' | xargs rm -f
rename s/"_clean"/""/g *.pdb

