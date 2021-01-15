# Loop refinement of an existing model

# The following is an example "MODELLER_myloop.py" helper python script.
# Please paste the following in an empty document in a text editor.
# Then save this new file as "MODELLER_myloop.py":
#       from modeller import *
#       from modeller.automodel import *
#       
#       class MyModel(loopmodel):
#           def select_loop_atoms(self):
#               from modeller import selection
#               return selection(
#                   self.residue_range('151:A', '161:A'),
#                   self.residue_range('350:A', '358:A'))

import os
import sys
from modeller import *
from modeller.automodel import *
from modeller.parallel import *

iiii = sys.argv[1]  # define the directory path from which the helper python script "MODELLER_myloop.py" will be called.
sys.path.append(os.path.realpath(os.path.join(os.path.dirname(__file__), iiii)))
from MODELLER_myloop import MyModel

aaaa = sys.argv[2]  # input pdb file name
bbbb = sys.argv[3]  # a prefix (a code without the ".pdb" extension) for the refined output pdb files

# Example:
# python3 MODELLER_loop_refine.py PCMjMAT.B99990007.pdb PCMjMAT07

j = job(host='localhost')
for i in range(5):
    j.append(local_slave())

log.verbose()
env = environ()
env.libs.topology.read(file='$(LIB)/top_heav.lib')
env.libs.parameters.read(file='$(LIB)/par.lib')
env.io.atom_files_directory = './:../atom_files'
env.io.hetatm = True

m = MyModel(env,
           inimodel=aaaa, # initial model of the target
           sequence=bbbb)          # code of the target

m.loop.starting_model= 1
m.loop.ending_model  = 20
m.library_schedule = autosched.slow
m.max_var_iterations = 300
m.loop.md_level = refine.very_slow
m.repeat_optimization = 2
m.max_molpdf = 1e6
m.use_parallel_job(j)
m.make()

