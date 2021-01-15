import sys
from modeller import *

aaaa = sys.argv[1]  # input pdb file name
bbbb = sys.argv[2]  # input pdb code
cccc = sys.argv[3]  # input sequence file name
dddd = sys.argv[4]  # input sequence code
eeee = sys.argv[5]  # output alignment file name with ".pir" extension
ffff = sys.argv[6]  # output alignment file name with ".pap" extension

# Example:
# python3 MODELLER_align2d.py 4l2z.pdb 4l2z PCMjMAT.ali PCMjMAT PCMjMAT-4l2z.ali PCMjMAT-4l2z.pap

env = environ()
env.libs.topology.read('${LIB}/top_heav.lib')
aln = alignment(env)
mdl = model(env, file=aaaa, model_segment=('FIRST:A','LAST:A'))
aln.append_model(mdl, align_codes=bbbb, atom_files=aaaa)
aln.append(file=cccc, align_codes=dddd)
aln.align2d()
aln.write(file=eeee, alignment_format='PIR')
aln.write(file=ffff, alignment_format='PAP')

