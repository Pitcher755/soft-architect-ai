# 📏 Tech Governance Rules: React & Next.js

> **Stack:** React 18+ / Next.js 14+ (App Router)
> **Lenguaje:** TypeScript Estricto
> **Estado:** ✅ MANDATORY RULES
> **Fecha:** 30 de Enero de 2026

Reglas inmutables para evitar el "useEffect Hell", re-renderizados infinitos y prop-drilling apocalíptico.

---

## 📖 Tabla de Contenidos

1. [Reglas de Hooks (The Law of Hooks)](#reglas-de-hooks-the-law-of-hooks)
2. [Server vs Client Components (RSC)](#server-vs-client-components-rsc)
3. [Estructura de Componentes](#estructura-de-componentes)
4. [TypeScript Estricto](#typescript-estricto)
5. [Anti-Patterns Prohibidos](#anti-patterns-prohibidos)

---

## Reglas de Hooks (The Law of Hooks)

### Regla 1: Top Level Only

**Obligatorio:** Hooks SOLO en el top level de componentes funcionales o custom hooks.

```tsx
// ✅ GOOD: Top level
function UserProfile() {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  return <div>{name}</div>;
}

// ❌ BAD: Dentro de condicional
function UserProfile() {
  if (isAdmin) {
    const [adminData, setAdminData] = useState(null);  // ← ERROR
  }
  return <div>...</div>;
}

// ❌ BAD: Dentro de loop
function UserList() {
  users.forEach(user => {
    const [state, setState] = useState(null);  // ← ERROR
  });
  return <ul>...</ul>;
}

// ✅ GOOD: En custom hook
function useAdminData() {
  const [adminData, setAdminData] = useState(null);
  return { adminData, setAdminData };
}
```

### Regla 2: Dependency Arrays (Never Lie)

**Obligatorio:** JAMÁS mentir en el array de dependencias. Si el linter se queja, arregla la lógica, no silencies el warning.

```tsx
// ❌ BAD: Missing dependency
function UserCard({ userId }) {
  useEffect(() => {
    fetchUser(userId);  // userId se usa adentro
  }, []);  // ← userId NO está en dependencias (BUG!)
}

// ✅ GOOD: Todas las dependencias
function UserCard({ userId }) {
  useEffect(() => {
    fetchUser(userId);
  }, [userId]);  // ← userId incluido
}

// ❌ BAD: Silenctious linter
function UserCard({ userId }) {
  useEffect(() => {
    fetchUser(userId);
  }, []);  // eslint-disable-next-line react-hooks/exhaustive-deps (❌ NO HAGAS ESTO)
}

// ✅ GOOD: Corregir la lógica
function useUser(userId) {
  const [user, setUser] = useState(null);

  useEffect(() => {
    if (!userId) return;  // Guardia
    fetchUser(userId).then(setUser);
  }, [userId]);

  return user;
}
```

### Regla 3: Custom Hooks para Lógica Compleja

**Obligatorio:** Extraer lógica reutilizable a `useNombreDelHook`.

```tsx
// ❌ BAD: Lógica mezclada en componente
function UserProfile({ userId }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    setLoading(true);
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  if (loading) return <Skeleton />;
  if (error) return <Error />;
  return <div>{user.name}</div>;
}

// ✅ GOOD: Custom hook
function useUser(userId) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!userId) return;
    setLoading(true);
    fetchUser(userId)
      .then(setUser)
      .catch(setError)
      .finally(() => setLoading(false));
  }, [userId]);

  return { user, loading, error };
}

function UserProfile({ userId }) {
  const { user, loading, error } = useUser(userId);

  if (loading) return <Skeleton />;
  if (error) return <Error />;
  return <div>{user.name}</div>;
}
```

### Regla 4: No useEffect para Data Fetching

**Prohibido:** Usar `useEffect` para cargar datos en componentes cliente.

```tsx
// ❌ BAD: useEffect en cliente
'use client';
function UserPage() {
  const [user, setUser] = useState(null);

  useEffect(() => {
    fetch('/api/user').then(r => r.json()).then(setUser);
  }, []);

  return <div>{user?.name}</div>;
}

// ✅ GOOD: Server Component (mejor)
// No necesita "use client" ni useEffect
async function UserPage() {
  const user = await db.user.findFirst();
  return <div>{user.name}</div>;
}

// ✅ GOOD: React Query en cliente (si es necesario)
'use client';
import { useQuery } from '@tanstack/react-query';

function UserPage() {
  const { data: user } = useQuery({
    queryKey: ['user'],
    queryFn: () => fetch('/api/user').then(r => r.json()),
  });

  return <div>{user?.name}</div>;
}
```

---

## Server vs Client Components (RSC)

### La Regla de Oro

**Por defecto:** TODO componente es **Server Component** (React Server Component).

**Solo si es necesario:** Añadir `"use client"` en la primera línea del archivo.

### Tabla de Comparación

| Característica | Server Component (Default) | Client Component (`"use client"`) |
|:---|:---:|:---:|
| **Acceso a BD/Filesystem** | ✅ SÍ | ❌ NO |
| **Secrets/API Keys** | ✅ SÍ (Seguro) | ❌ NO (Expuesto) |
| **Hooks (useState, useContext)** | ❌ NO | ✅ SÍ |
| **Event Listeners (onClick, onChange)** | ❌ NO | ✅ SÍ |
| **Browser APIs (localStorage, geolocation)** | ❌ NO | ✅ SÍ |
| **Envío de JS al navegador** | ❌ 0 KB (Solo HTML) | ✅ SÍ (Hydration) |
| **Tiempo de carga** | ✅ Rápido | ⚠️ Más JS |

### Ejemplos

```tsx
// ✅ GOOD: Server Component (datos desde DB)
// app/users/page.tsx
export default async function UsersPage() {
  const users = await db.user.findMany();
  return (
    <ul>
      {users.map(u => (
        <li key={u.id}>{u.name}</li>
      ))}
    </ul>
  );
}

// ✅ GOOD: Server Component que usa Client Component
// app/users/page.tsx
import { UserFilters } from '@/components/UserFilters';

export default async function UsersPage() {
  const users = await db.user.findMany();
  return (
    <>
      <UserFilters />  {/* Client Component para filtros interactivos */}
      <ul>
        {users.map(u => <li key={u.id}>{u.name}</li>)}
      </ul>
    </>
  );
}

// ✅ GOOD: Client Component (interactividad)
// components/UserFilters.tsx
'use client';
import { useState } from 'react';

export function UserFilters() {
  const [search, setSearch] = useState('');

  return (
    <input
      value={search}
      onChange={(e) => setSearch(e.target.value)}
      placeholder="Buscar usuarios..."
    />
  );
}
```

---

## Estructura de Componentes

### Regla 5: Naming Convenciones

| Elemento | Convención | Ejemplo |
|:---|:---|:---|
| **Componente** | PascalCase | `UserProfile.tsx`, `SettingsButton.tsx` |
| **Función de archivo** | camelCase | `utils/userHelpers.ts` |
| **Props interface** | `${ComponentName}Props` | `UserProfileProps` |
| **Event handler (def)** | `handle${Event}` | `handleClick`, `handleSubmit` |
| **Event handler (prop)** | `on${Event}` | `onClick`, `onSubmit` |

```tsx
// ✅ GOOD: Naming correcto
interface UserProfileProps {
  userId: string;
  onLogout?: () => void;
}

export function UserProfile({ userId, onLogout }: UserProfileProps) {
  const handleLogoutClick = () => {
    console.log('Logging out...');
    onLogout?.();
  };

  return <button onClick={handleLogoutClick}>Logout</button>;
}
```

### Regla 6: Composición sobre Prop-Drilling

**Obligatorio:** Usar `children` o Composition Pattern para evitar prop-drilling.

```tsx
// ❌ BAD: Prop-drilling
function Card({ title, subtitle, icon, imageSrc, imageAlt, content, footer }) {
  return (
    <div>
      <h2>{title}</h2>
      <h3>{subtitle}</h3>
      <img src={imageSrc} alt={imageAlt} />
      <p>{content}</p>
      <footer>{footer}</footer>
    </div>
  );
}

// ✅ GOOD: Composition
export function Card({ children }: { children: React.ReactNode }) {
  return <div className="card">{children}</div>;
}

export function CardHeader({ children }: { children: React.ReactNode }) {
  return <div className="card-header">{children}</div>;
}

// Uso:
<Card>
  <CardHeader>
    <h2>Título</h2>
  </CardHeader>
  <CardContent>Contenido</CardContent>
  <CardFooter>Footer</CardFooter>
</Card>
```

---

## TypeScript Estricto

### Regla 7: Nunca usar `any`

**Prohibido:** Usar `any` en props, retornos o variables.

```tsx
// ❌ BAD
function UserCard(props: any) {
  return <div>{props.name}</div>;
}

// ✅ GOOD
interface UserCardProps {
  name: string;
  email: string;
}

function UserCard({ name, email }: UserCardProps) {
  return <div>{name}</div>;
}

// ✅ GOOD: Con Zod para runtime validation
import { z } from 'zod';

const UserSchema = z.object({
  id: z.string().uuid(),
  name: z.string().min(1),
  email: z.string().email(),
});

type User = z.infer<typeof UserSchema>;

function UserCard({ name, email }: User) {
  return <div>{name}</div>;
}
```

### Regla 8: Estilos Tipados

**Prohibido:** Estilos inline o CSS-in-JS manual. Usar Tailwind CSS o CSS Modules.

```tsx
// ❌ BAD: Inline styles
function Button() {
  return (
    <button style={{ backgroundColor: 'blue', color: 'white' }}>
      Click me
    </button>
  );
}

// ✅ GOOD: Tailwind CSS
function Button() {
  return <button className="bg-blue-500 text-white">Click me</button>;
}

// ✅ GOOD: CSS Modules
import styles from './Button.module.css';

function Button() {
  return <button className={styles.button}>Click me</button>;
}
```

---

## Anti-Patterns Prohibidos

### ❌ PROHIBIDO 1: useCallback/useMemo sin Razón

```tsx
// ❌ BAD: Optimización prematura
function UserList() {
  const handleClick = useCallback(() => {
    console.log('clicked');
  }, []);  // ← Innecesario si no pasas a hijo memoizado

  return <button onClick={handleClick}>Click</button>;
}

// ✅ GOOD: Simple
function UserList() {
  const handleClick = () => {
    console.log('clicked');
  };

  return <button onClick={handleClick}>Click</button>;
}
```

### ❌ PROHIBIDO 2: useReducer para Estados Simples

```tsx
// ❌ BAD: Overengineering
function Counter() {
  const [state, dispatch] = useReducer((s, a) => {
    switch (a.type) {
      case 'INC': return { count: s.count + 1 };
      default: return s;
    }
  }, { count: 0 });

  return <button onClick={() => dispatch({ type: 'INC' })}>
    {state.count}
  </button>;
}

// ✅ GOOD: useState para simple
function Counter() {
  const [count, setCount] = useState(0);
  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;
}
```

### ❌ PROHIBIDO 3: Context para Datos Frecuentes

```tsx
// ❌ BAD: Context con estados que cambian cada render
export const FilterContext = createContext<Filters>({...});

function App() {
  const [filters, setFilters] = useState({...});
  // Re-render toda la app cada vez que filters cambia
  return (
    <FilterContext.Provider value={filters}>
      <UserList />
    </FilterContext.Provider>
  );
}

// ✅ GOOD: Usar React Query o Zustand para estado compartido
import { useQuery } from '@tanstack/react-query';

export function useFilters() {
  return useQuery({
    queryKey: ['filters'],
    queryFn: getFilters,
  });
}
```

### ❌ PROHIBIDO 4: Direct DOM Manipulation

```tsx
// ❌ BAD: useRef para manipular DOM
function Input() {
  const inputRef = useRef<HTMLInputElement>(null);

  const handleFocus = () => {
    inputRef.current?.focus();  // ← Manipulación manual
  };

  return (
    <>
      <input ref={inputRef} />
      <button onClick={handleFocus}>Focus Input</button>
    </>
  );
}

// ✅ GOOD: useRef solo para valores persistentes
function StopWatch() {
  const intervalRef = useRef<NodeJS.Timeout | null>(null);

  const start = () => {
    intervalRef.current = setInterval(() => {
      // ...
    }, 1000);
  };

  const stop = () => {
    if (intervalRef.current) clearInterval(intervalRef.current);
  };

  return <button onClick={start}>Start</button>;
}
```

---

## Checklist Pre-Deploy

```bash
# ✅ 1. Hooks
[ ] Todos los Hooks en top level
[ ] Dependency arrays completos (sin eslint-disable)
[ ] Lógica compleja extraída a custom hooks
[ ] useEffect usado solo para side effects (no data fetching)

# ✅ 2. Server vs Client
[ ] La mayoría de componentes son Server Components
[ ] "use client" solo donde sea necesario (interactividad)
[ ] Datos sensibles en Server Components

# ✅ 3. TypeScript
[ ] NO hay `any` en ningún lado
[ ] Interfaces definidas para props
[ ] Type inference donde sea posible

# ✅ 4. Naming
[ ] Componentes PascalCase
[ ] Handlers `handle*` y props `on*`
[ ] Variables descriptivas

# ✅ 5. Styling
[ ] Tailwind CSS o CSS Modules
[ ] NO inline styles
[ ] Responsive design mobile-first

# ✅ 6. Performance
[ ] Lazy loading para rutas pesadas
[ ] Memoization solo si es necesario
[ ] Bundle size < 200KB gzipped

# ✅ 7. Testing
[ ] Unit tests para custom hooks
[ ] Component tests con React Testing Library
[ ] E2E tests críticos
```

---

**Validación:** RAG rechazará PRs que violen estas reglas.

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ENFORCED
**Responsable:** ArchitectZero AI Agent
