import os
import wave
import math
import numpy as np

AUDIO_DIR = r"c:\Users\Sr_Hidalgo\Music\Proyectos IA\juego de carro antigravity\game_engine\assets\audio"
os.makedirs(AUDIO_DIR, exist_ok=True)
SAMPLE_RATE = 44100

def write_wav(filename, samples, sample_rate=SAMPLE_RATE):
    # Normalize to 16-bit PCM
    max_val = np.max(np.abs(samples))
    if max_val > 0:
        samples = (samples / max_val * 0.92 * 32767).astype(np.int16)
    else:
        samples = samples.astype(np.int16)
    path = os.path.join(AUDIO_DIR, filename)
    with wave.open(path, "wb") as wf:
        wf.setnchannels(1) # Mono for 3D positional audio
        wf.setsampwidth(2)
        wf.setframerate(sample_rate)
        wf.writeframes(samples.tobytes())
    print(f"Generated: {filename} ({len(samples)/sample_rate:.2f}s)")

# 1. Switch Click (Window button, lights, wipers)
t_click = np.linspace(0, 0.06, int(SAMPLE_RATE * 0.06), endpoint=False)
click = (
    np.sin(2 * np.pi * 320 * t_click) * np.exp(-t_click * 90) +
    0.5 * np.sin(2 * np.pi * 1200 * t_click) * np.exp(-t_click * 140) +
    0.2 * np.random.normal(0, 1, len(t_click)) * np.exp(-t_click * 120)
)
write_wav("switch_click.wav", click)

# 2. Central Door Lock (Solid mechanical solenoid "clack-thud")
t_lock = np.linspace(0, 0.18, int(SAMPLE_RATE * 0.18), endpoint=False)
lock = (
    np.sin(2 * np.pi * 180 * t_lock) * np.exp(-t_lock * 35) +
    0.8 * np.sin(2 * np.pi * 85 * t_lock) * np.exp(-t_lock * 22) +
    0.4 * np.sin(2 * np.pi * 950 * t_lock) * np.exp(-t_lock * 75)
)
write_wav("door_lock.wav", lock)

# 3. Door Open / Shut (Heavy sedan door latch)
t_door = np.linspace(0, 0.35, int(SAMPLE_RATE * 0.35), endpoint=False)
door = (
    np.sin(2 * np.pi * 65 * t_door) * np.exp(-t_door * 15) +
    0.6 * np.sin(2 * np.pi * 140 * t_door) * np.exp(-t_door * 25) +
    0.3 * np.random.normal(0, 1, len(t_door)) * np.exp(-t_door * 30)
)
write_wav("door_shut.wav", door)

# 4. Electric Window Motor (Whirr loop 1.5s)
t_win = np.linspace(0, 1.2, int(SAMPLE_RATE * 1.2), endpoint=False)
win_motor = (
    0.4 * np.sin(2 * np.pi * 380 * t_win) +
    0.2 * np.sin(2 * np.pi * 760 * t_win) +
    0.1 * np.random.normal(0, 1, len(t_win))
) * (0.8 + 0.2 * np.sin(2 * np.pi * 8 * t_win))
write_wav("window_motor.wav", win_motor)

# 5. Fuel Pump Prime (Zzzzz-click high-pitch whine on ignition run)
t_pump = np.linspace(0, 1.4, int(SAMPLE_RATE * 1.4), endpoint=False)
pump = (
    0.35 * np.sin(2 * np.pi * 1850 * t_pump) * np.exp(-t_pump * 0.4) +
    0.15 * np.sin(2 * np.pi * 3700 * t_pump) * np.exp(-t_pump * 0.6)
)
write_wav("fuel_pump_prime.wav", pump)

# 6. Starter Crank (Ch-ch-ch-ch starter motor)
t_crank = np.linspace(0, 1.1, int(SAMPLE_RATE * 1.1), endpoint=False)
crank = np.zeros_like(t_crank)
for rep in range(5):
    t_start = rep * 0.20
    mask = (t_crank >= t_start) & (t_crank < t_start + 0.16)
    tc = t_crank[mask] - t_start
    pulse = (
        np.sin(2 * np.pi * 45 * tc) * 0.7 +
        np.sin(2 * np.pi * 135 * tc) * 0.4 +
        np.random.normal(0, 0.2, len(tc))
    ) * np.sin(tc / 0.16 * np.pi)
    crank[mask] += pulse
write_wav("starter_crank.wav", crank)

# 7. Engine Idle 1.6L (Seamless Loopable 2.0s)
t_idle = np.linspace(0, 2.0, int(SAMPLE_RATE * 2.0), endpoint=False)
# ~850 RPM = ~14.1 Hz fundamental, with rich 4-cylinder firing harmonics (28.3Hz, 56.6Hz, 113Hz, 226Hz)
idle = (
    0.45 * np.sin(2 * np.pi * 28.3 * t_idle) +
    0.30 * np.sin(2 * np.pi * 56.6 * t_idle) +
    0.20 * np.sin(2 * np.pi * 113.3 * t_idle) +
    0.10 * np.sin(2 * np.pi * 226.6 * t_idle) +
    0.05 * np.random.normal(0, 0.15, len(t_idle))
)
write_wav("engine_idle.wav", idle)

# 8. Horn (Dual-tone noventero beep)
t_horn = np.linspace(0, 0.5, int(SAMPLE_RATE * 0.5), endpoint=False)
horn = (
    0.5 * np.sin(2 * np.pi * 440 * t_horn) +
    0.5 * np.sin(2 * np.pi * 554 * t_horn) # A4 + C#5
) * (1.0 - np.exp(-t_horn * 60)) * (1.0 - np.exp(-(0.5 - t_horn) * 60))
write_wav("horn.wav", horn)

# 9. Glovebox Open / Close
t_glove = np.linspace(0, 0.22, int(SAMPLE_RATE * 0.22), endpoint=False)
glove = (
    np.sin(2 * np.pi * 240 * t_glove) * np.exp(-t_glove * 25) +
    0.4 * np.random.normal(0, 1, len(t_glove)) * np.exp(-t_glove * 35)
)
write_wav("glovebox.wav", glove)

# 10. Wiper wipe sound
t_wip = np.linspace(0, 0.6, int(SAMPLE_RATE * 0.6), endpoint=False)
wiper = np.sin(2 * np.pi * 360 * t_wip) * np.sin(t_wip / 0.6 * np.pi) * 0.25 + np.random.normal(0, 0.05, len(t_wip))
write_wav("wiper_wipe.wav", wiper)

# 11. Tool Clank / Oil cap
t_tool = np.linspace(0, 0.25, int(SAMPLE_RATE * 0.25), endpoint=False)
tool = (
    np.sin(2 * np.pi * 1450 * t_tool) * np.exp(-t_tool * 30) +
    0.6 * np.sin(2 * np.pi * 2800 * t_tool) * np.exp(-t_tool * 45) +
    0.3 * np.random.normal(0, 1, len(t_tool)) * np.exp(-t_tool * 50)
)
write_wav("tool_clank.wav", tool)

print("Todos los sonidos Foley del habitáculo y garaje han sido sintetizados con éxito.")
