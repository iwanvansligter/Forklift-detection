# Forklift Detection System - Folder Structure

```
forklift.2.0/
│
├── README.md
├── ARCHITECTURE.md                 # This file
├── docker-compose.yml              # Multi-container orchestration
├── .env.example                    # Environment variables template
├── requirements.txt                # Python dependencies
│
├── app/                            # Application code
│   ├── backend/                    # Backend services
│   │   ├── api/                    # FastAPI application
│   │   │   ├── __init__.py
│   │   │   ├── main.py             # FastAPI entry point
│   │   │   ├── routes/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── stream.py       # GET /api/stream, /api/cameras
│   │   │   │   ├── events.py       # Events CRUD endpoints
│   │   │   │   ├── knowledge.py    # Knowledge base management
│   │   │   │   ├── websocket.py    # WebSocket for live updates
│   │   │   │   └── health.py       # Health check endpoints
│   │   │   ├── models/             # Pydantic models
│   │   │   │   ├── __init__.py
│   │   │   │   ├── event.py
│   │   │   │   ├── forklift.py
│   │   │   │   └── camera.py
│   │   │   ├── database/
│   │   │   │   ├── __init__.py
│   │   │   │   ├── connection.py   # DB connection pool
│   │   │   │   ├── models.py       # SQLAlchemy models
│   │   │   │   └── crud.py         # Database operations
│   │   │   └── utils/
│   │   │       ├── __init__.py
│   │   │       ├── auth.py         # Authentication (if needed)
│   │   │       └── validators.py
│   │   │
│   │   ├── services/               # Core processing services
│   │   │   ├── __init__.py
│   │   │   ├── stream_ingest.py    # RTSP/video ingestion
│   │   │   ├── detection.py        # Forklift detection (YOLO)
│   │   │   ├── tracking.py         # Object tracking (ByteTrack)
│   │   │   ├── ocr.py              # ID recognition (OCR)
│   │   │   ├── classification.py   # Load classification
│   │   │   ├── event_engine.py     # Event creation & deduplication
│   │   │   └── stream_server.py    # HLS/MJPEG streaming
│   │   │
│   │   ├── ml/                     # Machine learning models
│   │   │   ├── __init__.py
│   │   │   ├── forklift_detector.py
│   │   │   ├── load_classifier.py
│   │   │   ├── pallet_detector.py
│   │   │   └── preprocessors.py
│   │   │
│   │   └── workers/                # Background workers
│   │       ├── __init__.py
│   │       ├── inference_worker.py # Main detection pipeline
│   │       └── cleanup_worker.py   # Cleanup old data
│   │
│   ├── frontend/                   # React frontend
│   │   ├── public/
│   │   │   ├── index.html
│   │   │   └── favicon.ico
│   │   ├── src/
│   │   │   ├── App.tsx             # Main app component
│   │   │   ├── index.tsx           # Entry point
│   │   │   ├── components/
│   │   │   │   ├── LiveView/
│   │   │   │   │   ├── CameraStream.tsx
│   │   │   │   │   ├── DetectionOverlay.tsx
│   │   │   │   │   └── CameraSelector.tsx
│   │   │   │   ├── Events/
│   │   │   │   │   ├── EventFeed.tsx
│   │   │   │   │   ├── EventDetail.tsx
│   │   │   │   │   ├── EventFilter.tsx
│   │   │   │   │   └── LabelingDialog.tsx
│   │   │   │   ├── Knowledge/
│   │   │   │   │   ├── KnowledgeGallery.tsx
│   │   │   │   │   ├── ImageUploader.tsx
│   │   │   │   │   └── StatsPanel.tsx
│   │   │   │   └── Common/
│   │   │   │       ├── Navbar.tsx
│   │   │   │       ├── LoadingSpinner.tsx
│   │   │   │       └── ErrorBoundary.tsx
│   │   │   ├── pages/
│   │   │   │   ├── Dashboard.tsx
│   │   │   │   ├── LiveViewPage.tsx
│   │   │   │   ├── EventsPage.tsx
│   │   │   │   ├── KnowledgePage.tsx
│   │   │   │   └── SettingsPage.tsx
│   │   │   ├── services/
│   │   │   │   ├── api.ts          # API client
│   │   │   │   └── websocket.ts    # WebSocket client
│   │   │   ├── hooks/
│   │   │   │   ├── useWebSocket.ts
│   │   │   │   ├── useEvents.ts
│   │   │   │   └── useCameras.ts
│   │   │   ├── types/
│   │   │   │   └── index.ts        # TypeScript types
│   │   │   └── utils/
│   │   │       └── helpers.ts
│   │   ├── package.json
│   │   ├── tsconfig.json
│   │   └── vite.config.ts
│   │
│   └── shared/                     # Shared utilities
│       ├── __init__.py
│       ├── config.py               # Configuration loader
│       ├── logger.py               # Logging setup
│       └── constants.py            # Shared constants
│
├── configs/                        # Configuration files
│   ├── cameras.yaml                # Camera definitions
│   ├── thresholds.yaml             # Detection thresholds
│   ├── zones.yaml                  # Detection zones (optional)
│   ├── app.yaml                    # Application settings
│   └── database.yaml               # Database configuration
│
├── data/                           # Data storage
│   ├── input/                      # Input videos for testing
│   │   └── .gitkeep
│   ├── events/                     # Event data
│   │   ├── YYYY-MM-DD/             # Organized by date
│   │   │   └── <event_id>/
│   │   │       ├── snapshot.jpg    # Full frame
│   │   │       ├── crop.jpg        # Forklift crop
│   │   │       ├── metadata.json   # Event metadata
│   │   │       └── clip.mp4        # 5-sec video clip (optional)
│   │   └── .gitkeep
│   ├── logs/                       # Application logs
│   │   ├── api.log
│   │   ├── inference.log
│   │   └── errors.log
│   ├── knowledge/                  # Training/review dataset
│   │   ├── README.md               # Knowledge base usage guide
│   │   ├── loaded/                 # Confirmed loaded images
│   │   │   ├── <forklift_id>_<timestamp>.jpg
│   │   │   └── ...
│   │   ├── unloaded/               # Confirmed unloaded images
│   │   │   ├── <forklift_id>_<timestamp>.jpg
│   │   │   └── ...
│   │   ├── unknown/                # Uncertain/unlabeled
│   │   │   └── ...
│   │   ├── difficult/              # Edge cases for review
│   │   │   └── ...
│   │   └── metadata.csv            # Index of all images
│   ├── streams/                    # HLS stream fragments
│   │   ├── camera_1/
│   │   │   ├── stream.m3u8
│   │   │   ├── segment_001.ts
│   │   │   └── ...
│   │   └── .gitkeep
│   └── database/                   # SQLite database (if not using PostgreSQL)
│       └── forklift.db
│
├── models/                         # ML model weights
│   ├── forklift_detector_v1.pt     # YOLOv8 forklift detector
│   ├── forklift_detector_v1.onnx   # ONNX export for deployment
│   ├── load_classifier_v1.pt       # Binary classifier
│   ├── pallet_detector_v1.pt       # Pallet detector
│   └── model_versions.json         # Model version tracking
│
├── scripts/                        # Utility scripts
│   ├── train/                      # Training scripts
│   │   ├── train_forklift_detector.py
│   │   ├── train_load_classifier.py
│   │   └── prepare_dataset.py
│   ├── export_models.py            # Export to ONNX/TensorRT
│   ├── import_knowledge.py         # Import labeled images
│   ├── database_init.py            # Initialize database
│   ├── migrate_events.py           # Data migration utilities
│   └── benchmark.py                # Performance benchmarking
│
├── tests/                          # Test suite
│   ├── unit/
│   │   ├── test_detection.py
│   │   ├── test_tracking.py
│   │   ├── test_ocr.py
│   │   └── test_classification.py
│   ├── integration/
│   │   ├── test_pipeline.py
│   │   └── test_api.py
│   └── fixtures/
│       └── sample_videos/
│
├── docs/                           # Documentation
│   ├── API.md                      # API documentation
│   ├── DEPLOYMENT.md               # Deployment guide
│   ├── TRAINING.md                 # Model training guide
│   ├── TROUBLESHOOTING.md
│   └── images/                     # Documentation images
│
└── deployment/                     # Deployment configurations
    ├── docker/
    │   ├── Dockerfile.backend
    │   ├── Dockerfile.frontend
    │   └── Dockerfile.inference
    ├── kubernetes/                 # K8s manifests (for scaling)
    │   ├── deployment.yaml
    │   ├── service.yaml
    │   └── ingress.yaml
    └── nginx/
        └── nginx.conf              # Reverse proxy config
```

## Key Design Decisions

### 1. Date-based Event Organization
Events are stored in `data/events/YYYY-MM-DD/<event_id>/` for:
- Easy cleanup of old data
- Efficient time-range queries
- Better file system performance

### 2. Knowledge Base Structure
- **loaded/**, **unloaded/**: High-confidence labeled data for retraining
- **unknown/**: Requires manual review
- **difficult/**: Edge cases (partial loads, unusual angles, occlusions)
- **metadata.csv**: Tracks origin, labeling source (auto/manual/reviewed), confidence

### 3. Stream Fragments
HLS segments stored in `data/streams/` with automatic cleanup (keep last 2 minutes)

### 4. Model Versioning
All models tracked in `models/model_versions.json`:
```json
{
  "forklift_detector": {
    "version": "v1.2",
    "path": "forklift_detector_v1.2.pt",
    "trained_on": "2025-01-15",
    "mAP": 0.94,
    "training_images": 15000
  }
}
```

### 5. Configuration Separation
- `cameras.yaml`: Camera-specific settings (RTSP URLs, zones)
- `thresholds.yaml`: Detection/classification thresholds (tunable without code changes)
- `zones.yaml`: Optional spatial zones for triggering events
