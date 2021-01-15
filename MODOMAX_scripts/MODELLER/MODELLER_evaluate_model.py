import sys
from modeller import *
from modeller.scripts import complete_pdb

aaaa = sys.argv[1]  # input pdb file name
bbbb = sys.argv[2]  # output DOPE score profile file name with ".profile" extension

# Example
# python3 MODELLER_evaluate_model.py PCMjMAT.B99990007.pdb PCMjMAT.profile

log.verbose()    # request verbose output
env = environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib') # read topology
env.libs.parameters.read(file='$(LIB)/par.lib') # read parameters

# read model file
mdl = complete_pdb(env, aaaa)

# Assess with DOPE:
s = selection(mdl)   # all atom selection
s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file=bbbb,
              normalize_profile=True, smoothing_window=15)

