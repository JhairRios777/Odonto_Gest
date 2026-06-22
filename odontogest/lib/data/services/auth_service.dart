// AuthService — comunicación con el endpoint POST /auth/login
// El rol es determinado por el backend, nunca por el cliente.
import 'dart:convert';
import 'package:http/http.dart' as http;

// ── URL base de la API ────────────────────────────────────────
// Android emulador  → 10.0.2.2  (apunta al localhost de tu PC)
// Dispositivo físico → IP de tu PC en la red WiFi, ej: 192.168.1.X
// Web / Windows     → localhost
const String _kBaseUrl = 'http://localhost/odontogest_api';

class AuthResult {
  final bool   success;
  final String? token;
  final String? rol;
  final String? nombre;
  final String? errorMsg;

  const AuthResult({
    required this.success,
    this.token,
    this.rol,
    this.nombre,
    this.errorMsg,
  });
}

class AuthService {
  static const _timeout = Duration(seconds: 10);

  /// Llama a POST /auth/login y retorna [AuthResult].
  /// El backend valida credenciales y devuelve el rol asignado.
  static Future<AuthResult> login({
    required String usuario,
    required String contrasena,
  }) async {
    final uri = Uri.parse('$_kBaseUrl/auth/login.php');

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'usuario': usuario, 'contrasena': contrasena}),
          )
          .timeout(_timeout);

      final body = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && body['success'] == true) {
        return AuthResult(
          success: true,
          token:   body['token']  as String?,
          rol:     body['rol']    as String?,
          nombre:  body['nombre'] as String?,
        );
      }

      // Error del servidor (401, 403, 400…)
      return AuthResult(
        success:  false,
        errorMsg: body['mensaje'] as String? ?? 'Error desconocido',
      );
    } on Exception catch (e) {
      // Timeout, sin conexión, host no encontrado…
      return AuthResult(
        success:  false,
        errorMsg: 'No se pudo conectar con el servidor.\n$e',
      );
    }
  }
}
