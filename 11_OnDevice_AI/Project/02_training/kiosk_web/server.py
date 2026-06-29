#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
KIOSK Simulator Web Server
Serves the kiosk web application on port 8080.
Provides API endpoints for product data and product images.
"""

import http.server
import json
import csv
import os
import sys
import urllib.parse
import mimetypes
from pathlib import Path

# ── Paths ──────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent                       # kiosk_web/
PROJECT_ROOT = BASE_DIR.parent                                    # jetson_project/
CSV_PATH = PROJECT_ROOT / "Project" / "00_data" / "class.csv"
IMAGES_DIR = PROJECT_ROOT / "Dataset" / "Training" / "images"
LOGO_PATH = PROJECT_ROOT / "KCCI_Seoul_Logo_Final2.png"

PORT = 8080


def load_products():
    """Read class.csv and build the product list with image paths."""
    products = []
    with open(CSV_PATH, "r", encoding="utf-8-sig") as f:
        reader = csv.DictReader(f)
        for row in reader:
            class_id = int(row["class_id"])
            class_name = row["class_name"].strip()
            price = int(row["price"].strip())

            # Find the product image folder
            folder_name = f"{class_id}_{class_name}"
            folder_path = IMAGES_DIR / folder_name

            first_image = None
            if folder_path.exists():
                jpg_files = sorted([
                    f.name for f in folder_path.iterdir()
                    if f.suffix.lower() in ('.jpg', '.jpeg', '.png')
                ])
                if jpg_files:
                    first_image = jpg_files[0]

            # Category: 0-69 = snacks, 70-139 = drinks
            category = "snack" if class_id < 70 else "drink"

            products.append({
                "class_id": class_id,
                "class_name": class_name,
                "price": price,
                "category": category,
                "image": f"/api/image/{class_id}" if first_image else None,
                "folder_name": folder_name,
                "image_file": first_image,
            })
    return products


# Pre-load products at startup
PRODUCTS = load_products()
print(f"[INFO] Loaded {len(PRODUCTS)} products from {CSV_PATH}")

# Build a lookup: class_id -> (folder_path, image_filename)
IMAGE_LOOKUP = {}
for p in PRODUCTS:
    if p["image_file"]:
        IMAGE_LOOKUP[p["class_id"]] = (
            IMAGES_DIR / p["folder_name"] / p["image_file"]
        )


class KioskHandler(http.server.SimpleHTTPRequestHandler):
    """Custom HTTP handler with API endpoints."""

    def __init__(self, *args, **kwargs):
        # Serve files from the kiosk_web directory
        super().__init__(*args, directory=str(BASE_DIR), **kwargs)

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        path = urllib.parse.unquote(parsed.path)

        # ── API: Product list ──────────────────────────────────
        if path == "/api/products":
            self.send_json([{
                "class_id": p["class_id"],
                "class_name": p["class_name"],
                "price": p["price"],
                "category": p["category"],
                "image": p["image"],
            } for p in PRODUCTS])
            return

        # ── API: Product image ─────────────────────────────────
        if path.startswith("/api/image/"):
            try:
                class_id = int(path.split("/")[-1])
            except ValueError:
                self.send_error(400, "Invalid class_id")
                return

            if class_id in IMAGE_LOOKUP:
                img_path = IMAGE_LOOKUP[class_id]
                self.send_file(img_path)
            else:
                self.send_error(404, "Image not found")
            return

        # ── Logo ───────────────────────────────────────────────
        if path == "/logo.png":
            if LOGO_PATH.exists():
                self.send_file(LOGO_PATH)
            else:
                self.send_error(404, "Logo not found")
            return

        # ── Static files (index.html, style.css, app.js, …) ──
        super().do_GET()

    def send_json(self, data):
        """Send JSON response."""
        body = json.dumps(data, ensure_ascii=False).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.send_header("Cache-Control", "no-cache")
        self.end_headers()
        self.wfile.write(body)

    def send_file(self, file_path: Path):
        """Send a binary file (image, etc.)."""
        mime, _ = mimetypes.guess_type(str(file_path))
        if not mime:
            mime = "application/octet-stream"
        try:
            data = file_path.read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", mime)
            self.send_header("Content-Length", str(len(data)))
            self.send_header("Cache-Control", "public, max-age=86400")
            self.end_headers()
            self.wfile.write(data)
        except Exception as e:
            self.send_error(500, str(e))

    def log_message(self, format, *args):
        """Quieter logging – skip image requests."""
        msg = format % args
        if "/api/image/" not in msg:
            sys.stderr.write(f"[{self.log_date_time_string()}] {msg}\n")


def main():
    print(f"===============================================")
    print(f"   KIOSK Simulator Web Server                  ")
    print(f"   http://localhost:{PORT}                     ")
    print(f"===============================================")

    server = http.server.HTTPServer(("0.0.0.0", PORT), KioskHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[INFO] Server stopped.")
        server.server_close()


if __name__ == "__main__":
    main()
