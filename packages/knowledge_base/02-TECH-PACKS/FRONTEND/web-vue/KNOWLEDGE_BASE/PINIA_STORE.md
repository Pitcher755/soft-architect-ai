# 🍍 Pinia State Management

> **Sucesor de:** Vuex
> **Filosofía:** Simple, Type-Safe, Modular
> **Versión:** Pinia 2+
> **Estándar:** Setup Store Syntax (No Options)

Gestión de estado intuitiva para Vue 3. Elimina la complejidad de Vuex.

---

## 📖 Tabla de Contenidos

1. [Setup Store vs Option Store](#setup-store-vs-option-store)
2. [Definiendo un Store](#definiendo-un-store)
3. [Usando el Store](#usando-el-store)
4. [Getters (Computed)](#getters-computed)
5. [Actions (Async Logic)](#actions-async-logic)
6. [Desestructuración Reactiva](#desestructuración-reactiva)
7. [Plugins y Persistencia](#plugins-y-persistencia)

---

## Setup Store vs Option Store

### Setup Store (RECOMENDADO)

Sintaxis similar a `<script setup>`. Moderno y flexible.

```typescript
// ✅ GOOD: Setup Store
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export const useAuthStore = defineStore('auth', () => {
  // State (ref)
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)

  // Getters (computed)
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'admin')

  // Actions (functions)
  async function login(credentials: LoginDto) {
    const res = await api.post('/login', credentials)
    user.value = res.user
    token.value = res.token
  }

  function logout() {
    user.value = null
    token.value = null
  }

  return { user, token, isAuthenticated, isAdmin, login, logout }
})
```

### Option Store (LEGACY)

Sintaxis antigua. No la uses en proyectos nuevos.

```typescript
// ❌ OLD: Option Store
export const useAuthStore = defineStore('auth', {
  state: () => ({
    user: null,
    token: null,
  }),
  getters: {
    isAuthenticated: (state) => !!state.token,
  },
  actions: {
    async login(credentials) {
      // ...
    },
  },
})
```

---

## Definiendo un Store

### Tienda de Autenticación

```typescript
// stores/auth.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface User {
  id: string
  email: string
  name: string
  role: 'user' | 'admin'
}

export interface LoginDto {
  email: string
  password: string
}

export const useAuthStore = defineStore('auth', () => {
  // ============ STATE ============
  const user = ref<User | null>(null)
  const token = ref<string | null>(null)
  const loading = ref(false)
  const error = ref<string | null>(null)

  // ============ GETTERS ============
  const isAuthenticated = computed(() => !!token.value)
  const isAdmin = computed(() => user.value?.role === 'admin')
  const userName = computed(() => user.value?.name ?? 'Guest')

  // ============ ACTIONS ============
  async function login(credentials: LoginDto) {
    loading.value = true
    error.value = null

    try {
      const res = await fetch('/api/auth/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(credentials),
      })

      if (!res.ok) {
        throw new Error('Invalid credentials')
      }

      const data = await res.json()
      user.value = data.user
      token.value = data.token

      // Guardar token en localStorage
      localStorage.setItem('token', data.token)
    } catch (err) {
      error.value = (err as Error).message
      throw err
    } finally {
      loading.value = false
    }
  }

  async function logout() {
    user.value = null
    token.value = null
    localStorage.removeItem('token')
  }

  // Cargar usuario al iniciar sesión (ej: page refresh)
  async function hydrateFromToken() {
    const savedToken = localStorage.getItem('token')
    if (savedToken) {
      token.value = savedToken
      // Validar token con backend si es necesario
    }
  }

  return {
    // State
    user,
    token,
    loading,
    error,
    // Getters
    isAuthenticated,
    isAdmin,
    userName,
    // Actions
    login,
    logout,
    hydrateFromToken,
  }
})
```

### Tienda de Usuarios (Más Compleja)

```typescript
// stores/users.ts
import { defineStore } from 'pinia'
import { ref, computed } from 'vue'

export interface User {
  id: string
  name: string
  email: string
  role: string
}

export const useUsersStore = defineStore('users', () => {
  // State
  const users = ref<User[]>([])
  const selectedUser = ref<User | null>(null)
  const loading = ref(false)
  const filter = ref('')

  // Getters
  const filteredUsers = computed(() => {
    if (!filter.value) return users.value
    return users.value.filter(
      u =>
        u.name.toLowerCase().includes(filter.value.toLowerCase()) ||
        u.email.toLowerCase().includes(filter.value.toLowerCase())
    )
  })

  const userCount = computed(() => users.value.length)
  const adminCount = computed(() => users.value.filter(u => u.role === 'admin').length)

  // Actions
  async function fetchUsers() {
    loading.value = true
    try {
      const res = await fetch('/api/users')
      users.value = await res.json()
    } finally {
      loading.value = false
    }
  }

  async function createUser(data: Omit<User, 'id'>) {
    const res = await fetch('/api/users', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    })
    const newUser = await res.json()
    users.value.push(newUser)
    return newUser
  }

  async function updateUser(id: string, data: Partial<User>) {
    const res = await fetch(`/api/users/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(data),
    })
    const updated = await res.json()

    // Actualizar en el store
    const index = users.value.findIndex(u => u.id === id)
    if (index >= 0) {
      users.value[index] = updated
    }

    if (selectedUser.value?.id === id) {
      selectedUser.value = updated
    }

    return updated
  }

  async function deleteUser(id: string) {
    await fetch(`/api/users/${id}`, { method: 'DELETE' })
    users.value = users.value.filter(u => u.id !== id)

    if (selectedUser.value?.id === id) {
      selectedUser.value = null
    }
  }

  function selectUser(user: User) {
    selectedUser.value = user
  }

  function setFilter(text: string) {
    filter.value = text
  }

  return {
    // State
    users,
    selectedUser,
    loading,
    filter,
    // Getters
    filteredUsers,
    userCount,
    adminCount,
    // Actions
    fetchUsers,
    createUser,
    updateUser,
    deleteUser,
    selectUser,
    setFilter,
  }
})
```

---

## Usando el Store

### En Componentes Vue

```vue
<script setup lang="ts">
import { useAuthStore } from '@/stores/auth'
import { storeToRefs } from 'pinia'

// Importar el store
const auth = useAuthStore()

// Desestructurar con storeToRefs para mantener reactividad
const { user, isAuthenticated } = storeToRefs(auth)

// Las acciones se llaman directamente
const handleLogout = () => {
  auth.logout()
}
</script>

<template>
  <div v-if="isAuthenticated">
    <p>Bienvenido, {{ user?.name }}</p>
    <button @click="handleLogout">Logout</button>
  </div>
  <div v-else>
    <p>Por favor, inicia sesión</p>
  </div>
</template>
```

### En Composables

```typescript
// composables/useAuthCheck.ts
import { computed } from 'vue'
import { useAuthStore } from '@/stores/auth'

export function useAuthCheck() {
  const auth = useAuthStore()

  const canEdit = computed(() => {
    return auth.isAuthenticated && auth.isAdmin
  })

  const canDelete = computed(() => {
    return auth.isAdmin
  })

  return { canEdit, canDelete }
}
```

---

## Getters (Computed)

Los **Getters** son propiedades calculadas que se memorizan.

```typescript
export const useStoreExample = defineStore('example', () => {
  const todos = ref<Todo[]>([])

  // ✅ GOOD: Getter simple
  const todoCount = computed(() => todos.value.length)

  // ✅ GOOD: Getter con lógica
  const completedTodos = computed(() =>
    todos.value.filter(t => t.completed)
  )

  // ✅ GOOD: Getter que depende de otro getter
  const completionPercentage = computed(() => {
    if (todoCount.value === 0) return 0
    return Math.round((completedTodos.value.length / todoCount.value) * 100)
  })

  return { todos, todoCount, completedTodos, completionPercentage }
})
```

---

## Actions (Async Logic)

Las **Actions** son funciones que modifican el estado.

```typescript
export const useDataStore = defineStore('data', () => {
  const items = ref<Item[]>([])
  const loading = ref(false)
  const error = ref<string | null>(null)

  // ✅ GOOD: Action asíncrona
  async function fetchItems() {
    loading.value = true
    error.value = null

    try {
      const res = await fetch('/api/items')
      if (!res.ok) throw new Error('Failed to fetch')
      items.value = await res.json()
    } catch (err) {
      error.value = (err as Error).message
    } finally {
      loading.value = false
    }
  }

  // ✅ GOOD: Action síncrona
  function addItem(item: Item) {
    items.value.push(item)
  }

  // ✅ GOOD: Action que usa otra action
  async function syncItems() {
    await fetchItems()
    // ... más lógica
  }

  return { items, loading, error, fetchItems, addItem, syncItems }
})
```

---

## Desestructuración Reactiva

### El Problema: Perder Reactividad

```typescript
const store = useAuthStore()

// ❌ BAD: count y user pierden reactividad
const { user, isAuthenticated } = store

// ✅ GOOD: Usar storeToRefs
const { user, isAuthenticated } = storeToRefs(store)
```

### El Patrón Correcto

```typescript
import { storeToRefs } from 'pinia'

export default {
  setup() {
    const store = useAuthStore()

    // Para STATE y GETTERS: usar storeToRefs
    const { user, isAuthenticated } = storeToRefs(store)

    // Para ACTIONS: llamar directamente (no necesitan storeToRefs)
    const { login, logout } = store

    return {
      user,
      isAuthenticated,
      login,
      logout,
    }
  },
}
```

---

## Plugins y Persistencia

### Guardar en localStorage

```typescript
// pinia-plugins/localStorage.ts
import type { PiniaPluginContext } from 'pinia'

export function piniaLocalStoragePlugin({ store }: PiniaPluginContext) {
  // Al crear el store, cargar desde localStorage
  const saved = localStorage.getItem(store.$id)
  if (saved) {
    store.$patch(JSON.parse(saved))
  }

  // Cada vez que cambia el estado, guardar en localStorage
  store.$subscribe((mutation, state) => {
    localStorage.setItem(store.$id, JSON.stringify(state))
  })
}
```

### Usar el Plugin

```typescript
// main.ts
import { createPinia } from 'pinia'
import { piniaLocalStoragePlugin } from '@/pinia-plugins/localStorage'

const pinia = createPinia()
pinia.use(piniaLocalStoragePlugin)

app.use(pinia)
```

---

## Checklist: Pinia Bien Formada

```bash
# ✅ 1. Stores
[ ] Usar Setup Store syntax
[ ] Store por dominio lógico
[ ] Nombres descriptivos (useNombreStore)

# ✅ 2. State
[ ] ref para todos los estados
[ ] Tipos definidos con TypeScript
[ ] Estados iniciales con valores por defecto

# ✅ 3. Getters
[ ] computed para valores derivados
[ ] NO side effects en getters
[ ] Getters memorizados automáticamente

# ✅ 4. Actions
[ ] Funciones puras
[ ] Manejo de errores (try/catch)
[ ] Loading/error states explícitos

# ✅ 5. Usage
[ ] storeToRefs para desestructuración
[ ] Actions sin parentésis en template
[ ] NO modificar estado directamente fuera de actions

# ✅ 6. Performance
[ ] Lazy load stores si es necesario
[ ] No crear stores globales innecesarios
[ ] Usar computed para valores derivados
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ STATE MANAGEMENT READY
**Responsable:** ArchitectZero AI Agent
