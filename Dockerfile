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

# # Authorize SSH Host
# RUN mkdir -p /home/$USERNAME/.ssh && \
#     chown -R $USERNAME:root /home/$USERNAME/.ssh && \
#     chmod 700 /home/$USERNAME/.ssh

# COPY id_rsa /home/$USERNAME/.ssh/id_rsa

# # Add the key and set permission
# # RUN echo "$ssh_prv_key" > /home/$USERNAME/.ssh/id_rsa && \
# RUN chown -R $USERNAME:root /home/$USERNAME/.ssh/id_rsa && \
#     chmod 700 /home/$USERNAME/.ssh/id_rsa
# RUN touch /home/$USERNAME/.ssh/known_hosts && \
#     chown -R $USERNAME:root /home/$USERNAME/.ssh/known_hosts && \
#     chmod 700 /home/$USERNAME/.ssh/known_hosts
# RUN ssh-keyscan github.com >> /home/$USERNAME/.ssh/known_hosts

# Set the working directory
WORKDIR /home/$USERNAME

# Switch to the $USERNAME user
USER $USERNAME

# # DynamoRIO build from source
# RUN git clone --recursive https://github.com/DynamoRIO/dynamorio.git && cd dynamorio && git reset --hard release_10.0.0 && mkdir build && cd build && cmake .. && make -j 40

# Download DynamoRIO release tarball and extract
# ADD https://github.com/DynamoRIO/dynamorio/releases/download/cronbuild-9.0.19314/DynamoRIO-Linux-9.0.19314.tar.gz /home/$USERNAME
# RUN cd /home/$USERNAME && tar -xzvf DynamoRIO-Linux-9.0.19314.tar.gz

# # Optional: Clean up tarball after extraction
# RUN cd /home/$USERNAME && rm DynamoRIO-Linux-9.0.19314.tar.gz

# RUN cd ~ && wget https://github.com/DynamoRIO/dynamorio/releases/download/cronbuild-9.0.19314/DynamoRIO-Linux-9.0.19314.tar.gz \
#     && tar -xzvf DynamoRIO-Linux-9.0.19314.tar.gz \
#     && rm DynamoRIO-Linux-9.0.19314.tar.gz

# USER root

# ENV DYNAMORIO_HOME=/home/$USERNAME/DynamoRIO-Linux-9.0.19314


# # Build DynamoRIO package for fingerprint client
# RUN mkdir /home/$USERNAME/dynamorio/package && \
#     cd /home/$USERNAME/dynamorio/package && \
#     ctest -V -S ../make/package.cmake,build=1\;no32
# ENV DYNAMORIO_HOME=/home/$USERNAME/dynamorio/package/build_release-64/

# # Build fingerprint client
# COPY --chown=$USERNAME fingerprint_src /home/$USERNAME/fingerprint_src/
# RUN mkdir /home/$USERNAME/fingerprint_src/build && \
#     cd /home/$USERNAME/fingerprint_src/build && \
#     cmake -DDynamoRIO_DIR=$DYNAMORIO_HOME/cmake .. && \
#     make && \
#     cp ./libfpg.so /home/$USERNAME/libfpg.so

# # Copy workflow simpoint/no_simpoint script
# COPY --chown=$USERNAME utilities.sh /home/$USERNAME/utilities.sh
# COPY --chown=$USERNAME run_clustering.sh /home/$USERNAME/run_clustering.sh
# COPY --chown=$USERNAME run_trace_post_processing.sh /home/$USERNAME/run_trace_post_processing.sh

# COPY --chown=$USERNAME run_simpoint_trace.sh /home/$USERNAME/run_simpoint_trace.sh
# COPY --chown=$USERNAME run_scarab.sh /home/$USERNAME/run_scarab.sh
# COPY --chown=$USERNAME gather_fp_pieces.py /home/$USERNAME/gather_fp_pieces.py

# COPY --chown=$USERNAME run_scarab_mode_4.sh /home/$USERNAME/run_scarab_mode_4.sh
# COPY --chown=$USERNAME gather_cluster_results.py /home/$USERNAME/gather_cluster_results.py

# Clone the Scarab repository
# Comment out if you don't use scarab at all and don't have ssh key permitted to clone 'scarab_hlitz'
# RUN cd /home/$USERNAME && git clone -b decoupled_fe git@github.com:hlitz/scarab_hlitz.git scarab
# #  RUN cd /home/$USERNAME && https://github.com/kofyou/scarab.git scarab
# RUN cd /home/$USERNAME && git clone https://github.com/kofyou/scarab.git


# # # Install Scarab dependencies
# RUN pip3 install -r /home/$USERNAME/scarab/bin/requirements.txt
# RUN gdown 'https://drive.google.com/uc?id=1xD4zEEgg05CQEI9e5CQO4F5rRfJdfLZV' -O pinplay35.zip
# RUN unzip pinplay35.zip
# RUN rm pinplay35.zip

# # Build Scarab
# ENV PIN_ROOT /home/$USERNAME/pinplay-drdebug-3.5-pin-3.5-97503-gac534ca30-gcc-linux
# ENV SCARAB_ENABLE_PT_MEMTRACE 1
# ENV SCARAB_ENABLE_MEMTRACE 1
# ENV LD_LIBRARY_PATH /home/$USERNAME/pinplay-drdebug-3.5-pin-3.5-97503-gac534ca30-gcc-linux/extras/xed-intel64/lib
# ENV LD_LIBRARY_PATH /home/$USERNAME/pinplay-drdebug-3.5-pin-3.5-97503-gac534ca30-gcc-linux/intel64/runtime/pincrt:$LD_LIBRARY_PATH

# # # The root of the Scarab repository, as used by scarab_paths.py (found in scarab/bin/scarab_globals) 
# # ENV SIMDIR /home/$USERNAME/scarab

# RUN cd /home/$USERNAME/scarab/src && make
# RUN mkdir /home/$USERNAME/exp
# RUN mkdir -p /home/$USERNAME/traces

# # # Build SimPoint 3.2
# # # Reference:
# # # https://github.com/intel/pinplay-tools/blob/main/pinplay-scripts/PinPointsHome/Linux/bin/Makefile
# # RUN cd /home/$USERNAME/ && \
# #     wget -O - http://cseweb.ucsd.edu/~calder/simpoint/releases/SimPoint.3.2.tar.gz | tar -x -f - -z && \
# #     wget https://raw.githubusercontent.com/intel/pinplay-tools/main/pinplay-scripts/PinPointsHome/Linux/bin/simpoint_modern_gcc.patch -P SimPoint.3.2/ && \
# #     patch --directory=SimPoint.3.2 --strip=1 < SimPoint.3.2/simpoint_modern_gcc.patch && \
# #     make -C SimPoint.3.2 && \
# #     ln -s SimPoint.3.2/bin/simpoint ./simpoint

# ENV DOCKER_BUILDKIT 1
# ENV COMPOSE_DOCKER_CLI_BUILD 1

# Security issue! Do not comment out unless you want to expose your private key on the Docker image.
# RUN rm /home/$USERNAME/.ssh/id_rsa && rm /home/$USERNAME/.ssh/known_hosts


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

# RUN 
#     apt update \ 
#     && sudo apt install -y -qq --no-install-recommends gcc-11 g++-11

##############################
# Non-root user Setup
##############################
RUN echo $USERNAME ALL=\(ALL\) NOPASSWD:ALL >> /etc/sudoers \
    && touch /home/$USERNAME/.sudo_as_admin_successful \
    && gosu $USERNAME mkdir -p /home/$USERNAME/.xdg_runtime_dir
ENV XDG_RUNTIME_DIR=/home/$USERNAME/.xdg_runtime_dir

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

# # (Optional) Set Clang as the default compiler
# ENV CC=/usr/bin/clang
# ENV CXX=/usr/bin/clang++

# Update the linker to recognize recently added libraries. 
# See: https://stackoverflow.com/questions/480764/linux-error-while-loading-shared-libraries-cannot-open-shared-object-file-no-s
RUN ldconfig

# USER $USERNAME

# COPY --chown=$USERNAME docker_user_home/.bashrc /home/$USERNAME/.bashrc

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