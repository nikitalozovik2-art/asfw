#version 330

precision highp float;

uniform float iTime;
uniform vec2  iResolution;

uniform vec2  rayPos;        // screen-space (pixels), origin = TOP-left (через coord ниже)
uniform vec2  rayDir;        // screen-space direction (pixels space)
uniform vec3  raysColor;     // 0..1
uniform float raysSpeed;
uniform float lightSpread;   // 0..1 (меньше = уже, больше = шире)
uniform float rayLength;     // 1..4
uniform float pulsating;     // 0 or 1
uniform float fadeDistance;  // 0..2
uniform float saturation;    // 0..2

uniform vec2  mousePos;      // normalized 0..1 (x,y) from QML
uniform float mouseInfluence;
uniform float noiseAmount;
uniform float distortion;

out vec4 fragColor;

// простая шумовая функция
float noise(vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

// сила одного "лучевого слоя"
float rayStrength(vec2 raySource, vec2 rayRefDirection, vec2 coord,
                  float seedA, float seedB, float speed) {
  vec2 sourceToCoord = coord - raySource;
  float distance = length(sourceToCoord);

  vec2 dirNorm = normalize(sourceToCoord);
  float cosAngle = dot(dirNorm, rayRefDirection);

  // лёгкая деформация (почти незаметная), чтобы было "живее"
  float distortedAngle = cosAngle
    + distortion * sin(iTime * 2.0 + distance * 0.01) * 0.2;

  // spread: чем меньше lightSpread — тем уже конус
  float spreadFactor = pow(max(distortedAngle, 0.0), 1.0 / max(lightSpread, 0.001));

  // длина лучей
  float maxDistance = iResolution.y * rayLength;
  float lengthFalloff = clamp((maxDistance - distance) / maxDistance, 0.0, 1.0);

  // плавное затухание
  float fadeFalloff = clamp((iResolution.y * fadeDistance - distance) / (iResolution.y * fadeDistance), 0.0, 1.0);

  // пульсация (опционально)
  float pulse = (pulsating > 0.5) ? (0.90 + 0.10 * sin(iTime * speed * 2.4)) : 1.0;

  float baseStrength = clamp(
    (0.50 + 0.20 * sin(distortedAngle * seedA + iTime * speed)) +
    (0.25 + 0.25 * cos(-distortedAngle * seedB + iTime * speed)),
    0.0, 1.0
  );

  return baseStrength * lengthFalloff * fadeFalloff * spreadFactor * pulse;
}

void main() {
  // ====== КЛЮЧЕВОЕ: приводим координаты к TOP-left ======
  // gl_FragCoord: origin bottom-left, а нам нужно как "лампа сверху"
  vec2 coord = vec2(gl_FragCoord.x, iResolution.y - gl_FragCoord.y);

  // направление лучей
  vec2 finalRayDir = normalize(rayDir);

  // follow mouse: только влево/вправо мягко (без скачков)
  if (mouseInfluence > 0.0) {
    vec2 mousePx = vec2(mousePos.x * iResolution.x, mousePos.y * iResolution.y);
    vec2 mouseDirection = normalize(mousePx - rayPos);
    finalRayDir = normalize(mix(finalRayDir, mouseDirection, clamp(mouseInfluence, 0.0, 1.0)));
  }

  // два слоя для объёма
  float r1 = rayStrength(rayPos, finalRayDir, coord, 36.2214, 21.11349, 1.25 * raysSpeed);
  float r2 = rayStrength(rayPos, finalRayDir, coord, 22.3991, 18.0234, 0.95 * raysSpeed);

  float rays = r1 * 0.55 + r2 * 0.45;

  // шум (опционально)
  if (noiseAmount > 0.0) {
    float n = noise(coord * 0.01 + iTime * 0.08);
    rays *= (1.0 - noiseAmount + noiseAmount * n);
  }

  // “лампа”: ярче ближе к верху
  float topness = 1.0 - (coord.y / max(iResolution.y, 1.0));
  rays *= (0.25 + topness * 0.85);

  // цвет + насыщенность
  vec3 col = rays * raysColor;

  if (abs(saturation - 1.0) > 0.001) {
    float gray = dot(col.rgb, vec3(0.299, 0.587, 0.114));
    col = mix(vec3(gray), col, saturation);
  }

  // альфа: чтобы выглядело как мягкий свет (не “полосы”)
  float alpha = clamp(rays * 0.85, 0.0, 1.0);

  fragColor = vec4(col, alpha);
}
