import os
import sys
import zipfile
import urllib.request
import subprocess

TOOLS_DIR = r"c:\Users\Sr_Hidalgo\Music\Proyectos IA\juego de carro antigravity\tools\godot"
ZIP_PATH = os.path.join(TOOLS_DIR, "godot_v4.3.zip")
EXE_PATH = os.path.join(TOOLS_DIR, "godot.exe")
URL = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_win64.exe.zip"

os.makedirs(TOOLS_DIR, exist_ok=True)

if not os.path.exists(EXE_PATH):
    print(f"Descargando Godot Engine 4.3 Estable (~57 MB) desde {URL}...")
    req = urllib.request.Request(URL, headers={'User-Agent': 'Mozilla/5.0'})
    with urllib.request.urlopen(req) as resp, open(ZIP_PATH, 'wb') as out_f:
        total = int(resp.headers.get('Content-Length', 0))
        downloaded = 0
        chunk_size = 1024 * 1024
        while True:
            chunk = resp.read(chunk_size)
            if not chunk:
                break
            out_f.write(chunk)
            downloaded += len(chunk)
            if total > 0:
                percent = (downloaded / total) * 100
                print(f"Progreso: {percent:.1f}% ({downloaded // (1024*1024)} MB)", end='\r')

    print("\nDescarga finalizada. Descomprimiendo Godot...")
    with zipfile.ZipFile(ZIP_PATH, 'r') as z:
        for member in z.namelist():
            if member.endswith('.exe'):
                z.extract(member, TOOLS_DIR)
                extracted_path = os.path.join(TOOLS_DIR, member)
                if os.path.exists(EXE_PATH):
                    os.remove(EXE_PATH)
                os.rename(extracted_path, EXE_PATH)
                print(f"Ejecutable configurado en: {EXE_PATH}")

    if os.path.exists(ZIP_PATH):
        os.remove(ZIP_PATH)
else:
    print(f"Godot Engine ya está disponible en: {EXE_PATH}")

# Probar ejecución de versión
print("Verificando versión de Godot Engine...")
res = subprocess.run([EXE_PATH, "--version"], capture_output=True, text=True)
print(f"Godot Version detectada: {res.stdout.strip()}")
