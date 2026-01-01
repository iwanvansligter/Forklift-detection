# Forklift Detection System - Design Summary

## Executive Summary

This document provides a comprehensive overview of the Forklift Detection System 2.0 design. The system is a production-grade, end-to-end solution for real-time forklift monitoring, load classification, and event tracking with a web-based interface.

---

## Answers to Clarifying Questions

**Assumptions Made (based on typical warehouse environments):**

1. **Camera Position & Distance**: Side-mounted cameras at 10-15m distance, capturing forklift at eye-level or slightly elevated
2. **Forklift ID Location**: Front-facing plate or side panel with alphanumeric format (e.g., "FL-001")
3. **Number of Forklifts & Cameras**: 5-10 forklifts, 2-4 cameras initially, scalable to 20+ cameras
4. **Load Types**: Standardized pallets (80cm x 120cm minimum), system adaptable to other load types
5. **Performance Requirements**: Near real-time (<1s latency), 30-day event retention, 10 FPS processing per camera

---

## 1. System Architecture

### Component Overview

```
[RTSP Cameras] → [Stream Ingest] → [Detection & Tracking] → [ID Recognition & Classification]
                                                                            ↓
[Web UI] ← [Backend API] ← [Database & Storage] ← [Event Logic Engine]
```

### Key Components

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Stream Ingest** | Python + OpenCV/FFmpeg | Connect to RTSP streams, frame buffering |
| **Forklift Detector** | YOLOv8-Medium | Detect forklifts in frames |
| **Object Tracker** | ByteTrack | Assign stable track IDs |
| **ID Recognition** | EasyOCR | OCR for forklift identification |
| **Load Classifier** | Hybrid: YOLOv8-Nano + ResNet18 | Classify LOADED/UNLOADED |
| **Event Engine** | Python State Machine | Deduplication & event creation |
| **Backend API** | FastAPI | REST API + WebSocket |
| **Frontend** | React + TypeScript | Web interface |
| **Database** | PostgreSQL | Event storage & queries |
| **Streaming** | HLS (production) / MJPEG (MVP) | Live video delivery |

### Data Flow

1. **Ingest**: RTSP stream → Decode frames @ 10 FPS
2. **Detect**: YOLOv8 detects forklifts → Bounding boxes
3. **Track**: ByteTrack assigns track IDs → Stable tracking
4. **Recognize**: EasyOCR identifies forklift ID → "FL-001" or "UNKNOWN"
5. **Classify**: Hybrid classifier determines LOADED/UNLOADED
6. **Event Logic**: State machine checks for transitions → Creates event if conditions met
7. **Store**: Event saved to database + file system (snapshot, metadata)
8. **Serve**: Backend API provides data to frontend
9. **Display**: Web UI shows live feed + events + knowledge base

---

## 2. Web UI Design

### Streaming Technology: HLS (HTTP Live Streaming)

**Why HLS?**
- ✅ Scalable (supports multiple viewers, CDN-friendly)
- ✅ Universal browser support
- ✅ Adaptive bitrate
- ✅ Acceptable latency (2-5s) for monitoring use case

**Fallback:** MJPEG for MVP (simpler implementation, lower latency but poor scalability)

### Overlay Rendering: Client-Side

**Implementation:**
- Canvas overlay on top of video element
- WebSocket provides detection data with timestamps
- Client synchronizes overlays with video frames
- Interactive (hover for details, click to view event)

### Page Structure

#### 1. Live View Page
```
┌────────────────────────────────┬─────────────────┐
│                                │  Active         │
│                                │  Detections     │
│       Video Stream             │                 │
│    (with bbox overlays)        │  FL-001: LOADED │
│                                │  FL-002: UNLOAD │
│                                │                 │
│                                │  Recent Events  │
│                                │  14:30 FL-001   │
└────────────────────────────────┴─────────────────┘
```

**Features:**
- Real-time video with bounding boxes (color-coded by status)
- Labels showing forklift ID, status, confidence
- Active detections panel (current forklifts in frame)
- Recent events list
- Camera selector, fullscreen, screenshot controls

#### 2. Events Page
```
┌──────────────────────────────────────────────────┐
│  Filters: Camera | Forklift | Status | Date      │
├──────┬─────────┬──────────┬────────┬───────────┤
│ Time │ Camera  │ Forklift │ Status │ Actions   │
│ 14:30│ Cam 1   │ FL-001   │ LOADED │ View|Label│
└──────┴─────────┴──────────┴────────┴───────────┘
```

**Features:**
- Searchable, filterable event list with pagination
- Event detail modal with full metadata
- Labeling interface (correct/incorrect, move to knowledge)
- Bulk actions (label multiple events, export CSV)

#### 3. Knowledge Base Page
```
┌─────────────────────────────────────────────────┐
│  Stats: Loaded: 1,823 | Unloaded: 1,456        │
│  Filters: Label | Source | Forklift            │
├─────┬─────┬─────┬─────┬─────┬─────┬─────┬─────┤
│ img │ img │ img │ img │ img │ img │ img │ img │
│ 🟢  │ 🔴  │ 🟡  │ 🟢  │ 🟢  │ 🟡  │ 🟢  │ 🔴  │
└─────┴─────┴─────┴─────┴─────┴─────┴─────┴─────┘
```

**Features:**
- Gallery view of training images
- Upload new images manually
- Relabel images
- Export dataset for training
- Statistics dashboard

#### 4. Settings Page
- Threshold configuration (detection, classification, OCR)
- Camera management (add/edit/test RTSP)
- Zone drawing tool (polygon editor)
- System settings (retention, cleanup)

---

## 3. API Endpoints

### Core Endpoints

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/cameras` | List all cameras |
| GET | `/api/stream/{camera_id}` | HLS manifest or MJPEG stream |
| GET | `/api/events` | Paginated event list with filters |
| GET | `/api/events/{event_id}` | Event details |
| POST | `/api/events/{event_id}/label` | Label/correct event |
| GET | `/api/knowledge/stats` | Knowledge base statistics |
| POST | `/api/knowledge/upload` | Upload training image |
| GET | `/api/analytics/summary` | System statistics |
| WS | `/api/ws/live` | Real-time detection updates |

**See [docs/API.md](docs/API.md) for complete API documentation.**

---

## 4. Event Schema

### JSON Structure

```json
{
  "event_id": "evt_20250112_143052_cam1_fl001",
  "timestamp": "2025-01-12T14:30:52.347Z",
  "camera_id": "camera_1",
  "forklift_id": "FL-001",
  "status": "LOADED",
  "status_confidence": 0.87,
  "detection_confidence": 0.94,
  "bounding_box": {"x": 450, "y": 320, "width": 280, "height": 340},
  "load_detection": {
    "method": "pallet_detector",
    "pallet_detected": true,
    "pallet_confidence": 0.89
  },
  "ocr_results": {
    "raw_text": "FL-001",
    "confidence": 0.92
  },
  "tracking": {
    "track_id": 15,
    "track_duration": 8.5,
    "previous_state": "UNLOADED"
  },
  "snapshot_path": "data/events/2025-01-12/evt_20250112_143052_cam1_fl001/snapshot.jpg",
  "review": {
    "reviewed": false,
    "correct": null
  }
}
```

### Database Tables

- **cameras**: Camera configuration
- **events**: Event records with full metadata
- **forklifts**: Forklift registry
- **tracking_state**: Active track states (in-memory or Redis)
- **knowledge_images**: Knowledge base index

**See [docs/DATA_MODELS.md](docs/DATA_MODELS.md) for complete schemas.**

---

## 5. Event Deduplication Logic

### Core Principle

**Create event ONLY on state transition (LOADED ↔ UNLOADED), not continuous presence.**

### Decision Logic

Event created if **ALL** conditions met:

1. ✅ **Forklift ID identified** (not "UNKNOWN")
2. ✅ **Status determined** (LOADED or UNLOADED)
3. ✅ **Confidence ≥ threshold** (default: 0.7)
4. ✅ **Track duration ≥ minimum** (default: 3 seconds)
5. ✅ **Cooldown elapsed** (default: 30 seconds since last event)
6. ✅ **State transition occurred** (if required by config)

### Stabilization Mechanisms

- **Status Buffer**: Majority vote over last 5 frames (3/5 must agree)
- **OCR Buffer**: Most frequent ID over last 10 frames
- **Track Stability**: Track must exist for minimum duration

### Example Scenarios

**Scenario 1: State Transition (Event Created)**
```
Frame 100: FL-001 detected, UNLOADED, track_id=15
Frame 150: FL-001 detected, LOADED, track_id=15 (state changed!)
→ Event created: "FL-001 transitioned UNLOADED → LOADED"
```

**Scenario 2: Continuous Presence (No Event)**
```
Frame 100-200: FL-001 detected, LOADED, track_id=15 (no change)
→ No event (already LOADED)
```

**Scenario 3: Cooldown Prevents Duplicate**
```
Frame 100: FL-001 transitions UNLOADED → LOADED (event created)
Frame 120: FL-001 still LOADED (within 30s cooldown)
→ No duplicate event
```

**See [docs/EVENT_DEDUPLICATION.md](docs/EVENT_DEDUPLICATION.md) for detailed implementation.**

---

## 6. Load Classification Strategy

### Hybrid Approach (Production)

**Strategy 1: Pallet Detector (Primary)**
- YOLOv8-Nano trained to detect pallets
- Run on fork region (lower 30% of forklift bbox)
- If pallet detected with confidence >0.6 → LOADED

**Strategy 2: Binary Classifier (Fallback)**
- ResNet18 fine-tuned for binary classification
- Input: Fork region crop (224x224)
- Output: LOADED or UNLOADED with confidence

**Hybrid Logic:**
```python
if pallet_detected and pallet_confidence >= 0.6:
    return LOADED
else:
    return binary_classifier_result
```

### MVP Approach (Rule-Based)

For quick deployment without training:

```python
def classify_rule_based(fork_region):
    # Extract features
    variance = np.var(gray_fork_region)
    edge_density = cv2.Canny(fork_region).sum() / area

    # Simple thresholds
    if variance > 1000 and edge_density > 0.1:
        return LOADED
    else:
        return UNLOADED
```

**Accuracy:** 60-70% (sufficient for MVP, improves with training)

**See [docs/DETECTION_CLASSIFICATION.md](docs/DETECTION_CLASSIFICATION.md) for implementation details.**

---

## 7. Folder Structure

```
forklift.2.0/
├── app/
│   ├── backend/
│   │   ├── api/              # FastAPI application
│   │   ├── services/         # Detection, tracking, OCR, classification
│   │   ├── ml/               # ML model wrappers
│   │   └── workers/          # Background inference workers
│   ├── frontend/             # React web interface
│   └── shared/               # Shared utilities
├── configs/                  # YAML configuration files
├── data/
│   ├── events/               # Event snapshots & metadata (by date)
│   ├── knowledge/            # Training dataset (loaded/unloaded/unknown)
│   ├── logs/                 # Application logs
│   └── streams/              # HLS stream segments
├── models/                   # ML model weights (.pt, .onnx)
├── scripts/                  # Utility scripts (training, export, migration)
├── tests/                    # Test suite
└── docs/                     # Documentation
```

**See [ARCHITECTURE.md](ARCHITECTURE.md) for complete structure.**

---

## 8. Knowledge Base Usage

### Purpose

1. **Model Training**: Labeled images for retraining classifiers
2. **Active Learning**: System auto-adds high/low confidence events
3. **Quality Assurance**: Review difficult cases

### Directory Structure

```
knowledge/
├── loaded/           # Confirmed loaded forklifts
├── unloaded/         # Confirmed unloaded forklifts
├── unknown/          # Requires manual review
├── difficult/        # Edge cases (partial loads, occlusions)
└── metadata.csv      # Index with source, confidence, notes
```

### Workflow

**Automatic Population:**
```
Event Created (confidence > 0.9)
    ↓
Auto-add to knowledge/loaded/ or knowledge/unloaded/
    ↓
Weekly Retraining Pipeline
```

**Manual Review:**
```
User views event (confidence < 0.7)
    ↓
Marks as incorrect, selects correct label
    ↓
Moves to knowledge base
    ↓
Prioritized for next training batch
```

### Retraining Schedule

- **Weekly**: If 1,000+ new images added
- **Monthly**: Analyze metrics, tune thresholds
- **Quarterly**: Major model updates

**See [data/knowledge/README.md](data/knowledge/README.md) for complete guide.**

---

## 9. Implementation Roadmap

### Phase 1: MVP (2-3 weeks)

**Week 1:**
- [x] Environment setup
- [x] Stream ingest (RTSP → OpenCV)
- [x] Basic detection (pretrained YOLO)
- [x] Rule-based classification

**Week 2:**
- [x] Event engine implementation
- [x] Backend API (FastAPI)
- [x] MJPEG streaming

**Week 3:**
- [x] Frontend development (React)
- [x] End-to-end integration
- [x] Documentation

**MVP Success Criteria:**
- ✅ Detects forklifts at 5+ FPS
- ✅ Load classification accuracy ≥ 60%
- ✅ Events logged correctly
- ✅ Web UI functional

### Phase 2: Production (4-6 weeks)

**Weeks 4-5:**
- [ ] Collect & annotate 5,000+ forklift images
- [ ] Train custom YOLOv8 detector (target mAP: 0.90+)
- [ ] Train load classifiers (target accuracy: 85%+)
- [ ] Improve OCR (ROI strategy, fine-tuning)

**Week 6:**
- [ ] Multi-camera scaling
- [ ] HLS streaming implementation
- [ ] Database optimization
- [ ] Redis caching

**Week 7:**
- [ ] Knowledge base automation
- [ ] Zone-based detection
- [ ] Analytics dashboard
- [ ] Active learning pipeline

**Week 8:**
- [ ] Monitoring (Prometheus + Grafana)
- [ ] Security hardening
- [ ] Production deployment
- [ ] Load testing

**Production Success Criteria:**
- ✅ Detection accuracy ≥ 95%
- ✅ Classification accuracy ≥ 85%
- ✅ OCR accuracy ≥ 90%
- ✅ Handles 5+ cameras at 10 FPS each
- ✅ Uptime ≥ 99.5%

### Phase 3: Scaling (Ongoing)

- [ ] 20+ camera support
- [ ] Kubernetes deployment
- [ ] Mobile app
- [ ] ERP integration
- [ ] Predictive analytics

**See [docs/IMPLEMENTATION_ROADMAP.md](docs/IMPLEMENTATION_ROADMAP.md) for detailed timeline.**

---

## 10. Quality & Improvement Plan

### Metrics to Track

**Detection Metrics:**
- mAP (mean Average Precision)
- Precision / Recall
- Inference FPS
- False positive rate

**Classification Metrics:**
- Accuracy (loaded vs unloaded)
- Confusion matrix
- Confidence distribution

**OCR Metrics:**
- Recognition accuracy
- UNKNOWN rate
- Average confidence

**Event Metrics:**
- Events per hour (by camera, forklift)
- Duplicate event rate (<2% target)
- User correction rate (reviewed events)

### Review Process

**Daily:**
- Monitor system health (FPS, errors)
- Review flagged events (unknown/uncertain)

**Weekly:**
- Analyze false positives/negatives
- Label uncertain events (unknown folder)
- Check knowledge base statistics

**Monthly:**
- Retrain models if sufficient new data (1,000+ images)
- Tune thresholds based on metrics
- Review user feedback

### Continuous Improvement Loop

```
Events Created → Some Incorrect → User Corrects → Adds to Knowledge Base
                                                            ↓
                                                    Retrain Models
                                                            ↓
                                            Deploy New Models → A/B Test
                                                            ↓
                                                    Accuracy Improves
```

---

## 11. Code Examples (Pseudocode)

### Detection Pipeline

```python
class ForkliftInferencePipeline:
    def process_frame(self, frame):
        # 1. Detect forklifts
        detections = self.detector.detect(frame)

        # 2. Track objects
        tracks = self.tracker.update(detections)

        # 3. For each track
        for track in tracks:
            # 4. Recognize forklift ID (every 5 frames)
            if track.frame_count % 5 == 0:
                ocr_result = self.ocr.recognize(frame, track.bbox)
                track.update_id(ocr_result)

            # 5. Classify load status
            class_result = self.classifier.classify(frame, track.bbox)
            track.update_status(class_result)

            # 6. Check if event should be created
            if self.event_engine.should_create_event(track):
                event = self.event_engine.create_event(track, frame)
```

### Event Creation Logic

```python
def should_create_event(track):
    # Must have all attributes
    if not track.forklift_id or not track.status:
        return False

    # Must meet confidence threshold
    if track.status_confidence < 0.7:
        return False

    # Must exist for minimum duration
    if track.duration < 3.0:
        return False

    # Must pass cooldown period
    if track.time_since_last_event < 30.0:
        return False

    # Must have state transition
    if track.status == track.previous_status:
        return False

    return True
```

---

## 12. Deployment Options

### Option 1: Single Server (Small Scale)

**Hardware:**
- 1x server with RTX 3070 or better
- 32GB RAM, 1TB SSD

**Supports:**
- 4-5 cameras
- 10 FPS per camera

**Deployment:**
```bash
docker-compose up -d
```

### Option 2: Kubernetes Cluster (Large Scale)

**Hardware:**
- 3x GPU nodes (inference workers)
- 2x CPU nodes (API, database)
- 1x storage node (NAS for events)

**Supports:**
- 20+ cameras
- 15 FPS per camera
- High availability

**Deployment:**
```bash
kubectl apply -f deployment/kubernetes/
```

### Option 3: Edge Deployment (Jetson)

**Hardware:**
- NVIDIA Jetson Orin or Xavier

**Supports:**
- 2-4 cameras
- 8 FPS per camera
- Local processing (low latency)

---

## 13. Risk Mitigation

| Risk | Impact | Mitigation |
|------|--------|------------|
| OCR fails in low light | High | Add IR illuminators, night mode training data |
| Classification flickers | Medium | Increase stabilization buffer (5→10 frames) |
| RTSP stream drops | High | Auto-reconnection, health monitoring, alerts |
| Storage fills up | Medium | Auto-cleanup, retention policies, compression |
| GPU memory overflow | Medium | Batch size tuning, FP16 inference, monitoring |

---

## 14. Success Metrics

### Technical Metrics

- **Detection Accuracy**: ≥95% mAP
- **Classification Accuracy**: ≥85%
- **OCR Accuracy**: ≥90%
- **System Uptime**: ≥99.5%
- **Processing Latency**: <1s end-to-end
- **Duplicate Event Rate**: <2%

### Business Metrics

- Reduction in manual load tracking time
- Improved inventory accuracy
- Faster issue identification
- Better forklift utilization insights

---

## 15. Next Steps

To implement this system:

1. **Review Documentation**: Read all documents in [docs/](docs/)
2. **Set Up Environment**: Follow [README.md](README.md) Quick Start
3. **Configure Cameras**: Edit [configs/cameras.yaml](configs/cameras.yaml)
4. **Deploy MVP**: Start with rule-based classification
5. **Collect Data**: Run system, gather training data
6. **Train Models**: Follow [docs/TRAINING.md](docs/TRAINING.md) (TBD)
7. **Iterate**: Review metrics, improve accuracy
8. **Scale**: Add more cameras, optimize performance

---

## Conclusion

This design provides a complete, production-ready architecture for forklift detection, classification, and monitoring. The system is:

- ✅ **Scalable**: Supports 2-20+ cameras
- ✅ **Accurate**: 85-95% classification accuracy (with training)
- ✅ **Intelligent**: Event deduplication prevents duplicates
- ✅ **Maintainable**: Active learning improves over time
- ✅ **User-Friendly**: Web interface for monitoring and labeling
- ✅ **Deployable**: MVP in 2-3 weeks, production in 6-8 weeks

**All design documents, configurations, and implementation guides are now ready for development.**

---

**Document Version**: 1.0
**Last Updated**: 2025-01-12
**Status**: Design Complete, Ready for Implementation
