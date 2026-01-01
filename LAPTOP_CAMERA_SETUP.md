# Laptop/USB Camera Setup Guide

This guide explains how to use the forklift detection system with a laptop camera or USB camera instead of RTSP network cameras.

---

## Quick Setup (Laptop Camera)

### Step 1: Use Laptop Camera Config

```bash
# Copy laptop camera config
cp configs/cameras_laptop.yaml configs/cameras.yaml

# Or edit configs/cameras.yaml directly
nano configs/cameras.yaml
```

### Step 2: Verify Camera Access

Test your laptop camera:

```bash
# Install OpenCV if not already installed
pip install opencv-python

# Test camera access (Python)
python -c "
import cv2
cap = cv2.VideoCapture(0)
if cap.isOpened():
    print('✅ Camera 0 is accessible')
    ret, frame = cap.read()
    if ret:
        print(f'✅ Frame size: {frame.shape}')
    else:
        print('❌ Could not read frame')
    cap.release()
else:
    print('❌ Camera 0 is not accessible')
"
```

**Common Issues:**
- **Permission denied**: On Linux, add user to `video` group: `sudo usermod -a -G video $USER`
- **Camera not found**: Try different indices (1, 2, 3) if 0 doesn't work
- **Already in use**: Close other apps using camera (Zoom, Skype, etc.)

### Step 3: Configure for Laptop Camera

Edit [configs/cameras.yaml](configs/cameras.yaml):

```yaml
cameras:
  - camera_id: laptop_camera
    name: "Laptop Camera"
    type: "usb"
    device_index: 0  # Change to 1, 2, etc. if needed
    resolution: "1280x720"
    fps: 15
    enabled: true
```

### Step 4: Adjust Thresholds for Testing

Edit [configs/thresholds.yaml](configs/thresholds.yaml):

```yaml
# Lower thresholds for testing/demo (more detections)
detection:
  forklift_confidence: 0.4  # Lower from 0.6 for testing

classification:
  loaded_confidence: 0.6  # Lower from 0.7
  unloaded_confidence: 0.6

event_creation:
  min_track_duration: 2.0  # Lower from 3.0 for faster testing
  cooldown_seconds: 10  # Lower from 30 for testing
  require_state_transition: false  # Disable for initial testing
```

**Note**: These are testing thresholds. Use higher values in production.

### Step 5: Start the System

```bash
# Activate virtual environment
source venv/bin/activate

# Start inference worker (processes camera feed)
python app/backend/workers/inference_worker.py &

# Start API server (in another terminal)
cd app/backend
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload &

# Start frontend (in another terminal)
cd app/frontend
npm run dev
```

**Or use Docker:**
```bash
docker-compose -f docker-compose-laptop.yml up
```

---

## USB Camera Setup (Next Week)

### Step 1: Connect USB Camera

1. Plug in USB camera
2. Verify it's detected:

```bash
# Linux/Mac
ls /dev/video*
# Should show: /dev/video0, /dev/video1, etc.

# Windows
# Use Device Manager to check

# Test with Python
python -c "
import cv2
for i in range(4):
    cap = cv2.VideoCapture(i)
    if cap.isOpened():
        print(f'✅ Camera {i} is available')
        ret, frame = cap.read()
        if ret:
            print(f'   Resolution: {frame.shape[1]}x{frame.shape[0]}')
        cap.release()
    else:
        print(f'❌ Camera {i} not found')
"
```

### Step 2: Configure USB Camera

Edit [configs/cameras.yaml](configs/cameras.yaml):

```yaml
cameras:
  - camera_id: usb_camera_1
    name: "USB Camera - Warehouse"
    type: "usb"
    device_index: 1  # Usually 1 if laptop camera is 0
    resolution: "1920x1080"  # USB cameras usually support higher res
    fps: 25
    enabled: true

    # Optional: Camera position and mounting info
    location: "Warehouse - Entry Point"
    mounting_height: "3.5m"
    angle: "45deg"

    # Detection zones (optional)
    zones:
      - zone_id: entry_zone
        name: "Entry Area"
        polygon:
          - [200, 300]
          - [1700, 300]
          - [1700, 900]
          - [200, 900]
```

### Step 3: Test Multiple Cameras

If using both laptop camera (testing) and USB camera (production):

```yaml
cameras:
  # Laptop camera (for development/testing)
  - camera_id: laptop_camera
    name: "Laptop Camera (Dev)"
    type: "usb"
    device_index: 0
    enabled: true  # Keep enabled for testing

  # USB camera (for forklift monitoring)
  - camera_id: usb_camera_1
    name: "USB Camera (Production)"
    type: "usb"
    device_index: 1
    enabled: true
```

Both will be processed simultaneously.

---

## Camera Stream Implementation

### Modified Stream Ingest (USB Camera Support)

The system needs to support both USB and RTSP cameras. Here's the implementation approach:

```python
# app/backend/services/stream_ingest.py
import cv2

class CameraStream:
    def __init__(self, camera_config):
        self.config = camera_config
        self.camera_type = camera_config.get('type', 'rtsp')

        if self.camera_type == 'usb':
            # USB/Laptop camera
            device_index = camera_config.get('device_index', 0)
            self.cap = cv2.VideoCapture(device_index)

            # Set resolution
            width, height = self._parse_resolution(camera_config.get('resolution', '1280x720'))
            self.cap.set(cv2.CAP_PROP_FRAME_WIDTH, width)
            self.cap.set(cv2.CAP_PROP_FRAME_HEIGHT, height)

            # Set FPS
            fps = camera_config.get('fps', 30)
            self.cap.set(cv2.CAP_PROP_FPS, fps)

        elif self.camera_type == 'rtsp':
            # RTSP network camera
            rtsp_url = camera_config['rtsp_url']
            self.cap = cv2.VideoCapture(rtsp_url)

        if not self.cap.isOpened():
            raise RuntimeError(f"Failed to open camera: {camera_config['camera_id']}")

    def read_frame(self):
        ret, frame = self.cap.read()
        if not ret:
            return None
        return frame

    def release(self):
        self.cap.release()
```

---

## Testing Without Real Forklifts

### Option 1: Use Test Videos

Download sample forklift videos:

```bash
mkdir -p data/input

# Download sample videos (you'll need to find these)
# Or record your own test footage
```

Configure to use video file:

```yaml
# configs/cameras.yaml
testing:
  use_video_file: true
  video_file_path: "data/input/forklift_test.mp4"
  loop_video: true
```

### Option 2: Mock Detection Mode

For UI/frontend testing without a camera:

```yaml
# configs/cameras.yaml
testing:
  mock_mode: true
  mock_detection_interval: 3  # Generate fake detection every 3 seconds
```

This generates synthetic detection events for testing the web interface.

### Option 3: Test with Toy Forklifts

For laptop camera testing:
- Use toy forklifts or forklift images
- Print forklift photos and hold them up to camera
- Use forklift videos playing on another screen

**Tips for Testing:**
- Place objects on toy forklift to test LOADED detection
- Remove objects to test UNLOADED classification
- Add printed IDs (e.g., "FL-001") to test OCR

---

## Performance Considerations (Laptop)

### CPU vs GPU

**Laptop with GPU (NVIDIA):**
```bash
# Check if CUDA is available
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"

# If available, use GPU (default)
# Edit .env:
MODEL_DEVICE="cuda"
```

**Laptop without GPU (CPU only):**
```bash
# Edit .env:
MODEL_DEVICE="cpu"
USE_HALF_PRECISION="false"

# Lower thresholds in configs/thresholds.yaml:
performance:
  inference_fps: 5  # Process only 5 frames per second
  batch_size: 1
```

**Expected Performance:**

| Hardware | FPS | Latency |
|----------|-----|---------|
| Laptop GPU (GTX 1650+) | 8-10 | <1s |
| Laptop CPU (i7/i9) | 2-4 | 2-3s |
| Laptop CPU (i5) | 1-2 | 3-5s |

### Optimize for Laptop Performance

Edit [configs/thresholds.yaml](configs/thresholds.yaml):

```yaml
performance:
  inference_fps: 5  # Lower FPS for laptop (vs 10 for server)
  num_workers: 1  # Single worker on laptop
  frame_buffer_size: 30  # Smaller buffer

# Use smaller models for faster inference
models:
  forklift_detector:
    type: "yolov8n"  # Use nano (fastest) instead of medium
    path: "models/yolov8n.pt"
```

Download nano model:
```bash
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt -O models/forklift_detector_v1.pt
```

---

## Troubleshooting

### Camera Not Working

**Issue**: `Cannot open camera 0`

**Solutions:**
1. Check permissions:
   ```bash
   # Linux
   sudo usermod -a -G video $USER
   # Log out and back in
   ```

2. Try different device indices:
   ```python
   # Test all cameras
   python scripts/test_cameras.py
   ```

3. Close other applications using camera

4. Verify camera in system:
   ```bash
   # Linux
   v4l2-ctl --list-devices

   # Mac
   system_profiler SPCameraDataType

   # Windows
   # Device Manager → Cameras
   ```

### Low FPS

**Issue**: Processing too slow on laptop

**Solutions:**
1. Lower resolution in `cameras.yaml`:
   ```yaml
   resolution: "640x480"  # Lower resolution
   ```

2. Reduce inference FPS:
   ```yaml
   inference_fps: 3  # Process every 3rd frame
   ```

3. Use smaller model (YOLOv8-nano):
   ```bash
   wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt
   ```

4. Disable features:
   ```yaml
   features:
     zones: false
     video_clips: false
   ```

### Camera Image Flipped/Rotated

Add flip/rotate to config:

```yaml
cameras:
  - camera_id: laptop_camera
    properties:
      flip_horizontal: true
      flip_vertical: false
      rotate: 0  # 0, 90, 180, 270
```

---

## Development Workflow

### Week 1 (This Week): Laptop Camera Testing

**Goals:**
- ✅ Verify system works with laptop camera
- ✅ Test detection pipeline (even without real forklifts)
- ✅ Debug web interface
- ✅ Test event creation and logging
- ✅ Familiarize with system

**Steps:**
1. Set up laptop camera
2. Run system with mock/test data
3. Verify all components work
4. Review and understand codebase
5. Plan USB camera placement for next week

### Week 2: USB Camera Deployment

**Goals:**
- ✅ Mount USB camera in test area
- ✅ Configure proper camera angle
- ✅ Test with real forklifts (or forklift mockups)
- ✅ Tune detection thresholds
- ✅ Begin collecting training data

**Steps:**
1. Mount USB camera (3-4m height, angled view)
2. Configure `cameras.yaml` with USB camera
3. Test detection with real forklifts
4. Adjust thresholds based on results
5. Start knowledge base collection

### Week 3+: Production Deployment

**Goals:**
- ✅ Train custom models with collected data
- ✅ Deploy multiple cameras
- ✅ Fine-tune classification
- ✅ Scale to production

---

## Camera Placement Tips (For Next Week)

### Optimal USB Camera Setup

**Mounting:**
- **Height**: 3-4 meters (10-13 feet)
- **Angle**: 30-45 degrees downward
- **Distance**: 5-15 meters from forklift path
- **Lighting**: Avoid direct sunlight, ensure even lighting

**Good Placement:**
```
        Camera (3m high, 45° down)
           🎥
            \
             \
              \  <-- 5-10m -->
               ⚠️ Detection Zone
              [   Forklift   ]
              [   FL-001     ]
              [______________|]
```

**What to Avoid:**
- ❌ Direct sunlight/glare
- ❌ Obstructions (pillars, shelves)
- ❌ Too low (can't see fork region)
- ❌ Too far (ID not readable)

---

## Next Steps

### This Week (Laptop Camera)
```bash
# 1. Set up laptop camera
cp configs/cameras_laptop.yaml configs/cameras.yaml

# 2. Test camera
python scripts/test_cameras.py

# 3. Start system
python app/backend/workers/inference_worker.py

# 4. Test with toy forklifts or images
# Hold forklift images up to camera, observe detections

# 5. Explore web UI
# Open http://localhost:5173
```

### Next Week (USB Camera)
```bash
# 1. Connect USB camera, find device index
python scripts/test_cameras.py

# 2. Update config
nano configs/cameras.yaml
# Set device_index to USB camera (usually 1)

# 3. Mount camera in test area

# 4. Start collecting real data

# 5. Begin model training with collected images
```

---

## Example: Test Script

Save this as [scripts/test_cameras.py](scripts/test_cameras.py):

```python
#!/usr/bin/env python3
"""Test all available cameras and display their properties."""

import cv2

def test_cameras(max_cameras=5):
    """Test camera devices 0 through max_cameras-1."""
    print("Testing available cameras...\n")

    available_cameras = []

    for i in range(max_cameras):
        cap = cv2.VideoCapture(i)

        if cap.isOpened():
            ret, frame = cap.read()

            if ret:
                height, width = frame.shape[:2]
                fps = cap.get(cv2.CAP_PROP_FPS)

                print(f"✅ Camera {i}:")
                print(f"   Resolution: {width}x{height}")
                print(f"   FPS: {fps}")
                print()

                available_cameras.append(i)

                # Display frame
                cv2.imshow(f'Camera {i}', frame)
                cv2.waitKey(1000)  # Show for 1 second
                cv2.destroyAllWindows()

            cap.release()
        else:
            print(f"❌ Camera {i}: Not available\n")

    if available_cameras:
        print(f"\nFound {len(available_cameras)} camera(s): {available_cameras}")
        print(f"\nUse device_index: {available_cameras[0]} in configs/cameras.yaml")
    else:
        print("\n⚠️  No cameras found!")
        print("   - Check camera permissions")
        print("   - Ensure camera is not in use by another app")
        print("   - Try running: sudo usermod -a -G video $USER")

if __name__ == "__main__":
    test_cameras()
```

Make it executable:
```bash
chmod +x scripts/test_cameras.py
python scripts/test_cameras.py
```

---

**You're all set for laptop camera testing this week, and ready to deploy USB camera next week!** 🚀
