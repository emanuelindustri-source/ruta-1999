# REGLAS Y DIRECTRICES MAESTRAS DEL PROYECTO: RUTA 1999

Este documento rige el desarrollo absoluto del videojuego **Ruta 1999** por parte del agente Antigravity. Todas las decisiones de código, arquitectura, renderizado y arte deben alinearse rigurosamente con estas reglas.

---

## 1. Reglas de Plataforma y Hardware
1. **Rango de Versiones:** Compatibilidad nativa desde **Android 10 (API 29)** hasta **Android 17 (API 36+)**.
2. **Dispositivo de Pruebas Físico:** Dispositivo conectado vía ADB: **Xiaomi Redmi (Android 14 / API 34)**. Cada build jugable debe desplegarse y verificarse en este equipo.
3. **Optimización Multi-SoC y Cobertura de Todas las Gamas:**
   * **Gama Entrada & Económica (MediaTek Helio G/P & Unisoc Tiger T-series):**
     - **MediaTek Helio:** Soporte específico para Helio G99, G96, G88, G85, G36, P60/P70 (Mali-G52 / G57 / G72).
     - **Unisoc Tiger ("Tigre"):** Soporte optimizado para Tiger T606, T610, T612, T616, T618, T700 y T820.
     - **Snapdragon 4-series & Exynos 850:** Perfil *Eficiente / Rendimiento* (30 a 60 FPS estables) con resolución dinámica escalada (720p adaptativo), cubemaps estáticos para retrovisores, reducción de carga poligonal en vegetación y shaders optimizados sin sobregiro de memoria.
   * **Gama Media (Snapdragon 6/7-series, Dimensity 6000/7000, Exynos 1280/1380):**
     - Perfil *Equilibrado* (60 a 90 FPS) con sombreado dinámico del foco del carro, gotas fluidas en parabrisas y compresión ASTC.
   * **Gama Alta & Flagship (Snapdragon 8 Gen / 8 Elite, Dimensity 8000/9000/Immortalis, Exynos con AMD RDNA):**
     - Perfil *Ultra* (120 a 240 FPS) con oclusión ambiental, niebla volumétrica con scattering de luces altas, reflejos de charcos en asfalto y tasas de refresco desbloqueadas.
   * **Amlogic (Android TV 32" a 80"):**
     - Modos 1080p escalados, interfaz adaptable para navegación con control remoto (D-Pad) y mandos Bluetooth.
4. **Factor de Forma Adaptable:** Interfaz y viewport dinámico preparado para Smartphones convencionales, Teléfonos Plegables (relación de aspecto cambiante en caliente), Tablets y Smart TVs de 32" a 80".
5. **Control de Cuadros por Segundo (FPS) y Tasa de Refresco (Hz):**
   * El juego debe soportar selector en ajustes: **30, 60, 90, 120, 144, 240 FPS o Ilimitado**.
   * **Física Desacoplada (DeltaTime Fijo a 60 Ticks):** Toda la simulación mecánica (inercia, suspensión, frenado, colisiones) se procesa en pasos fijos de tiempo para que jugar a 120Hz o 240Hz no acelere ni rompa la física.

---

## 2. Reglas del Vehículo: "Araguaney '99 / Estima 1.6L"
1. **Identidad:** Sedán clásico noventero de 1.6L color Beige con tapicería de tela retro (evitando infracciones de marca registrada).
2. **Interactividad del Habitáculo:**
   * **4 Ventanas Eléctricas Independientes:** Control maestro de 4 pulsadores en la puerta del chofer y botones individuales en las puertas de copiloto y traseras.
   * **Seguros Centralizados:** Bloquear los seguros con pasajeros a bordo activa reacciones de alarma o sospecha en el árbol de diálogo del NPC.
   * **Luz de Techo:** Manipulable manualmente. Ilumina el interior para buscar objetos en la guantera, pero aumenta el riesgo de ser detectado por entidades nocturnas.
   * **Asiento del Conductor:** Desplazamiento adelante/atrás que altera el campo de visión, el ángulo de los retrovisores y la molestia del pasajero posterior.
   * **Guantera y Retrovisores:** Guantera interactiva con linterna, mapa, casetes y dinero. Retrovisores izquierdo, derecho e interior funcionales.
   * **Limpia Parabrisas:** Selector de velocidades intermitentes con eyección de agua para limpiar barro, lluvia o sangre.
   * **Descenso del Vehículo:** El jugador puede abrir la puerta y salir a pie a examinar el exterior, reparar el radiador, o **agacharse y esconderse bajo el chasis del carro** si es perseguido. Abrir la puerta en movimiento expulsa al jugador por inercia.

---

## 3. Reglas de Sensores y Controles
1. **Modos de Control Dual:** El jugador puede conmutar en cualquier momento entre **Controles Táctiles en Pantalla** y **Control por Sensores Físicos**.
2. **Giroscopio:** Control de vista libre dentro del habitáculo para girar la cabeza de forma natural.
3. **Acelerómetro:** Giro de dirección por inclinación y sacudidas de cámara ante troneras o baches del camino.
4. **Barómetro (Innovación Central):**
   * Lectura de presión atmosférica del sensor de hardware (o emulada por altitud de mapa si el equipo carece de él).
   * Al subir hacia el Páramo de Mérida (3.450+ msnm), la caída de presión ahoga el motor 1.6L, reduciendo caballos de fuerza y exigiendo bajar a marcha [2] o [L].
   * Caídas súbitas de presión alertan de la llegada inminente de tormentas eléctricas o fenómenos paranormales antes de que sean visibles en la niebla.

---

## 4. Reglas Narrativas, Folklore y Alcabalas
1. **Terror Psicológico Genuino:** Atmósfera opresiva, susurros, distorsión en la radio, lluvia intensa, neblina espesa y paranoia.
2. **Entidades del Folklore Venezolano:**
   * **El Silbón:** Sonido inverso (silbido fuerte = lejos; silbido débil = pegado a tu oreja o maleta).
   * **La Sayona:** Mujeres espectrales en curvas solitarias; castigo a conductores infieles o descuidados.
   * **La Loca Luz Caraballo:** Aparición errante en la niebla helada de los Andes.
   * **El Carretón de Puerto Cabello:** Carruaje en llamas con cadenas que anuncia catástrofe.
3. **Sistema de Alcabalas y Matraca:**
   * La radio del carro permite sintonizar frecuencias policiales para anticipar si un punto de control está extorsionando.
   * Entrega de papeles (Cédula, Carnet, RCV).
   * Negarse a pagar retiene al conductor y acelera la fatiga; pagar el soborno libera el paso pero el oficial avisa por radio a las siguientes alcabalas la matrícula y color del carro.
   * Manejo imprudente activa patrullas con sirenas para interceptar al jugador.

---

## 5. Reglas de Calidad y Monetización
1. **Cero activos mediocres:** Sombras dinámicas, oclusión ambiental, texturas PBR, audio espacial 3D con bajos potentes y voces sintetizadas con acento venezolano auténtico.
2. **Monetización Ética:** Respeto absoluto a las políticas de Google Play Store. Anuncios recompensados opcionales (pedir remolque/grúa o linterna), sin interrupciones intrusivas durante escenas de terror.
3. **Localización en 9 Idiomas:** Interfaz y subtítulos en Español Venezolano, Español España, Inglés, Italiano, Portugués (PT), Portugués (BR), Francés, Chino Simplificado y Japonés.
