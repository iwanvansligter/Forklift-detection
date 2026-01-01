# Current System Status - Forklift Detection v2.0

## System Overview

**Status**: Working MVP - Video Processing Only
**Last Updated**: January 2025
**Version**: 2.0-MVP

## What Works Now

### ✅ Core Features
- Video upload and processing (MP4 format)
- YOLOv8-nano forklift detection
- Binary classification (LOADED/UNLOADED)
- Centroid-based object tracking
- Event logging with timestamps
- CSV/Excel export
- Web interface for upload and viewing

### ✅ Model Performance
- **mAP50**: 99.47%
- **Precision**: 98.16%
- **Recall**: 99.68%
- **Model**: YOLOv8-nano trained on balanced forklift dataset
- **Location**: `runs/train/forklift_detector_n/weights/best.pt`

### ✅ Web Interface
- **URL**: http://localhost:8000/app
- **Features**:
  - Video file upload
  - Real-time processing status
  - Event log display
  - CSV/Excel export buttons
  - Confidence scores and timestamps

## Quick Start

```bash
# Start the server
cd app/backend
py -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

# Open browser
http://localhost:8000/app
```

## API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | API root information |
| `/api/health` | GET | Health check |
| `/api/cameras` | GET | List cameras (demo data) |
| `/api/events` | GET | Get processed events |
| `/api/upload-video` | POST | Upload and process video |
| `/api/export/csv` | GET | Export events as CSV |
| `/api/export/excel` | GET | Export events as Excel |
| `/app` | GET | Web interface |
| `/docs` | GET | Interactive API docs |

## Architecture

```
User Browser
    ↓ (Upload MP4)
FastAPI Server (Port 8000)
    ↓
Video Processing (OpenCV)
    ↓
YOLOv8 Detection (GPU/CPU)
    ↓
Centroid Tracking
    ↓
Majority Vote Classification
    ↓
Event Log (In-Memory)
    ↓
Web UI / CSV Export
```

## Tracking Parameters

Located in `app/backend/api/main.py` lines 97-100:

```python
CONFIDENCE_THRESHOLD = 0.20    # Minimum confidence for detection
MAX_TRACKING_DISTANCE = 200    # Maximum pixels between frames
MAX_LOST_FRAMES = 30           # Frames before ending track
MIN_DETECTION_COUNT = 8        # Minimum detections for valid track
```

## Important Notes

### Class Label Inversion
The model was trained with these labels in `data.yaml`:
- Class 0: forklift_unloaded
- Class 1: forklift_loaded

But the model outputs are inverted:
- **Class 0 detects LOADED forklifts**
- **Class 1 detects UNLOADED forklifts**

**Fix applied** in code (lines 193, 224):
```python
'status': 'UNLOADED' if final_class == 1 else 'LOADED'
```

### Track Fragmentation
Multiple tracks may be created for a single forklift due to:
- Temporary occlusions
- Leaving/re-entering frame
- Fast movement (>200 pixels/frame)
- Low confidence periods

**To reduce fragmentation:**
- Increase `MAX_LOST_FRAMES` to 60-90
- Increase `MAX_TRACKING_DISTANCE` to 300-400
- Increase `MIN_DETECTION_COUNT` to 15-20

## File Structure

```
app/
├── backend/
│   └── api/
│       └── main.py          # Main API server (all logic here)
└── frontend/
    └── index.html           # Web interface

runs/
└── train/
    └── forklift_detector_n/
        └── weights/
            └── best.pt      # Trained model

data/
└── uploads/                 # Uploaded videos stored here

dataset/
└── forklift_balanced/
    └── data.yaml           # Training dataset configuration
```

## Typical Workflow

1. Start server: `py -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload`
2. Open browser: http://localhost:8000/app
3. Upload video (MP4)
4. Wait for processing (progress shown)
5. View results in event log
6. Export as CSV/Excel if needed

## Event Data Structure

```json
{
  "forklift_id": "FL-001",
  "status": "LOADED",
  "confidence": 0.87,
  "timestamp": "2025-01-18T14:30:52.347Z",
  "first_seen": 0.0,
  "duration": 8.2
}
```

## Console Output Example

```
Track completed: Class votes - UNLOADED(0):1400, LOADED(1):10, Final:0, Conf:0.92
Remaining track: Class votes - UNLOADED(0):89, LOADED(1):0, Final:0, Conf:0.81

=== Video Processing Complete ===
Total tracks detected: 7
Track 1: LOADED (conf: 0.46, duration: 0.4s)
Track 2: UNLOADED (conf: 0.23, duration: 0.3s)
Track 3: LOADED (conf: 0.43, duration: 0.9s)
Track 4: UNLOADED (conf: 0.34, duration: 2.9s)
Track 5: LOADED (conf: 0.92, duration: 45.7s)
Track 6: LOADED (conf: 0.46, duration: 1.4s)
Track 7: LOADED (conf: 0.81, duration: 4.6s)
================================
```

## What's NOT Implemented Yet

- ❌ Real-time camera streaming (RTSP/webcam)
- ❌ Database persistence
- ❌ OCR forklift ID recognition
- ❌ WebSocket live updates
- ❌ Advanced tracking (ByteTrack/DeepSORT)
- ❌ Knowledge base / active learning
- ❌ Multi-camera support
- ❌ Zone-based detection
- ❌ User authentication

## Dependencies

**Core:**
- Python 3.10+
- FastAPI
- Uvicorn
- OpenCV (cv2)
- Ultralytics YOLOv8
- NumPy

**Optional:**
- CUDA 11.8+ for GPU acceleration

## Troubleshooting

| Problem | Solution |
|---------|----------|
| Port 8000 already in use | Change port or kill process using port 8000 |
| Model not found | Verify `runs/train/forklift_detector_n/weights/best.pt` exists |
| Slow processing | Check GPU availability, reduce video resolution |
| Too many tracks | Increase `MAX_LOST_FRAMES` and `MAX_TRACKING_DISTANCE` |
| Missing detections | Lower `CONFIDENCE_THRESHOLD` (e.g., 0.15) |
| False positives | Increase `MIN_DETECTION_COUNT` (e.g., 15) |

## Contact & Support

- **Documentation**: See [README.md](README.md)
- **Code**: [app/backend/api/main.py](app/backend/api/main.py)
- **Training**: [TRAINING_STATUS.md](TRAINING_STATUS.md)
