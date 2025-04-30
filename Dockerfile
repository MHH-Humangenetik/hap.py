FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# Update Ubuntu repositories and install basic dependencies, including software-properties-common for add-apt-repository
RUN apt-get update --fix-missing && \
    apt-get install -y \
        software-properties-common \
        autoconf \
        build-essential \
        bzip2 \
        cmake \
        cython \
        git \
        libbz2-dev \
        libncurses5-dev \
        pkg-config \
        wget \
        zlib1g-dev

# Add deadsnakes PPA for legacy Python versions
RUN add-apt-repository ppa:deadsnakes/ppa -y && \
    apt-get update --fix-missing

# Install Python 2.7 and its dependencies
RUN apt-get install -y \
    python2.7 \
    python2.7-dev \
    python-setuptools \
    python-psutil \
    python-numpy \
    python-pysam

# Install pip for Python 2 using get-pip.py
RUN wget https://bootstrap.pypa.io/pip/2.7/get-pip.py && \
    python2 get-pip.py && \
    rm get-pip.py

# Use pip2 to install Python 2 packages
RUN pip2 install pandas==0.24.2 scipy bx-python

# Download and install hap.py
WORKDIR /opt
RUN wget https://github.com/Illumina/hap.py/archive/refs/tags/v0.3.14.tar.gz && \
    tar -xvzf v0.3.14.tar.gz && \
    mv hap.py-0.3.14 hap.py-0.3.14-src && \
    mkdir -p hap.py-0.3.14
WORKDIR /opt/hap.py-0.3.14
RUN python2 install.py /opt/hap.py-0.3.14 --no-tests && \
    cd .. && \
    rm -rf v0.3.14.tar.gz hap.py-0.3.14-src

# Cleanup build dependencies
RUN apt-get remove -y \
    wget \
	software-properties-common \
	zlib1g-dev \
    git \
    build-essential \
    bzip2 \
    autoconf \
    cmake \
    cython \
    libbz2-dev \
    libncurses5-dev \
	pkg-config && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
