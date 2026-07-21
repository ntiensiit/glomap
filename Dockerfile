FROM runpod/pytorch:2.1.0-py3.10-cuda11.8.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
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
RUN git clone --depth 1 https://github.com/colmap/glomap.git

WORKDIR /workspace/glomap
RUN mkdir build && \
    cd build && \
    /usr/local/bin/cmake .. -GNinja && \
    ninja && \
    ninja install

COPY run.sh /workspace/run.sh
RUN chmod +x /workspace/run.sh

WORKDIR /workspace

ENTRYPOINT ["/workspace/run.sh"]
CMD ["south-building"]
