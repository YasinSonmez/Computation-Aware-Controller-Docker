USERNAME=yasin

cd /home/$USERNAME && git clone https://github.com/kofyou/scarab.git
pip3 install -r /home/$USERNAME/scarab/bin/requirements.txt

gdown 'https://drive.google.com/uc?id=1xD4zEEgg05CQEI9e5CQO4F5rRfJdfLZV' -O pinplay35.zip
unzip pinplay35.zip
rm pinplay35.zip

export PIN_ROOT=/home/$USERNAME/pinplay-drdebug-3.5-pin-3.5-97503-gac534ca30-gcc-linux
export SCARAB_ENABLE_PT_MEMTRACE=1
export SCARAB_ENABLE_MEMTRACE=1
export LD_LIBRARY_PATH=/home/$USERNAME/pinplay-drdebug-3.5-pin-3.5-97503-gac534ca30-gcc-linux/extras/xed-intel64/lib
export LD_LIBRARY_PATH=/home/$USERNAME/pinplay-drdebug-3.5-pin-3.5-97503-gac534ca30-gcc-linux/intel64/runtime/pincrt:$LD_LIBRARY_PATH
export DYNAMORIO_HOME=/home/$USERNAME/DynamoRIO-Linux-9.0.19314

cd /home/$USERNAME/scarab/src && make