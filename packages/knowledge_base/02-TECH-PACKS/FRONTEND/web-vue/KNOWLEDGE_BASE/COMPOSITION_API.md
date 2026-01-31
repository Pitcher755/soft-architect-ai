# 🍃 Vue 3 Composition API: The Progressive Framework

> **Versión:** Vue 3.3+
> **Estándar:** `<script setup lang="ts">`
> **Paradigma:** Composition API (Options API is Legacy)
> **Fecha:** 30 de Enero de 2026

La sintaxis `<script setup>` eliminó el boilerplate de Vue. La Composition API es la forma moderna de escribir componentes.

---

## 📖 Tabla de Contenidos

1. [Sintaxis `<script setup>`](#sintaxis-script-setup)
2. [Reactividad: `ref` vs `reactive`](#reactividad-ref-vs-reactive)
3. [Composables (Hooks)](#composables-hooks)
4. [Lifecycle Hooks](#lifecycle-hooks)
5. [Props & Emits](#props--emits)
6. [Anti-Patterns](#anti-patterns)

---

## Sintaxis `<script setup>`

### ¿Qué es `<script setup>`?

Es azúcar sintáctico que reduce el código en un 40%. No necesitas `return` ni `export default`.

```vue
<!-- ❌ OLD: Options API -->
<script lang="ts">
export default {
  data() {
    return { count: 0 }
  },
  computed: {
    double() {
      return this.count * 2
    }
  },
  methods: {
    increment() {
      this.count++
    }
  }
}
</script>

<!-- ✅ NEW: Composition API with <script setup> -->
<script setup lang="ts">
import { ref, computed } from 'vue'

const count = ref(0)
const double = computed(() => count.value * 2)

const increment = () => {
  count++  // Vue actualiza automáticamente
}
</script>

<template>
  <button @click="increment">
    Count: {{ count }} (Double: {{ double }})
  </button>
</template>
```

### Todo se Importa y se Usa

En `<script setup>`, no necesitas registrar componentes ni helpers. Solo importa y úsalo:

```vue
<script setup lang="ts">
import { ref } from 'vue'
import UserCard from './UserCard.vue'  // ← Auto-registrado
import { useRouter } from 'vue-router'  // ← Hook

const router = useRouter()
const user = ref(null)

const goToProfile = () => {
  router.push(`/user/${user.value.id}`)
}
</script>

<template>
  <UserCard :user="user" />
  <button @click="goToProfile">Ver Perfil</button>
</template>
```

---

## Reactividad: `ref` vs `reactive`

### Regla de Oro: Usa `ref` para Todo

**`ref`** es seguro, predecible y funciona con primitivos y objetos.

```typescript
// ✅ GOOD: ref para primitivos
const count = ref(0)
const name = ref('Ana')
const isLoading = ref(false)

// ✅ GOOD: ref para objetos (acceso con .value)
const user = ref({ id: 1, name: 'Ana' })
user.value.name = 'Bob'

// ✅ GOOD: Reasignar ref (seguro)
const data = ref<string | null>(null)
data.value = 'test'
```

### Evita `reactive` (Es Peligroso)

`reactive` solo funciona con objetos y pierde reactividad si lo desestructuras.

```typescript
// ❌ BAD: reactive destructuring
const state = reactive({ count: 0, name: 'Ana' })
const { count, name } = state  // ← count y name ya NO son reactivos

// ✅ GOOD: Si insistes en reactive, usa toRefs
const state = reactive({ count: 0, name: 'Ana' })
const { count, name } = toRefs(state)  // ← Ahora sí son reactivos
```

### Template: `.value` No Se Necesita

Vue "desempaca" automáticamente en templates:

```vue
<script setup lang="ts">
const count = ref(0)
const user = ref({ name: 'Ana' })
</script>

<template>
  <!-- No necesitas .value -->
  <p>{{ count }}</p>        <!-- 0 -->
  <p>{{ user.name }}</p>    <!-- Ana -->
</template>
```

---

## Composables (Hooks)

**Composables** son funciones que reutilizan lógica (igual que React Hooks).

### Crear un Composable

```typescript
// composables/useMouse.ts
import { ref, onMounted, onUnmounted } from 'vue'

export function useMouse() {
  const x = ref(0)
  const y = ref(0)

  const update = (event: MouseEvent) => {
    x.value = event.clientX
    y.value = event.clientY
  }

  onMounted(() => window.addEventListener('mousemove', update))
  onUnmounted(() => window.removeEventListener('mousemove', update))

  return { x, y }
}
```

### Usar el Composable

```vue
<script setup lang="ts">
import { useMouse } from '@/composables/useMouse'

const { x, y } = useMouse()
</script>

<template>
  <p>Mouse: {{ x }}, {{ y }}</p>
</template>
```

### Composables Asíncronos

```typescript
// composables/useFetch.ts
import { ref, isRef, unref, watch } from 'vue'

export function useFetch(url) {
  const data = ref(null)
  const error = ref(null)
  const loading = ref(false)

  const fetch = async () => {
    loading.value = true
    try {
      const response = await fetch(unref(url))
      data.value = await response.json()
    } catch (e) {
      error.value = e
    } finally {
      loading.value = false
    }
  }

  // Si url es ref, refetch cuando cambie
  if (isRef(url)) {
    watch(url, fetch)
  }

  fetch()

  return { data, error, loading }
}
```

---

## Lifecycle Hooks

Vue organiza el ciclo de vida en hooks simples:

```typescript
import {
  onBeforeMount,
  onMounted,
  onBeforeUpdate,
  onUpdated,
  onBeforeUnmount,
  onUnmounted,
  onErrorCaptured,
} from 'vue'

export default {
  setup() {
    onBeforeMount(() => console.log('Antes de montar'))
    onMounted(() => console.log('Montado'))
    onBeforeUpdate(() => console.log('Antes de actualizar'))
    onUpdated(() => console.log('Actualizado'))
    onBeforeUnmount(() => console.log('Antes de desmontar'))
    onUnmounted(() => console.log('Desmontado'))
    onErrorCaptured((err) => console.error('Error capturado', err))
  },
}
```

### Caso Común: Fetch en onMounted

```typescript
const user = ref(null)
const loading = ref(false)

onMounted(async () => {
  loading.value = true
  try {
    const res = await fetch('/api/user')
    user.value = await res.json()
  } finally {
    loading.value = false
  }
})
```

---

## Props & Emits

### Definir Props (Tipadas)

```vue
<script setup lang="ts">
interface Props {
  id: string
  title?: string
  disabled?: boolean
}

const props = defineProps<Props>()

// Acceder:
console.log(props.id)
</script>

<template>
  <div :class="{ disabled: props.disabled }">
    {{ props.title }}
  </div>
</template>
```

### Definir Emits (Tipados)

```vue
<script setup lang="ts">
const emit = defineEmits<{
  (e: 'update', value: string): void
  (e: 'close'): void
}>()

const handleSubmit = (value: string) => {
  emit('update', value)
}

const handleClose = () => {
  emit('close')
}
</script>

<template>
  <button @click="handleSubmit('test')">Update</button>
  <button @click="handleClose">Close</button>
</template>
```

### Usar el Componente

```vue
<script setup lang="ts">
import UserForm from './UserForm.vue'

const onUpdate = (value: string) => {
  console.log('Updated:', value)
}

const onClose = () => {
  console.log('Closed')
}
</script>

<template>
  <UserForm id="1" title="Edit" @update="onUpdate" @close="onClose" />
</template>
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Mutar Directamente Refs

```typescript
// ❌ BAD: Mutar sin .value
const count = ref(0)
count = count + 1  // ← Pierde reactividad

// ✅ GOOD: Usar .value
count.value = count.value + 1

// ✅ GOOD: Usar .value en métodos
const increment = () => {
  count.value++
}
```

### ❌ ANTI-PATTERN 2: reactive Sin Desestructuración Segura

```typescript
// ❌ BAD: Desestructuración pierde reactividad
const state = reactive({ count: 0 })
const { count } = state  // count es estático

// ✅ GOOD: Con toRefs
const { count } = toRefs(state)

// ✅ GOOD: Acceso directo
state.count++
```

### ❌ ANTI-PATTERN 3: No Limpiar Listeners en onUnmounted

```typescript
// ❌ BAD: Memory leak
const count = ref(0)
onMounted(() => {
  window.addEventListener('click', () => {
    count.value++
  })
  // ← Nunca se elimina el listener
})

// ✅ GOOD: Limpiar en onUnmounted
onMounted(() => {
  const handler = () => {
    count.value++
  }
  window.addEventListener('click', handler)

  onUnmounted(() => {
    window.removeEventListener('click', handler)
  })
})
```

### ❌ ANTI-PATTERN 4: Computed con Side Effects

```typescript
// ❌ BAD: Computed NO debe tener side effects
const fullName = computed(() => {
  localStorage.setItem('name', firstName.value)  // ← BAD!
  return `${firstName.value} ${lastName.value}`
})

// ✅ GOOD: Usar watch para side effects
const fullName = computed(() => `${firstName.value} ${lastName.value}`)

watch(fullName, (newName) => {
  localStorage.setItem('name', newName)
})
```

---

## Checklist: Composition API Bien Formada

```bash
# ✅ 1. Sintaxis
[ ] Usar <script setup lang="ts">
[ ] Sin Options API en el proyecto
[ ] Imports al inicio del script

# ✅ 2. Reactividad
[ ] ref para todo (primarios y objetos)
[ ] NO usar reactive sin toRefs
[ ] .value en JavaScript, NO en template

# ✅ 3. Composables
[ ] Lógica compleja extraída a composables
[ ] Composables son funciones puras
[ ] Nombres con prefijo "use"

# ✅ 4. Lifecycle
[ ] onMounted para fetches iniciales
[ ] onUnmounted para limpiar listeners
[ ] watch para observar cambios
[ ] computed para valores derivados

# ✅ 5. Props & Emits
[ ] Props tipadas con defineProps<T>()
[ ] Emits tipados con defineEmits<{...}>()
[ ] NO modificar props directamente

# ✅ 6. Performance
[ ] Evitar computed innecesarios
[ ] Usar v-show en lugar de v-if para toggles frecuentes
[ ] Lazy loading de componentes con defineAsyncComponent
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ PROGRESSIVE FRAMEWORK
**Responsable:** ArchitectZero AI Agent
