# Script to build Salome
# First, get the software.zip file from Salome FTP
# located at: ftp://ftp.cea.fr/pub/salome/prerequisites/software.zip
# I stored the unizipped file at ~/Downloads/software

# Move the software folder to C:/software so it can be discovered by the setup.bat script
mv ~/Downloads/software /c/software

# Make a working directory
mkdir /c/S
cd /c/S

# Fetch SAT/SAT_Salome from Salome Github repository
git clone https://git.salome-platform.org/gitpub/tools/sat.git
cd sat
git clone https://git.salome-platform.org/gitpub/tools/sat_salome.git
cd ..

# Copy setup.bat into working directory
cp /c/setup.bat .

# ***Manual changes to setup.bat***:
# My Visual Studio installed to C:/Program Files (x86)/Microsoft Visual Studio/2017/BuildTools instead of C:/Program Files (x86)/Microsoft Visual Studio/2017/Community
# So I had to modify the setup.bat to point to BuildTools

# Run setup.bat
./setup.bat

# Create a python virtual environment for SAT
# Install distro (required b/c running SAT with Python 3.10)
cd sat
python -m venv sat-env
source sat-env/Scripts/activate
pip install distro

# ***Manual changes to sat_salome***: 
# 1. sat_salome/salome.pyconf
#   - ARCHIVEPATH (if already have ARCHIVES locally, move them into /c/S/ARCHIVES: cp -r /c/Users/DELL/ARCHIVES /c/S/ARCHIVES and change the reference in sat_salome/salome.pyconf
#   - LICENSEPATH: I could not figure out what to do here...
# 2. sat_salome/applications/SALOME-9.11.0-windows.pyconf
#   - Change repo_dev: "yes" to repo_dev: "no"
#   - Comment out OPENTURNS_SALOME (can't find in public repo)
# 3. change repo locations within sat_salome/products
#   - ADAO.pyconf: repo : $PROJECTS.projects.salome.git_info.default_git_server + "modules/adao.git"
#   - EFICAS.pyconf: repo : $PROJECTS.projects.salome.git_info.default_git_server + "modules/eficas.git"
#   - SALOME.pyconf: repo : $PROJECTS.projects.salome.git_info.default_git_server + "tools/" + $name + ".git"
#   - SHAPERSTUDY.pyconf: repo : $PROJECTS.projects.salome.git_info.default_git_server + "modules/shaper_study.git"

# Add Salome to SAT
# Add SALOME-9.11.0-windows to SAT (learned how to do this from SAT documentation)
# SAT documentation location: ftp://ftp.cea.fr/pub/salome/targz/SAT-5.8/sat-5.8.pdf
# To reset projects: python sat/sat init --reset_projects
python sat init --add_project sat_salome/salome.pyconf

# Run sat prepare
# Had to remove OPENTURNS_SALOME from product list b/c there is no public repo for it
python sat prepare SALOME-9.11.0-windows --properties is_SALOME_module:yes

# Run sat compile
python sat compile SALOME-9.11.0-windows --properties is_SALOME_module:yes