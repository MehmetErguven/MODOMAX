# Comparative modeling by the automodel class
#
# Demonstrates how to build multi-chain models, and symmetry restraints
#
import sys
from modeller import *
from modeller.automodel import *    # Load the automodel class
from modeller.parallel import *
from MODELLER_myhomodimer import MyModel

aaaa = sys.argv[1]  # input alignment file name
bbbb = sys.argv[2]  # input pdb code
cccc = sys.argv[3]  # input sequence code

# Example:
# python3 MODELLER_model_multi.py PCMjMAT-4l2z.ali 4l2z PCMjMAT

j = job(host='localhost')
for i in range(5):
    j.append(local_slave())

log.verbose()
env = environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib')
env.libs.parameters.read(file='$(LIB)/par.lib')
env.io.atom_files_directory = ['.', '../atom_files']
env.io.hetatm = True
# Be sure to use 'MyModel' rather than 'automodel' here!
m = MyModel(env,
            alnfile  = aaaa,     # alignment filename
            knowns   = bbbb,              # codes of the templates
            sequence = cccc)              # code of the target

m.starting_model= 1
m.ending_model  = 10
m.library_schedule = autosched.slow
m.max_var_iterations = 300
m.md_level = refine.very_slow
m.repeat_optimization = 2
m.max_molpdf = 1e6
m.use_parallel_job(j)
m.make()

