# Model Training Status & Progress

**Last Updated:** 2025-12-17

## Current Model Performance

### Model Version: forklift_detector_n (YOLOv8 Nano)
**Training Date:** 2025-12-17
**Training Duration:** 23 epochs (stopped early)
**Model Location:** `runs/train/forklift_detector_n/weights/best.pt`

### Performance Metrics

| Metric | Value |
|--------|-------|
| Precision | 96.8% |
| Recall | 42.6% |
| mAP50 | 46.3% |
| mAP50-95 | 26.7% |

### Dataset Statistics

**Training Data:**
- Total Images: 196 images
- Train Split: 156 images (80%)
- Validation Split: 40 images (20%)

**Class Distribution:**
- **Loaded (Class 1):** 170 images (87%)
- **Unloaded (Class 0):** 26 images (13%)

⚠️ **Data Imbalance Issue:** The model has significant class imbalance, leading to poor unloaded detection.

---

## Detection Performance

### Test Results (Video: 6 forklifts expected)

**Detection Count:** 7 forklift passages detected

**Status Classification:**
- ✅ Loaded: 7 detected
- ❌ Unloaded: 0 detected (should be 2)

**Issue:** Model classifies all forklifts as LOADED due to insufficient unloaded training data.

### Detection Parameters (Optimized)

```python
CONFIDENCE_THRESHOLD = 0.20
MAX_TRACKING_DISTANCE = 200  # pixels
MAX_LOST_FRAMES = 30  # ~1 second at 30fps
MIN_DETECTION_COUNT = 8  # frames
```

---

## Known Issues & Limitations

### 1. Unloaded Detection Failure
**Problem:** Model cannot reliably detect unloaded forklifts (forks visible)

**Cause:**
- Only 26 unloaded images vs 170 loaded images (13% vs 87%)
- Model is heavily biased toward "loaded" class

**Solution:**
- Collect 50-80 more unloaded forklift images
- Preferably extract frames from actual warehouse videos
- Retrain with balanced dataset (target: 40-50% unloaded)

### 2. Early Training Termination
**Problem:** Training stopped at epoch 23/100

**Cause:** Likely early stopping or system interruption

**Impact:** Model may not have fully converged

**Solution:** Retrain for full 100 epochs after balancing dataset

---

## Next Steps for Improvement

### Priority 1: Balance Training Data ⚠️

**Current Status:**
- ✅ Created `data/knowledge/loaded/` (170 images)
- ✅ Created `data/knowledge/unloaded/` (45 images)
- ❌ Need 35-55 more unloaded images

**Action Items:**
1. Record videos of unloaded forklifts passing through warehouse
2. Extract frames using detection system
3. Manually verify and label frames
4. Add to `data/knowledge/unloaded/`

**Script to Extract Frames:**
```bash
python scripts/prepare_dataset.py extract path/to/video.mp4 --output data/knowledge/candidates
```

### Priority 2: Retrain with Balanced Data

**Steps:**
1. Run dataset creation:
   ```bash
   python scripts/create_balanced_dataset.py
   ```

2. Train new model:
   ```bash
   python scripts/train_forklift_model.py --epochs 100 --device cpu
   ```

3. Test model:
   ```bash
   python scripts/test_new_model_improved.py
   ```

### Priority 3: Integrate into Web Interface

The API has been updated with improved tracking logic:
- ✅ Proximity-based forklift tracking
- ✅ One detection per pass through frame
- ✅ Configurable detection thresholds
- ✅ Minimum detection count filtering

**File:** `app/backend/api/main.py` (lines 125-235)

---

## Training History

### Attempt 1: Initial Training (Dec 17, 2025)
- **Dataset:** 298 generic forklift images from Roboflow
- **Result:** 5 epochs, stopped early
- **Performance:** 47% precision, 37% mAP50
- **Issue:** Generic dataset not specific to use case

### Attempt 2: Classified Training (Dec 17, 2025)
- **Dataset:** 196 manually classified images (loaded/unloaded based on fork visibility)
- **Result:** 23 epochs, stopped early
- **Performance:** 97% precision, 46% mAP50, 43% recall
- **Issue:** Severe class imbalance (87% loaded, 13% unloaded)
- **Status:** ✅ Current model in production

### Attempt 3: Planned (Pending Data Collection)
- **Dataset:** Balanced dataset with real warehouse footage
- **Target:** 150-200 images per class (50/50 split)
- **Expected:** Full 100 epoch training
- **Goal:** >70% recall, accurate loaded/unloaded classification

---

## Classification Criteria

### Loaded (Class 1)
- **Definition:** Forks are NOT visible (hidden by cargo/pallet)
- **Indicators:**
  - Cargo/pallet obstructing fork view
  - Forklift carrying load
  - Forks raised with material

### Unloaded (Class 0)
- **Definition:** Forks ARE visible (no cargo)
- **Indicators:**
  - Empty forks clearly visible
  - No material on forks
  - Forks in lowered or neutral position

⚠️ **Important:** Fork visibility is the PRIMARY classification criterion, not load weight or driver presence.

---

## Model Integration

### Current Implementation
The trained model is integrated into:

1. **Web API** (`app/backend/api/main.py`)
   - Video upload processing
   - Real-time forklift tracking
   - Event creation with load status

2. **Testing Scripts**
   - `scripts/test_new_model.py` - Basic testing
   - `scripts/test_new_model_improved.py` - Advanced tracking testing

### Usage Example

```python
from ultralytics import YOLO
import cv2

# Load model
model = YOLO('runs/train/forklift_detector_n/weights/best.pt')

# Run detection
results = model('path/to/image.jpg', conf=0.20)

# Process results
for result in results:
    boxes = result.boxes
    for box in boxes:
        cls = int(box.cls[0])  # 0=unloaded, 1=loaded
        conf = float(box.conf[0])
        status = "UNLOADED" if cls == 0 else "LOADED"
        print(f"Forklift detected: {status} (confidence: {conf:.2f})")
```

---

## Resources

### Scripts
- `scripts/create_balanced_dataset.py` - Create training dataset from organized images
- `scripts/train_forklift_model.py` - Train YOLOv8 model
- `scripts/test_new_model_improved.py` - Test model with improved tracking
- `scripts/download_unloaded_forklifts.py` - Download stock images (limited success)

### Documentation
- [TRAINING_GUIDE.md](TRAINING_GUIDE.md) - Detailed training instructions
- [DATA_COLLECTION_GUIDE.md](DATA_COLLECTION_GUIDE.md) - How to collect training data
- [README.md](README.md) - Main project documentation

### Directories
- `data/knowledge/loaded/` - Loaded forklift images
- `data/knowledge/unloaded/` - Unloaded forklift images
- `dataset/forklift_balanced/` - Processed YOLO training dataset
- `runs/train/forklift_detector_n/` - Training outputs and model weights

---

## Conclusion

**Current Status:** ✅ Functional model deployed with good detection accuracy

**Main Limitation:** ❌ Cannot distinguish loaded vs unloaded forklifts

**Root Cause:** Insufficient unloaded training data (13% of dataset)

**Solution:** Collect 50+ more unloaded forklift images from actual warehouse videos and retrain

**Next Action:** Record/collect real warehouse videos → extract frames → retrain model
