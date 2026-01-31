# ⚡ Angular Reactivity: Signals vs RxJS

> **Versión:** Angular 17+
> **Paradigma:** Reactividad Granular
> **Estado:** ✅ PRODUCTION-READY
> **Fecha:** 30 de Enero de 2026

La nueva era de Angular: Signals para estado local, RxJS para orquestación de flujos complejos.

---

## 📖 Tabla de Contenidos

1. [Signals: Estado Síncrono](#signals-estado-síncrono)
2. [RxJS: Eventos Asíncronos](#rxjs-eventos-asíncronos)
3. [Interop: RxJS ↔ Signals](#interop-rxjs--signals)
4. [Patrones de Flujos](#patrones-de-flujos)
5. [Anti-Patterns](#anti-patterns)

---

## Signals: Estado Síncrono

### ¿Qué Son Signals?

**Signals** son referencias mutables tipadas que notifican a Angular cuando cambian. Reemplazan a `BehaviorSubject` en el 90% de los casos.

```typescript
// ✅ GOOD: Signal para estado local
import { signal, computed, effect } from '@angular/core';

@Component({
  selector: 'app-counter',
  template: `
    <p>Count: {{ count() }}</p>
    <p>Double: {{ double() }}</p>
    <button (click)="increment()">Increment</button>
  `,
  standalone: true
})
export class CounterComponent {
  count = signal(0);
  double = computed(() => this.count() * 2);

  constructor() {
    // Side effects cuando count cambia
    effect(() => {
      console.log(`Count changed to ${this.count()}`);
    });
  }

  increment() {
    this.count.update(v => v + 1);
  }
}
```

### Métodos de Signal

| Método | Propósito | Ejemplo |
|:---|:---|:---|
| **`set()`** | Reemplaza valor | `count.set(5)` |
| **`update()`** | Función transformadora | `count.update(v => v + 1)` |
| **`mutate()`** | Muta array/objeto in-place | `items.mutate(arr => arr.push(item))` |
| **()`** | Lectura (getter) | `value = count()` |

```typescript
// ❌ BAD: Confundir Signal con observable
const items$ = signal([1, 2, 3]);
items$.value.push(4); // ← Muta sin notificar

// ✅ GOOD: Usar mutate para arrays
const items = signal([1, 2, 3]);
items.mutate(arr => arr.push(4)); // ← Notifica correctamente
```

### Computed vs Derived

```typescript
// ✅ GOOD: Signals derivadas con computed()
const firstName = signal('John');
const lastName = signal('Doe');
const fullName = computed(() => `${firstName()} ${lastName()}`);

// Reactivo: fullName se actualiza automáticamente
firstName.set('Jane'); // fullName → 'Jane Doe'
```

---

## RxJS: Eventos Asíncronos

### Regla de Oro: NO Anidar `.subscribe()`

RxJS es perfecto para orquestar **flujos asíncronos complejos**. Pero JAMÁS anidar `.subscribe()`.

```typescript
// ❌ BAD: Subscribe Hell (Memory Leaks + Race Conditions)
@Component({...})
export class SearchComponent {
  searchControl = new FormControl();

  constructor(private api: ApiService) {
    this.searchControl.valueChanges.subscribe(term => {
      this.api.search(term).subscribe(results => {  // 💀 BUG!
        this.results = results;
        // Si el usuario escribe rápido, ¿cuál resultado ganará?
        // Además, ¿quién desuscribe esto?
      });
    });
  }
}

// ✅ GOOD: Pipeline Declarativa con switchMap
@Component({...})
export class SearchComponent {
  searchControl = new FormControl();
  results$ = this.searchControl.valueChanges.pipe(
    debounceTime(300),          // Espera 300ms entre cambios
    distinctUntilChanged(),      // Solo si el valor es diferente
    switchMap(term =>            // Cancela peticiones previas
      this.api.search(term).pipe(
        catchError(error => {
          console.error(error);
          return of([]);         // Retorna array vacío en error
        })
      )
    )
  );

  constructor(private api: ApiService) {}
}
```

### Operadores Clave para Aplanamiento

| Operador | Comportamiento | Caso de Uso |
|:---|:---|:---|
| **`switchMap`** | Cancela observable anterior | Búsquedas, cambios frecuentes |
| **`mergeMap`** | Ejecuta todos en paralelo | HTTP calls independientes |
| **`concatMap`** | Ejecuta en serie (orden) | Operaciones dependientes |
| **`exhaustMap`** | Ignora mientras se procesa | Botones (evita clicks múltiples) |

```typescript
// switchMap: Cancelar búsquedas anteriores
searchControl.valueChanges.pipe(
  switchMap(term => this.api.search(term))
);
// Si escribes "hello" → "help" → "he":
// Cancela "hello", luego cancela "help", ejecuta "he"

// mergeMap: Todos en paralelo
buttonClicks.pipe(
  mergeMap(() => this.api.longOperation())  // 5 clicks = 5 requests
);

// concatMap: En orden
uploads.pipe(
  concatMap(file => this.api.upload(file))  // Espera cada upload
);

// exhaustMap: Ignore si ya está en progreso
saveButton.pipe(
  exhaustMap(() => this.api.save())  // Ignora clicks mientras guarda
);
```

---

## Interop: RxJS ↔ Signals

### `toSignal()`: Observable → Signal

Convierte un Observable en Signal para que se pueda usar como función en templates.

```typescript
import { toSignal } from '@angular/core/rxjs-interop';

@Component({
  selector: 'app-users',
  template: `
    <div>Users: {{ users().length }}</div>
    <div *ngFor="let user of users()">{{ user.name }}</div>
  `,
  standalone: true,
  imports: [CommonModule]
})
export class UsersComponent {
  // Convierte Observable a Signal
  users = toSignal(
    this.userService.getUsers(),
    { initialValue: [] }  // Valor inicial mientras carga
  );

  constructor(private userService: UserService) {}
}
```

### `toObservable()`: Signal → Observable

Convierte Signal en Observable si necesitas orquestar flujos.

```typescript
import { toObservable } from '@angular/core/rxjs-interop';

@Component({...})
export class FilterComponent {
  searchTerm = signal('');

  // Observable del cambio de searchTerm
  results$ = toObservable(this.searchTerm).pipe(
    debounceTime(300),
    switchMap(term => this.api.search(term))
  );

  constructor(private api: ApiService) {}
}
```

---

## Patrones de Flujos

### Patrón 1: Login + Redirect

```typescript
login$ = this.loginForm.submitted$.pipe(
  filter(() => this.loginForm.valid),
  switchMap(credentials =>
    this.authService.login(credentials).pipe(
      tap(user => {
        // Side effect: guardar token
        localStorage.setItem('token', user.token);
      }),
      tap(user => {
        // Side effect: redirigir
        this.router.navigate(['/dashboard']);
      }),
      catchError(error => {
        this.loginError.set(error.message);
        return EMPTY;
      })
    )
  )
);
```

### Patrón 2: Auto-Save (Debounce)

```typescript
// Auto-save cada 1 segundo sin escribir
@Component({...})
export class EditorComponent {
  content = signal('');

  constructor(private api: ApiService) {
    toObservable(this.content).pipe(
      debounceTime(1000),
      switchMap(text => this.api.saveDocument(text)),
      tap(() => this.lastSaved.set(new Date()))
    ).subscribe();
  }
}
```

### Patrón 3: Request + Retry + Timeout

```typescript
data$ = this.trigger$.pipe(
  switchMap(() =>
    this.api.fetchData().pipe(
      timeout(5000),              // Max 5 segundos
      retry({ count: 3, delay: 1000 }),  // Reintentar 3 veces
      catchError(error => {
        this.error.set('Failed to fetch data');
        return of(null);
      })
    )
  )
);
```

### Patrón 4: Combinar Múltiples Streams

```typescript
// Esperar a que ambos observables emitan
data$ = combineLatest([
  this.userService.currentUser$,
  this.settingsService.preferences$
]).pipe(
  map(([user, settings]) => ({ user, settings }))
);

// O usar withLatestFrom (izquierda es el trigger)
clicks$.pipe(
  withLatestFrom(this.searchTerm$),
  tap(([_, searchTerm]) => console.log(`Clicked with term: ${searchTerm}`))
);
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Memory Leaks (Sin Desuscribir)

```typescript
// ❌ BAD: Leak en ngInit
ngOnInit() {
  this.userService.getUser().subscribe(user => {
    this.user = user;  // ← Se ejecuta N veces si el componente se crea N veces
  });
}

// ✅ GOOD: Usar Signal (no necesita desuscripción)
user = toSignal(this.userService.getUser(), { initialValue: null });

// ✅ GOOD: Usar takeUntilDestroyed
ngOnInit() {
  this.userService.getUser()
    .pipe(takeUntilDestroyed())
    .subscribe(user => this.user = user);
}
```

### ❌ ANTI-PATTERN 2: Múltiples Subscriptions (Ineficiente)

```typescript
// ❌ BAD: 3 requests para el mismo data
user$ = this.userService.getUser();

// En template:
{{ user$ | async }}  // Subscribe 1
{{ user$ | async }}  // Subscribe 2
{{ (user$ | async).name }}  // Subscribe 3 (3 requests!)

// ✅ GOOD: Usar shareReplay()
user$ = this.userService.getUser().pipe(shareReplay(1));

// ✅ GOOD: Usar Signal (una única evaluación)
user = toSignal(this.userService.getUser());
```

### ❌ ANTI-PATTERN 3: Signals en Observables (Sin `toObservable()`)

```typescript
// ❌ BAD: Intentar usar signal en pipe
const term = signal('');
results$ = term.pipe(  // ← term no es un observable
  switchMap(t => this.api.search(t))
);

// ✅ GOOD: Convertir con toObservable
results$ = toObservable(term).pipe(
  switchMap(t => this.api.search(t))
);
```

### ❌ ANTI-PATTERN 4: Observable.subscribe en Componente (Sin Cleanup)

```typescript
// ❌ BAD: Sin cleanup
export class SearchComponent {
  subscription: Subscription;

  ngOnInit() {
    this.subscription = this.searchControl.valueChanges
      .pipe(switchMap(term => this.api.search(term)))
      .subscribe(results => this.results = results);
  }

  // ← Olvidó ngOnDestroy (leak!)
}

// ✅ GOOD: takeUntilDestroyed o async pipe
export class SearchComponent {
  results$ = this.searchControl.valueChanges.pipe(
    switchMap(term => this.api.search(term))
  );

  constructor() {
    // takeUntilDestroyed disponible en providedIn: 'root'
  }
}
```

---

## Checklist: Reactividad Bien Formada

```bash
# ✅ 1. Signals
[ ] Estados locales en Signals (no BehaviorSubject)
[ ] computed() para valores derivados
[ ] effect() solo para side effects críticos

# ✅ 2. RxJS
[ ] switchMap para búsquedas/cambios
[ ] mergeMap solo si necesitas paralelismo
[ ] exhaustMap para évitar clicks múltiples
[ ] NUNCA anidar .subscribe()

# ✅ 3. Interop
[ ] toSignal() en componentes
[ ] toObservable() cuando necesites orquestar
[ ] Async pipe o Signal en templates

# ✅ 4. Cleanup
[ ] takeUntilDestroyed() si usas Observable.subscribe()
[ ] NO olvides destroy subjects
[ ] Signals no necesitan limpieza

# ✅ 5. Performance
[ ] shareReplay(1) para requests compartidas
[ ] distinctUntilChanged() para evitar duplicados
[ ] debounceTime() en búsquedas/input events
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ REACTIVE FOUNDATION
**Responsable:** ArchitectZero AI Agent
