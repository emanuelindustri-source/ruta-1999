// MOTOR DE AUDIO SINTETIZADO EN TIEMPO REAL CON WEB AUDIO API
// Permite reproducir Foley interactivo, motor 1.6L, lluvia, radio policial y silbido del Silbón directamente en el navegador.

class RutaAudioEngine {
  constructor() {
    this.ctx = null;
    this.isPlayingAmbient = false;
    this.ambientGain = null;
    this.engineOsc1 = null;
    this.engineOsc2 = null;
    this.rainNode = null;
  }

  init() {
    if (!this.ctx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      this.ctx = new AudioContext();
    }
    if (this.ctx.state === 'suspended') {
      this.ctx.resume();
    }
  }

  toggleAmbient() {
    this.init();
    if (this.isPlayingAmbient) {
      this.stopAmbient();
      return false;
    } else {
      this.startAmbient();
      return true;
    }
  }

  startAmbient() {
    if (this.isPlayingAmbient) return;
    this.init();

    // Master Ambient Gain
    this.ambientGain = this.ctx.createGain();
    this.ambientGain.gain.setValueAtTime(0.01, this.ctx.currentTime);
    this.ambientGain.gain.exponentialRampToValueAtTime(0.35, this.ctx.currentTime + 1.5);
    this.ambientGain.connect(this.ctx.destination);

    // 1. Engine Hum (Low Frequency 62Hz & 124Hz)
    this.engineOsc1 = this.ctx.createOscillator();
    this.engineOsc1.type = 'sawtooth';
    this.engineOsc1.frequency.setValueAtTime(62, this.ctx.currentTime);

    this.engineOsc2 = this.ctx.createOscillator();
    this.engineOsc2.type = 'sine';
    this.engineOsc2.frequency.setValueAtTime(124, this.ctx.currentTime);

    const engineFilter = this.ctx.createBiquadFilter();
    engineFilter.type = 'lowpass';
    engineFilter.frequency.setValueAtTime(180, this.ctx.currentTime);

    const engineGain = this.ctx.createGain();
    engineGain.gain.setValueAtTime(0.4, this.ctx.currentTime);

    this.engineOsc1.connect(engineFilter);
    this.engineOsc2.connect(engineFilter);
    engineFilter.connect(engineGain);
    engineGain.connect(this.ambientGain);

    this.engineOsc1.start();
    this.engineOsc2.start();

    // 2. Rain Noise (Bandpass Filtered White Noise)
    const bufferSize = this.ctx.sampleRate * 2;
    const noiseBuffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const output = noiseBuffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      output[i] = Math.random() * 2 - 1;
    }

    this.rainNode = this.ctx.createBufferSource();
    this.rainNode.buffer = noiseBuffer;
    this.rainNode.loop = true;

    const rainFilter = this.ctx.createBiquadFilter();
    rainFilter.type = 'bandpass';
    rainFilter.frequency.setValueAtTime(1200, this.ctx.currentTime);
    rainFilter.Q.setValueAtTime(1.5, this.ctx.currentTime);

    const rainGain = this.ctx.createGain();
    rainGain.gain.setValueAtTime(0.18, this.ctx.currentTime);

    this.rainNode.connect(rainFilter);
    rainFilter.connect(rainGain);
    rainGain.connect(this.ambientGain);

    this.rainNode.start();

    this.isPlayingAmbient = true;
  }

  stopAmbient() {
    if (!this.isPlayingAmbient) return;
    if (this.ambientGain) {
      this.ambientGain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.8);
      setTimeout(() => {
        try {
          this.engineOsc1.stop();
          this.engineOsc2.stop();
          this.rainNode.stop();
        } catch (e) {}
        this.isPlayingAmbient = false;
      }, 850);
    }
  }

  // Play static tuning click
  playStatic(duration = 0.3) {
    this.init();
    const bufferSize = this.ctx.sampleRate * duration;
    const buffer = this.ctx.createBuffer(1, bufferSize, this.ctx.sampleRate);
    const data = buffer.getChannelData(0);
    for (let i = 0; i < bufferSize; i++) {
      data[i] = Math.random() * 2 - 1;
    }

    const noise = this.ctx.createBufferSource();
    noise.buffer = buffer;

    const filter = this.ctx.createBiquadFilter();
    filter.type = 'highpass';
    filter.frequency.setValueAtTime(800, this.ctx.currentTime);

    const gain = this.ctx.createGain();
    gain.gain.setValueAtTime(0.2, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + duration);

    noise.connect(filter);
    filter.connect(gain);
    gain.connect(this.ctx.destination);
    noise.start();
  }

  // Play Roger Beep for Police Radio
  playPoliceBeep() {
    this.init();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'sine';
    osc.frequency.setValueAtTime(1150, this.ctx.currentTime);
    gain.gain.setValueAtTime(0.25, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.001, this.ctx.currentTime + 0.12);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.12);
  }

  // Play El Silbón motif
  playSilbonWhistle() {
    this.init();
    const notes = [523.25, 587.33, 659.25, 783.99]; // C5, D5, E5, G5
    notes.forEach((freq, idx) => {
      const startTime = this.ctx.currentTime + idx * 0.28;
      const osc = this.ctx.createOscillator();
      const gain = this.ctx.createGain();

      osc.type = 'sine';
      osc.frequency.setValueAtTime(freq, startTime);

      // Tremolo / eerie vibrato
      gain.gain.setValueAtTime(0.001, startTime);
      gain.gain.linearRampToValueAtTime(0.2, startTime + 0.08);
      gain.gain.exponentialRampToValueAtTime(0.001, startTime + 0.26);

      osc.connect(gain);
      gain.connect(this.ctx.destination);

      osc.start(startTime);
      osc.stop(startTime + 0.28);
    });
  }

  // Play Mechanical Click (Switch, window button, shifter)
  playClick() {
    this.init();
    const osc = this.ctx.createOscillator();
    const gain = this.ctx.createGain();

    osc.type = 'triangle';
    osc.frequency.setValueAtTime(320, this.ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(80, this.ctx.currentTime + 0.05);

    gain.gain.setValueAtTime(0.3, this.ctx.currentTime);
    gain.gain.exponentialRampToValueAtTime(0.01, this.ctx.currentTime + 0.05);

    osc.connect(gain);
    gain.connect(this.ctx.destination);

    osc.start();
    osc.stop(this.ctx.currentTime + 0.05);
  }
}

window.rutaAudio = new RutaAudioEngine();
