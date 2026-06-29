// ── Configuración central de la app ───────────────────────────
// UN SOLO lugar para cambiar la URL de la API.
// Cada integrante del equipo solo edita este archivo.
//
// Casos de uso:
//   Flutter Web / Windows → 'http://localhost/odontogest_api'
//   Android emulador      → 'http://10.0.2.2/odontogest_api'
//   Dispositivo físico    → 'http://192.168.X.X/odontogest_api'
//   Apache en otro puerto → 'http://localhost:8080/odontogest_api'

class AppConfig {
  // ↓ CAMBIAR AQUÍ según tu entorno
  static const String apiBase = 'http://localhost/Clini_Dent/odontogest_api';
}
