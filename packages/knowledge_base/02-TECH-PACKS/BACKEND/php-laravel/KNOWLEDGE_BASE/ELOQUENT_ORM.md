# 💎 Eloquent ORM: Active Record Mastery

> **Versión:** Laravel 11.0+
> **Patrón:** Active Record (Model = Row + Methods)
> **Estilo:** Fluent Interface, Chainable Queries
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Paradigma: Active Record](#paradigma-active-record)
2. [CRUD Básico](#crud-básico)
3. [Query Builder Fluent](#query-builder-fluent)
4. [Relaciones](#relaciones)
5. [Eager Loading](#eager-loading)
6. [Scopes](#scopes)
7. [Accessors & Mutators](#accessors--mutators)
8. [Eventos de Modelo](#eventos-de-modelo)

---

## Paradigma: Active Record

### ¿Qué es Active Record?

**Active Record** = El modelo sabe guardarse/actualizarse a sí mismo. No hay Repository externo.

```php
// Vs Data Mapper (ej: Doctrine)
// ❌ Data Mapper: Repositorio externo
$repository = new UserRepository();
$user = $repository->findById(1);
$user->setName('John');
$repository->save($user);

// ✅ Active Record (Eloquent): Modelo autosuficiente
$user = User::find(1);
$user->name = 'John';
$user->save();  // ← El modelo se actualiza a sí mismo
```

**Ventaja:** Menos boilerplate, más intuitivo.
**Desventaja:** Menos testeable si no se usa bien.

---

## CRUD Básico

### Crear (Create)

```php
// Forma 1: Instancia + save
$product = new Product();
$product->name = 'Laptop';
$product->price = 999;
$product->save();

// Forma 2: create() (Mass Assignment)
$product = Product::create([
    'name' => 'Laptop',
    'price' => 999,
    'stock' => 10
]);

// Forma 3: firstOrCreate (si existe, lo devuelve; si no, crea)
$product = Product::firstOrCreate(
    ['sku' => 'LAP-001'],              // Criterio de búsqueda
    ['name' => 'Laptop', 'price' => 999]  // Valores por defecto
);

// Forma 4: updateOrCreate
$product = Product::updateOrCreate(
    ['id' => 1],
    ['price' => 1099]  // Actualizar o crear
);
```

**Importante:** Mass Assignment

```php
// app/Models/Product.php
class Product extends Model {
    protected $fillable = ['name', 'price', 'stock', 'sku'];
    // ↑ Solo estos campos pueden ser creados con create()

    // O alternativamente
    protected $guarded = ['id'];  // Proteger solo 'id'
}
```

### Leer (Read)

```php
// Por ID (retorna o null)
$product = Product::find(1);

// Por ID o error 404
$product = Product::findOrFail(1);

// Primer resultado
$product = Product::first();

// Todos
$products = Product::all();

// Con filtros
$products = Product::where('price', '>', 100)
    ->where('stock', '>', 0)
    ->get();

// Contar
$count = Product::where('active', true)->count();
```

### Actualizar (Update)

```php
// Forma 1: Obtener, modificar, guardar
$product = Product::find(1);
$product->name = 'MacBook Pro';
$product->save();

// Forma 2: update() directo en query
Product::where('category', 'electronics')
    ->update(['price' => $price * 1.1]);  // +10%

// Forma 3: increment/decrement
$product->increment('stock', 5);      // stock += 5
$product->decrement('stock', 5);      // stock -= 5
Product::where('active', true)->increment('views');
```

### Eliminar (Delete)

```php
// Forma 1: Obtener y borrar
$product = Product::find(1);
$product->delete();

// Forma 2: delete() directo en query
Product::where('price', '<', 10)->delete();

// Forma 3: Borrar todo (CUIDADO)
Product::truncate();  // Vaciar tabla completamente
```

---

## Query Builder Fluent

### Chainable Methods

```php
$products = Product::where('active', true)
    ->where('price', '>', 100)
    ->orWhere('featured', true)
    ->orderBy('price', 'desc')
    ->limit(10)
    ->get();

// SQL generado:
// SELECT * FROM products
// WHERE active = true AND price > 100 OR featured = true
// ORDER BY price DESC
// LIMIT 10
```

### Operadores Comunes

```php
// Igualdad
Product::where('status', 'active');

// Comparación
Product::where('price', '>', 100);
Product::where('price', '<', 50);
Product::where('price', '>=', 100);

// LIKE
Product::where('name', 'like', '%laptop%');
Product::where('name', 'like', 'laptop%');  // Comienza con

// IN
Product::whereIn('category_id', [1, 2, 3]);
Product::whereNotIn('status', ['deleted', 'archived']);

// NULL
Product::whereNull('deleted_at');
Product::whereNotNull('verified_at');

// BETWEEN
Product::whereBetween('price', [100, 500]);

// EXISTS
Product::whereExists(function ($query) {
    $query->select('id')
        ->from('orders')
        ->whereColumn('orders.product_id', 'products.id');
});
```

### Agregaciones

```php
// COUNT
$count = Product::count();
$count = Product::where('active', true)->count();

// SUM
$total = Product::sum('price');

// AVG
$average = Product::avg('price');

// MIN/MAX
$cheapest = Product::min('price');
$expensive = Product::max('price');

// GROUP BY + Agregación
$categories = Product::selectRaw('category, COUNT(*) as count, AVG(price) as avg_price')
    ->groupBy('category')
    ->having('count', '>', 5)
    ->get();
```

### Pagination

```php
// Paginar por defecto (15 items)
$products = Product::paginate();

// Paginar con custom per page
$products = Product::paginate(25);

// En la vista
{{ $products->links() }}

// Con query string
{{ $products->links('pagination::bootstrap-5') }}

// Obtener página actual
$page = $products->currentPage();
$lastPage = $products->lastPage();
```

---

## Relaciones

### One-to-Many (ForeignKey)

```php
// app/Models/Category.php
class Category extends Model {
    public function products() {
        return $this->hasMany(Product::class);
    }
}

// app/Models/Product.php
class Product extends Model {
    public function category() {
        return $this->belongsTo(Category::class);
    }
}

// Uso
$category = Category::find(1);
$products = $category->products;  // Todos los productos de categoría 1

$product = Product::find(1);
$categoryName = $product->category->name;  // Nombre de categoría
```

### Many-to-Many

```php
// app/Models/User.php
class User extends Model {
    public function roles() {
        return $this->belongsToMany(Role::class);
    }
}

// app/Models/Role.php
class Role extends Model {
    public function users() {
        return $this->belongsToMany(User::class);
    }
}

// Tabla pivote: user_role (user_id, role_id)

// Uso
$user = User::find(1);
$roles = $user->roles;  // Todos los roles del usuario

$role = Role::find(1);
$users = $role->users;  // Todos los usuarios con este rol

// Agregar relación
$user->roles()->attach($roleId);

// Remover
$user->roles()->detach($roleId);

// Toggle (agregar si no existe, remover si existe)
$user->roles()->toggle($roleId);
```

### Has-One

```php
// app/Models/User.php
class User extends Model {
    public function profile() {
        return $this->hasOne(UserProfile::class);
    }
}

// Uso
$user = User::find(1);
$profile = $user->profile;  // Una relación
```

---

## Eager Loading

### Problema: N+1 Queries

```php
// ❌ INCORRECTO: N+1
$products = Product::all();
foreach ($products as $product) {
    echo $product->category->name;  // 1 query por producto
}
// Total: 1 (products) + 1000 (categories) = 1001 queries

// ✅ CORRECTO: Eager Loading
$products = Product::with('category')->get();
foreach ($products as $product) {
    echo $product->category->name;  // Usa caché
}
// Total: 1 (products) + 1 (categories via JOIN) = 2 queries
```

### With Multiple Relaciones

```php
// Cargar múltiples relaciones
$products = Product::with('category', 'manufacturer')
    ->get();

// Relaciones anidadas
$products = Product::with('category.subcategory')
    ->get();

// Relaciones condicionales
$products = Product::with(['category' => function ($query) {
    $query->where('active', true);
}])->get();
```

---

## Scopes

### Local Scope

```php
// app/Models/Product.php
class Product extends Model {
    // ✅ Local Scope: Lógica reutilizable
    public function scopeActive($query) {
        return $query->where('active', true);
    }

    public function scopePriceBetween($query, $min, $max) {
        return $query->whereBetween('price', [$min, $max]);
    }

    public function scopePopular($query) {
        return $query->where('views', '>', 1000);
    }
}

// Uso
$products = Product::active()->get();
$products = Product::active()->priceBetween(100, 500)->get();
$popular = Product::popular()->active()->get();

// SQL: WHERE active = true AND views > 1000
```

### Global Scope

```php
// app/Models/Product.php
class Product extends Model {
    protected static function booted() {
        // ✅ Global Scope: Se aplica siempre
        static::addGlobalScope('active', function ($query) {
            $query->where('active', true);
        });
    }
}

// Todos los queries filtraran por active = true automáticamente
$products = Product::all();  // Ya está filtrado

// Remover global scope si es necesario
$products = Product::withoutGlobalScopes()->get();
```

---

## Accessors & Mutators

### Accessors (GET): Transformar al Leer

```php
// app/Models/Product.php
use Illuminate\Database\Eloquent\Casts\Attribute;

class Product extends Model {
    protected function formattedPrice(): Attribute {
        return Attribute::make(
            get: fn () => '$' . number_format($this->price, 2),
        );
    }

    protected function categoryName(): Attribute {
        return Attribute::make(
            get: fn () => $this->category?->name ?? 'N/A',
        );
    }
}

// Uso
$product = Product::find(1);
echo $product->formatted_price;  // $ 99.99
echo $product->category_name;    // Electronics
```

### Mutators (SET): Transformar al Guardar

```php
// app/Models/User.php
use Illuminate\Database\Eloquent\Casts\Attribute;

class User extends Model {
    protected function password(): Attribute {
        return Attribute::make(
            set: fn ($value) => Hash::make($value),  // Hashear contraseña
        );
    }

    protected function email(): Attribute {
        return Attribute::make(
            set: fn ($value) => strtolower($value),  // Minúsculas
        );
    }
}

// Uso
$user = User::create([
    'email' => 'JOHN@EXAMPLE.COM',
    'password' => 'plaintext'
]);

// Automáticamente:
// - email guardado como 'john@example.com'
// - password hasheado (no plaintext)
```

---

## Eventos de Modelo

### Lifecycle Hooks

```php
// app/Models/Product.php
class Product extends Model {
    protected static function booted() {
        // Antes de crear
        static::creating(function ($product) {
            $product->sku = strtoupper($product->name);
        });

        // Después de crear
        static::created(function ($product) {
            Log::info("Producto creado: {$product->id}");
        });

        // Antes de actualizar
        static::updating(function ($product) {
            Log::info("Actualizando producto {$product->id}");
        });

        // Antes de eliminar
        static::deleting(function ($product) {
            // Soft delete: marcar como eliminado
            $product->update(['deleted_at' => now()]);
        });
    }
}

// Ciclo completo
Product::create([...]);  // creating → created
$product->update([...]);  // updating → updated
$product->delete();       // deleting → deleted
```

---

## Ejemplo Completo: E-commerce

```php
// app/Models/Product.php
class Product extends Model {
    use SoftDeletes;  // Soft delete support

    protected $fillable = ['name', 'price', 'stock', 'category_id'];

    public function category() {
        return $this->belongsTo(Category::class);
    }

    public function orders() {
        return $this->belongsToMany(Order::class, 'order_items')
            ->withPivot('quantity', 'price');
    }

    public function scopeActive($query) {
        return $query->where('active', true);
    }

    public function scopeInStock($query) {
        return $query->where('stock', '>', 0);
    }

    protected function formattedPrice(): Attribute {
        return Attribute::make(
            get: fn () => '$' . number_format($this->price, 2),
        );
    }
}

// Uso
$products = Product::active()
    ->inStock()
    ->where('price', '<', 100)
    ->with('category')
    ->paginate(20);

foreach ($products as $product) {
    echo "{$product->name}: {$product->formatted_price}";
}
```

Eloquent = Potencia + Elegancia. 💎✨
