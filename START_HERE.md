# 🚀 START HERE - Forklift Detection System

## Your 2-Week Plan

### This Week: Laptop Camera Testing ✅
- Use built-in laptop camera for development and testing
- Learn the system, explore features
- No real forklifts needed yet

### Next Week: USB Camera Deployment 📸
- Connect USB camera
- Mount in test area
- Start monitoring real forklifts

---

## ⚡ Quick Start (5 Minutes)

### Step 1: Test Your Camera

```bash
python scripts/test_cameras.py
```

Expected: `Camera 0: ✅ FOUND`

### Step 2: Setup Configuration

```bash
# Use laptop camera config
cp configs/cameras_laptop.yaml configs/cameras.yaml
```

### Step 3: Install Dependencies

```bash
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### Step 4: Download Model

```bash
# Fast nano model (best for laptop)
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -O models/forklift_detector_v1.pt
```

### Step 5: Test Detection

```bash
# Simple test (no database, just detection)
python scripts/test_detection_laptop.py
```

A window should open showing your camera feed with detection boxes!

---

## 📚 Essential Documentation

**Start Here:**
1. [GETTING_STARTED_LAPTOP.md](GETTING_STARTED_LAPTOP.md) - Laptop camera setup (this week)
2. [LAPTOP_CAMERA_SETUP.md](LAPTOP_CAMERA_SETUP.md) - Detailed camera guide (this + next week)

**System Overview:**
3. [README.md](README.md) - Main documentation
4. [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Developer cheat sheet

**Complete Design:**
5. [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md) - Complete system design
6. [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
7. [docs/](docs/) - Detailed documentation (API, ML, UI, etc.)

---

## 🎯 This Week's Goals

- [ ] Get laptop camera working (`python scripts/test_cameras.py`)
- [ ] See detections on screen (`python scripts/test_detection_laptop.py`)
- [ ] Understand configuration files (`configs/*.yaml`)
- [ ] Explore documentation
- [ ] Plan USB camera placement for next week

---

## 🔧 Configuration Files

All settings in `configs/` directory:

| File | Purpose |
|------|---------|
| [cameras.yaml](configs/cameras.yaml) | Camera setup (USB/RTSP) |
| [thresholds.yaml](configs/thresholds.yaml) | Detection/classification thresholds |
| [app.yaml](configs/app.yaml) | API server, storage settings |
| [zones.yaml](configs/zones.yaml) | Detection zones (optional) |

---

## 📱 Testing Without Real Forklifts

**This Week (Laptop Camera):**
- Use forklift images on another screen
- Print forklift photos
- Use toy forklifts
- Find forklift videos online

**Goal:** Just verify the system runs and can detect objects!

---

## 🐛 Troubleshooting

### Camera not found?
```bash
python scripts/test_cameras.py
# Try index 1, 2, 3 if 0 doesn't work
```

### Model not found?
```bash
# Download it
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -O models/forklift_detector_v1.pt
```

### Slow performance?
```yaml
# Edit configs/thresholds.yaml
performance:
  inference_fps: 3  # Lower FPS
```

---

## 📍 Next Week: USB Camera

When your USB camera arrives:

```bash
# 1. Connect USB camera
# 2. Test it
python scripts/test_cameras.py

# 3. Update config
nano configs/cameras.yaml
# Change device_index to 1 (or whatever test_cameras.py shows)

# 4. Mount camera in test area
# Height: 3-4m, Angle: 30-45°, Distance: 5-15m

# 5. Start monitoring real forklifts!
```

See [LAPTOP_CAMERA_SETUP.md](LAPTOP_CAMERA_SETUP.md) for complete USB camera guide.

---

## 🎓 Learning Path

**Day 1:** Setup + Camera Test
- Run `test_cameras.py`
- Run `test_detection_laptop.py`
- See something detect on screen

**Day 2-3:** Explore System
- Read [GETTING_STARTED_LAPTOP.md](GETTING_STARTED_LAPTOP.md)
- Read [QUICK_REFERENCE.md](QUICK_REFERENCE.md)
- Browse `configs/` files

**Day 4-5:** Understand Design
- Read [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md)
- Understand event deduplication logic
- Understand classification strategy

**Day 6-7:** Plan Production
- Identify USB camera location
- Measure height, angle, distance
- Prepare for next week

---

## ✨ Key Features

**Completed Design Includes:**
- ✅ Real-time forklift detection (YOLOv8)
- ✅ Load classification (LOADED/UNLOADED)
- ✅ Forklift ID recognition (OCR)
- ✅ Event logging with deduplication
- ✅ Live web interface
- ✅ Knowledge base & active learning
- ✅ Multi-camera support
- ✅ REST API + WebSocket

**Everything is designed, documented, and ready to implement!**

---

## 📞 Need Help?

**Camera Issues:**
→ [LAPTOP_CAMERA_SETUP.md](LAPTOP_CAMERA_SETUP.md)

**General Setup:**
→ [GETTING_STARTED_LAPTOP.md](GETTING_STARTED_LAPTOP.md)

**System Questions:**
→ [README.md](README.md)
→ [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**Complete Design:**
→ [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md)
→ [docs/](docs/) directory

---

## 🎉 You're All Set!

```bash
# Quick test right now:
python scripts/test_cameras.py

# If camera found, test detection:
python scripts/test_detection_laptop.py
```

**Happy forklift detecting!** 🚛📸
