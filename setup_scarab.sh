USERNAME=username
# FOLDER_NAME=computation/Computation-Aware-Controller-Docker
# RESOURCES_DIR=/global/scratch/users/$USERNAME/$FOLDER_NAME/resources

MAIN_DIR=/home/$USERNAME/Project
RESOURCES_DIR=$PROJECT_DIR/resources

mkdir -p $RESOURCES_DIR
cd $RESOURCES_DIR && git clone https://github.com/Litz-Lab/scarab.git
pip3 install -r $RESOURCES_DIR/scarab/bin/requirements.txt

cd $RESOURCES_DIR && wget https://github.com/DynamoRIO/dynamorio/releases/download/cronbuild-9.0.19314/DynamoRIO-Linux-9.0.19314.tar.gz \
    && tar -xzvf DynamoRIO-Linux-9.0.19314.tar.gz \
    && rm DynamoRIO-Linux-9.0.19314.tar.gz

export DYNAMORIO_HOME=$RESOURCES_DIR/DynamoRIO-Linux-9.0.19314

# cd $RESOURCES_DIR && gdown 'https://drive.google.com/uc?id=1xD4zEEgg05CQEI9e5CQO4F5rRfJdfLZV' -O pinplay35.zip
# unzip pinplay35.zip
# rm pinplay35.zip

## Download pinplay 3.15
cd $RESOURCES_DIR && gdown 'https://drive.google.com/uc?export=download&id=1KRrs0CfR67UGa_IcGDTzaL5zFBMds0ZS' -O pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz \
    && tar -xzvf pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz \
    && rm pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz


export PIN_ROOT=$RESOURCES_DIR/pin-3.15-98253-gb56e429b1-gcc-linux
export SCARAB_ENABLE_PT_MEMTRACE=1
export SCARAB_ENABLE_MEMTRACE=1
export LD_LIBRARY_PATH=$RESOURCES_DIR/pin-3.15-98253-gb56e429b1-gcc-linux/extras/xed-intel64/lib
export LD_LIBRARY_PATH=$RESOURCES_DIR/pin-3.15-98253-gb56e429b1-gcc-linux/intel64/runtime/pincrt:$LD_LIBRARY_PATH

cd $RESOURCES_DIR/scarab/src && make

# cd $MAIN_DIR && git clone https://github.com/YasinSonmez/Inverted-Pendulum.git

# PROJECT_DIR=$MAIN_DIR/Inverted-Pendulum
# cd $PROJECT_DIR && git clone https://github.com/YasinSonmez/Scarab-Trace-and-Simulate-Script.git
# cd $PROJECT_DIR && mkdir build && cd build
# cmake -DDynamoRIO_DIR=$DYNAMORIO_HOME/cmake ..
# make

# cd $RESOURCES_DIR && wget https://github.com/nicolapiccinelli/libmpc/archive/refs/tags/0.4.2.tar.gz \
#     && tar -xzvf 0.4.2.tar.gz \
#     && rm 0.4.2.tar.gz

# cd $RESOURCES_DIR/libmpc-0.4.2 && sudo ./configure.sh --disable-test && mkdir build && cd build && cmake .. && make && sudo make install