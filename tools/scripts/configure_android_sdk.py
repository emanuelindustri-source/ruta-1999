import os

appdata = os.getenv('APPDATA')
settings_path = os.path.join(appdata, 'Godot', 'editor_settings-4.3.tres')

with open(settings_path, 'r', encoding='utf-8') as f:
    content = f.read()

android_sdk = 'C:/Users/Sr_Hidalgo/AppData/Local/Android/Sdk'
debug_ks = 'C:/Users/Sr_Hidalgo/Music/Proyectos IA/juego de carro antigravity/build_android/debug.keystore'
java_sdk = 'C:/Program Files/Eclipse Adoptium/jdk-21.0.13.9-hotspot'

lines = content.splitlines()
new_lines = [l for l in lines if not l.startswith('export/android/')]

android_settings = [
    f'export/android/android_sdk_path = "{android_sdk}"',
    f'export/android/debug_keystore = "{debug_ks}"',
    'export/android/debug_keystore_user = "androiddebugkey"',
    'export/android/debug_keystore_pass = "android"',
    f'export/android/java_sdk_path = "{java_sdk}"'
]

# Insert before closing resource
new_lines.extend(android_settings)

with open(settings_path, 'w', encoding='utf-8') as f:
    f.write('\n'.join(new_lines) + '\n')

print("Godot 4.3 editor settings for Android configured successfully.")
