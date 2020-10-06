import os,sys
import MDSplus as mds


os.environ['test_path'] = os.getcwd()
print('current tree test: ', os.environ['test_path'])

test = mds.tree.Tree('test', -1, mode="NEW")
test.addNode('prova')
test.write()


