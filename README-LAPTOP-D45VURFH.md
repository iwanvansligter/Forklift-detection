# Forklift Detection System 2.0

An end-to-end AI-powered system for detecting forklifts, classifying load status (LOADED/UNLOADED) based on fork visibility, and logging events with a web-based monitoring interface.

**Current Status:** ✅ Detection working, ⚠️ Load classification needs more training data

## Features

### Core Capabilities
- ✅ **Forklift Detection** using custom-trained YOLOv8 model
- ⚠️ **Load Classification** (LOADED/UNLOADED) based on fork visibility
  - Fork visible = UNLOADED
  - Fork hidden by cargo = LOADED
  - *Currently limited by training data imbalance*
- ✅ **Video Upload Processing** with forklift tracking
- ✅ **Event Logging** with one event per forklift pass
- ✅ **Web Interface** for video upload and event monitoring
- ✅ **Knowledge Base** for continuous model improvement

### Web Interface
- **Live View**: Real-time camera feeds with detection overlays
- **Events Dashboard**: Searchable event history with filters
- **Labeling Tool**: Manual review and correction of events
- **Knowledge Base**: Training dataset management
- **Analytics**: Performance metrics and system monitoring

### Advanced Features
- Zone-based event triggering
- Multi-camera support (scalable to 20+ cameras)
- Video clip recording for events
- Automatic model retraining pipeline
- REST API and WebSocket for integrations
- Prometheus metrics for monitoring

---

## System Architecture

```
┌─────────────────┐
│  RTSP Cameras   │
└────────┬────────┘
         │
    ┌────▼────┐
    │ Stream  │
    │ Ingest  │
    └────┬────┘
         │
    ┌────▼────────┐
    │ Detection & │
    │  Tracking   │
    └────┬────────┘
         │
    ┌────▼─────────────┐
    │ ID Recognition & │
    │ Classification   │
    └────┬─────────────┘
         │
    ┌────▼────────┐
    │ Event Logic │
    └────┬────────┘
         │
    ┌────▼────────┐     ┌──────────┐
    │  Database   │────▶│ Web API  │
    └─────────────┘     └────┬─────┘
                             │
                        ┌────▼─────┐
                        │ Frontend │
                        └──────────┘
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed architecture documentation.

---

## Quick Start

### Prerequisites

**Hardware:**
- NVIDIA GPU with 4GB+ VRAM (e.g., GTX 1650 or better)
- 16GB RAM (32GB recommended)
- 500GB+ SSD storage

**Software:**
- Python 3.10+
- CUDA 11.8+ (for GPU acceleration)
- Docker & Docker Compose (optional)
- Node.js 18+ (for frontend)

### Installation

#### Option 1: Docker (Recommended)

```bash
# 1. Clone repository
git clone <repository_url>
cd forklift.2.0

# 2. Configure environment
cp .env.example .env
nano .env  # Edit configuration

# 3. Start services
docker-compose up -d

# 4. Initialize database
docker-compose exec backend python scripts/database_init.py

# 5. Access web interface
# Open http://localhost:80 in browser
```

#### Option 2: Manual Installation

```bash
# 1. Clone repository
git clone <repository_url>
cd forklift.2.0

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment
cp .env.example .env
nano .env

# 5. Initialize database
python scripts/database_init.py

# 6. Download models (MVP - uses pretrained models)
# For production, train custom models (see TRAINING.md)
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8m.pt -O models/forklift_detector_v1.pt

# 7. Start backend
cd app/backend
uvicorn api.main:app --host 0.0.0.0 --port 8000 &

# 8. Start inference worker
python workers/inference_worker.py &

# 9. Start frontend
cd app/frontend
npm install
npm run dev

# 10. Access web interface
# Open http://localhost:5173 in browser
```

---

## Configuration

### Camera Setup

Edit [configs/cameras.yaml](configs/cameras.yaml):

```yaml
cameras:
  - camera_id: camera_1
    name: "Warehouse Entry"
    rtsp_url: "rtsp://192.168.1.100:554/stream1"
    location: "Building A - Entry"
    resolution: "1920x1080"
    fps: 25
    enabled: true
```

### Detection Thresholds

Edit [configs/thresholds.yaml](configs/thresholds.yaml):

```yaml
detection:
  forklift_confidence: 0.6

classification:
  loaded_confidence: 0.7
  unloaded_confidence: 0.7

event_creation:
  min_track_duration: 3.0
  cooldown_seconds: 30
  require_state_transition: true
```

### Zones (Optional)

Define detection zones in [configs/zones.yaml](configs/zones.yaml):

```yaml
zones:
  - zone_id: entry_zone_1
    name: "Main Entry"
    camera_id: camera_1
    polygon:
      - [100, 200]
      - [500, 200]
      - [500, 800]
      - [100, 800]
```

---

## Usage

### Web Interface

**Live View:**
1. Navigate to **Live View** page
2. Select camera from dropdown
3. View real-time detections with overlays
4. Monitor active detections in side panel

**Events:**
1. Navigate to **Events** page
2. Filter by camera, forklift, status, date
3. Click event to view details
4. Label events as correct/incorrect
5. Move to knowledge base for training

**Knowledge Base:**
1. Navigate to **Knowledge Base** page
2. View and manage training images
3. Upload new images manually
4. Export dataset for model retraining

### API Usage

**Get Events:**
```bash
curl http://localhost:8000/api/events?page=1&page_size=50
```

**Get Specific Event:**
```bash
curl http://localhost:8000/api/events/{event_id}
```

**Label Event:**
```bash
curl -X POST http://localhost:8000/api/events/{event_id}/label \
  -H "Content-Type: application/json" \
  -d '{"correct": false, "corrected_status": "UNLOADED", "move_to_knowledge": true}'
```

**WebSocket (Real-time Updates):**
```javascript
const ws = new WebSocket('ws://localhost:8000/api/ws/live');
ws.send(JSON.stringify({ action: 'subscribe', camera_id: 'camera_1' }));
ws.onmessage = (event) => {
  const data = JSON.parse(event.data);
  console.log('Detection update:', data);
};
```

See [docs/API.md](docs/API.md) for complete API documentation.

---

## Event Deduplication Logic

The system implements intelligent event deduplication to avoid creating duplicate events:

**Event Created When:**
- ✅ Forklift state transitions (UNLOADED → LOADED or vice versa)
- ✅ Track duration ≥ 3 seconds (configurable)
- ✅ Confidence ≥ threshold (0.7 default)
- ✅ Cooldown period elapsed (30 seconds default)

**Event NOT Created When:**
- ❌ Forklift remains in same state
- ❌ Brief detection (< 3 seconds)
- ❌ Low confidence
- ❌ Within cooldown period

See [docs/EVENT_DEDUPLICATION.md](docs/EVENT_DEDUPLICATION.md) for detailed logic.

---

## Knowledge Base & Active Learning

The system continuously improves through active learning:

1. **High-Confidence Events (>0.9)** → Auto-added to knowledge base
2. **Low-Confidence Events (<0.7)** → Flagged for manual review
3. **User Corrections** → High-priority training data
4. **Weekly Retraining** → Models updated with new data

See [data/knowledge/README.md](data/knowledge/README.md) for knowledge base usage.

---

## Documentation

📖 **[DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md)** - Complete documentation index with quick navigation

### Getting Started
- [README.md](README.md) - This file (overview)
- [QUICK_START_TOMORROW.md](QUICK_START_TOMORROW.md) - **Step-by-step guide for tomorrow**
- [TRAINING_STATUS.md](TRAINING_STATUS.md) - Current model performance & next steps
- [TRAINING_GUIDE.md](TRAINING_GUIDE.md) - How to train/retrain models
- [DATA_COLLECTION_GUIDE.md](DATA_COLLECTION_GUIDE.md) - How to collect training data

### Technical Documentation
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture and folder structure
- [docs/API.md](docs/API.md) - Complete API documentation
- [docs/WEB_UI_DESIGN.md](docs/WEB_UI_DESIGN.md) - Web interface design
- [docs/DETECTION_CLASSIFICATION.md](docs/DETECTION_CLASSIFICATION.md) - ML pipeline details
- [docs/EVENT_DEDUPLICATION.md](docs/EVENT_DEDUPLICATION.md) - Event logic
- [docs/DATA_MODELS.md](docs/DATA_MODELS.md) - Database schemas
- [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) - Step-by-step implementation guide

---

## Performance Benchmarks

| Hardware | Cameras | FPS per Camera | Events/Hour |
|----------|---------|----------------|-------------|
| RTX 3070 | 4 | 10 | ~100 |
| RTX 4090 | 10 | 15 | ~250 |
| Jetson Orin | 2 | 8 | ~50 |

---

## Support

- **Documentation**: See [docs/](docs/) directory
- **Issues**: Open an issue in this repository
- **Questions**: Review documentation or contact system administrator

---

**Built for warehouse automation and forklift monitoring**