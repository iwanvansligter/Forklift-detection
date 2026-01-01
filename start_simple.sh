#!/bin/bash
# Simple startup script for quick testing with laptop camera

set -e  # Exit on error

echo "======================================================"
echo "  Forklift Detection System - Simple Startup"
echo "======================================================"
echo ""

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Check if model exists
if [ ! -f "models/forklift_detector_v1.pt" ]; then
    echo ""
    echo "Model not found! Downloading YOLOv8 nano model..."
    mkdir -p models

    # Try wget first, fallback to curl
    if command -v wget &> /dev/null; then
        wget -q --show-progress \
            https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
            -O models/forklift_detector_v1.pt
    elif command -v curl &> /dev/null; then
        curl -L --progress-bar \
            https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
            -o models/forklift_detector_v1.pt
    else
        echo "Error: Neither wget nor curl found. Please download model manually."
        echo "URL: https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt"
        echo "Save to: models/forklift_detector_v1.pt"
        exit 1
    fi

    echo "✓ Model downloaded successfully"
fi

echo ""
echo "======================================================"
echo "  Starting Simple Detection Test"
echo "======================================================"
echo ""
echo "This will:"
echo "  1. Open your laptop camera"
echo "  2. Run forklift detection"
echo "  3. Display video with bounding boxes"
echo ""
echo "Press 'q' to quit, 's' to save screenshot"
echo ""
echo "Starting in 3 seconds..."
sleep 3

# Run simple detection test
python scripts/test_detection_laptop.py

echo ""
echo "Test completed. Thank you!"
