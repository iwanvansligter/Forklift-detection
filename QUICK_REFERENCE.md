# Quick Reference Card

## System Overview

**Purpose**: Detect forklifts, classify load status (LOADED/UNLOADED), identify forklift IDs, and log events with live web monitoring.

---

## Key Concepts

### Detection Pipeline
```
Camera → Detect Forklift → Track → Recognize ID → Classify Load → Check Transition → Create Event
```

### Event Creation Rules

✅ **Event Created When:**
- State transitions (UNLOADED → LOADED or LOADED → UNLOADED)
- Track duration ≥ 3 seconds
- Confidence ≥ 0.7
- Cooldown period elapsed (30 seconds)

❌ **Event NOT Created When:**
- Same state (no transition)
- Brief detection (< 3 seconds)
- Low confidence
- Within cooldown period

---

## Configuration Files

| File | Purpose |
|------|---------|
| [configs/cameras.yaml](configs/cameras.yaml) | Camera RTSP URLs, zones |
| [configs/thresholds.yaml](configs/thresholds.yaml) | Detection/classification thresholds |
| [configs/app.yaml](configs/app.yaml) | API server, storage, features |
| [configs/zones.yaml](configs/zones.yaml) | Detection zones (optional) |
| `.env` | Environment variables (secrets) |

---

## Key Thresholds (Tunable)

```yaml
# configs/thresholds.yaml
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

**Tuning Tips:**
- **High false positives?** → Increase `forklift_confidence`
- **Missing events?** → Decrease `loaded_confidence`
- **Too many duplicates?** → Increase `cooldown_seconds`
- **Events too frequent?** → Increase `min_track_duration`

---

## Quick Start Commands

### MVP Setup (5 minutes)

```bash
# 1. Install dependencies
python -m venv venv && source venv/bin/activate
pip install -r requirements.txt

# 2. Configure
cp .env.example .env
nano configs/cameras.yaml  # Add your RTSP URLs

# 3. Download pretrained model (MVP)
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8m.pt -O models/forklift_detector_v1.pt

# 4. Initialize database
python scripts/database_init.py

# 5. Start services
python app/backend/workers/inference_worker.py &
cd app/backend && uvicorn api.main:app --port 8000 &
cd app/frontend && npm install && npm run dev
```

### Docker Setup (Recommended)

```bash
docker-compose up -d
docker-compose logs -f
```

---

## API Quick Reference

### Get Events
```bash
curl http://localhost:8000/api/events?page=1&page_size=50
```

### Get Specific Event
```bash
curl http://localhost:8000/api/events/{event_id}
```

### Label Event
```bash
curl -X POST http://localhost:8000/api/events/{event_id}/label \
  -H "Content-Type: application/json" \
  -d '{"correct": false, "corrected_status": "UNLOADED"}'
```

### WebSocket (Real-time)
```javascript
const ws = new WebSocket('ws://localhost:8000/api/ws/live');
ws.send(JSON.stringify({ action: 'subscribe', camera_id: 'camera_1' }));
```

---

## Folder Structure (Key Locations)

```
forklift.2.0/
├── app/backend/services/     # Detection, tracking, OCR, classification
├── configs/                  # YAML configuration files
├── data/events/              # Event snapshots (organized by date)
├── data/knowledge/           # Training dataset (loaded/unloaded)
├── models/                   # ML model weights (.pt files)
├── docs/                     # Complete documentation
└── scripts/                  # Utility scripts
```

---

## Event File Structure

```
data/events/YYYY-MM-DD/{event_id}/
├── snapshot.jpg       # Full frame
├── crop.jpg           # Forklift crop
├── metadata.json      # Event details
└── clip.mp4           # Video clip (optional)
```

**Metadata Example:**
```json
{
  "event_id": "evt_20250112_143052_cam1_fl001",
  "timestamp": "2025-01-12T14:30:52.347Z",
  "camera_id": "camera_1",
  "forklift_id": "FL-001",
  "status": "LOADED",
  "status_confidence": 0.87,
  "detection_confidence": 0.94
}
```

---

## Knowledge Base Usage

### Directory Structure
```
data/knowledge/
├── loaded/        # Confirmed loaded images
├── unloaded/      # Confirmed unloaded images
├── unknown/       # Needs review
└── difficult/     # Edge cases
```

### Add Image to Knowledge Base

**From Event (Web UI):**
1. Go to Events page
2. Click event → "Label"
3. Check "Move to Knowledge Base"
4. Select label (loaded/unloaded)

**Manual Upload:**
```bash
python scripts/import_knowledge.py \
  --source /path/to/image.jpg \
  --label loaded \
  --forklift-id FL-001
```

---

## Common Tasks

### Add New Camera

Edit `configs/cameras.yaml`:
```yaml
cameras:
  - camera_id: camera_3
    name: "New Camera"
    rtsp_url: "rtsp://192.168.1.103:554/stream1"
    enabled: true
```

Restart services:
```bash
docker-compose restart backend
```

### Change Detection Zone

Edit `configs/zones.yaml`:
```yaml
zones:
  - zone_id: entry_zone_1
    camera_id: camera_1
    polygon:
      - [100, 200]
      - [500, 200]
      - [500, 800]
      - [100, 800]
```

Or use Web UI: Settings → Zones → Draw Polygon

### Export Events to CSV

```bash
curl http://localhost:8000/api/events?format=csv > events.csv
```

Or via Web UI: Events → Export CSV

### Retrain Models (Weekly)

```bash
# 1. Export knowledge base
python scripts/export_knowledge.py --output data/training/

# 2. Train load classifier
python scripts/train/train_load_classifier.py \
  --data data/training/ \
  --epochs 50

# 3. Evaluate
python scripts/evaluate_model.py --model models/load_classifier_v2.pt

# 4. Deploy if improved
cp models/load_classifier_v2.pt models/load_classifier_v1.pt
docker-compose restart backend
```

---

## Troubleshooting

### Issue: No detections

**Check:**
1. Camera stream accessible? `ffplay rtsp://...`
2. CUDA available? `python -c "import torch; print(torch.cuda.is_available())"`
3. Model loaded? Check logs: `tail -f data/logs/inference.log`
4. Threshold too high? Lower `forklift_confidence` in `thresholds.yaml`

### Issue: Low FPS

**Solutions:**
- Reduce `inference_fps` in `thresholds.yaml` (default: 10)
- Enable half-precision: `USE_HALF_PRECISION=true` in `.env`
- Use smaller model: YOLOv8-small instead of medium

### Issue: Too many false positives

**Solutions:**
- Increase `forklift_confidence` to 0.7-0.8
- Enable zones (only detect in specific areas)
- Train custom model with your warehouse data

### Issue: Events duplicating

**Check:**
- `cooldown_seconds` high enough? (default: 30)
- `require_state_transition` enabled? (default: true)
- Review event logs for duplicate track IDs

---

## Monitoring

### Health Check
```bash
curl http://localhost:8000/api/health
```

### Metrics (Prometheus)
```bash
curl http://localhost:9090/metrics
```

### Logs
```bash
# API logs
tail -f data/logs/api.log

# Inference logs
tail -f data/logs/inference.log

# Docker logs
docker-compose logs -f backend
```

---

## Performance Benchmarks

| Hardware | Cameras | FPS/Cam | Latency |
|----------|---------|---------|---------|
| RTX 3070 | 4 | 10 | <1s |
| RTX 4090 | 10 | 15 | <1s |
| Jetson Orin | 2 | 8 | <2s |

---

## Documentation Links

- [README.md](README.md) - Getting started
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [docs/API.md](docs/API.md) - API documentation
- [docs/WEB_UI_DESIGN.md](docs/WEB_UI_DESIGN.md) - Web interface
- [docs/DETECTION_CLASSIFICATION.md](docs/DETECTION_CLASSIFICATION.md) - ML details
- [docs/EVENT_DEDUPLICATION.md](docs/EVENT_DEDUPLICATION.md) - Event logic
- [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) - Implementation steps
- [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md) - Complete design overview

---

## Cheat Sheet

### File Paths
```python
# Events
"data/events/{date}/{event_id}/snapshot.jpg"

# Knowledge
"data/knowledge/{label}/{forklift_id}_{timestamp}.jpg"

# Models
"models/forklift_detector_v1.pt"
"models/load_classifier_v1.pt"

# Configs
"configs/cameras.yaml"
"configs/thresholds.yaml"
```

### Status Values
- `LOADED` - Forklift carrying a load
- `UNLOADED` - Forklift empty

### Confidence Ranges
- **0.9-1.0**: Very high (auto-add to knowledge)
- **0.7-0.9**: Good (create event)
- **0.5-0.7**: Uncertain (flag for review)
- **<0.5**: Low (ignore or manual review)

---

## Support

- **Issues**: Open GitHub issue
- **Documentation**: See [docs/](docs/) directory
- **Slack**: #forklift-detection (if available)

---

**Quick Ref Version**: 1.0 | **Last Updated**: 2025-01-12
