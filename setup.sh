#!/bin/bash
set -e

DATASETS_DIR="./datasets"
OUTPUTS_DIR="./outputs"
DATASET_NAME="south-building"
DATASET_PATH="$DATASETS_DIR/$DATASET_NAME"
OUTPUT_PATH="$OUTPUTS_DIR/$DATASET_NAME"
COLMAP_RELEASE="3.11.1"
DATASET_URL="https://github.com/colmap/colmap/releases/download/${COLMAP_RELEASE}/${DATASET_NAME}.zip"

apt-get update && apt-get install -y --no-install-recommends \
    build-essential pkg-config ninja-build git wget unzip tree \
    libboost-program-options-dev libboost-graph-dev libboost-system-dev \
    libboost-filesystem-dev libeigen3-dev libgoogle-glog-dev libgflags-dev \
    libsqlite3-dev libglew-dev libfreeimage-dev libmetis-dev libceres-dev libcgal-dev

cd /tmp && wget https://github.com/Kitware/CMake/releases/download/v3.30.9/cmake-3.30.9-linux-x86_64.sh && \
    chmod +x cmake-3.30.9-linux-x86_64.sh && \
    ./cmake-3.30.9-linux-x86_64.sh --skip-license --prefix=/usr/local && \
    rm cmake-3.30.9-linux-x86_64.sh

cd - && mkdir -p build && cd build && \
    /usr/local/bin/cmake .. -GNinja && ninja && ninja install

cd ..

mkdir -p "$DATASETS_DIR" "$OUTPUTS_DIR"

if [ ! -f "$DATASET_PATH/database.db" ]; then
    DATASET_ZIP="$DATASETS_DIR/$DATASET_NAME.zip"
    wget -O "$DATASET_ZIP" "$DATASET_URL" && \
    unzip -q "$DATASET_ZIP" -d "$DATASETS_DIR" && \
    rm -f "$DATASET_ZIP"
fi

mkdir -p "$OUTPUT_PATH"
glomap mapper --database_path "$DATASET_PATH/database.db" \
    --image_path "$DATASET_PATH/images" --output_path "$OUTPUT_PATH"

for f in cameras.bin images.bin points3D.bin; do
    [ ! -f "$OUTPUT_PATH/0/$f" ] && echo "ERROR: $f not generated" && exit 1
done
