# ▲ Next.js App Router Patterns

> **Framework:** Next.js 14+
> **Router:** App Router (No Pages Router)
> **Versión:** Estable
> **Paradigma:** Server Components First

Arquitectura moderna de Next.js basada en componentes servidores y Route Handlers.

---

## 📖 Tabla de Contenidos

1. [App Router Structure](#app-router-structure)
2. [Server Actions](#server-actions)
3. [Data Fetching](#data-fetching)
4. [Route Handlers (API Routes)](#route-handlers-api-routes)
5. [Layouts y Error Boundaries](#layouts-y-error-boundaries)
6. [Caching & Revalidation](#caching--revalidation)

---

## App Router Structure

### Convención de Archivos

La carpeta `app/` define la estructura de rutas. Cada `page.tsx` es una ruta accesible.

```text
app/
├── layout.tsx                 # Layout raíz (wrapper de todas las páginas)
├── page.tsx                   # / (inicio)
├── error.tsx                  # Error boundary global
├── not-found.tsx              # 404 global
│
├── (auth)/                    # Route Group (no afecta URL)
│   ├── layout.tsx             # Layout solo para auth
│   ├── login/
│   │   └── page.tsx           # /login
│   └── register/
│       └── page.tsx           # /register
│
├── (dashboard)/               # Route Group para dashboard
│   ├── layout.tsx             # Sidebar + persistente
│   ├── dashboard/
│   │   ├── page.tsx           # /dashboard
│   │   ├── loading.tsx        # Skeleton mientras carga
│   │   ├── error.tsx          # Error boundary para dashboard
│   │   └── @sidebar/          # Slot (composición avanzada)
│   │       └── page.tsx
│   └── settings/
│       ├── page.tsx           # /settings
│       └── [id]/
│           └── page.tsx       # /settings/123
│
├── api/                       # Route Handlers (Backend)
│   ├── auth/
│   │   └── route.ts           # POST /api/auth
│   └── users/
│       ├── route.ts           # GET/POST /api/users
│       └── [id]/
│           └── route.ts       # GET/PUT /api/users/123
│
└── _components/               # Componentes privados (NOT routable)
    ├── Navigation.tsx
    └── Footer.tsx

```

### Route Groups (Organización)

Los paréntesis `(nombre)` crean grupos que NO afectan la URL.

```tsx
// app/(auth)/login/page.tsx
// URL: /login (NO /auth/login)

export default function LoginPage() {
  return <div>Login</div>;
}

// app/(auth)/layout.tsx
export default function AuthLayout({ children }) {
  return (
    <div className="auth-container">
      {/* Solo para /login, /register, etc */}
      {children}
    </div>
  );
}
```

---

## Server Actions

**Server Actions** son funciones ejecutadas en el servidor desde el cliente. Olvídate de crear APIs REST para cada formulario.

### Definición y Uso

```tsx
// app/actions/userActions.ts
'use server'

import { db } from '@/lib/db';
import { revalidatePath } from 'next/cache';
import { redirect } from 'next/navigation';

export async function createUser(formData: FormData) {
  const name = formData.get('name') as string;
  const email = formData.get('email') as string;

  // Validación
  if (!name || !email) {
    return { error: 'Name and email required' };
  }

  // Crear en DB
  try {
    await db.user.create({
      data: { name, email },
    });
  } catch (error) {
    return { error: 'Failed to create user' };
  }

  // Revalidar cache
  revalidatePath('/users');

  // Redirect
  redirect('/users');
}

export async function deleteUser(userId: string) {
  await db.user.delete({
    where: { id: userId },
  });

  revalidatePath('/users');
}
```

### Usar en Componente Cliente

```tsx
// components/UserForm.tsx
'use client'

import { createUser } from '@/app/actions/userActions';
import { useFormStatus } from 'react-dom';
import { SubmitButton } from './SubmitButton';

export function UserForm() {
  return (
    <form action={createUser}>
      <input
        name="name"
        placeholder="Name"
        required
      />
      <input
        name="email"
        type="email"
        placeholder="Email"
        required
      />
      <SubmitButton />
    </form>
  );
}

// Componente para mostrar estado
function SubmitButton() {
  const { pending } = useFormStatus();

  return (
    <button type="submit" disabled={pending}>
      {pending ? 'Creating...' : 'Create User'}
    </button>
  );
}
```

### Progressive Enhancement

```tsx
// Formulario sin JavaScript (funciona igual)
<form action={createUser}>
  <input name="email" />
  <button type="submit">Subscribe</button>
</form>

// Con JavaScript: revalidación automática
// Sin JavaScript: navegador hace POST normal
```

---

## Data Fetching

### Server Component: Fetch Directo

Los Server Components pueden hacer fetch directamente (no necesita useEffect).

```tsx
// app/users/page.tsx
async function getUsers() {
  const res = await fetch('https://api.example.com/users', {
    next: { revalidate: 3600 }, // ISR: Cache por 1 hora
  });

  if (!res.ok) {
    throw new Error('Failed to fetch users');
  }

  return res.json();
}

export default async function UsersPage() {
  const users = await getUsers();

  return (
    <ul>
      {users.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Cliente: React Query (TanStack Query)

```tsx
// app/users/client.tsx
'use client'

import { useQuery } from '@tanstack/react-query';

export function UsersList() {
  const { data: users, isLoading } = useQuery({
    queryKey: ['users'],
    queryFn: async () => {
      const res = await fetch('/api/users');
      return res.json();
    },
  });

  if (isLoading) return <div>Loading...</div>;

  return (
    <ul>
      {users?.map((user) => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  );
}
```

### Deduplicación Automática

Next.js deduplica automáticamente múltiples fetches de la misma URL.

```tsx
// Mismo en Server Component
const users = await fetch('/api/users'); // Fetch 1
const users2 = await fetch('/api/users'); // Deduplicated (mismo request)

// Resultado: Una sola llamada a `/api/users`
```

---

## Route Handlers (API Routes)

### GET Handler

```tsx
// app/api/users/route.ts
import { db } from '@/lib/db';

export async function GET() {
  const users = await db.user.findMany();

  return Response.json(users);
}
```

### POST Handler

```tsx
// app/api/users/route.ts
import { db } from '@/lib/db';

export async function POST(request: Request) {
  const { name, email } = await request.json();

  const user = await db.user.create({
    data: { name, email },
  });

  return Response.json(user, { status: 201 });
}
```

### Rutas Dinámicas

```tsx
// app/api/users/[id]/route.ts
export async function GET(
  request: Request,
  { params }: { params: { id: string } }
) {
  const user = await db.user.findUnique({
    where: { id: params.id },
  });

  if (!user) {
    return Response.json({ error: 'Not found' }, { status: 404 });
  }

  return Response.json(user);
}

export async function PUT(
  request: Request,
  { params }: { params: { id: string } }
) {
  const data = await request.json();

  const user = await db.user.update({
    where: { id: params.id },
    data,
  });

  return Response.json(user);
}

export async function DELETE(
  request: Request,
  { params }: { params: { id: string } }
) {
  await db.user.delete({
    where: { id: params.id },
  });

  return Response.json({ ok: true });
}
```

---

## Layouts y Error Boundaries

### Layouts Anidados

```tsx
// app/layout.tsx (Raíz - se renderiza siempre)
export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html>
      <body>
        <Header />
        {children}
        <Footer />
      </body>
    </html>
  );
}

// app/(dashboard)/layout.tsx (Solo para /dashboard/*)
export default function DashboardLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="dashboard-container">
      <Sidebar />
      <main>{children}</main>
    </div>
  );
}

// app/(dashboard)/dashboard/page.tsx
export default function DashboardPage() {
  return <h1>Dashboard</h1>;
}
```

### Error Boundaries

```tsx
// app/dashboard/error.tsx
'use client'

export default function Error({
  error,
  reset,
}: {
  error: Error;
  reset: () => void;
}) {
  return (
    <div>
      <h2>Something went wrong!</h2>
      <p>{error.message}</p>
      <button onClick={() => reset()}>Try again</button>
    </div>
  );
}

// app/not-found.tsx (404 Global)
export default function NotFound() {
  return (
    <div>
      <h1>404 - Page Not Found</h1>
    </div>
  );
}
```

### Loading State (Suspense Automático)

```tsx
// app/dashboard/loading.tsx
export default function Loading() {
  return (
    <div className="skeleton">
      <div className="skeleton-bar" />
      <div className="skeleton-bar" />
    </div>
  );
}

// app/dashboard/page.tsx
async function getDashboardData() {
  // Simula delay
  await new Promise((resolve) => setTimeout(resolve, 2000));
  return { revenue: 1000 };
}

export default async function DashboardPage() {
  const data = await getDashboardData();
  // Mientras carga → muestra loading.tsx
  // Cuando termina → muestra page.tsx
  return <div>{data.revenue}</div>;
}
```

---

## Caching & Revalidation

### ISR (Incremental Static Regeneration)

```tsx
// app/blog/[slug]/page.tsx
export const revalidate = 3600; // Revalidate cada 1 hora

async function getPost(slug: string) {
  const res = await fetch(`https://api.example.com/posts/${slug}`, {
    next: { revalidate: 3600 },
  });
  return res.json();
}

export default async function PostPage({
  params,
}: {
  params: { slug: string };
}) {
  const post = await getPost(params.slug);
  return <article>{post.content}</article>;
}
```

### Manual Revalidation

```tsx
// app/actions/revalidateActions.ts
'use server'

import { revalidatePath, revalidateTag } from 'next/cache';

export async function revalidateBlog() {
  revalidatePath('/blog'); // Revalidar /blog y subrutas
}

export async function revalidatePost(slug: string) {
  revalidateTag(`post-${slug}`); // Revalidar por tag
}
```

### No-Cache

```tsx
// app/live/page.tsx
// Fetch dinámico (sin caché)
async function getLiveData() {
  const res = await fetch('https://api.example.com/live', {
    cache: 'no-store',
  });
  return res.json();
}

export default async function LivePage() {
  const data = await getLiveData();
  return <div>{data}</div>;
}
```

---

## Best Practices Checklist

```bash
# ✅ 1. Server Components
[ ] Mayoría de componentes son Server Components
[ ] Data fetching en Server Components
[ ] "use client" solo donde se necesita

# ✅ 2. Route Organization
[ ] app/ estructura clara
[ ] Route Groups para organizar
[ ] Layouts compartidos

# ✅ 3. Server Actions
[ ] Formularios usan Server Actions
[ ] Validación en servidor
[ ] revalidatePath() después de mutaciones

# ✅ 4. Error Handling
[ ] error.tsx en cada nivel
[ ] not-found.tsx para 404s
[ ] Loading states definidos

# ✅ 5. Caching
[ ] Fetch tiene `next: { revalidate: ... }`
[ ] ISR configurado para datos lentos
[ ] no-store solo cuando sea necesario

# ✅ 6. Performance
[ ] Code splitting automático
[ ] Images optimizadas con Next Image
[ ] Bundle size monitoreado
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ PRODUCTION-READY PATTERNS
**Responsable:** ArchitectZero AI Agent
