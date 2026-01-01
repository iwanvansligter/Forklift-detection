# Quick Start Guide - Improving Unloaded Detection

**Goal:** Collect real warehouse video data to improve unloaded forklift detection

---

## Current Situation

✅ **What Works:**
- Forklift detection (96.8% precision)
- Counting individual forklifts (7 detected in test video)
- Web interface for video upload

❌ **What Needs Improvement:**
- Unloaded classification (currently detects everything as LOADED)
- Only 45 unloaded training images vs 170 loaded (21% vs 79%)

---

## Step-by-Step: Collect Training Data

### 1. Record Videos (5-10 minutes)

**What to capture:**
- ✅ Empty forklifts with **visible forks** (unloaded)
- ✅ Forklifts with **cargo covering forks** (loaded)
- ✅ Multiple angles and lighting conditions
- ✅ Various forklift types/colors

**Tips:**
- Record at normal warehouse speed
- Include both loaded and unloaded passes
- Keep camera steady
- Good lighting preferred

**Save videos to:**
```
data/uploads/
```

---

### 2. Extract Frames from Videos

Run this command for each video:

```bash
python scripts/prepare_dataset.py extract path/to/video.mp4 --output data/knowledge/candidates --interval 30
```

**What it does:**
- Extracts 1 frame per second (every 30 frames)
- Saves frames to `data/knowledge/candidates/`
- You'll manually sort these next

---

### 3. Organize Frames

Move extracted frames to correct folders:

**Unloaded (forks visible):**
```
data/knowledge/unloaded/
```

**Loaded (forks hidden by cargo):**
```
data/knowledge/loaded/
```

**Target:**
- At least 80-100 unloaded images
- Keep loaded at ~170 images
- Aim for 40-50% unloaded ratio

---

### 4. Create New Training Dataset

Once you have enough images:

```bash
python scripts/create_balanced_dataset.py
```

**What it does:**
- Reads from `data/knowledge/loaded/` and `data/knowledge/unloaded/`
- Creates YOLO format dataset in `dataset/forklift_balanced/`
- Splits 80% train, 20% validation
- Finds and converts existing labels

**Output:**
```
Dataset location: dataset/forklift_balanced/
  Train: X images
  Val: Y images
```

---

### 5. Retrain Model

```bash
python scripts/train_forklift_model.py --epochs 100 --device cpu
```

**What happens:**
- Trains for 100 epochs (~2-3 hours on CPU)
- Saves checkpoints every 10 epochs
- Creates best model at: `runs/train/forklift_detector_n/weights/best.pt`

**Training updates:**
You'll see progress like:
```
Epoch 10/100: precision=0.85, recall=0.55, mAP50=0.45
```

---

### 6. Test New Model

```bash
python scripts/test_new_model_improved.py
```

**What it does:**
- Loads the newly trained model
- Tests on most recent uploaded video
- Shows detection results with load status

**Expected output:**
```
Total forklift passes: 6
  Loaded: 4
  Unloaded: 2  ← Should now work!
```

---

### 7. Deploy to Web Interface

The model is automatically loaded by the API from:
```
runs/train/forklift_detector_n/weights/best.pt
```

If server is running, it will use the new model immediately. If not, start it:

```bash
# Find py executable
py --version

# Start server
py -m uvicorn app.backend.api.main:app --host 0.0.0.0 --port 8000 --reload
```

Access at: http://localhost:8000/app

---

## Quick Reference Commands

### Check Current Dataset
```bash
# Count images
ls data/knowledge/loaded/ | wc -l
ls data/knowledge/unloaded/ | wc -l
```

### View Training Progress
```bash
# Check latest training
tail -20 runs/train/forklift_detector_n/results.csv
```

### Test Current Model
```bash
python scripts/test_new_model_improved.py
```

---

## Expected Timeline

| Task | Time |
|------|------|
| Record videos | 15-30 min |
| Extract frames | 5 min |
| Organize frames | 20-30 min |
| Create dataset | 2 min |
| Train model | 2-3 hours |
| Test model | 5 min |
| **Total** | **~3-4 hours** |

---

## Success Criteria

After retraining, the model should:

✅ Detect 5-7 forklifts in test video (currently: 7 ✓)
✅ Correctly classify loaded vs unloaded (currently: 0/2 ✗)
✅ Precision >70% (currently: 96.8% ✓)
✅ Recall >50% (currently: 42.6%)

**Main goal:** Get unloaded detection working properly!

---

## Troubleshooting

**Problem:** Training stops early
- **Solution:** Check if all videos are accessible, reduce batch size if memory issues

**Problem:** Still detecting everything as loaded
- **Solution:** Need more unloaded images (target: 80-100)

**Problem:** Low precision/recall
- **Solution:** Check if frames are clear and well-lit, may need more diverse data

**Problem:** Server won't start
- **Solution:** Check if port 8000 is free, try different port: `--port 8001`

---

## Files Created Today

**Scripts:**
- `scripts/create_balanced_dataset.py` - Create training dataset
- `scripts/test_new_model_improved.py` - Test with improved tracking
- `scripts/download_unloaded_forklifts.py` - Download stock images (limited)

**Documentation:**
- `TRAINING_STATUS.md` - Current status and performance
- `QUICK_START_TOMORROW.md` - This file

**Model:**
- `runs/train/forklift_detector_n/weights/best.pt` - Current trained model

**API:**
- `app/backend/api/main.py` - Updated with improved tracking (lines 125-235)

---

## Need Help?

**Check documentation:**
- [TRAINING_STATUS.md](TRAINING_STATUS.md) - Detailed current status
- [TRAINING_GUIDE.md](TRAINING_GUIDE.md) - Complete training guide
- [DATA_COLLECTION_GUIDE.md](DATA_COLLECTION_GUIDE.md) - Data collection tips

**Key concept:**
- **Fork visible** = UNLOADED
- **Fork hidden by cargo** = LOADED

Good luck tomorrow! 🚀
