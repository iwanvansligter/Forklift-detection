# Project Structure Overview

Clean, organized project structure with only relevant files and folders.

---

## 📁 Root Directory

```
Forklift.2.0/
├── 📄 README.md                     # Main documentation
├── 📄 DOCUMENTATION_INDEX.md        # Navigation index
├── 📄 QUICK_START_TOMORROW.md       # Tomorrow's action plan
├── 📄 TRAINING_STATUS.md            # Current model status
├── 📄 TRAINING_GUIDE.md             # Training instructions
├── 📄 DATA_COLLECTION_GUIDE.md      # Data collection guide
├── 📄 ARCHITECTURE.md               # System architecture
│
├── 📂 app/                          # Application code
├── 📂 configs/                      # Configuration files
├── 📂 data/                         # Data storage
├── 📂 dataset/                      # Training datasets
├── 📂 docs/                         # Technical documentation
├── 📂 models/                       # Model storage
├── 📂 runs/                         # Training outputs
├── 📂 scripts/                      # Utility scripts
└── 📂 venv/                         # Python virtual environment
```

---

## 📂 Application Code (`app/`)

```
app/
├── backend/
│   └── api/
│       └── main.py                  # FastAPI application with improved tracking
├── frontend/                        # Web interface (if implemented)
└── shared/                          # Shared utilities
```

**Key File:**
- `backend/api/main.py` - Video processing with forklift detection & tracking

---

## 📂 Data Folders (`data/`)

```
data/
├── knowledge/                       # ⭐ TRAINING DATA
│   ├── loaded/                     # Loaded forklift images (170)
│   ├── unloaded/                   # Unloaded forklift images (45)
│   └── README.md
│
├── uploads/                         # ⭐ VIDEO UPLOADS
│   └── video_*.mp4                 # Uploaded test videos (8 files)
│
├── forklift_logs/                   # ⭐ EVENT LOGS
│   └── events_*.json               # Event history (7 files)
│
└── [Empty placeholder folders]      # For future use
    ├── events/
    ├── input/
    ├── logs/
    └── streams/
```

---

## 📂 Training Datasets (`dataset/`)

```
dataset/
├── forklift/                        # ⭐ ORIGINAL ROBOFLOW DATA
│   └── Forklift.v1i.yolov8-obb/   # 298 images with OBB labels
│       ├── train/
│       ├── test/
│       └── valid/
│
└── forklift_balanced/               # ⭐ ACTIVE TRAINING DATASET
    ├── images/
    │   ├── train/                   # 156 training images
    │   └── val/                     # 40 validation images
    ├── labels/
    │   ├── train/                   # YOLO format labels
    │   └── val/
    └── data.yaml                    # Dataset configuration
```

**Removed (old/unused):**
- ~~forklift_classified/~~ - Old attempt
- ~~forklift_yolo/~~ - Old YOLO conversion

---

## 📂 Trained Models (`runs/`)

```
runs/
└── train/
    └── forklift_detector_n/         # ⭐ CURRENT MODEL
        ├── weights/
        │   ├── best.pt              # Best model checkpoint
        │   ├── last.pt              # Latest checkpoint
        │   ├── epoch10.pt           # Checkpoint at epoch 10
        │   └── epoch20.pt           # Checkpoint at epoch 20
        ├── results.csv              # Training metrics
        ├── labels.jpg               # Label distribution
        └── train_batch*.jpg         # Training batch samples
```

---

## 📂 Scripts (`scripts/`)

### Training & Testing
- `train_forklift_model.py` - Train YOLOv8 model
- `create_balanced_dataset.py` - Create YOLO dataset from organized images
- `test_new_model_improved.py` - Test model with improved tracking
- `test_new_model.py` - Basic model testing

### Data Collection
- `prepare_dataset.py` - Extract frames from videos
- `organize_loaded_unloaded.py` - Interactive image organizer
- `download_unloaded_forklifts.py` - Download stock images
- `convert_obb_to_yolo.py` - Convert OBB to YOLO format

### Other Utilities
- `download_roboflow_dataset.py` - Download from Roboflow
- `test_trained_model.py` - Model validation
- `export_to_excel.py` - Export events to Excel

---

## 📂 Documentation (`docs/`)

Technical documentation for system components:

- `API.md` - API endpoints and usage
- `DATA_MODELS.md` - Database schemas
- `DETECTION_CLASSIFICATION.md` - ML pipeline details
- `EVENT_DEDUPLICATION.md` - Event logic
- `IMPLEMENTATION_ROADMAP.md` - Implementation guide
- `WEB_UI_DESIGN.md` - Web interface design

---

## 🗑️ Cleaned Up

### Removed Folders
- ~~appfrontend/~~ - Incorrectly named empty folder
- ~~dataforklift_logs/~~ - Incorrectly named empty folder
- ~~datauploads/~~ - Incorrectly named empty folder
- ~~dataset/forklift_classified/~~ - Old unused dataset
- ~~dataset/forklift_yolo/~~ - Old unused dataset

### Removed Documents
- ~~DESIGN_SUMMARY.md~~ - Outdated
- ~~GETTING_STARTED_LAPTOP.md~~ - Not relevant
- ~~LAPTOP_CAMERA_SETUP.md~~ - Not relevant
- ~~QUICK_REFERENCE.md~~ - Outdated
- ~~QUICK_START_TRAINING.md~~ - Duplicate
- ~~RELABELING_INSTRUCTIONS.md~~ - Specific old instructions
- ~~START_HERE.md~~ - Outdated
- ~~STARTUP_GUIDE.md~~ - Outdated
- ~~IMAGE_SCRAPING_GUIDE.md~~ - Not relevant

---

## 📊 Current Statistics

### Training Data
- Loaded images: **170** (79%)
- Unloaded images: **45** (21%)
- **Target:** 80-100 unloaded images

### Model Performance
- Precision: **96.8%** ✅
- Recall: **42.6%**
- mAP50: **46.3%**
- **Issue:** Unloaded detection not working

### Detection Test
- Forklifts detected: **7 of 6** ✅
- Loaded classification: **7 of 4** ⚠️
- Unloaded classification: **0 of 2** ❌

---

## 🎯 Priority Files/Folders

**For Daily Use:**
1. `data/knowledge/` - Add training images here
2. `data/uploads/` - Upload test videos here
3. `scripts/create_balanced_dataset.py` - Run after adding images
4. `scripts/train_forklift_model.py` - Retrain model
5. `scripts/test_new_model_improved.py` - Test results

**Key Documentation:**
1. `QUICK_START_TOMORROW.md` - Tomorrow's plan
2. `TRAINING_STATUS.md` - Current status
3. `DOCUMENTATION_INDEX.md` - Navigation

**Current Model:**
- `runs/train/forklift_detector_n/weights/best.pt`

---

## ✅ Structure Quality

- ✅ No duplicate folders
- ✅ No incorrectly named folders
- ✅ Old datasets removed
- ✅ Documentation consolidated
- ✅ Clear separation of concerns
- ✅ Easy to navigate

**Result:** Clean, organized project ready for continued development! 🚀

---

Last Updated: 2025-12-17
