#!/bin/bash

# Metagenomics Pipeline installer
# S Sturrock - ESR
# 30/07/2021

PIPELINE=metagenomics_pipeline

# User can specify destination
if [ $# -lt 1 ]; then
	INSTALL_DIR=${PWD}/${PIPELINE}
else
	INSTALL_DIR=${1}/${PIPELINE}
fi

echo $INSTALL_DIR

# If the directory already exists, delete it
if [ -d $INSTALL_DIR ]; then
	rm -rf $INSTALL_DIR
fi

mkdir -p $INSTALL_DIR/bin
# Go into install directory and everything will be put in here
cd $INSTALL_DIR

# Download and build kraken2
git clone https://github.com/DerrickWood/kraken2.git
cd kraken2
./install_kraken2.sh $INSTALL_DIR/bin
# Create init.sh to set up path etc for user
echo "export PATH=${INSTALL_DIR}/bin:${PATH}" > $INSTALL_DIR/bin/init.sh
chmod +x $INSTALL_DIR/bin/init.sh
cd $INSTALL_DIR

# Set up miniconda
mkdir $INSTALL_DIR/miniconda
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-aarch64.sh
bash Miniconda3-latest-Linux-aarch64.sh -b -f -p $INSTALL_DIR/miniconda
# Add miniconda to the init.sh
echo 'eval "$('$INSTALL_DIR'/miniconda/bin/conda shell.bash hook)"' >> $INSTALL_DIR/bin/init.sh

# Activate the conda env
eval "$(${INSTALL_DIR}/miniconda/bin/conda shell.bash hook)"
# Add channels
# conda config --add channels defaults
conda config --add channels bioconda
conda config --add channels conda-forge
# Mamba
conda install -y mamba -n base -c conda-forge

# recentrifuge install
mamba install -y -c bioconda recentrifuge
cd $INSTALL_DIR
git clone https://github.com/khyox/recentrifuge.git
cd recentrifuge
# Download NCBI node db
./retaxdump

# Install R
mamba create -y -n r_env r-essentials r-base
mamba install -y -c conda-forge r-shinylp
mamba install -y -c conda-forge r-dt
conda install -y -c conda-forge r-flexdashboard
conda install -y -c conda-forge r-here
conda install -y -c conda-forge r-plotly
#mamba install -c conda-forge r-fontawesome
# recent version of fontawesome isn't available in conda
R -e "install.packages('fontawesome', repos='http://cran.rstudio.com/')"

# Install Python 3.9
PY3_VER=3.9
conda install -y python=${PY3_VER}