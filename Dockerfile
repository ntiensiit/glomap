FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

RUN apt-get update && apt-get install -y \
    build-essential \
    pkg-config \
    ninja-build \
    git \
    wget \
    unzip \
    tree \
    libboost-program-options-dev \
    libboost-graph-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libeigen3-dev \
    libgoogle-glog-dev \
    libgflags-dev \
    libsqlite3-dev \
    libglew-dev \
    libfreeimage-dev \
    libmetis-dev \
    libceres-dev \
    libcgal-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /tmp
RUN wget https://github.com/Kitware/CMake/releases/download/v3.30.9/cmake-3.30.9-linux-x86_64.sh \
    && chmod +x cmake-3.30.9-linux-x86_64.sh \
    && ./cmake-3.30.9-linux-x86_64.sh --skip-license --prefix=/usr/local \
    && rm cmake-3.30.9-linux-x86_64.sh

WORKDIR /workspace
RUN git clone https://github.com/colmap/glomap.git
WORKDIR /workspace/glomap
RUN mkdir build && cd build && /usr/local/bin/cmake .. -GNinja && ninja

WORKDIR /workspace
RUN mkdir -p /glomap/datasets/south-building
WORKDIR /workspace/glomap/datasets/south-building
RUN wget -O south-building.zip https://github.com/colmap/colmap/releases/download/3.11.1/south-building.zip
RUN unzip south-building.zip
RUN mkdir -p glomap_sparse

WORKDIR /workspace/glomap/build
RUN ./glomap/glomap mapper \
    --database_path /workspace/glomap/datasets/south-building/database.db \
    --image_path /workspace/glomap/datasets/south-building/images \
    --output_path /workspace/glomap/datasets/south-building/glomap_sparse

WORKDIR /workspace/glomap/build

CMD ["/bin/bash"]
