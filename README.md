# OdontoGest Mobile Suite

**Ecosistema informático multiplataforma para la gestión integral de clínicas dentales.**

> Cliente piloto: Clínica Dental Paz — Santa Bárbara, Honduras  
> Asignatura: Programación Móvil II — Universidad Tecnológica de Honduras — Periodo 2-2026  
> Docente: Máster Luis Fernando Teruel Umanzor

---

## Stack tecnológico

| Capa | Tecnología |
|------|-----------|
| App móvil | Flutter (Dart) — iOS & Android |
| Backend / API | PHP (REST API) |
| Base de datos | MySQL |
| Control de versiones | Git & GitHub |

---

## Módulos del sistema

- **Seguridad y RBAC** — Autenticación cifrada + roles (Admin / Odontólogo / Recepción)
- **Agenda Inteligente** — Citas sin colisiones por especialista o sillón dental
- **Expediente Clínico** — Odontograma digital interactivo + historial de tratamientos
- **Facturación Interna** — Comprobantes, abonos y control de saldos por paciente
- **Inventario** — Registro de insumos con alertas de stock crítico y caducidad

---

## Requisitos previos

Antes de clonar el proyecto, asegúrate de tener instalado:

- [Flutter SDK 3.x](https://docs.flutter.dev/get-started/install/windows)
- [Git](https://git-scm.com/downloads)
- [XAMPP](https://www.apachefriends.org/) (Apache + PHP + MySQL) para el backend
- VS Code con extensión Flutter/Dart (recomendado)

---

## Primera vez — configuración completa

### 1. Clonar el repositorio

```bash
git clone https://github.com/JhairRios777/Clini_Dent.git
cd Clini_Dent
```

### 2. Configurar la base de datos

```bash
# Importar el esquema en MySQL (desde XAMPP phpMyAdmin o consola)
mysql -u root -p < database/odontogest.sql
```

### 3. Configurar el backend PHP

```bash
# Copiar la carpeta backend al servidor local de XAMPP
cp -r backend/ C:/xampp/htdocs/odontogest-api/

# Editar el archivo de configuración con tus credenciales MySQL
# backend/config/database.php
```

### 4. Instalar dependencias Flutter y correr la app

```bash
cd odontogest
flutter pub get
flutter run
```

---

## Ya tienes el proyecto — actualizar cambios del equipo

```bash
# 1. Bajar los últimos cambios
git pull origin main

# 2. Actualizar dependencias Flutter si alguien modificó pubspec.yaml
cd odontogest
flutter pub get

# 3. Correr la app
flutter run
```

---

## Elegir dispositivo de ejecución

```bash
# Ver dispositivos disponibles
flutter devices

# Android (emulador o físico por USB con depuración activada)
flutter run -d android

# Windows (escritorio)
flutter run -d windows

# Chrome (web, para pruebas rápidas de UI)
flutter run -d chrome
```

---

## Si `flutter` no se reconoce en PowerShell

```powershell
# Agregar Flutter al PATH de la sesión actual
# Ajusta la ruta a donde tengas Flutter instalado
$env:PATH += ";C:\flutter\bin"

# Para hacerlo permanente
[System.Environment]::SetEnvironmentVariable(
    "PATH", $env:PATH + ";C:\flutter\bin",
    [System.EnvironmentVariableTarget]::User
)
```

---

## Estructura del proyecto

```
Clini_Dent/
├── odontogest/                        # App Flutter
│   ├── lib/
│   │   ├── main.dart                  # Entry point + LoginScreen
│   │   ├── core/
│   │   │   ├── constants/             # Colores, rutas, strings globales
│   │   │   ├── utils/                 # Helpers: fechas, formato, validaciones
│   │   │   └── widgets/               # Widgets reutilizables (botones, inputs, cards)
│   │   ├── data/
│   │   │   ├── models/                # Clases Dart que mapean la BD
│   │   │   ├── services/              # Llamadas HTTP a la API PHP
│   │   │   └── repositories/          # Abstracción entre services y controllers
│   │   └── modules/
│   │       ├── seguridad/
│   │       │   ├── views/             # Pantallas de UI del módulo
│   │       │   ├── controllers/       # Lógica de estado y navegación
│   │       │   └── models/            # Modelos específicos del módulo
│   │       ├── agenda/                # (igual estructura)
│   │       ├── expedientes/           # (igual estructura)
│   │       ├── facturacion/           # (igual estructura)
│   │       └── inventario/            # (igual estructura)
│   ├── assets/
│   │   ├── images/                    # Logos, fondos, fotos
│   │   ├── icons/                     # Íconos SVG/PNG propios
│   │   └── fonts/                     # Tipografías custom
│   └── pubspec.yaml
├── backend/                           # API REST en PHP
│   ├── config/
│   ├── controllers/
│   ├── models/
│   └── routes/
├── database/
│   └── odontogest.sql                 # Esquema MySQL
└── README.md
```

### ¿Dónde va cada cosa?

| Qué crear | Dónde va |
|-----------|----------|
| Logo o imagen | `assets/images/` |
| Ícono propio (SVG/PNG) | `assets/icons/` |
| Fuente tipográfica | `assets/fonts/` |
| Constantes de color / rutas | `core/constants/` |
| Función helper (ej. formatear fecha) | `core/utils/` |
| Widget reutilizable en varios módulos | `core/widgets/` |
| Clase que mapea tabla de BD | `data/models/` |
| Llamada HTTP (login, get citas, etc.) | `data/services/` |
| Pantalla de un módulo | `modules/<modulo>/views/` |
| Lógica/estado de un módulo | `modules/<modulo>/controllers/` |
| Modelo exclusivo de un módulo | `modules/<modulo>/models/` |

---

## Flujo de trabajo Git (trabajo en equipo)

```bash
# Ver estado de tus cambios antes de subir
git status

# Crear tu rama de trabajo (una por feature o módulo)
git checkout -b feature/modulo-agenda

# Guardar y subir tus cambios
git add .
git commit -m "feat: implementar validación de colisiones en agenda"
git push origin feature/modulo-agenda

# Actualizar tu rama con los cambios de main
git checkout main
git pull origin main
git checkout feature/modulo-agenda
git merge main

# Cuando tu módulo esté listo, fusionar a main
git checkout main
git merge feature/modulo-agenda
git push origin main
```

### Convención de commits

```
feat:      nueva funcionalidad
fix:       corrección de bug
refactor:  refactorización sin cambio de comportamiento
docs:      cambios en documentación
test:      pruebas
```

---

## Equipo de desarrollo

| Nombre ---------------- | Cuenta ------| Rol |

| Jorge Arturo Vallecillo | 202310050061 | Project Manager |
| Lucas Rodrigo Bautista  | 202310050126 | Systems Analyst |
| Ángel Antonio Pérez     | 202310050007 | Backend & BD |
| Diany Lizbeth Enamorado | 202310050027 | Backend & BD |
| Edson Jhair Ríos        | 202310050190 | Frontend Developer |
| Derick Dair Muñoz       | 202210050083 | QA & Documentación |
