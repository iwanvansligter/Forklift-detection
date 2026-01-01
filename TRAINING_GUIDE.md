# 🚜 Forklift Detection Model Training Guide

This guide explains how to train a custom YOLOv8 model to recognize forklifts and classify their load status (LOADED/UNLOADED).

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Dataset Preparation](#dataset-preparation)
3. [Image Annotation](#image-annotation)
4. [Training the Model](#training-the-model)
5. [Model Validation](#model-validation)
6. [Using the Trained Model](#using-the-trained-model)

---

## Prerequisites

### Required Software
- Python 3.8+ with virtual environment activated
- All dependencies from `requirements.txt` installed

### Hardware Recommendations
- **Minimum**: CPU training (slow but works)
- **Recommended**: NVIDIA GPU with CUDA support
  - 4GB+ VRAM for small models
  - 8GB+ VRAM for medium/large models

### Check GPU Availability
```bash
python -c "import torch; print(f'CUDA available: {torch.cuda.is_available()}')"
```

---

## Dataset Preparation

### 1. Directory Structure

Your dataset is already structured correctly:
```
dataset/forklift/
├── data.yaml              # Dataset configuration
├── images/
│   ├── train/            # Training images (70-80%)
│   ├── val/              # Validation images (10-20%)
│   └── test/             # Test images (10%)
└── labels/
    ├── train/            # Training annotations
    ├── val/              # Validation annotations
    └── test/             # Test annotations
```

### 2. Collect Images

You need images of:
- ✅ **Forklifts with loads** (pallets, boxes, materials)
- ✅ **Empty forklifts** (no load)

**Sources:**
- Record videos from your warehouse cameras
- Extract frames from existing footage
- Download from public datasets (Roboflow, Kaggle)
- Take photos with your phone/camera

**Recommended Dataset Size:**
- **Minimum**: 100 images per class (200 total)
- **Good**: 500 images per class (1000 total)
- **Excellent**: 1000+ images per class (2000+ total)

### 3. Split Your Data

Divide images into:
- **70-80%** → `images/train/`
- **10-20%** → `images/val/`
- **10%** → `images/test/` (optional)

**Example split for 1000 images:**
- 700 images → train
- 200 images → val
- 100 images → test

---

## Image Annotation

### What is Annotation?
For each forklift in your images, you need to:
1. Draw a bounding box around it
2. Label it as either:
   - **Class 0**: `forklift_loaded` (carrying a load)
   - **Class 1**: `forklift_unloaded` (empty)

### Annotation Tools

#### Option 1: Label Studio (Recommended - Free & Easy)
```bash
pip install label-studio
label-studio start
```
1. Open http://localhost:8080
2. Create new project → Object Detection
3. Upload images from `dataset/forklift/images/train/`
4. Add labels: `forklift_loaded`, `forklift_unloaded`
5. Draw boxes and label each forklift
6. Export as **YOLO format**

#### Option 2: Roboflow (Web-based - Free)
1. Go to https://roboflow.com
2. Create free account
3. Upload images
4. Annotate online
5. Export as **YOLOv8 format**

#### Option 3: LabelImg (Desktop - Free)
```bash
pip install labelImg
labelImg
```
- Set format to **YOLO**
- Annotate and save

### YOLO Label Format

For each image `forklift_001.jpg`, create `forklift_001.txt`:
```
<class_id> <x_center> <y_center> <width> <height>
```

**Example** (`labels/train/forklift_001.txt`):
```
0 0.5 0.4 0.3 0.6
```
- `0` = forklift_loaded
- `0.5` = center X (50% from left)
- `0.4` = center Y (40% from top)
- `0.3` = box width (30% of image)
- `0.6` = box height (60% of image)

**All values are normalized (0.0 to 1.0)**

### Quick Annotation Script

Extract frames from video and prepare for annotation:

```python
import cv2
from pathlib import Path

def extract_frames(video_path, output_dir, interval=30):
    """Extract frames from video every N frames"""
    cap = cv2.VideoCapture(video_path)
    output_dir = Path(output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)

    frame_count = 0
    saved_count = 0

    while True:
        ret, frame = cap.read()
        if not ret:
            break

        if frame_count % interval == 0:
            output_path = output_dir / f"frame_{saved_count:04d}.jpg"
            cv2.imwrite(str(output_path), frame)
            saved_count += 1

        frame_count += 1

    cap.release()
    print(f"Extracted {saved_count} frames from {frame_count} total frames")

# Usage
extract_frames("warehouse_video.mp4", "dataset/forklift/images/train", interval=30)
```

---

## Training the Model

### Basic Training

**CPU Training (Slow but works):**
```bash
python scripts/train_forklift_model.py --model n --epochs 100 --batch 8
```

**GPU Training (Recommended):**
```bash
python scripts/train_forklift_model.py --model n --epochs 100 --batch 16 --device cuda
```

### Training Parameters

| Parameter | Description | Recommended Values |
|-----------|-------------|-------------------|
| `--model` | Model size | `n` (fast), `s` (balanced), `m` (accurate) |
| `--epochs` | Training iterations | 100-300 |
| `--batch` | Batch size | 8-32 (depends on GPU) |
| `--img-size` | Image size | 640 (default) |
| `--device` | Hardware | `cpu` or `cuda` |

### Model Sizes

| Size | Speed | Accuracy | GPU Memory | Use Case |
|------|-------|----------|------------|----------|
| `n` (nano) | ⚡⚡⚡⚡⚡ | ⭐⭐⭐ | 2GB | Real-time on laptops |
| `s` (small) | ⚡⚡⚡⚡ | ⭐⭐⭐⭐ | 4GB | Balanced performance |
| `m` (medium) | ⚡⚡⚡ | ⭐⭐⭐⭐⭐ | 6GB | High accuracy |
| `l` (large) | ⚡⚡ | ⭐⭐⭐⭐⭐ | 8GB | Maximum accuracy |

### Training Examples

**Fast training for testing:**
```bash
python scripts/train_forklift_model.py --model n --epochs 50 --batch 16
```

**Production model (best accuracy):**
```bash
python scripts/train_forklift_model.py --model s --epochs 200 --batch 16 --device cuda
```

**Resume interrupted training:**
```bash
python scripts/train_forklift_model.py --resume
```

### Monitor Training

Training progress is saved in `runs/train/forklift_detector_*/`:
- `results.png` - Training curves
- `confusion_matrix.png` - Classification accuracy
- `val_batch0_pred.jpg` - Prediction examples
- `weights/best.pt` - Best model checkpoint
- `weights/last.pt` - Latest checkpoint

---

## Model Validation

### Validate Trained Model

```bash
python scripts/train_forklift_model.py --validate runs/train/forklift_detector_n/weights/best.pt
```

### Understanding Metrics

| Metric | What it Means | Good Value |
|--------|---------------|------------|
| **mAP50** | Detection accuracy at 50% overlap | > 0.85 |
| **mAP50-95** | Overall detection accuracy | > 0.70 |
| **Precision** | How many detections are correct | > 0.80 |
| **Recall** | How many forklifts are found | > 0.80 |

### Test on Single Image

```python
from ultralytics import YOLO

# Load your trained model
model = YOLO('runs/train/forklift_detector_n/weights/best.pt')

# Test on image
results = model('test_image.jpg', conf=0.5)

# Show results
results[0].show()

# Get predictions
for box in results[0].boxes:
    class_id = int(box.cls)
    confidence = float(box.conf)
    class_name = model.names[class_id]
    print(f"Detected: {class_name} ({confidence:.2f})")
```

---

## Using the Trained Model

### 1. Copy Model to Project

```bash
# Copy best model
cp runs/train/forklift_detector_n/weights/best.pt models/forklift_detector_custom.pt
```

### 2. Update Detection Script

Create `scripts/test_custom_model.py`:

```python
from ultralytics import YOLO
import cv2

# Load your custom trained model
model = YOLO('models/forklift_detector_custom.pt')

# Open camera
cap = cv2.VideoCapture(0)

while True:
    ret, frame = cap.read()
    if not ret:
        break

    # Run inference
    results = model(frame, conf=0.5)

    # Draw results
    annotated = results[0].plot()

    # Display
    cv2.imshow('Forklift Detection', annotated)

    if cv2.waitKey(1) & 0xFF == ord('q'):
        break

cap.release()
cv2.destroyAllWindows()
```

### 3. Update API to Use Custom Model

Edit `app/backend/api/main.py`:

```python
# Change from:
model = YOLO('models/forklift_detector_v1.pt')

# To:
model = YOLO('models/forklift_detector_custom.pt')
```

### 4. Run Detection

```bash
python scripts/test_custom_model.py
```

---

## Tips for Better Results

### 📸 Data Collection
- ✅ Vary lighting conditions (day/night, indoor/outdoor)
- ✅ Different angles and distances
- ✅ Various forklift models and colors
- ✅ Different load types (pallets, boxes, drums)
- ✅ Cluttered backgrounds (realistic warehouse)

### 🏷️ Annotation Quality
- ✅ Tight bounding boxes (no extra space)
- ✅ Include partially visible forklifts
- ✅ Consistent labeling (loaded = has pallet/load)
- ✅ Label all forklifts in each image

### 🚀 Training Tips
- ✅ Start with pretrained weights (transfer learning)
- ✅ Use data augmentation (already enabled in script)
- ✅ Train longer if accuracy is low (200-300 epochs)
- ✅ Use early stopping (automatic in script)
- ✅ Monitor training curves in TensorBoard

### ⚡ Performance Optimization
- ✅ Use smaller model (nano/small) for real-time
- ✅ Use larger model (medium/large) for accuracy
- ✅ Lower confidence threshold to catch more forklifts
- ✅ Raise confidence threshold to reduce false positives

---

## Troubleshooting

### Problem: "No training images found"
**Solution:** Add images to `dataset/forklift/images/train/`

### Problem: "No labels found"
**Solution:** Add corresponding `.txt` files to `dataset/forklift/labels/train/`

### Problem: Training is very slow
**Solutions:**
- Use smaller batch size (`--batch 4` or `--batch 8`)
- Use smaller model (`--model n`)
- Enable GPU training (`--device cuda`)

### Problem: Low accuracy (mAP < 0.5)
**Solutions:**
- Add more training data
- Train longer (`--epochs 200`)
- Use larger model (`--model s` or `--model m`)
- Check annotation quality

### Problem: Out of memory error
**Solutions:**
- Reduce batch size (`--batch 4`)
- Reduce image size (`--img-size 416`)
- Use smaller model (`--model n`)

---

## Next Steps

1. **Collect 200+ images** of loaded and unloaded forklifts
2. **Annotate them** using Label Studio or Roboflow
3. **Train the model** with `python scripts/train_forklift_model.py`
4. **Validate results** and check metrics
5. **Deploy to your system** by updating the model path

---

## Example Dataset Resources

### Public Datasets
- **Roboflow Universe**: Search for "forklift" datasets
- **Kaggle**: Industrial vehicle datasets
- **Google Open Images**: Search "forklift"

### Create Your Own
1. Record 10-20 minutes of warehouse footage
2. Extract 1 frame every second → 600-1200 images
3. Annotate 200-400 best quality images
4. Train and iterate

---

## Questions?

Check the training logs in `runs/train/` for detailed metrics and visualizations.

Good luck with training! 🚀
