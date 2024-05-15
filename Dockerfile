FROM ubuntu:20.04	

ARG USERNAME=username

# Install required packages
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    python3 \
    python3-pip \
    python2 \
    git \
    sudo \
    wget \
    cmake \
    binutils \
    libunwind-dev \
    libboost-dev \
    zlib1g-dev \
    libsnappy-dev \
    liblz4-dev \
    g++-9 \
    #g++-9-multilib \
    doxygen \
    libconfig++-dev \
    libboost-dev \
    vim \
    bc \
    unzip

RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 1

RUN pip3 install gdown

# Needed for the plots
RUN pip3 install matplotlib

RUN apt-get update -qq \
    && apt-get install -y --no-install-recommends \
    sudo \
    gosu
#  \
# && rm -rf /var/lib/apt/lists/* \

# Create a new user '$USERNAME' with password '$USERNAME'
RUN useradd --create-home --home-dir /home/$USERNAME --shell /bin/bash --user-group --groups adm,sudo $USERNAME && \
    echo "$USERNAME:$USERNAME" | chpasswd 

# Set the working directory
WORKDIR /home/$USERNAME

##############################
# Dynamorio & Scarab
##############################

# Set environment variables for the setup
ENV PROJECT_DIR=/home/$USERNAME/Project
ENV RESOURCES_DIR=$PROJECT_DIR/resources
ENV DYNAMORIO_HOME=$RESOURCES_DIR/DynamoRIO-Linux-9.0.19314
ENV PIN_ROOT=$RESOURCES_DIR/pin-3.15-98253-gb56e429b1-gcc-linux
ENV SCARAB_ENABLE_PT_MEMTRACE=1
ENV SCARAB_ENABLE_MEMTRACE=1
ENV LD_LIBRARY_PATH=$RESOURCES_DIR/pin-3.15-98253-gb56e429b1-gcc-linux/extras/xed-intel64/lib:$RESOURCES_DIR/pin-3.15-98253-gb56e429b1-gcc-linux/intel64/runtime/pincrt:$LD_LIBRARY_PATH

# Setup the main directory and clone necessary repositories
RUN mkdir -p $RESOURCES_DIR && \
    cd $RESOURCES_DIR && \
    git clone https://github.com/Litz-Lab/scarab.git && \
    pip3 install -r $RESOURCES_DIR/scarab/bin/requirements.txt

# Download and extract DynamoRIO
RUN cd $RESOURCES_DIR && \
    wget https://github.com/DynamoRIO/dynamorio/releases/download/cronbuild-9.0.19314/DynamoRIO-Linux-9.0.19314.tar.gz && \
    tar -xzvf DynamoRIO-Linux-9.0.19314.tar.gz && \
    rm DynamoRIO-Linux-9.0.19314.tar.gz

# Download and extract PinPlay
RUN cd $RESOURCES_DIR && \
    gdown 'https://drive.google.com/uc?export=download&id=1KRrs0CfR67UGa_IcGDTzaL5zFBMds0ZS' -O pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz && \
    tar -xzvf pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz && \
    rm pin-3.15-98253-gb56e429b1-gcc-linux.tar.gz

# # Compile Scarab
RUN cd $RESOURCES_DIR/scarab/src && make

# change to g++-11
# Install GCC 11 and G++ 11
RUN apt-get install -y gcc-11 g++-11

# Set up update-alternatives to configure gcc and g++ commands
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 2 \
 && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 2

# Optionally set GCC 11 and G++ 11 as the default compilers
RUN update-alternatives --set gcc /usr/bin/gcc-11 \
 && update-alternatives --set g++ /usr/bin/g++-11

########################
##### SETUP LIBMPC #####
########################

##############################
# Core tools
##############################

# Install programs as 'root' user.
user root
RUN apt install  -y -qq --no-install-recommends build-essential manpages-dev software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test && \
    apt-get update -y -qq &&\
    apt-get install -y -qq --no-install-recommends \
    apt-utils \
    lsb-release \
    build-essential \
    software-properties-common \
    ca-certificates \
    gpg-agent \
    wget \
    git \
    cmake \
    lcov \
    gcc-11 \
    g++-11 \
    # clang \
    # clang-tidy \
    # clang-format \
    libomp-dev \
    sudo \
    gosu \
    libsfml-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

##############################
# Non-root user Setup
##############################
RUN echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL >> /etc/sudoers \
    && touch /home/$USERNAME/.sudo_as_admin_successful \
    && gosu $USERNAME mkdir -p /home/$USERNAME/.xdg_runtime_dir
ENV XDG_RUNTIME_DIR=/home/$USERNAME/.xdg_runtime_dir

##############################
# libMPC++
##############################
# Downloads and unzips lipmpc into the home directory.
USER $USERNAME
RUN cd ~ && wget https://github.com/nicolapiccinelli/libmpc/archive/refs/tags/0.4.0.tar.gz \
    && tar -xzvf 0.4.0.tar.gz \
    && rm 0.4.0.tar.gz

USER root

##############################
# Eigen
##############################
RUN apt-get update -y -qq \
    && apt-get install -y -qq --no-install-recommends \
    libeigen3-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


##############################
# NL Optimization
##############################
RUN git clone https://github.com/stevengj/nlopt /tmp/nlopt \
    && cd /tmp/nlopt \
    && mkdir build \
    && cd build \
    && cmake \
    -D CMAKE_BUILD_TYPE=Release \
    -D NLOPT_PYTHON=OFF \
    -D NLOPT_OCTAVE=OFF \
    -D NLOPT_MATLAB=OFF \
    -D NLOPT_GUILE=OFF \
    -D NLOPT_SWIG=OFF \
    .. \
    && make -j$(($(nproc)-1)) \
    && make install \
    && rm -rf /tmp/*


##############################
# OSQP Solver
##############################
RUN git clone --depth 1 --branch v0.6.3 --recursive https://github.com/osqp/osqp /tmp/osqp \
    && cd /tmp/osqp \
    && mkdir build \
    && cd build \
    && cmake \
    -G "Unix Makefiles" \
    .. \
    && make -j$(($(nproc)-1)) \
    && make install \
    && rm -rf /tmp/*


##############################
# Catch2
##############################
RUN git clone https://github.com/catchorg/Catch2.git /tmp/Catch2 \
    && cd /tmp/Catch2 \
    && mkdir build \
    && cd build \
    && cmake \
    -D BUILD_TESTING=OFF \
    .. \
    && make -j$(($(nproc)-1)) \
    && make install \
    && rm -rf /tmp/*

# Update the linker to recognize recently added libraries. 
# See: https://stackoverflow.com/questions/480764/linux-error-while-loading-shared-libraries-cannot-open-shared-object-file-no-s
RUN ldconfig

##############################
# Controller Files
##############################

# Additional setup can be uncommented and customized as needed
ENV MAIN_DIR=$PROJECT_DIR/Inverted-Pendulum
RUN cd $PROJECT_DIR && git clone https://github.com/YasinSonmez/Inverted-Pendulum.git
RUN cd $MAIN_DIR && git clone https://github.com/YasinSonmez/Scarab-Trace-and-Simulate-Script.git
RUN cd $MAIN_DIR && mkdir build && cd build && cmake -DDynamoRIO_DIR=$DYNAMORIO_HOME/cmake .. && make
RUN cd $RESOURCES_DIR && wget https://github.com/nicolapiccinelli/libmpc/archive/refs/tags/0.4.2.tar.gz && tar -xzvf 0.4.2.tar.gz && rm 0.4.2.tar.gz
RUN cd $RESOURCES_DIR/libmpc-0.4.2 && sudo ./configure.sh --disable-test && mkdir build && cd build && cmake .. && make && sudo make install