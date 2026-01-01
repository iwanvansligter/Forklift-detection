# Forklift Detection System 2.0

An AI-powered system for detecting forklifts and classifying load status (LOADED/UNLOADED) using YOLOv8 object detection with video upload processing and CSV export capabilities.

## Current Status (December 2025)

**✅ Working Features:**
- Video upload and processing
- YOLOv8 forklift detection (nano model: 99.47% mAP50, 98.16% precision, 99.68% recall)
- Binary classification (LOADED/UNLOADED)
- Centroid-based object tracking
- Majority voting for stable classifications
- Event logging with timestamps and confidence scores
- CSV/Excel export functionality
- Web interface for video upload and results viewing

**🚧 Planned Features:**
- Real-time camera stream processing (RTSP/webcam)
- Forklift ID recognition via OCR
- Live web dashboard with WebSocket updates
- Knowledge base for continuous model improvement
- Multi-camera support
- Advanced tracking with ByteTrack/DeepSORT

## Features

### Core Capabilities
- ✅ **Video Processing** - Upload and analyze MP4 videos
- ✅ **Forklift Detection** using YOLOv8-nano
- ✅ **Load Classification** (LOADED/UNLOADED) using trained binary classifier
- ✅ **Object Tracking** with centroid-based distance matching
- ✅ **Event Logging** with confidence scores and timestamps
- ✅ **Web Interface** for video upload and results viewing
- ✅ **CSV/Excel Export** for event data

### Model Performance
- **Model**: YOLOv8-nano custom trained on forklift dataset
- **mAP50**: 99.47%
- **Precision**: 98.16%
- **Recall**: 99.68%
- **Classes**: forklift_loaded (class 0), forklift_unloaded (class 1)
- **Note**: Model output classes are inverted - class 0 detects LOADED forklifts, class 1 detects UNLOADED

### Tracking System
- **Algorithm**: Centroid-based Euclidean distance matching
- **Parameters**:
  - Confidence threshold: 0.20
  - Max tracking distance: 200 pixels
  - Max lost frames: 30
  - Min detection count: 8
- **Classification**: Majority voting across track lifetime

---

## System Architecture

**Current Implementation (Video Processing):**

```
┌──────────────┐
│  User Upload │
│   (MP4 File) │
└──────┬───────┘
       │
  ┌────▼─────────┐
  │  FastAPI     │
  │  Backend     │
  └────┬─────────┘
       │
  ┌────▼──────────────┐
  │  Video Processing │
  │  (OpenCV/YOLOv8)  │
  └────┬──────────────┘
       │
  ┌────▼────────┐
  │  Detection  │
  │  & Tracking │
  └────┬────────┘
       │
  ┌────▼────────────┐
  │  Classification │
  │  (Majority Vote)│
  └────┬────────────┘
       │
  ┌────▼────────┐
  │  Event Log  │
  │  (In-Memory)│
  └────┬────────┘
       │
  ┌────▼─────────┐
  │  Web UI /    │
  │  CSV Export  │
  |   Excel      |
  └──────────────┘
```

**Future Architecture** will include real-time camera streams, database persistence, WebSocket updates, and OCR-based ID recognition. See [ARCHITECTURE.md](ARCHITECTURE.md) for planned architecture.

---

## Quick Start

### Prerequisites

**Hardware:**
- Python-capable machine (GPU optional but recommended for faster processing)
- 8GB+ RAM
- 10GB+ free storage

**Software:**
- Python 3.10+
- CUDA 11.8+ (optional, for GPU acceleration)

### Installation & Running

```bash
# 1. Navigate to project directory
cd forklift.2.0

# 2. Activate virtual environment (if not already active)
# Windows:
venv\Scripts\activate
# Linux/Mac:
source venv/bin/activate

# 3. Install dependencies (if not already installed)
pip install -r requirements.txt

# 4. Start the FastAPI server
cd app/backend
py -m uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload

# 5. Access web interface
# Open http://localhost:8000/app in your browser
```

### Quick Usage

1. **Open the web interface** at `http://localhost:8000/app`
2. **Upload a video** (MP4 format) using the upload button
3. **Wait for processing** - the system will analyze the video
4. **View results** in the event log showing:
   - Forklift ID (e.g., FL-001, FL-002)
   - Status (LOADED/UNLOADED)
   - Confidence score
   - Timestamp and duration
5. **Export results** using CSV or Excel export buttons

### Model Location

The trained YOLOv8 model is located at:
```
runs/train/forklift_detector_n/weights/best.pt
```

### API Documentation

Interactive API documentation available at:
```
http://localhost:8000/docs
```

---

## Configuration

### Tracking Parameters

Adjust tracking parameters in [app/backend/api/main.py:97-100](app/backend/api/main.py#L97-L100):

```python
CONFIDENCE_THRESHOLD = 0.20    # Min confidence for detections
MAX_TRACKING_DISTANCE = 200    # Max pixels between frames to match tracks
MAX_LOST_FRAMES = 30          # Frames before ending track
MIN_DETECTION_COUNT = 8       # Min detections to create valid track
```

**Recommended Adjustments:**
- To reduce track fragmentation:
  - Increase `MAX_LOST_FRAMES` to 60-90
  - Increase `MAX_TRACKING_DISTANCE` to 300-400
  - Increase `MIN_DETECTION_COUNT` to 15-20

### Class Mapping Fix

**Important:** The model training labels are inverted compared to output classes:

```python
# data.yaml during training:
# 0: forklift_unloaded
# 1: forklift_loaded

# Model output (inverted):
# class 0 → detects LOADED forklifts
# class 1 → detects UNLOADED forklifts

# Fix in code (line 193, 224):
'status': 'UNLOADED' if final_class == 1 else 'LOADED'
```

---

## Current API Endpoints

### Core Endpoints

**GET** `/` - API root information
**GET** `/api/health` - Health check
**GET** `/api/cameras` - List available cameras (currently returns demo data)
**GET** `/api/events` - Get processed events from last video upload
**GET** `/app` - Web interface

### Export

**GET** `/api/export/csv` - Export current events as CSV
**GET** `/api/export/excel` - Export current events as Excel (currently returns CSV)

**Example API Usage:**

```bash
# Get current events
curl http://localhost:8000/api/events

# Export as CSV
curl http://localhost:8000/api/export/csv > detections.csv

# Upload video for processing
curl -X POST http://localhost:8000/api/upload-video \
  -F "file=@path/to/video.mp4"
```

---

## Tracking Behavior

### How Tracking Works

The system uses **centroid-based tracking** which matches detections across frames:

1. **Detection**: YOLOv8 detects forklifts in each frame with bounding boxes
2. **Centroid Calculation**: Center point (x, y) calculated for each detection
3. **Matching**: New detections matched to existing tracks by Euclidean distance
4. **Track Creation**: If no match within 200 pixels, create new track
5. **Track Termination**: If no matching detection for 30 frames, end track
6. **Classification**: Majority vote of class predictions across track lifetime

### Why Multiple Tracks for One Forklift?

Track fragmentation can occur when:
- **Occlusion**: Forklift temporarily hidden behind object
- **Frame Exit**: Forklift leaves camera view and re-enters
- **Fast Movement**: Forklift moves >200 pixels between frames
- **Low Confidence**: Detection confidence temporarily drops below threshold

---

## Known Issues & Limitations

### Current Limitations

1. **No Real-Time Streaming**: System only processes uploaded videos, no live camera feeds
2. **In-Memory Storage**: Events stored in memory, lost on server restart
3. **No Database**: No persistent storage for events or analytics
4. **No Forklift ID Recognition**: OCR for ID recognition not yet implemented
5. **Basic Tracking**: Centroid-based tracking can fragment tracks (see Tracking Behavior section)
6. **Class Label Inversion**: Model training labels inverted from output (fixed in code)

### Troubleshooting

**Problem**: Track fragmentation (too many tracks for one forklift)
- **Solution**: Increase `MAX_LOST_FRAMES` and `MAX_TRACKING_DISTANCE` parameters

**Problem**: Missing detections
- **Solution**: Lower `CONFIDENCE_THRESHOLD` (currently 0.20)

**Problem**: False positives
- **Solution**: Increase `MIN_DETECTION_COUNT` (currently 8)

**Problem**: Video processing is slow
- **Solution**: Ensure GPU is being used (check CUDA installation), or reduce video resolution

**Problem**: Server not starting
- **Solution**: Check if port 8000 is available, ensure all dependencies installed

---

## Documentation

**Current Implementation:**
- [README.md](README.md) - This file (getting started, current features)
- [app/backend/api/main.py](app/backend/api/main.py) - Main API implementation with tracking logic
- [TRAINING_STATUS.md](TRAINING_STATUS.md) - Model training results and metrics

**Planned Features Documentation:**
- [ARCHITECTURE.md](ARCHITECTURE.md) - Planned full system architecture
- [docs/API.md](docs/API.md) - Planned complete API specification
- [docs/DETECTION_CLASSIFICATION.md](docs/DETECTION_CLASSIFICATION.md) - ML pipeline details
- [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) - Implementation roadmap

---

## Project Status

**Version**: 2.0 (MVP - Video Processing)
**Last Updated**: January 2025
**Status**: Working MVP for video upload and processing

### Next Steps

1. Implement real-time camera stream processing (RTSP/webcam)
2. Add database persistence (PostgreSQL/SQLite)
3. Implement OCR for forklift ID recognition
4. Add WebSocket support for live updates
5. Implement advanced tracking (ByteTrack/DeepSORT)
6. Build knowledge base and active learning pipeline

---

**Built for warehouse automation and forklift monitoring**
