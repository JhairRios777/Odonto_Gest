# OdontoGest Mobile Suite

**Ecosistema informático multiplataforma para la gestión integral de clínicas dentales.**

> Cliente piloto: Clínica Dental Paz — Santa Bárbara, Honduras  
> Asignatura: Programación Móvil II — Universidad Tecnológica de Honduras — Periodo 2-2026  
> Docente: Máster Luis Fernando Teruel Umanzor

---

## Arquitectura del sistema

```
┌─────────────────────┐        ┌──────────────────────────┐
│   Flutter (móvil)   │        │    PHP MVC (web admin)   │
│  Rol principal:     │        │  Todos los roles desde   │
│  Odontólogo en      │◄──────►│  cualquier PC/laptop     │
│  sala de atención   │        │  (incluso en sala)       │
└─────────────────────┘        └──────────────────────────┘
            │                              │
            └──────────────┬───────────────┘
                           ▼
                  ┌─────────────────┐
                  │  REST API PHP   │
                  │  Bearer Token   │
                  └────────┬────────┘
                           ▼
                  ┌─────────────────┐
                  │  MySQL/MariaDB  │
                  │  odonto_gest    │
                  └─────────────────┘
```

**Regla de login (no negociable):** El backend determina el rol a partir de las credenciales. Nunca hay selector de rol en el cliente.

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| App móvil | Flutter (Dart) — iOS & Android |
| Panel web | PHP MVC puro — sin frameworks |
| Backend / API | PHP REST — Bearer Token |
| Base de datos | MySQL / MariaDB (XAMPP) |
| Seguridad contraseñas | bcrypt cost 12 (`password_hash` PHP) |

---

## Estructura del proyecto

```
Proyecto_Final/
├── odontogest/                        # App Flutter
│   ├── lib/
│   │   ├── main.dart                  # Entry point + LoginScreen + AuthService call
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   │   ├── app_theme.dart     # Tokens: AppColors, AppTypography, AppGradients
│   │   │   │   ├── app_assets.dart
│   │   │   │   └── app_strings.dart
│   │   │   └── widgets/               # AppCard, GradientAppBar, StatusBadge
│   │   ├── data/
│   │   │   └── services/
│   │   │       └── auth_service.dart  # POST /auth/login → AuthResult(token, rol, nombre)
│   │   └── modules/
│   │       ├── seguridad/views/       # home_shell.dart, dashboard_screen.dart
│   │       ├── agenda/views/          # agenda_screen.dart, nueva_cita_screen.dart
│   │       ├── expedientes/views/     # pacientes_screen.dart, expediente_paciente_screen.dart
│   │       ├── facturacion/views/     # facturacion_screen.dart
│   │       └── inventario/views/      # inventario_screen.dart
│   └── pubspec.yaml                   # Deps: flutter, google_fonts, http
│
├── odontogest_api/                    # REST API PHP (servido por XAMPP)
│   ├── core/
│   │   ├── db.php                     # Conexión PDO a odonto_gest
│   │   └── Response.php               # Helpers ok() / error()
│   ├── auth/
│   │   └── login.php                  # POST — valida bcrypt, retorna token+rol+nombre
│   ├── tools/
│   │   └── generar_hash.php           # Utilidad: genera hash bcrypt para HeidiSQL
│   └── .htaccess                      # Pasa Authorization header a PHP
│
└── BD_OdontoGest/
    ├── odonto_gest_v3.sql             # CREATE DATABASE completo — 35 tablas
    └── ER_OdontoGest_v3.png           # Diagrama E-R generado
```

---

## Módulos — 8 bloques de BD

| Bloque | Tablas principales |
|--------|-------------------|
| Seguridad | roles, permisos, usuarios, permisos_roles |
| Personal / Clínica | cargo, especialidades, odontologos, empleados, horario_laboral |
| Catálogos Clínicos | sangres, alergias, enfermedades, medicamentos, tratamientos |
| Pacientes | pacientes, expedientes, odontograma, tratamientos_historial |
| Agenda | horarios, servicios, citas |
| Inventario | proveedores, kv_producto, producto, reportes_inventario |
| Facturación | sucursal, factura, detalle_factura, historial_facturacion |
| Sistema | kv_img, imagenes, auditoria, notificaciones, configuracion, reportes |

---

## Requisitos previos

- [Flutter SDK 3.x](https://docs.flutter.dev/get-started/install/windows)
- [XAMPP](https://www.apachefriends.org/) — Apache + PHP + MySQL
- VS Code con extensión Flutter/Dart
- HeidiSQL (incluido en XAMPP) para administrar la BD

---

## Configuración inicial (primera vez)

### 1. Base de datos

Abre HeidiSQL → conecta con `root` sin contraseña → abre `BD_OdontoGest/odonto_gest_v3.sql` → ejecuta con **F9**.

Esto crea la BD `odonto_gest` con todas las tablas, datos semilla y el usuario administrador inicial.

### 2. API PHP en XAMPP

Crea un enlace simbólico para que XAMPP sirva la API sin mover archivos:

```cmd
# CMD como Administrador
mklink /J "C:\xampp\htdocs\odontogest_api" "C:\Users\jhsir\OneDrive\Documentos\Movil_ll\Proyecto_Final\odontogest_api"
```

Verifica que funciona en el browser:
```
http://localhost/odontogest_api/auth/login.php
```
Debe responder: `{"success":false,"mensaje":"Método no permitido"}`

### 3. Instalar dependencias Flutter

```cmd
cd odontogest
flutter pub get
```

### 4. Ejecutar la app

```cmd
# Navegador (web-server — sin emulador)
flutter run -d web-server --web-port 8080
# Luego abrir: http://localhost:8080

# Emulador Android
flutter run -d android

# Windows desktop (requiere Visual Studio con C++)
flutter run -d windows
```

---

## Credenciales de prueba

| Campo | Valor |
|-------|-------|
| Usuario | `JhairRios` |
| Contraseña | `JhairRios10` |
| Rol | Administrador |

---

## Gestión de contraseñas

Las contraseñas se almacenan con **bcrypt cost 12**. Para crear o actualizar contraseñas desde HeidiSQL:

**Paso 1** — Genera el hash (con XAMPP corriendo):
```
http://localhost/odontogest_api/tools/generar_hash.php?pass=NuevaContrasenia
```

**Paso 2** — Copia el hash generado y ejecuta en HeidiSQL:
```sql
UPDATE odonto_gest.usuarios
SET contrasena = '$2y$12$...'
WHERE usuario = 'JhairRios';
```

---

## URL base de la API

Definida en `lib/data/services/auth_service.dart`:

| Entorno | URL |
|---------|-----|
| Web / Windows desktop | `http://localhost/odontogest_api` |
| Emulador Android | `http://10.0.2.2/odontogest_api` |
| Dispositivo físico (WiFi) | `http://192.168.X.X/odontogest_api` |

---

## Si IIS bloquea el puerto 80

Windows tiene IIS activo por defecto. Para liberar el puerto:

```cmd
# CMD como Administrador
net stop w3svc
net stop was
net stop http /y
```

Luego iniciar Apache desde el XAMPP Control Panel.

---

## Problema: Flutter no reconoce el dispositivo Chrome

Usar web-server como alternativa:

```cmd
flutter run -d web-server --web-port 8080
```

---

## Actualizar cambios

```cmd
git pull origin main
cd odontogest
flutter pub get
flutter run -d web-server --web-port 8080
```

---

## Estado actual del proyecto

| Componente | Estado |
|------------|--------|
| `app_theme.dart` — design tokens | ✅ Completo |
| `main.dart` — Login + AuthService | ✅ Completo |
| `home_shell.dart` — BottomNav + IndexedStack | ✅ Completo |
| `dashboard_screen.dart` | ✅ Completo |
| `pacientes_screen.dart` | ✅ Completo |
| `agenda_screen.dart` | ✅ Completo |
| `nueva_cita_screen.dart` | ✅ Completo |
| `facturacion_screen.dart` | 🔧 Stub (pendiente) |
| `inventario_screen.dart` | 🔧 Stub (pendiente) |
| `expediente_paciente_screen.dart` | 🔧 Stub (pendiente) |
| BD `odonto_gest` — 35 tablas | ✅ Completo |
| API `/auth/login` | ✅ Completo |
| API demás módulos | ⏳ Pendiente |
| Panel web PHP MVC | ⏳ Pendiente |
