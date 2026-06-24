// ── AppSession — singleton de sesión activa ───────────────────
// Almacena el token y datos del usuario autenticado en memoria.
// Se popula en main.dart tras el login exitoso.

class AppSession {
  AppSession._();
  static final AppSession _instance = AppSession._();
  static AppSession get instance => _instance;

  String? token;
  int?    idUsuario;
  String? rol;
  String? nombre;

  bool get isLoggedIn => token != null;

  void set({
    required String token,
    required int    idUsuario,
    required String rol,
    required String nombre,
  }) {
    this.token     = token;
    this.idUsuario = idUsuario;
    this.rol       = rol;
    this.nombre    = nombre;
  }

  void clear() {
    token     = null;
    idUsuario = null;
    rol       = null;
    nombre    = null;
  }
}
