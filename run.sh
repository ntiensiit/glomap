#!/bin/bash
set -e

DATASET_NAME="${1:-south-building}"
DATASETS_DIR="/workspace/datasets/glomap"
OUTPUTS_DIR="/workspace/outputs/glomap"
DATASET_PATH="$DATASETS_DIR/$DATASET_NAME"
OUTPUT_PATH="$OUTPUTS_DIR/$DATASET_NAME"
COLMAP_RELEASE="3.11.1"
DATASET_URL="https://github.com/colmap/colmap/releases/download/${COLMAP_RELEASE}/${DATASET_NAME}.zip"

mkdir -p "$DATASETS_DIR" "$OUTPUTS_DIR"

if ! command -v glomap >/dev/null 2>&1; then
    echo "ERROR: glomap not found in PATH"
    echo "Verify ninja install completed successfully"
    exit 1
fi

if [ ! -f "$DATASET_PATH/database.db" ]; then
    echo "Downloading $DATASET_NAME dataset..."
    DATASET_ZIP="$DATASETS_DIR/$DATASET_NAME.zip"
    if ! wget -O "$DATASET_ZIP" "$DATASET_URL"; then
        echo "ERROR: Failed to download dataset from $DATASET_URL"
        exit 1
    fi
    if ! unzip -q "$DATASET_ZIP" -d "$DATASETS_DIR"; then
        echo "ERROR: Dataset extraction failed"
        rm -f "$DATASET_ZIP"
        exit 1
    fi
    rm -f "$DATASET_ZIP"
    echo "Dataset downloaded to $DATASET_PATH"
fi

if [ ! -d "$DATASET_PATH/images" ]; then
    echo "ERROR: images directory not found in $DATASET_PATH"
    exit 1
fi

if [ ! -f "$DATASET_PATH/database.db" ]; then
    echo "ERROR: database.db not found in $DATASET_PATH"
    exit 1
fi

mkdir -p "$OUTPUT_PATH"

echo "Running glomap mapper for $DATASET_NAME..."
glomap mapper \
    --database_path "$DATASET_PATH/database.db" \
    --image_path "$DATASET_PATH/images" \
    --output_path "$OUTPUT_PATH"

for output_file in cameras.bin images.bin points3D.bin; do
    if [ ! -f "$OUTPUT_PATH/$output_file" ]; then
        echo "ERROR: Reconstruction failed - $output_file not generated"
        exit 1
    fi
done

echo "Mapper completed successfully"
echo "Sparse reconstruction saved to $OUTPUT_PATH"
