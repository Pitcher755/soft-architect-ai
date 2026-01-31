# 🆔 Tech Profile: React Native (Expo)

> **Categoría:** Mobile Development Framework
> **Flavor:** Expo (Managed Workflow)
> **Plataformas:** iOS, Android
> **Versión Objetivo:** Expo SDK 50+

La forma estándar y moderna de hacer React Native hoy en día (2026).

---

## 📖 Tabla de Contenidos

1. [Expo: ¿Por Qué?](#expo-por-qué)
2. [Expo vs CLI (Bare Workflow)](#expo-vs-cli-bare-workflow)
3. [Casos de Uso](#casos-de-uso)
4. [Stack Recomendado](#stack-recomendado)
5. [Decisión de Adopción](#decisión-de-adopción)

---

## Expo: ¿Por Qué?

### Problemas que Expo Resuelve

1. **Setup Complejo:** Configurar React Native puro requiere Xcode + Android Studio. Expo abstraé todo.
2. **OTA Updates:** Actualizar la app en producción sin pasar por App Store/Google Play (EAS Update).
3. **Desarrollo Rápido:** Expo Go permite probar en dispositivo físico sin compilar.
4. **Código Nativo Limitado:** 99% de casos se pueden hacer con Expo Modules. No necesitas ejectar.

### ¿Qué es Expo exactamente?

Expo es:
- **SDK:** Librería que envuelve APIs nativas (Cámara, GPS, Notificaciones, etc.)
- **CLI:** Herramienta para crear, buildear y deployar apps
- **Servicios:** EAS Build (compilación), EAS Update (OTA), Expo Go (testing rápido)
- **Estándar:** La mayoría de apps React Native usan Expo hoy en día

---

## Expo vs CLI (Bare Workflow)

| Aspecto | Expo (Managed) | CLI (Bare) |
|:---|:---|:---|
| **Setup Inicial** | 2 minutos (`npx create-expo-app`) | 30 minutos (Xcode + Android Studio) |
| **Desarrollo Rápido** | ✅ Expo Go (1 segundo reload) | ⚠️ Esperar compilación (30 segundos) |
| **OTA Updates** | ✅ EAS Update (integrado) | ❌ Requires custom setup |
| **Librerías Nativas** | ✅ 95% compatibles (Config Plugins) | ✅ 100% (pero manual) |
| **Control de Código Nativo** | ⚠️ Limitado (Config Plugins) | ✅ Total |
| **Librerías Propietarias** | ⚠️ Raro encontrar incompatibilidad | ✅ Compatible siempre |
| **Tamaño del Build** | ~50 MB (base) | ~30 MB (más ligero) |
| **Curva de Aprendizaje** | ✅ Suave (JS developers) | ⚠️ Steep (Swift/Kotlin) |

### ¿Cuándo Ejectar?

Casi nunca. Pero si necesitas:
- Librería nativa propietaria sin Config Plugin
- Control total de código Objective-C/Kotlin
- Performance crítica al millisegundo

**Aún entonces:** Usa **Expo Prebuild** (Continuous Native Generation) en lugar de ejectar manualmente.

---

## Casos de Uso

### ✅ Ideal Para

* **Startups / MVP rápido:** Lanzar app en días, no meses
* **Cross-platform:** Compartir código entre iOS y Android
* **OTA Updates:** Actualizaciones sin App Store (contenido, UI, lógica)
* **Prototipos:** Probar ideas rápidamente
* **Equipo JS-first:** Desarrolladores sin experiencia Swift/Kotlin

### ❌ No Usar Para

* **Juegos 3D pesados:** Usa Unity o Unreal Engine
* **AR/VR Avanzado:** Usa ARKit/ARCore directamente
* **Máquina de Estados Complejas:** (Aunque Expo es flexible)
* **Llamadas Nativas Frecuentes:** Si necesitas mucho código nativo, CLI es mejor

---

## Stack Recomendado

### Navegación: Expo Router

```
app/
├── _layout.tsx          # Stack/Tabs navigator
├── index.tsx            # /(inicio)
├── (tabs)/
│   ├── _layout.tsx      # Tab Navigator
│   ├── home.tsx         # /home
│   └── settings.tsx     # /settings
└── user/
    └── [id].tsx         # /user/123
```

**Expo Router** es el "Next.js para apps." File-based routing, sin configuración manual.

### UI Components: NativeWind + Tamagui

| Stack | Ventaja |
|:---|:---|
| **NativeWind** | Tailwind CSS para React Native (familiar) |
| **Tamagui** | Componentes pre-built + Tailwind integrado |

```tsx
// Con NativeWind
<View className="flex-1 justify-center items-center bg-blue-500">
  <Text className="text-white text-lg">Hello World</Text>
</View>

// O Tamagui (más completo)
import { Button, Input } from 'tamagui';

<YStack>
  <Input placeholder="Name" />
  <Button>Submit</Button>
</YStack>
```

### State Management: Zustand o Context

* **Zustand:** Para estado global (similar a Pinia en Vue)
* **Context API:** Para state local (no global)
* **React Query:** Para datos remotos

---

## Stack SoftArchitect para Mobile

```
Stack Recomendado (TRAMA 5.1 - Expo)
├── Framework: Expo SDK 50+
├── Router: Expo Router (file-based)
├── UI: NativeWind (Tailwind)
├── State: Zustand (global) + Context (local)
├── Data: React Query + TanStack Query
├── Styling: Tailwind CSS (via NativeWind)
└── Build: EAS Build + EAS Update (OTA)
```

---

## Decisión de Adopción

✅ **SoftArchitect adopta Expo como estándar para React Native** bajo estas condiciones:

1. **Expo Router como navegación estándar** (no React Navigation manual)
2. **NativeWind para estilos** (Tailwind compatibility)
3. **EAS Update para OTA** (actualizaciones sin App Store)
4. **EAS Build para CI/CD** (compilaciones en cloud)
5. **Prebuild en lugar de ejectar** (si código nativo es necesario)

---

## Ventajas Competitivas para SoftArchitect

1. **Reutilizar lógica:** Compartir código entre Next.js (web) y Expo (móvil)
2. **TypeScript nativo:** Todo el stack es TypeScript-first
3. **Developer Experience:** Reload en 1 segundo (vs 30s en CLI)
4. **OTA Updates:** Actualizar features sin esperar App Store review
5. **Escalabilidad:** De MVP a millones de usuarios sin cambiar stack

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ADOPTED (Mobile Standard)
**Responsable:** ArchitectZero AI Agent
