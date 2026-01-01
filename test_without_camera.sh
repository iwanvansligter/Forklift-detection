#!/bin/bash
# Test system without camera (demonstration mode)

echo "================================================"
echo "  Forklift Detection System - Demo Mode"
echo "  (No camera required)"
echo "================================================"
echo ""

source venv/bin/activate

echo "✅ Virtual environment activated"
echo "✅ Dependencies installed:"
python -c "import cv2, torch, ultralytics; print(f'   - OpenCV: {cv2.__version__}'); print(f'   - PyTorch: {torch.__version__}'); print(f'   - Ultralytics: {ultralytics.__version__}')"

echo ""
echo "📂 Project Structure:"
echo "   - Documentation: docs/"
echo "   - Configuration: configs/"
echo "   - Knowledge Base: data/knowledge/"
echo "   - Events: data/events/"
echo ""

echo "📋 Next Steps:"
echo "   1. Import your empty forklift images:"
echo "      python scripts/import_knowledge.py --source /path/to/images/ --label unloaded"
echo ""
echo "   2. Deploy to laptop with camera:"
echo "      - Copy project to your laptop"
echo "      - Run: ./start_simple.sh"
echo ""
echo "   3. Read documentation:"
echo "      - START_HERE.md - Quick start guide"
echo "      - GETTING_STARTED_LAPTOP.md - Laptop setup"
echo "      - DESIGN_SUMMARY.md - Complete design"
echo ""

echo "================================================"
echo "System is ready! Deploy to machine with camera."
echo "================================================"
