# 🦋 SoftArchitect AI - Flutter Client

**Languages:** [English](#english) | [Español](#español)

---

<a name="english"></a>
## 🇬🇧 English Version

### 🎯 Overview

Local-First AI Assistant for Software Architecture - Desktop Application (v0.1.0)

This is the Flutter Desktop frontend for **SoftArchitect AI**, a privacy-first AI assistant that helps developers navigate complex software architecture decisions without leaving their machine.

#### Supported Platforms
- ✅ Linux (Primary)
- ✅ Windows
- ✅ macOS
- ✅ Web (Secondary)

### 🏗️ Architecture

This project follows **Clean Architecture** with a Feature-First approach:

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared configuration & setup
│   ├── config/                  # Theme, routes, environment
│   ├── router/                  # GoRouter navigation
│   └── utils/                   # Helper functions
├── features/                    # Feature modules
│   ├── chat/                    # Main chat interface
│   │   ├── data/                # API calls & local storage
│   │   ├── domain/              # Business logic & entities
│   │   └── presentation/        # Widgets & state management
│   ├── settings/                # Configuration UI
│   └── knowledge/               # Knowledge base management
└── shared/                      # Reusable UI components
    └── widgets/                 # Common buttons, inputs, etc.
```

### 🚀 Getting Started

#### Prerequisites
- Flutter >= 3.10.1
- Dart >= 3.10.1

#### Installation

1. **Clone & Setup:**
   ```bash
   cd src/client
   flutter pub get
   ```

2. **Configure Environment:**
   ```bash
   cp .env.example .env
   # Edit .env with your local settings
   ```

3. **Run on Desktop (Linux):**
   ```bash
   flutter run -d linux
   ```

4. **Run on Web:**
   ```bash
   flutter run -d web
   ```

### 📦 Dependencies

#### State Management
- `flutter_riverpod` (3.1.0+) - Reactive state management with code generation

#### Routing
- `go_router` (17.0+) - Declarative navigation

#### Networking
- `dio` (5.9+) - HTTP client with interceptor support

#### Serialization
- `freezed` - Immutable models with code generation
- `json_serializable` - JSON serialization

#### UI/UX
- `flutter_markdown` - Markdown rendering for AI responses
- `highlight` - Code syntax highlighting

#### Environment
- `flutter_dotenv` - Load `.env` variables

### 🎨 Design System

The app follows a custom dark theme inspired by VS Code, Linear, and GitHub Dark Mode.

**Color Tokens:**
- `bg-primary`: `#0D1117` (Main background)
- `primary`: `#58A6FF` (Tech Blue - CTA buttons)
- `secondary`: `#238636` (Git Green - Success)
- `accent`: `#A371F7` (Purple - AI elements)

### 🔧 Development

#### Run Development Server
```bash
flutter run
```

#### Run Tests
```bash
flutter test
```

#### Analyze Code
```bash
flutter analyze
```

### 🤝 Contributing

Follow GitFlow: create feature branches from `develop`, open PRs, and squash merge.

### 📄 License

Part of **SoftArchitect AI**. See LICENSE in project root.

---

<a name="español"></a>
## 🇪🇸 Versión en Español

### 🎯 Descripción General

Asistente de IA Local para Arquitectura de Software - Aplicación de Escritorio (v0.1.0)

Este es el frontend Flutter Desktop de **SoftArchitect AI**, un asistente de IA que prioriza la privacidad y ayuda a los desarrolladores a navegar decisiones complejas de arquitectura de software sin salir de su máquina.

#### Plataformas Soportadas
- ✅ Linux (Principal)
- ✅ Windows
- ✅ macOS
- ✅ Web (Secundaria)

### 🏗️ Arquitectura

Este proyecto sigue **Clean Architecture** con un enfoque Feature-First:

```
lib/
├── main.dart                    # Punto de entrada
├── core/                        # Configuración compartida
│   ├── config/                  # Tema, rutas, entorno
│   ├── router/                  # Navegación GoRouter
│   └── utils/                   # Funciones auxiliares
├── features/                    # Módulos de funcionalidades
│   ├── chat/                    # Interfaz principal de chat
│   │   ├── data/                # Llamadas API y almacenamiento local
│   │   ├── domain/              # Lógica de negocio y entidades
│   │   └── presentation/        # Widgets y gestión de estado
│   ├── settings/                # UI de configuración
│   └── knowledge/               # Gestión de base de conocimiento
└── shared/                      # Componentes UI reutilizables
    └── widgets/                 # Botones, inputs comunes, etc.
```

### 🚀 Primeros Pasos

#### Prerequisitos
- Flutter >= 3.10.1
- Dart >= 3.10.1

#### Instalación

1. **Clonar y Configurar:**
   ```bash
   cd src/client
   flutter pub get
   ```

2. **Configurar Entorno:**
   ```bash
   cp .env.example .env
   # Editar .env con tu configuración local
   ```

3. **Ejecutar en Escritorio (Linux):**
   ```bash
   flutter run -d linux
   ```

4. **Ejecutar en Web:**
   ```bash
   flutter run -d web
   ```

### 📦 Dependencias

#### Gestión de Estado
- `flutter_riverpod` (3.1.0+) - Gestión de estado reactivo con generación de código

#### Enrutamiento
- `go_router` (17.0+) - Navegación declarativa

#### Networking
- `dio` (5.9+) - Cliente HTTP con soporte de interceptores

#### Serialización
- `freezed` - Modelos inmutables con generación de código
- `json_serializable` - Serialización JSON

#### UI/UX
- `flutter_markdown` - Renderizado Markdown para respuestas de IA
- `highlight` - Resaltado de sintaxis de código

#### Entorno
- `flutter_dotenv` - Cargar variables `.env`

### 🎨 Sistema de Diseño

La aplicación sigue un tema oscuro personalizado inspirado en VS Code, Linear y GitHub Dark Mode.

**Tokens de Color:**
- `bg-primary`: `#0D1117` (Fondo principal)
- `primary`: `#58A6FF` (Azul Tech - Botones CTA)
- `secondary`: `#238636` (Verde Git - Éxito)
- `accent`: `#A371F7` (Púrpura - Elementos IA)

### 🔧 Desarrollo

#### Ejecutar Servidor de Desarrollo
```bash
flutter run
```

#### Ejecutar Tests
```bash
flutter test
```

#### Analizar Código
```bash
flutter analyze
```

### 🤝 Contribuir

Seguir GitFlow: crear ramas feature desde `develop`, abrir PRs y hacer squash merge.

### 📄 Licencia

Parte de **SoftArchitect AI**. Ver LICENSE en la raíz del proyecto.

---

**[⬆ Volver arriba](#-softarchitect-ai---flutter-client)**
