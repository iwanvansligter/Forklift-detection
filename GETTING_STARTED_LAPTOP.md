# Getting Started with Laptop Camera

Quick guide to get the forklift detection system running with your laptop camera this week, then transition to USB camera next week.

---

## ⚡ Quick Start (5 Minutes)

### 1. Test Your Laptop Camera

```bash
# Install dependencies
pip install opencv-python

# Test camera
python scripts/test_cameras.py
```

**Expected output:**
```
Testing camera 0... ✅ FOUND
   Resolution: 1280x720
   FPS: 30.0
```

### 2. Configure for Laptop Camera

```bash
# Use laptop camera configuration
cp configs/cameras_laptop.yaml configs/cameras.yaml
```

### 3. Adjust for Testing (Lower Thresholds)

Edit [configs/thresholds.yaml](configs/thresholds.yaml):

```yaml
detection:
  forklift_confidence: 0.4  # Lower for testing (was 0.6)

event_creation:
  min_track_duration: 2.0  # Faster events (was 3.0)
  cooldown_seconds: 10  # More frequent (was 30)
  require_state_transition: false  # Create events without transition
```

### 4. Download Model

```bash
# Create models directory
mkdir -p models

# Download pretrained YOLOv8 nano (fastest for laptop)
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -O models/forklift_detector_v1.pt

# Or if wget not available:
curl -L https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -o models/forklift_detector_v1.pt
```

### 5. Install Dependencies

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# Install requirements
pip install -r requirements.txt
```

### 6. Run System (Simplified for Testing)

**Option A: Test Detection Only (Easiest)**

```bash
# Simple detection test script
python scripts/test_detection_laptop.py
```

This will:
- Open your laptop camera
- Run forklift detection
- Display video with bounding boxes
- No event logging (just testing)

**Option B: Full System**

```bash
# Terminal 1: Start inference worker
python app/backend/workers/inference_worker.py

# Terminal 2: Start API server
cd app/backend
uvicorn api.main:app --host 0.0.0.0 --port 8000

# Terminal 3: Start frontend
cd app/frontend
npm install
npm run dev
```

Open http://localhost:5173 in your browser.

---

## 🧪 Testing Without Real Forklifts

Since you're using a laptop camera this week, here are ways to test:

### Method 1: Use Forklift Images

```bash
# Print or display forklift images on another screen
# Point laptop camera at the images

# Good test images:
# - Forklift with pallet (LOADED)
# - Empty forklift (UNLOADED)
# - Forklift with visible ID number
```

### Method 2: Use Toy Forklifts

- Use toy forklift models
- Add/remove objects to test LOADED/UNLOADED detection
- Attach printed ID labels (e.g., "FL-001")

### Method 3: Use Test Video

Download a forklift test video and configure:

```yaml
# configs/cameras.yaml
testing:
  use_video_file: true
  video_file_path: "data/input/forklift_test.mp4"
  loop_video: true
```

### Method 4: Mock Mode (UI Testing)

Test the web interface without real detections:

```yaml
# configs/cameras.yaml
testing:
  mock_mode: true
  mock_detection_interval: 3
```

---

## 📸 Camera Troubleshooting

### Camera Not Found

```bash
# Linux: Check video devices
ls -l /dev/video*

# Add user to video group
sudo usermod -a -G video $USER
# Log out and back in

# Test different indices
python scripts/test_cameras.py 10
```

### Camera Permission Denied

**Linux:**
```bash
sudo usermod -a -G video $USER
# Log out and log back in
```

**Mac:**
```
System Preferences → Security & Privacy → Camera
→ Allow Terminal/Python
```

**Windows:**
```
Settings → Privacy → Camera → Allow apps to access camera
```

### Camera Already in Use

Close other applications:
- Zoom
- Microsoft Teams
- Skype
- Google Meet
- Discord
- Any browser tabs with video

---

## 🎯 This Week's Goals

**Day 1-2: Setup**
- ✅ Get system running with laptop camera
- ✅ Verify detection works (even if not accurate)
- ✅ Explore web interface

**Day 3-4: Understanding**
- ✅ Read documentation
- ✅ Understand event creation logic
- ✅ Test with forklift images/videos
- ✅ Familiarize with configuration files

**Day 5-7: Planning**
- ✅ Plan USB camera placement for next week
- ✅ Identify where to mount camera (height, angle)
- ✅ Understand field of view needed
- ✅ Prepare test area

---

## 📋 Next Week: USB Camera Transition

### Before Next Week, Prepare:

1. **USB Camera**: Purchase if not available
   - Recommended: Logitech C920/C930e or similar
   - Resolution: 1080p minimum
   - USB 2.0/3.0

2. **Mounting**: Plan camera placement
   - Height: 3-4 meters
   - Angle: 30-45 degrees downward
   - Distance: 5-15 meters from forklift path

3. **Test Area**: Identify location
   - Good lighting
   - Clear view of forklift path
   - No obstructions

### When USB Camera Arrives:

```bash
# 1. Connect USB camera
# 2. Test it
python scripts/test_cameras.py

# 3. Update config (change device_index to 1 or 2)
nano configs/cameras.yaml

# 4. Restart system
# It should now use USB camera automatically
```

---

## 💻 Laptop Performance Tips

If your laptop is slow:

**1. Use Smaller Model:**
```bash
# YOLOv8-nano (fastest)
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -O models/forklift_detector_v1.pt
```

**2. Lower FPS:**
```yaml
# configs/thresholds.yaml
performance:
  inference_fps: 3  # Process fewer frames
```

**3. Lower Resolution:**
```yaml
# configs/cameras.yaml
cameras:
  - resolution: "640x480"  # Lower resolution
```

**4. Use CPU (if GPU not available):**
```bash
# .env
MODEL_DEVICE="cpu"
USE_HALF_PRECISION="false"
```

**Expected Performance:**

| Laptop Type | FPS | Usable? |
|-------------|-----|---------|
| Gaming (GPU) | 8-12 | ✅ Excellent |
| Modern (i7+) | 3-5 | ✅ Good |
| Older (i5) | 1-3 | ⚠️ Slow but works |

---

## 📞 Need Help?

**Camera Issues:**
- Run: `python scripts/test_cameras.py`
- Check: [LAPTOP_CAMERA_SETUP.md](LAPTOP_CAMERA_SETUP.md)

**Performance Issues:**
- Lower resolution in `cameras.yaml`
- Reduce FPS in `thresholds.yaml`
- Use nano model instead of medium

**General Questions:**
- Read: [README.md](README.md)
- See: [docs/](docs/) directory
- Check: [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

---

## ✅ Success Checklist

- [ ] Laptop camera detected (`python scripts/test_cameras.py`)
- [ ] Dependencies installed (`pip install -r requirements.txt`)
- [ ] Model downloaded (`models/forklift_detector_v1.pt` exists)
- [ ] Config set for USB camera (`configs/cameras.yaml`)
- [ ] System runs without errors
- [ ] Can see camera feed (even if no detections)
- [ ] Understand folder structure and configuration
- [ ] Planned USB camera setup for next week

---

**You're all set! Start with the laptop camera this week, learn the system, then deploy USB camera next week.** 🚀
