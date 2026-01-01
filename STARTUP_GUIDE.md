# System Startup Guide

Complete guide to starting and using the forklift detection system.

---

## Quick Start (After Installation)

### Option 1: Simple Test (Easiest - Recommended for First Time)

```bash
cd /workspaces/forklift.2.0
./start_simple.sh
```

This will:
1. Activate virtual environment
2. Download model if needed
3. Open your camera
4. Run detection and display results

**Controls:**
- Press **'q'** to quit
- Press **'s'** to save screenshot

---

## Step-by-Step Manual Startup

### Step 1: Activate Virtual Environment

```bash
cd /workspaces/forklift.2.0
source venv/bin/activate
```

You should see `(venv)` in your terminal prompt.

### Step 2: Download Model (First Time Only)

```bash
# Create models directory
mkdir -p models

# Download YOLOv8 nano (fast, good for laptop)
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -O models/forklift_detector_v1.pt

# Or use curl if wget not available
curl -L https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -o models/forklift_detector_v1.pt
```

**Model size:** ~6 MB (downloads in seconds)

### Step 3: Test Your Camera

```bash
python scripts/test_cameras.py
```

Expected output:
```
✅ Camera 0: FOUND
   Resolution: 1280x720
   FPS: 30
```

If camera not found, see troubleshooting below.

### Step 4: Run Simple Detection Test

```bash
python scripts/test_detection_laptop.py
```

A window will open showing your camera feed with detection bounding boxes.

---

## Full System Startup (Backend + Frontend + API)

### Terminal 1: Backend API

```bash
cd /workspaces/forklift.2.0
source venv/bin/activate

# Start FastAPI server
cd app/backend
uvicorn api.main:app --host 0.0.0.0 --port 8000 --reload
```

**Expected output:**
```
INFO: Uvicorn running on http://0.0.0.0:8000
INFO: Application startup complete.
```

### Terminal 2: Inference Worker

```bash
cd /workspaces/forklift.2.0
source venv/bin/activate

# Start detection worker
python app/backend/workers/inference_worker.py
```

This processes camera frames and creates events.

### Terminal 3: Frontend (Optional)

```bash
cd /workspaces/forklift.2.0/app/frontend

# Install dependencies (first time only)
npm install

# Start development server
npm run dev
```

**Access:** http://localhost:5173

---

## Verification Checklist

After starting the system, verify:

- [ ] Virtual environment activated (`(venv)` in prompt)
- [ ] Model downloaded (`ls -lh models/forklift_detector_v1.pt`)
- [ ] Camera accessible (`python scripts/test_cameras.py`)
- [ ] Detection working (`python scripts/test_detection_laptop.py`)
- [ ] API responding (`curl http://localhost:8000/api/health`)
- [ ] Events being created (check `data/events/`)

---

## Testing the System

### Test 1: Camera Detection

```bash
python scripts/test_detection_laptop.py
```

**What to expect:**
- Camera window opens
- Objects detected (may not be forklifts yet)
- Bounding boxes drawn
- Confidence scores shown

**Note:** Pretrained model detects general objects. For forklift-specific detection, you'll need to train a custom model later.

### Test 2: API Health Check

```bash
curl http://localhost:8000/api/health
```

**Expected response:**
```json
{
  "status": "healthy",
  "services": {
    "api": "healthy",
    "database": "healthy"
  }
}
```

### Test 3: Check Events

```bash
# List events directory
ls -la data/events/

# Check if any events created
find data/events -name "*.jpg" | head -5
```

---

## Configuration

### Camera Configuration

Edit `configs/cameras.yaml`:

```yaml
cameras:
  - camera_id: laptop_camera
    name: "Laptop Camera"
    type: "usb"
    device_index: 0  # Change if needed (1, 2, etc.)
    resolution: "1280x720"
    fps: 15
    enabled: true
```

### Adjust for Testing

Edit `configs/thresholds.yaml`:

```yaml
detection:
  forklift_confidence: 0.3  # Lower for testing (default: 0.6)

classification:
  loaded_confidence: 0.6    # Lower for testing (default: 0.7)
  unloaded_confidence: 0.6

event_creation:
  min_track_duration: 2.0   # Lower for testing (default: 3.0)
  cooldown_seconds: 10      # Lower for testing (default: 30)
  require_state_transition: false  # Disable for initial testing
```

**Note:** Use higher thresholds in production!

---

## Troubleshooting

### Camera Not Found

**Issue:** `Camera 0 not available`

**Solutions:**

1. **Try different indices:**
   ```bash
   python scripts/test_cameras.py 10
   ```

2. **Check permissions (Linux):**
   ```bash
   sudo usermod -a -G video $USER
   # Log out and back in
   ```

3. **Close other apps:**
   - Zoom, Teams, Skype, Discord
   - Any browser tabs using camera

4. **Check camera device:**
   ```bash
   # Linux
   ls -l /dev/video*

   # Mac
   system_profiler SPCameraDataType
   ```

### Model Not Found

**Issue:** `Model not found: models/forklift_detector_v1.pt`

**Solution:**
```bash
mkdir -p models
wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
  -O models/forklift_detector_v1.pt
```

### Port Already in Use

**Issue:** `Address already in use: 8000`

**Solution:**
```bash
# Find process using port 8000
lsof -i :8000

# Kill it
kill -9 <PID>

# Or use different port
uvicorn api.main:app --port 8001
```

### Slow Performance

**Issue:** Low FPS, system freezing

**Solutions:**

1. **Lower resolution:**
   ```yaml
   # configs/cameras.yaml
   resolution: "640x480"
   ```

2. **Reduce inference FPS:**
   ```yaml
   # configs/thresholds.yaml
   performance:
     inference_fps: 3
   ```

3. **Use CPU mode:**
   ```bash
   # .env
   MODEL_DEVICE="cpu"
   ```

### Import Errors

**Issue:** `ModuleNotFoundError: No module named 'xxx'`

**Solution:**
```bash
# Activate venv first
source venv/bin/activate

# Reinstall dependencies
pip install -r requirements.txt
```

---

## System Status Commands

### Check Running Processes

```bash
# List Python processes
ps aux | grep python

# Check if API is running
ps aux | grep uvicorn

# Check if worker is running
ps aux | grep inference_worker
```

### Check Logs

```bash
# API logs
tail -f data/logs/api.log

# Inference logs
tail -f data/logs/inference.log

# Error logs
tail -f data/logs/errors.log
```

### Check Disk Usage

```bash
# Total data directory size
du -sh data/

# By subdirectory
du -sh data/*/

# Events by date
du -sh data/events/*/
```

### Check GPU Status

```bash
# NVIDIA GPU
nvidia-smi

# Check PyTorch CUDA
python -c "import torch; print(f'CUDA Available: {torch.cuda.is_available()}')"
```

---

## Stopping the System

### Stop All Services

```bash
# In each terminal where services are running:
Ctrl + C

# Or kill all Python processes (careful!)
pkill -f "python.*forklift"
pkill -f uvicorn
```

### Deactivate Virtual Environment

```bash
deactivate
```

---

## Next Steps After Startup

### 1. Test with Forklift Images

```bash
# Import your empty forklift pictures
python scripts/import_knowledge.py \
  --source /path/to/your/images/ \
  --label unloaded
```

### 2. Review Configuration

- Check `configs/cameras.yaml` - camera settings
- Check `configs/thresholds.yaml` - detection settings
- Adjust based on your needs

### 3. Explore Web Interface

If you started the frontend:
- Open http://localhost:5173
- Navigate through pages
- Test live view, events, knowledge base

### 4. Monitor Events

```bash
# Watch for new events
watch -n 5 'ls -lh data/events/$(date +%Y-%m-%d)/ | tail -10'
```

### 5. Plan USB Camera Setup

- Identify mounting location
- Measure height and angle
- Order USB camera if needed
- Plan for next week's deployment

---

## Common Workflows

### Daily Startup (Quick)

```bash
cd /workspaces/forklift.2.0
./start_simple.sh
```

### Development Mode

```bash
# Terminal 1: API with auto-reload
cd app/backend
uvicorn api.main:app --reload

# Terminal 2: Worker
python app/backend/workers/inference_worker.py

# Terminal 3: Frontend with hot reload
cd app/frontend
npm run dev
```

### Production Mode

```bash
# Use Docker Compose
docker-compose up -d

# Check status
docker-compose ps

# View logs
docker-compose logs -f
```

---

## Performance Tips

### For Laptop

1. **Use nano model** (fastest):
   ```bash
   wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8n.pt \
     -O models/forklift_detector_v1.pt
   ```

2. **Lower resolution**: 640x480 instead of 1280x720

3. **Reduce FPS**: Process 3-5 frames per second

4. **Close other apps**: Free up RAM and CPU

### For Desktop with GPU

1. **Use medium model** (better accuracy):
   ```bash
   wget https://github.com/ultralytics/assets/releases/download/v0.0.0/yolov8m.pt \
     -O models/forklift_detector_v1.pt
   ```

2. **Higher resolution**: 1920x1080

3. **Higher FPS**: Process 10-15 frames per second

4. **Enable half-precision**:
   ```bash
   # .env
   USE_HALF_PRECISION="true"
   ```

---

## Useful Commands

```bash
# Quick camera test
python scripts/test_cameras.py

# Simple detection test
python scripts/test_detection_laptop.py

# Import images
python scripts/import_knowledge.py --source /path/to/images/ --label unloaded

# Check API health
curl http://localhost:8000/api/health

# List events
curl http://localhost:8000/api/events | jq

# Export events
curl "http://localhost:8000/api/events?format=csv" > events.csv

# Backup data
tar -czf backup_$(date +%Y%m%d).tar.gz data/

# Clean old events (older than 30 days)
find data/events -type d -mtime +30 -exec rm -rf {} +
```

---

## Getting Help

**System won't start?**
→ Check this guide's troubleshooting section

**Camera issues?**
→ See [LAPTOP_CAMERA_SETUP.md](LAPTOP_CAMERA_SETUP.md)

**Configuration questions?**
→ See [QUICK_REFERENCE.md](QUICK_REFERENCE.md)

**Want to understand the system?**
→ Read [DESIGN_SUMMARY.md](DESIGN_SUMMARY.md)

---

**Happy detecting!** 🚀
