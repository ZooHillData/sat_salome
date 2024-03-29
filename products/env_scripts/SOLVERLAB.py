#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os.path
import platform

def set_env(env, product_dir, version):
    env.set('CoreFlows_INSTALL', product_dir)
    env.set('CoreFlows_ROOT_DIR', product_dir)

    install_rep = env.get('CoreFlows_INSTALL')
    root_module_rep = env.get('CoreFlows_ROOT_DIR')

    env.set('CoreFlows_ROOT', product_dir)
    env.set('CoreFlows_PYTHON', 'ON')
    env.set('CoreFlows_DOC', 'ON')
    env.set('CoreFlows_GUI', 'ON')
    env.set('CoreFlows', os.path.join(install_rep,'bin','CoreFlowsMainExe'))
    env.set('CoreFlowsGUI', os.path.join(install_rep,'bin','CoreFlows_Standalone.py'))
    env.set('COREFLOWS_ROOT_DIR', root_module_rep)

    root = env.get('CoreFlows_ROOT_DIR')
    
    env.prepend('PATH', os.path.join(root, 'include'))
    env.prepend('LD_LIBRARY_PATH', os.path.join(root, 'lib'))
    env.prepend('PYTHONPATH', root)
    env.prepend('PYTHONPATH', os.path.join(root, 'lib'))
    env.prepend('PYTHONPATH', os.path.join(root, 'bin'))
    env.prepend('PYTHONPATH', os.path.join(root, 'lib', 'coreflows'))
    env.prepend('PYTHONPATH', os.path.join(root, 'bin', 'coreflows'))
    env.prepend('PYTHONPATH', os.path.join(root, 'lib', 'cdmath'))
    env.prepend('PYTHONPATH', os.path.join(root, 'bin', 'cdmath'))
    env.prepend('PYTHONPATH', os.path.join(root, 'bin', 'cdmath','postprocessing'))
 
def set_nativ_env(env):
    pass
