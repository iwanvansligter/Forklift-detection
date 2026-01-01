# 📸 Forklift Dataset - Data Collection Guide

Praktische gids voor het verzamelen van forklift images voor je training dataset.

---

## 🚀 Snelste Methoden (Aanbevolen)

### ⭐ Methode 1: Roboflow Universe (BESTE - Al geannoteerd!)

**Voordeel:** Images zijn al geannoteerd met bounding boxes!

```
1. Ga naar: https://universe.roboflow.com/
2. Search: "forklift" of "warehouse vehicles"
3. Kies een dataset (kijk naar aantal images en classes)
4. Klik "Download Dataset"
5. Selecteer format: "YOLOv8"
6. Download ZIP file
7. Extract naar: dataset/forklift/
```

**Populaire datasets op Roboflow:**
- "Forklift Detection"
- "Warehouse Vehicles"
- "Industrial Equipment Detection"

**Tijd:** 10 minuten
**Resultaat:** 200-1000 images, al geannoteerd! ✅

---

### ⭐ Methode 2: YouTube Videos Extracten

**Voordeel:** Veel diverse images uit echte warehouse footage

```bash
# 1. Download warehouse video van YouTube (gebruik youtube-dl of online tools)
# 2. Extract frames (1 per seconde = 30 frames interval bij 30fps)
python scripts/prepare_dataset.py extract warehouse_video.mp4 --interval 30 --max 300

# 3. Review images en delete slechte frames
# 4. Annoteer met Label Studio
```

**Aanbevolen YouTube searches:**
- "warehouse forklift operations"
- "forklift loading pallets"
- "forklift warehouse time lapse"
- "forklift training video"

**Tijd:** 30 minuten
**Resultaat:** 200-500 images uit real-world footage

---

### ⭐ Methode 3: Google Images (Handmatig maar effectief)

**Stappen:**

1. **Install browser extensie:**
   - Chrome/Edge: "Download All Images" of "Image Downloader"
   - Firefox: "DownThemAll!"

2. **Search en download:**

   Voor LOADED forklifts:
   ```
   - "forklift carrying pallet"
   - "forklift warehouse loaded"
   - "forklift with boxes"
   - "heftruck met pallet" (Nederlands)
   ```

   Voor UNLOADED forklifts:
   ```
   - "empty forklift warehouse"
   - "forklift no load"
   - "warehouse forklift ready"
   - "lege heftruck" (Nederlands)
   ```

3. **Download process:**
   - Open Google Images
   - Scroll down om meer images te laden
   - Use extensie: "Download All Images"
   - Save naar: `dataset/forklift/raw_images/loaded/` of `unloaded/`

**Tijd:** 20-30 minuten voor 100-200 images
**Resultaat:** Hoogwaardige diverse images

---

## 📊 Stock Photo Websites (Gratis, Hoge Kwaliteit)

### Pexels

```
1. Ga naar: https://www.pexels.com/
2. Search: "forklift"
3. Filter: "Free to use"
4. Download images één voor één (right-click -> Save As)
5. Of gebruik Pexels API (zie IMAGE_SCRAPING_GUIDE.md)
```

**Beschikbaar:** ~500+ forklift images
**Licentie:** Volledig gratis, commercieel gebruik OK

### Pixabay

```
1. Ga naar: https://pixabay.com/
2. Search: "forklift" of "gabelstapler" (Duits)
3. Download gratis images
```

**Beschikbaar:** ~300+ forklift images
**Licentie:** Pixabay Licentie, gratis gebruik

### Unsplash

```
1. Ga naar: https://unsplash.com/
2. Search: "forklift" of "warehouse"
3. Download high-res images
```

**Beschikbaar:** ~200+ forklift images
**Licentie:** Unsplash Licentie, zeer permissief

---

## 🎥 Eigen Footage (Beste voor je specifieke use-case!)

Als je toegang hebt tot een warehouse:

### Camera/Phone Opnames

```
1. Neem 5-10 minuten video footage van:
   - Forklifts met lading
   - Lege forklifts
   - Verschillende hoeken en afstanden
   - Verschillende verlichting

2. Extract frames:
   python scripts/prepare_dataset.py extract mijn_footage.mp4 --interval 30 --max 500

3. Review en delete blurry/slechte images

4. Annoteer
```

**Voordeel:** Perfect afgestemd op jouw warehouse omgeving!
**Tijd:** 1-2 uur totaal
**Resultaat:** 200-500 images specifiek voor jouw situatie

---

## 📦 Kaggle Datasets

```
1. Ga naar: https://www.kaggle.com/datasets
2. Search: "forklift" of "industrial vehicles" of "warehouse"
3. Download dataset (gratis Kaggle account nodig)
4. Extract naar: dataset/forklift/raw_images/
```

**Mogelijke datasets:**
- Industrial Equipment Detection
- Warehouse Objects
- Construction Vehicles

**Tijd:** 15 minuten
**Resultaat:** Varieert (50-1000+ images)

---

## 🔧 Dataset Voorbereiding Workflow

Na het verzamelen van images:

### Stap 1: Organiseer Images

```bash
# Plaats images in folders:
dataset/forklift/raw_images/
├── loaded/      # Forklifts met lading
└── unloaded/    # Lege forklifts
```

### Stap 2: Quality Check

```
1. Open de folders
2. Delete:
   - Blurry images
   - Duplicates
   - Images zonder forklifts
   - Te donkere/lichte images
   - Images met verkeerde labels
```

**Target:** 80-90% goede images behouden

### Stap 3: Annotatie (Label Studio)

```bash
# Install Label Studio
pip install label-studio

# Start Label Studio
label-studio start
```

**In Label Studio:**

1. Create project → Object Detection
2. Import images
3. Add labels:
   - `forklift_loaded` (rode box)
   - `forklift_unloaded` (groene box)
4. Draw tight bounding boxes rond elke forklift
5. Export as YOLOv8 format

**Tijd:** ~1 minuut per image (100 images = ~2 uur)

### Stap 4: Split Dataset

```bash
python scripts/prepare_dataset.py split dataset/forklift/raw_images/
```

Dit split automatisch in:
- 70% training
- 20% validation
- 10% test

### Stap 5: Verify

```bash
python scripts/prepare_dataset.py verify
```

Check dat je hebt:
- ✅ Minimaal 100 images per class
- ✅ Alle images geannoteerd
- ✅ Labels in correct YOLO formaat

---

## 📊 Aanbevolen Dataset Sizes

| Use Case | Min Images | Good | Excellent |
|----------|-----------|------|-----------|
| **Testing** | 50 totaal | 100 | 200 |
| **Prototype** | 200 totaal | 500 | 1000 |
| **Production** | 500 totaal | 1000 | 2000+ |

**Per class (loaded/unloaded):** Verdeel 50/50

---

## ⚡ Snelste Route naar Werkend Model

**Voor snelste resultaat (2-3 uur totaal):**

```
1. Download Roboflow dataset (10 min)
   → Al geannoteerd!

2. OF: Download YouTube video + extract frames (30 min)
   → python scripts/prepare_dataset.py extract video.mp4 --max 200

3. Supplement met Google Images (20 min)
   → Download 50-100 extra images

4. Annoteer indien nodig (60-90 min)
   → label-studio start

5. Train model (20 min met GPU)
   → python scripts/train_forklift_model.py
```

**Totaal: 2-3 uur → Werkend forklift detection model!**

---

## 🎯 Tips voor Beste Resultaten

### Diversity is Key

Verzamel images met:
- ✅ Verschillende forklift types (reach truck, counterbalance, etc.)
- ✅ Verschillende lading (pallets, dozen, vaten, rollen)
- ✅ Verschillende verlichting (dag, nacht, kunstlicht)
- ✅ Verschillende hoeken (front, side, 45°)
- ✅ Verschillende afstanden (close-up, medium, far)
- ✅ Verschillende achtergronden (warehouse, outdoor, industrial)

### Balanced Dataset

- ✅ 50/50 split tussen loaded en unloaded
- ✅ Vergelijkbare kwaliteit voor beide classes
- ✅ Vergelijkbare scenario's voor beide classes

### Annotation Quality

- ✅ Tight bounding boxes (geen extra ruimte)
- ✅ Include hele forklift (ook als partially visible)
- ✅ Consistent labeling: loaded = heeft pallet/lading
- ✅ Label ALLE forklifts in elke image

---

## 🚨 Veelgemaakte Fouten

### ❌ NIET DOEN:

1. **Te weinig images**
   - Minstens 100 per class, liefst 200+

2. **Unbalanced dataset**
   - Niet 300 loaded en 20 unloaded!

3. **Slechte kwaliteit images**
   - Delete blurry, dark, unclear images

4. **Inconsistente annotaties**
   - "Loaded" moet altijd betekenen: heeft lading
   - Lege forks = unloaded, ook al is er een pallet nearby

5. **Te homogeen**
   - Alleen images van 1 forklift type/locatie = slecht generaliseert

---

## 📝 Checklist voor Complete Dataset

Voordat je gaat trainen, check:

- [ ] Minimaal 100 images per class (loaded/unloaded)
- [ ] Images zijn diverse (verschillende scenarios)
- [ ] Alle images zijn geannoteerd
- [ ] Annotaties zijn gecheckt op kwaliteit
- [ ] Dataset is gesplit (train/val/test)
- [ ] Verified met: `python scripts/prepare_dataset.py verify`
- [ ] Geen duplicates
- [ ] Balanced (ongeveer 50/50 loaded/unloaded)

---

## 🔗 Handige Links

**Image Bronnen:**
- Roboflow Universe: https://universe.roboflow.com/
- Pexels: https://www.pexels.com/search/forklift/
- Pixabay: https://pixabay.com/images/search/forklift/
- Unsplash: https://unsplash.com/s/photos/forklift
- Kaggle: https://www.kaggle.com/datasets

**Tools:**
- Label Studio: https://labelstud.io/
- YouTube Downloader: https://www.y2mate.com/
- Image Downloader Extensions: Chrome Web Store

**Onze Scripts:**
- `scripts/prepare_dataset.py` - Dataset utilities
- `scripts/train_forklift_model.py` - Training script
- `scripts/test_trained_model.py` - Testing script

---

## ❓ Hulp Nodig?

**Dataset te klein?**
→ Probeer meerdere bronnen te combineren

**Annotatie duurt te lang?**
→ Start met 100 images, train, test, expand later

**Niet zeker of images goed zijn?**
→ Run verify script: `python scripts/prepare_dataset.py verify`

**Model accuracy te laag?**
→ Voeg meer diverse images toe en train longer (200-300 epochs)

---

**Succes met het verzamelen van je dataset!** 🚀

Na data collectie, zie: [TRAINING_GUIDE.md](TRAINING_GUIDE.md) voor training instructies.
