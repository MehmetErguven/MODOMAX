MODOMAX is a new repository for applications of computational structural biology tools and programs.

Currently, MODOMAX is constituted of a bundle of interconnected Bash scripts and python3 scripts that provide an automatized workflow for the modeling program named MODELLER.

The ultimate aim of the project is to combine homology modeling, ligand docking, and molecular dynamics simulation in an all-in-one, user-friendly stand-alone package.

## Dependencies:

- **MODELLER:**
MODOMAX depends on MODELLER for homology modeling. MODELLER is a program for comparative protein structure modeling by satisfaction of spatial restraints.

    - Please refer to the following web page for further information about the program and how it has to be cited:
    
    https://salilab.org/modeller/

    - Please refer to the following web page for downloads and license registry:
    
    https://salilab.org/modeller/download_installation.html

    - Please refer to the following web page to get to the links to the manuals, frequently asked questions (FAQs), and tutorials:
    
    https://salilab.org/modeller/documentation.html

- **pdb-tools:**
MODOMAX depends on pdb-tools in order to prepare "clean" input coordinate files for MODELLER to use.
    
    - Please refer to the following web page for further information about pdb tools and how it has to be cited:
    
    https://github.com/JoaoRodrigues/pdb-tools
    
    After cloning that repository, copy the python scripts within the subfolder named "pdbtools" into the subdirectory of MODAMAX, which is also named pdbtools.

- **"python3":** The python scripts that invoke MODELLER are python3 compatible. Please make sure python3 is installed.

- **"rename":** Rename is a Linux command. It is not preinstalled in Ubuntu. The scripts depend on it in order to rename files.

- **"tree":** Tree is a Linux command. It is not preinstalled in Ubuntu. The scripts depend on it in order to enable users to quickly check their directory organizations.

- **"code":** Some of the scripts invoke Visual Studio Code at some point, to allow users to manually edit the alignment files for homodimers.

## Current state of the repository (2021_01_15):

There are four "master" shell scripts located in the "MODOMAX_scripts" directory. Each of these master scripts stand for a different homology modeling scenario. To automatize the use of MODELLER, these master scripts call the other scripts that are located in the subdirectories "MODELLER" and "pdb-tools".

The master scripts are:

- **automatic_monomer_build.sh:** Used for monomer model building.

- **automatic_monomer_build_then_refine_loops.sh:** Used for custom loop refinement of the readily built monomer models.

- **automatic_homodimer_build.sh:** Used for homodimer model building.

- **automatic_homodimer_build_then_refine_loops.sh:** Used for custom loop refinement of the readily built homodimer models.

## Usage:

At the moment, MODOMAX is designed to automatically perform homology modeling, using a single coordinate file as the template. This organization is inspired by site-directed mutagenesis based studies, in which each variant will correspond to a different sequence file with one common template.

Put your: 

- input **coordinate file,**

- **PIR-formatted sequence files,**

- and **"MODELLER_myloop.py"** into an empty directory.

The "MODELLER_myloop.py" is used for loop refinement. But its usage is determined by the master scripts. Briefly, if you do not aim for a loop refinement, still put the script in the directory, it will not effect the modeling process, but its absence will cause an error.

If you aim for loop refinement, then customize the loop residue ranges within the "MODELLER_myloop.py" script, and choose the appropriate master script that will actually make use of MODELLER_myloop.py.

The models are ranked according to their DOPE scores and the ranking is given in the following:

> ./runs/model_\*/DOPE_scores.txt

The loop-refined models are ranked according to their DOPE scores and the ranking is given in the following:

> ./runs/model_\*/loop_refinement/DOPE_scores.txt


