# Documentation Index

Quick navigation to all project documentation.

---

## 🚀 Getting Started

### For Daily Use
- **[QUICK_START_TOMORROW.md](QUICK_START_TOMORROW.md)** - Step-by-step guide for collecting training data and retraining
- **[README.md](README.md)** - Project overview and main documentation

### Current Status
- **[TRAINING_STATUS.md](TRAINING_STATUS.md)** - Current model performance, known issues, and next steps
  - Model metrics: 96.8% precision, 42.6% recall
  - Main issue: Unloaded detection (needs more training data)
  - Action plan for improvement

---

## 📚 Training & Data Collection

### Training
- **[TRAINING_GUIDE.md](TRAINING_GUIDE.md)** - Complete guide for training/retraining models
  - Dataset preparation
  - Training commands
  - Model evaluation
  - Deployment

### Data Collection
- **[DATA_COLLECTION_GUIDE.md](DATA_COLLECTION_GUIDE.md)** - How to collect and organize training data
  - Recording videos
  - Extracting frames
  - Labeling guidelines
  - Fork visibility criteria

---

## 🏗️ Technical Documentation

### System Architecture
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - System architecture and folder structure
  - Component overview
  - Data flow
  - Directory structure
  - Technology stack

### API & Backend
- **[docs/API.md](docs/API.md)** - Complete API documentation
  - Endpoints
  - Request/response formats
  - WebSocket connections
  - Authentication

### Database
- **[docs/DATA_MODELS.md](docs/DATA_MODELS.md)** - Database schemas and data models
  - Event schema
  - Forklift data
  - Relationships

### Detection System
- **[docs/DETECTION_CLASSIFICATION.md](docs/DETECTION_CLASSIFICATION.md)** - ML pipeline details
  - YOLOv8 detection
  - Classification logic
  - Tracking algorithms
  - Fork visibility detection

### Event Logic
- **[docs/EVENT_DEDUPLICATION.md](docs/EVENT_DEDUPLICATION.md)** - Event creation and deduplication
  - When events are created
  - Deduplication rules
  - Cooldown periods
  - State transitions

### Web Interface
- **[docs/WEB_UI_DESIGN.md](docs/WEB_UI_DESIGN.md)** - Web interface design and features
  - Component structure
  - User flows
  - Features
  - Mockups

### Implementation
- **[docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md)** - Step-by-step implementation guide
  - Phase breakdown
  - Task list
  - Dependencies
  - Timeline

---

## 📂 Key Directories

### Code
```
app/
├── backend/
│   ├── api/          # FastAPI application
│   └── workers/      # Background workers
└── frontend/         # Web interface

scripts/              # Utility scripts
├── train_forklift_model.py           # Training script
├── create_balanced_dataset.py        # Dataset creation
├── test_new_model_improved.py        # Model testing
└── prepare_dataset.py                # Data preparation
```

### Data
```
data/
├── knowledge/        # Training data
│   ├── loaded/      # Loaded forklift images (170)
│   └── unloaded/    # Unloaded forklift images (45)
├── uploads/         # Video uploads
└── forklift_logs/   # Event logs

dataset/
└── forklift_balanced/  # YOLO training dataset
    ├── images/         # Train/val images
    ├── labels/         # YOLO format labels
    └── data.yaml       # Dataset config
```

### Models
```
runs/
└── train/
    └── forklift_detector_n/
        └── weights/
            └── best.pt     # Trained model
```

---

## 🎯 Quick Actions

### Test Current Model
```bash
python scripts/test_new_model_improved.py
```

### Create New Dataset
```bash
python scripts/create_balanced_dataset.py
```

### Train Model
```bash
python scripts/train_forklift_model.py --epochs 100 --device cpu
```

### Start Web Server
```bash
py -m uvicorn app.backend.api.main:app --host 0.0.0.0 --port 8000 --reload
```

### Check Dataset Balance
```bash
ls data/knowledge/loaded/ | wc -l
ls data/knowledge/unloaded/ | wc -l
```

---

## 📊 Current Status Summary

**What Works:** ✅
- Forklift detection (96.8% precision)
- Video processing and upload
- Event logging (one per forklift pass)
- Web interface

**What Needs Work:** ⚠️
- Unloaded classification (0/2 detected correctly)
- Need 35-55 more unloaded training images
- Target: 80-100 unloaded images total

**Next Steps:**
1. Record warehouse videos with loaded/unloaded forklifts
2. Extract frames and organize into data/knowledge/
3. Retrain model with balanced dataset
4. Test and deploy

---

## 🔗 External Resources

- [YOLOv8 Documentation](https://docs.ultralytics.com/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [OpenCV Documentation](https://docs.opencv.org/)

---

Last Updated: 2025-12-17
