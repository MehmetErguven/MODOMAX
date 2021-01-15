import sys
from modeller import *
from modeller.scripts import complete_pdb

aaaa = sys.argv[1]  # input pdb file name

# Example:
# python3 MODELLER_loop_model_energies.py PCMjMAT.BL%04d0001.pdb > DOPE_messy.log
# Note that this example is different.
# The string "%04d" is necessary for the for loop to process each pdb file.

log.verbose()    # request verbose output
env = environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib') # read topology
env.libs.parameters.read(file='$(LIB)/par.lib') # read parameters

for i in range(1, 21):
    # read model file
    code = aaaa % i
    mdl = complete_pdb(env, code)
    s = selection(mdl)
    s.assess_dope(output='ENERGY_PROFILE NO_REPORT', file='last_delete.profile',
                  normalize_profile=True, smoothing_window=15)

