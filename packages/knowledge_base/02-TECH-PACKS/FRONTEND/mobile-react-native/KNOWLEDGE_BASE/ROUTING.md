# 📱 Expo Router Patterns

> **Framework:** Expo Router (Expo 49+)
> **Patrón:** File-Based Routing
> **Paradigma:** "Next.js pero para Apps"

Navegación sin configuración. La carpeta `app/` define tus pantallas.

---

## 📖 Tabla de Contenidos

1. [File Structure](#file-structure)
2. [Navigation: Links y router](#navigation-links-y-router)
3. [Dynamic Routes](#dynamic-routes)
4. [Layouts & Stacks](#layouts--stacks)
5. [Tabs Navigation](#tabs-navigation)
6. [Deep Linking](#deep-linking)
7. [Anti-Patterns](#anti-patterns)

---

## File Structure

### Convención Básica

Cada `.tsx` en `app/` es una pantalla accesible por ruta.

```text
app/
├── _layout.tsx            # Stack Navigator (global)
├── index.tsx              # / (pantalla inicial)
├── profile.tsx            # /profile
│
├── (tabs)/                # Tab Navigator group
│   ├── _layout.tsx        # Configura Tabs
│   ├── home.tsx           # /home
│   ├── search.tsx         # /search
│   └── profile.tsx        # /profile
│
├── (auth)/                # Auth group (no en navigation)
│   ├── _layout.tsx        # Stack para auth
│   ├── login.tsx          # /login
│   └── register.tsx       # /register
│
└── user/
    ├── [id].tsx           # /user/:id (dinámico)
    └── _layout.tsx        # Stack para detalles usuario
```

### Route Groups (Organización sin Afectar URL)

Los paréntesis `(nombre)` crean grupos lógicos que **NO** aparecen en la URL.

```tsx
// app/(auth)/login.tsx
// Ruta: /login (NO /auth/login)

export default function LoginScreen() {
  return <Text>Login</Text>;
}

// app/(auth)/_layout.tsx (Layout solo para auth)
import { Stack } from 'expo-router';

export default function AuthLayout() {
  return (
    <Stack
      screenOptions={{
        headerShown: false,
        animationEnabled: false, // Sin animación entre login/register
      }}
    />
  );
}
```

---

## Navigation: Links y router

### Navegación Declarativa: `<Link>`

Usar `<Link>` para navegación similar a web (mejor SEO/accessibility en web).

```tsx
import { Link } from 'expo-router';
import { Text, View } from 'react-native';

export default function HomeScreen() {
  return (
    <View>
      <Link href="/user/123">
        <Text>Ver Perfil</Text>
      </Link>
    </View>
  );
}
```

### Navegación Imperativa: `useRouter()`

Usar `router` para lógica condicional.

```tsx
import { useRouter } from 'expo-router';
import { Button, View } from 'react-native';

export default function LoginScreen() {
  const router = useRouter();

  const handleLogin = async () => {
    // Lógica de login
    const success = await performLogin();

    if (success) {
      router.replace('/(tabs)/home'); // Replace (no volver atrás)
    } else {
      alert('Login failed');
    }
  };

  return (
    <View>
      <Button title="Login" onPress={handleLogin} />
    </View>
  );
}
```

### Push vs Replace

| Método | Comportamiento | Ejemplo |
|:---|:---|:---|
| **`push()`** | Añade a stack (se puede volver atrás) | Ir a detalles de user |
| **`replace()`** | Reemplaza ruta actual (no volver atrás) | Login → Dashboard |
| **`back()`** | Volver a pantalla anterior | Botón "Atrás" |
| **`dismiss()`** | Cerrar modal | Cerrar hoja modal |

```tsx
const router = useRouter();

// Push: Puedo volver atrás
<Button title="Ver Detalles" onPress={() => router.push('/user/123')} />

// Replace: No puedo volver atrás (ideal para login)
<Button title="Login" onPress={() => router.replace('/(tabs)/home')} />

// Back: Navegar atrás
<Button title="Volver" onPress={() => router.back()} />
```

---

## Dynamic Routes

### Parámetro Dinámico `[id]`

```text
app/user/[id].tsx          # /user/:id

```

```tsx
import { useLocalSearchParams } from 'expo-router';
import { Text, View } from 'react-native';

export default function UserScreen() {
  const { id } = useLocalSearchParams();

  return (
    <View>
      <Text>Perfil del Usuario: {id}</Text>
    </View>
  );
}

// Acceso:
// /user/123 → id = "123"
// /user/456 → id = "456"
```

### Múltiples Parámetros

```text
app/chat/[userId]/[messageId].tsx   # /chat/:userId/:messageId

```

```tsx
import { useLocalSearchParams } from 'expo-router';

export default function ChatScreen() {
  const { userId, messageId } = useLocalSearchParams();

  return <Text>Chat de {userId}, mensaje {messageId}</Text>;
}

// /chat/user-1/msg-999 → { userId: "user-1", messageId: "msg-999" }
```

### Parámetro Catch-All `[...id]`

```text
app/docs/[...id].tsx       # /docs/*, /docs/api/reference, etc

```

```tsx
import { useLocalSearchParams } from 'expo-router';

export default function DocsScreen() {
  const { id } = useLocalSearchParams();

  // id es un array si tienes múltiples segmentos
  const path = Array.isArray(id) ? id.join('/') : id;

  return <Text>Documentación: {path}</Text>;
}

// /docs/api → path = "api"
// /docs/api/reference → path = "api/reference"
```

---

## Layouts & Stacks

### Stack Navigator Global

```tsx
// app/_layout.tsx
import { Stack } from 'expo-router';

export default function RootLayout() {
  return (
    <Stack>
      <Stack.Screen
        name="index"
        options={{ title: 'Inicio', headerShown: false }}
      />
      <Stack.Screen
        name="(auth)"
        options={{ headerShown: false }}
      />
      <Stack.Screen
        name="(tabs)"
        options={{ headerShown: false }}
      />
    </Stack>
  );
}
```

### Customizar Headers

```tsx
// app/(dashboard)/_layout.tsx
import { Stack } from 'expo-router';
import { HeaderButton } from '@/components/HeaderButton';

export default function DashboardLayout() {
  return (
    <Stack
      screenOptions={{
        headerTintColor: '#0a7ea4',
        headerTitleStyle: { fontSize: 18, fontWeight: 'bold' },
      }}
    >
      <Stack.Screen
        name="dashboard"
        options={{
          title: 'Dashboard',
          headerRight: () => <HeaderButton />,
        }}
      />
      <Stack.Screen
        name="settings"
        options={{ title: 'Configuración' }}
      />
    </Stack>
  );
}
```

---

## Tabs Navigation

### Tabs Con Expo Router

```tsx
// app/(tabs)/_layout.tsx
import { Tabs } from 'expo-router';
import { Ionicons } from '@expo/vector-icons';

export default function TabsLayout() {
  return (
    <Tabs
      screenOptions={{
        tabBarActiveTintColor: '#0a7ea4',
        headerShown: true,
      }}
    >
      <Tabs.Screen
        name="home"
        options={{
          title: 'Home',
          tabBarIcon: ({ color }) => (
            <Ionicons name="home" size={24} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="search"
        options={{
          title: 'Search',
          tabBarIcon: ({ color }) => (
            <Ionicons name="search" size={24} color={color} />
          ),
        }}
      />
      <Tabs.Screen
        name="profile"
        options={{
          title: 'Profile',
          tabBarIcon: ({ color }) => (
            <Ionicons name="person" size={24} color={color} />
          ),
        }}
      />
    </Tabs>
  );
}

// app/(tabs)/home.tsx
export default function HomeScreen() {
  return <Text>Home Tab</Text>;
}

// app/(tabs)/search.tsx
export default function SearchScreen() {
  return <Text>Search Tab</Text>;
}

// app/(tabs)/profile.tsx
export default function ProfileScreen() {
  return <Text>Profile Tab</Text>;
}
```

---

## Deep Linking

### Configurar Deep Links

```json
// app.json
{
  "expo": {
    "scheme": "myapp",
    "plugins": [
      [
        "expo-router",
        {
          "origin": "https://myapp.com"
        }
      ]
    ]
  }
}
```

### Manejar Deep Links

```tsx
// app/_layout.tsx
import { useEffect } from 'react';
import { useRouter } from 'expo-router';
import * as Linking from 'expo-linking';

export default function RootLayout() {
  const router = useRouter();

  useEffect(() => {
    // Escuchar deep links
    const subscription = Linking.addEventListener('url', ({ url }) => {
      const parsed = Linking.parse(url);
      const path = parsed.path?.replace(/^\/+/, '/'); // Remove leading slash

      if (path) {
        router.push(path);
      }
    });

    return () => subscription.remove();
  }, [router]);

  return <Stack />;
}

// Links:
// myapp://user/123 → /user/123
// https://myapp.com/user/123 → /user/123
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: React Navigation Manual

```tsx
// ❌ BAD: Configuración manual de React Navigation
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

export default function App() {
  return (
    <NavigationContainer>
      <Stack.Navigator>
        <Stack.Screen name="Home" component={HomeScreen} />
        <Stack.Screen name="Profile" component={ProfileScreen} />
      </Stack.Navigator>
    </NavigationContainer>
  );
}
```

**DEBE SER:** Expo Router (file-based).

```tsx
// ✅ GOOD: Expo Router
// app/index.tsx
export default function HomeScreen() { /* ... */ }

// app/profile.tsx
export default function ProfileScreen() { /* ... */ }
```

### ❌ ANTI-PATTERN 2: Props Drilling de Rutas

```tsx
// ❌ BAD: Pasar datos por props
<Button
  onPress={() =>
    router.push({
      pathname: '/user/[id]',
      params: { id: userId, name: 'John', email: 'john@example.com' },
    })
  }
/>
```

**DEBE SER:** Usar solo IDs en URL, fetch datos en pantalla destino.

```tsx
// ✅ GOOD: Pasar solo ID
<Button onPress={() => router.push(`/user/${userId}`)} />

// En app/user/[id].tsx
const { id } = useLocalSearchParams();
const { data: user } = useQuery(['user', id], () => fetchUser(id));
```

### ❌ ANTI-PATTERN 3: Lógica en Layouts

```tsx
// ❌ BAD: useEffect en layout buscando data
export default function RootLayout() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetchUser().then(setUser);  // ← Re-fetch cada montaje
  }, []);

  return <Stack />;
}
```

**DEBE SER:** Usar Context o State Management (Zustand, Redux).

```tsx
// ✅ GOOD: Zustand store
export const useAuthStore = create((set) => ({
  user: null,
  setUser: (user) => set({ user }),
}));

// En app/_layout.tsx
const user = useAuthStore((state) => state.user);
// User persiste, sin re-fetching
```

---

## Checklist: Routing Bien Formado

```bash
# ✅ 1. Structure
[ ] File-based routing en app/
[ ] Route Groups para organización
[ ] Dynamic routes con [id]

# ✅ 2. Navigation
[ ] <Link> para web-like feeling
[ ] useRouter para lógica
[ ] push vs replace usado correctamente

# ✅ 3. Parameters
[ ] useLocalSearchParams() para leer params
[ ] Type-safe params con Zod
[ ] Query strings en URL (no props)

# ✅ 4. Layouts
[ ] Layouts anidados por grupo
[ ] Headers customizados
[ ] Stack/Tabs bien configurados

# ✅ 5. Deep Linking
[ ] Deep links configurados (si necesario)
[ ] Handlers de Linking.addEventListener
[ ] Testing de deep links

# ✅ 6. Performance
[ ] Lazy loading de rutas (automático)
[ ] Transiciones suaves
[ ] No re-renders innecesarios
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ PRODUCTION-READY PATTERNS
**Responsable:** ArchitectZero AI Agent
