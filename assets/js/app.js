// LOGICA INTERACTIVA DEL PORTAL RUTA 1999

document.addEventListener('DOMContentLoaded', () => {
  initTelemetryTicker();
  initAudioToggle();
  initVehicleExplorer();
  initRadioTuner();
  initRoadmapInteractivity();
});

// 1. Telemetry Ticker (Simulador en tiempo real)
function initTelemetryTicker() {
  const altEl = document.getElementById('telemetry-alt');
  const barEl = document.getElementById('telemetry-bar');
  const tempEl = document.getElementById('telemetry-temp');
  const fatigaEl = document.getElementById('telemetry-fatiga');

  let alt = 480; // msnm
  let bar = 955; // hPa
  let temp = 82; // °C
  let fatiga = 42; // %

  setInterval(() => {
    // Variación sutil
    alt += (Math.random() - 0.48) * 4;
    bar = Math.round(1013 - (alt / 1000) * 115);
    temp += (Math.random() - 0.49) * 0.4;
    fatiga = Math.min(100, Math.max(10, fatiga + (Math.random() - 0.4) * 0.2));

    if (altEl) altEl.textContent = `${Math.round(alt)} msnm`;
    if (barEl) barEl.textContent = `${bar} hPa`;
    if (tempEl) tempEl.textContent = `${temp.toFixed(1)} °C`;
    if (fatigaEl) fatigaEl.textContent = `${Math.round(fatiga)}%`;
  }, 2000);
}

// 2. Audio Toggle
function initAudioToggle() {
  const btn = document.getElementById('btn-audio-toggle');
  if (!btn) return;

  btn.addEventListener('click', () => {
    const isPlaying = window.rutaAudio.toggleAmbient();
    if (isPlaying) {
      btn.textContent = '🔊 AUDIO AMBIENTAL: ACTIVO';
      btn.style.background = 'var(--accent-amber)';
      btn.style.color = '#000';
    } else {
      btn.textContent = '🔇 ACTIVAR AUDIO AMBIENTE';
      btn.style.background = 'rgba(255, 183, 3, 0.15)';
      btn.style.color = 'var(--accent-amber)';
    }
  });
}

// 3. Vehicle Interactive Explorer
const vehicleComponents = {
  dash: {
    tag: 'TABLERO & INSTRUMENTOS',
    name: 'Panel Clásico con Agujas Analógicas',
    details: 'Tablero icónico noventero en tono beige con odómetro mecánico, velocímetro hasta 200 km/h, tacómetro hasta 8.000 RPM, medidor de temperatura de aguja y luz de Check Engine que titila cuando la presión barométrica desciende en los Andes.',
    mechanic: 'La aguja de temperatura debe vigilarse al subir cuestas pronunciadas. Si pasa de 95°C, el ventilador del radiador se forzará al máximo y habrá que detenerse a pie a echar agua.',
    hotspotPos: { top: '56%', left: '36%' }
  },
  shifter: {
    tag: 'TRANSMISIÓN AUTOMÁTICA',
    name: 'Palanca P-R-N-D-2-L con Overdrive',
    details: 'Selector de marchas de 4 velocidades con botón lateral de bloqueo. En terrenos planos de los Llanos se conduce en D con Overdrive para ahorrar combustible. En la subida de Troncal 5 o el Páramo de Mérida, se debe bajar manualmente a [2] o [L].',
    mechanic: 'Mecánica de Conducción: Subir pendientes con marchas altas sobrecalienta la caja de cambios y ahoga el motor 1.6L, reduciendo la aceleración ante emboscadas o persecuciones.',
    hotspotPos: { top: '82%', left: '59%' }
  },
  windows: {
    tag: 'SISTEMA ELÉCTRICO',
    name: '4 Ventanas Eléctricas Independientes',
    details: 'Consola maestra con 4 pulsadores en el descansabrazos del conductor y comandos individuales en cada una de las otras 3 puertas. Permite subir o bajar cada cristal a voluntad.',
    mechanic: 'Bajar las ventanas aumenta la ventilación y reduce la somnolencia del chofer, pero permite que los susurros y silbidos de la noche penetren con fuerza binaural en la cabina.',
    hotspotPos: { top: '72%', left: '15%' }
  },
  locks: {
    tag: 'SEGURIDAD & PSICOLOGÍA',
    name: 'Seguro Centralizado de Puertas',
    details: 'Interruptor central que traba los pestillos de las 4 puertas simultáneamente con un golpe metálico característico.',
    mechanic: 'Efecto Psicológico en NPCs: Bajar los seguros abruptamente con un pasajero a bordo altera su comportamiento y genera diálogos tensos: "¿Por qué trancas las puertas, mano? ¿Qué inventas?".',
    hotspotPos: { top: '65%', left: '12%' }
  },
  glovebox: {
    tag: 'INVENTARIO DE CABINA',
    name: 'Guantera Iluminada',
    details: 'Compartimiento frontal del copiloto. Alberga la linterna metálica pesada, el mapa de carreteras de Venezuela, los casetes de música noventera, la libreta de carreras y el dinero de las propinas (Bolívares en efectivo).',
    mechanic: 'Se puede abrir en marcha o con el carro detenido para consultar el mapa o recargar las pilas de la linterna antes de bajar a pie.',
    hotspotPos: { top: '62%', left: '74%' }
  },
  domelight: {
    tag: 'ILUMINACIÓN INTERIOR',
    name: 'Luz de Techo Central',
    details: 'Lámpara de techo con selector de 3 posiciones: Encendida, Puerta (Door) y Apagada.',
    mechanic: 'Doble filo: Encenderla ilumina el habitáculo para buscar objetos en la guantera, pero te vuelve visible a kilómetros de distancia en la oscuridad, atrayendo miradas espectrales.',
    hotspotPos: { top: '22%', left: '50%' }
  },
  radiator: {
    tag: 'MECÁNICA DEL MOTOR',
    name: 'Radiador 1.6L y Bomba de Agua',
    details: 'Sistema de enfriamiento de aluminio con depósito de expansión de refrigerante transparente.',
    mechanic: 'En el Páramo de Mucuchíes o tras trayectos prolongados, el motor puede hervir botando vapor por el capó. El jugador debe descender a pie con un envase de agua para rellenarlo con cuidado.',
    hotspotPos: { top: '48%', left: '50%' }
  }
};

function initVehicleExplorer() {
  const compButtons = document.querySelectorAll('.comp-btn');
  const compTag = document.getElementById('comp-tag');
  const compName = document.getElementById('comp-name');
  const compDetails = document.getElementById('comp-details');
  const compMechanic = document.getElementById('comp-mechanic');
  const compHotspot = document.getElementById('main-hotspot');

  function selectComponent(key) {
    const data = vehicleComponents[key];
    if (!data) return;

    if (window.rutaAudio) window.rutaAudio.playClick();

    if (compTag) compTag.textContent = data.tag;
    if (compName) compName.textContent = data.name;
    if (compDetails) compDetails.textContent = data.details;
    if (compMechanic) compMechanic.textContent = data.mechanic;

    if (compHotspot) {
      compHotspot.style.top = data.hotspotPos.top;
      compHotspot.style.left = data.hotspotPos.left;
    }

    compButtons.forEach(btn => {
      if (btn.dataset.comp === key) {
        btn.classList.add('active');
      } else {
        btn.classList.remove('active');
      }
    });
  }

  compButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      selectComponent(btn.dataset.comp);
    });
  });

  if (compHotspot) {
    compHotspot.addEventListener('click', () => {
      if (window.rutaAudio) window.rutaAudio.playClick();
    });
  }
}

// 4. Radio Tuner Interactivo
const radioStations = {
  fm104: {
    freq: '104.5 MHz FM',
    title: 'Radio Éxitos Noventeros (Caracas / Centro)',
    body: '[Sintonía FM nítida]\n"Estás en sintonía de Éxitos 104.5 FM... Transmitiendo en vivo para toda la región central. Son las 3:15 de la madrugada en este año 1999. Recuerde a los conductores en Troncal 5 manejar con precaución por las fuertes precipitaciones..."\n[Música pop y baladas de los 90 de fondo].',
    type: 'music'
  },
  am890: {
    freq: '890 KHz AM',
    title: 'Radio Noticias del Asfalto',
    body: '[Interferencia AM de onda media]\n"...Reportamos desbordamiento parcial de quebradas en el tramo hacia Puerto Cabello y neblina espesa en la bajada de Tazón. Se recomienda a los conductores no detenerse en tramos despoblados por reportes de avistamientos y anomalías en la vía..."',
    type: 'news'
  },
  police: {
    freq: '142.300 MHz (Banda Corta)',
    title: 'Frecuencia Policial / Puesto de Alcabala Troncal 5',
    body: '[BEEP DE RADIO - ROGER BEEP]\n"Central, aquí móvil 04 en la alcabala del puente... Copia, tenemos paso de un Estima noventero color beige, matrícula DFX 283. Ya aflojó pal\' fresco de la guardia. Avisa al puesto de San Felipe que va subiendo para que le bajen otro poco antes del peaje. Cambio y fuera."',
    type: 'police'
  },
  paranormal: {
    freq: '66.6 MHz (Frecuencia Vacía)',
    title: 'Canal Fantasma / Interferencia Inversa',
    body: '[ESTÁTICA DENSA Y CRUJIDOS DE CABLE]\n"...(Silbido lúgubre que asciende en notas lejanas: Do - Re - Mi - Sol)... Si lo escuchas cerca, está lejos... Si lo escuchas lejos, ya lo tienes dentro del carro... Abre los ojos... no mires el retrovisor..."',
    type: 'paranormal'
  }
};

function initRadioTuner() {
  const stationButtons = document.querySelectorAll('.radio-station-btn');
  const freqDisplay = document.getElementById('radio-freq-val');
  const infoDisplay = document.getElementById('radio-info-val');
  const transcriptBody = document.getElementById('radio-transcript-body');

  stationButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const key = btn.dataset.station;
      const data = radioStations[key];
      if (!data) return;

      stationButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      if (window.rutaAudio) {
        window.rutaAudio.playStatic(0.25);
        if (data.type === 'police') {
          setTimeout(() => window.rutaAudio.playPoliceBeep(), 280);
        } else if (data.type === 'paranormal') {
          setTimeout(() => window.rutaAudio.playSilbonWhistle(), 300);
        }
      }

      if (freqDisplay) freqDisplay.textContent = data.freq;
      if (infoDisplay) infoDisplay.textContent = data.title;
      if (transcriptBody) {
        transcriptBody.textContent = data.body;
        if (data.type === 'police') {
          transcriptBody.innerHTML = `<span class="police-alert">${data.body.replace(/\n/g, '<br>')}</span>`;
        } else {
          transcriptBody.innerHTML = data.body.replace(/\n/g, '<br>');
        }
      }
    });
  });
}

// 5. Roadmap Interactivity
function initRoadmapInteractivity() {
  const phaseCards = document.querySelectorAll('.phase-card');
  phaseCards.forEach(card => {
    card.addEventListener('click', () => {
      if (window.rutaAudio) window.rutaAudio.playClick();
      phaseCards.forEach(c => c.classList.remove('active'));
      card.classList.add('active');
    });
  });
}
