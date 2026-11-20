import os
import zipfile
import urllib.request

appdata = os.getenv('APPDATA')
target_dir = os.path.join(appdata, 'Godot', 'export_templates', '4.3.stable')
os.makedirs(target_dir, exist_ok=True)

# Check if already installed
if os.path.exists(os.path.join(target_dir, 'android_debug.apk')):
    print("Plantillas de exportación para Android ya están instaladas.")
    exit(0)

tpz_url = "https://github.com/godotengine/godot/releases/download/4.3-stable/Godot_v4.3-stable_export_templates.tpz"
temp_tpz = os.path.join(target_dir, "templates.tpz")

print(f"Descargando paquete de plantillas Godot 4.3 (~1023 MB)...")
req = urllib.request.Request(tpz_url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req) as resp, open(temp_tpz, 'wb') as out_f:
    total = int(resp.headers.get('Content-Length', 0))
    downloaded = 0
    chunk_size = 4 * 1024 * 1024
    while True:
        chunk = resp.read(chunk_size)
        if not chunk:
            break
        out_f.write(chunk)
        downloaded += len(chunk)
        if total > 0:
            pct = (downloaded / total) * 100
            print(f"Progreso plantillas: {pct:.1f}% ({downloaded // (1024*1024)} MB)", end='\r')

print("\nDescarga completada. Extrayendo archivos Android a:", target_dir)
with zipfile.ZipFile(temp_tpz, 'r') as z:
    for member in z.namelist():
        # Only extract files inside templates/ directly into 4.3.stable
        if member.startswith('templates/'):
            filename = member[len('templates/'):]
            if filename:
                out_path = os.path.join(target_dir, filename)
                if member.endswith('/'):
                    os.makedirs(out_path, exist_ok=True)
                else:
                    os.makedirs(os.path.dirname(out_path), exist_ok=True)
                    with z.open(member) as src, open(out_path, 'wb') as dst:
                        dst.write(src.read())

if os.path.exists(temp_tpz):
    os.remove(temp_tpz)

print("Plantillas de exportación instaladas exitosamente en Godot 4.3.")
