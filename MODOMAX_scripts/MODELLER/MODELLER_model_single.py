import sys
from modeller import *
from modeller.automodel import *
from modeller.parallel import *

aaaa = sys.argv[1]  # input alignment file name
bbbb = sys.argv[2]  # input pdb code
cccc = sys.argv[3]  # input sequence code

# Example:
# python3 MODELLER_model_single.py PCMjMAT-4l2z.ali 4l2z PCMjMAT

j = job(host='localhost')
for i in range(5):
    j.append(local_slave())

#from modeller import soap_protein_od

log.verbose()
env = environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib')
env.libs.parameters.read(file='$(LIB)/par.lib')
env.io.atom_files_directory = ['.', '../atom_files']
env.io.hetatm = True

a = automodel(env, alnfile=aaaa,
              knowns=bbbb, sequence=cccc,
              assess_methods=(assess.DOPE,
                              #soap_protein_od.Scorer(),
                              assess.GA341))
a.starting_model = 1
a.ending_model = 10
a.library_schedule = autosched.slow
a.max_var_iterations = 300
a.md_level = refine.very_slow
a.repeat_optimization = 2
a.max_molpdf = 1e6
a.use_parallel_job(j)
a.make()

