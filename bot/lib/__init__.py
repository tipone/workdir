import os
modlist = []

for module in os.listdir(os.path.dirname(__file__)):
    if module == '__init__.py' or module[-3:] != '.py':
        continue
    modlist.append(module[:-3])

__import__("lib", fromlist=modlist)

del module
del os
del modlist

