# ⌨️ Artisan Console: The Power CLI of Laravel

> **Versión:** Laravel 11.0+
> **Propósito:** Automatización y mantenimiento desde CLI
> **Herramienta:** Built-in Artisan (equivalent a Django management, Rails rake)
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Artisan Básico](#artisan-básico)
2. [Generar Archivos](#generar-archivos)
3. [Custom Commands](#custom-commands)
4. [Task Scheduling](#task-scheduling)
5. [Migraciones](#migraciones)
6. [Seeding](#seeding)
7. [Debugging Commands](#debugging-commands)

---

## Artisan Básico

### Comandos Más Usados

```bash
# Listar todos los comandos
php artisan list

# Ayuda de un comando
php artisan help migrate

# Ejecutar servidor de desarrollo
php artisan serve

# Ejecutar en puerto específico
php artisan serve --port=8080

# Ver configuración
php artisan config:show

# Cachear configuración (producción)
php artisan config:cache

# Limpiar caché
php artisan cache:clear
php artisan route:clear
php artisan view:clear
```

---

## Generar Archivos

### Make Commands (Scaffolding)

```bash
# Generar Modelo
php artisan make:model Product

# Modelo + Migración + Controlador
php artisan make:model Product -mcr

# Opcionalmente Resource Controller
php artisan make:controller ProductController --resource

# Middleware
php artisan make:middleware CheckAdmin

# Validador personalizado
php artisan make:rule Uppercase

# Job (background processing)
php artisan make:job SendOrderEmail

# Event
php artisan make:event OrderShipped

# Listener
php artisan make:listener NotifyCustomer --event=OrderShipped

# Request (Form Request con validación)
php artisan make:request StoreProductRequest

# Seeder
php artisan make:seeder ProductSeeder

# Mail
php artisan make:mail OrderShipped

# Notification
php artisan make:notification OrderShipped
```

### Flags Útiles

```bash
# Modelo con migración y factory
php artisan make:model Product -mf

# Modelo + todo (migration, factory, seeder, policy, resource)
php artisan make:model Product --all

# Fuerza creación si ya existe
php artisan make:model Product --force

# API Resource Controller (sin create/edit, solo JSON)
php artisan make:controller API/ProductController --api
```

---

## Custom Commands

### Crear un Comando Personalizado

```bash
php artisan make:command SendEmails
```

```php
// app/Console/Commands/SendEmails.php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Models\User;
use App\Mail\WelcomeEmail;

class SendEmails extends Command {
    // Nombre y descripción
    protected $signature = 'email:send {user}';
    protected $description = 'Send welcome email to a user';

    public function handle() {
        // Obtener argumento
        $userId = $this->argument('user');
        $user = User::find($userId);

        if (!$user) {
            $this->error("User not found");
            return Command::FAILURE;
        }

        // Enviar email
        Mail::send(new WelcomeEmail($user));

        // Output
        $this->info("Email sent to {$user->email}");
        return Command::SUCCESS;
    }
}
```

### Usar el Comando

```bash
# Ejecutar
php artisan email:send 1

# Con opciones
php artisan email:send 1 --queue

# Ayuda
php artisan email:send --help
```

### Argumentos y Opciones

```php
// Sintaxis: {argumento} [argumento_opcional] {--opcion}

protected $signature = 'email:send
    {user : ID del usuario}
    {--queue : Encolar email en lugar de enviar inmediatamente}
    {--delay=0 : Delay en segundos}
';

public function handle() {
    $user = $this->argument('user');
    $queue = $this->option('queue');
    $delay = $this->option('delay');

    if ($queue) {
        Mail::queue(new WelcomeEmail($user));
    } else {
        Mail::send(new WelcomeEmail($user));
    }
}
```

### Interacción con el Usuario

```php
public function handle() {
    // Preguntar
    $name = $this->ask('What is your name?');

    // Contraseña (oculta)
    $password = $this->secret('Enter password:');

    // Confirmar
    if ($this->confirm('Are you sure?')) {
        $this->info('Confirmed!');
    }

    // Múltiple elección
    $choice = $this->choice('Which color?', ['red', 'green', 'blue'], 0);

    // Progress bar
    $progress = $this->withProgressBar($items, function ($item) {
        // Procesar item
    });

    // Tabla
    $this->table(['ID', 'Name'], [
        [1, 'John'],
        [2, 'Jane'],
    ]);
}
```

---

## Task Scheduling

### Scheduler Centralizado en PHP

```php
// app/Console/Kernel.php
protected function schedule(Schedule $schedule) {
    // Cada día a las 2 AM
    $schedule->command('email:send')
        ->dailyAt('02:00');

    // Cada hora
    $schedule->command('cache:clear')
        ->hourly();

    // Cada 5 minutos
    $schedule->command('reports:generate')
        ->everyFiveMinutes();

    // Custom frecuencia
    $schedule->command('backups:run')
        ->everyFourHours();

    // Correr solo si producción
    $schedule->command('optimize')
        ->daily()
        ->onOneServer()  // Solo un servidor en cluster
        ->environments(['production']);

    // Solo lunes
    $schedule->command('tasks')
        ->weeklyOn(1, '09:00');  // Monday at 9 AM
}
```

### Eventos de Schedule

```php
$schedule->command('email:send')
    ->dailyAt('02:00')
    ->before(function () {
        Log::info('Task starting...');
    })
    ->after(function () {
        Log::info('Task complete!');
    })
    ->onFailure(function () {
        Log::error('Task failed!');
    });
```

### Ejecutar Scheduler

```bash
# En producción, agregar al crontab del servidor
* * * * * cd /app && php artisan schedule:run >> /dev/null 2>&1

# O en Docker/Kubernetes, usar un contenedor dedicado
```

---

## Migraciones

### Crear Migración

```bash
php artisan make:migration create_products_table

# Opción: para una tabla existente
php artisan make:migration add_price_to_products_table
```

### Escribir Migración

```php
// database/migrations/2026_01_30_create_products_table.php
public function up(): void {
    Schema::create('products', function (Blueprint $table) {
        $table->id();
        $table->string('name');
        $table->decimal('price', 10, 2);
        $table->integer('stock')->default(0);
        $table->timestamps();
    });
}

public function down(): void {
    Schema::dropIfExists('products');
}
```

### Ejecutar Migraciones

```bash
# Aplicar todas las migraciones pendientes
php artisan migrate

# Rollback última migración
php artisan migrate:rollback

# Rollback todas
php artisan migrate:reset

# Refresh (rollback + migrate)
php artisan migrate:refresh

# Ver estado de migraciones
php artisan migrate:status
```

---

## Seeding

### Crear Seeder

```bash
php artisan make:seeder ProductSeeder
```

```php
// database/seeders/ProductSeeder.php
namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Product;

class ProductSeeder extends Seeder {
    public function run(): void {
        // Opción 1: Creación manual
        Product::create([
            'name' => 'Laptop',
            'price' => 999,
            'stock' => 10
        ]);

        // Opción 2: Factory (genera datos fake)
        Product::factory(100)->create();
    }
}
```

### Ejecutar Seeders

```bash
# Ejecutar DatabaseSeeder (por defecto)
php artisan db:seed

# Ejecutar seeder específico
php artisan db:seed --class=ProductSeeder

# Refresh (migrate + seed)
php artisan migrate:refresh --seed
```

### Factories (Datos Fake)

```php
// database/factories/ProductFactory.php
namespace Database\Factories;

use App\Models\Product;
use Illuminate\Database\Eloquent\Factories\Factory;

class ProductFactory extends Factory {
    protected $model = Product::class;

    public function definition(): array {
        return [
            'name' => $this->faker->word(),
            'price' => $this->faker->numberBetween(10, 1000),
            'stock' => $this->faker->numberBetween(0, 100),
        ];
    }
}

// Uso
Product::factory(100)->create();  // Crear 100 productos fake
```

---

## Debugging Commands

### Ver Información de la App

```bash
# Ver rutas registradas
php artisan route:list

# Ver middleware
php artisan middleware:list

# Ver configuración
php artisan config:show

# Ver variables de entorno
php artisan env

# Información de eventos
php artisan event:list
```

### Tinker (REPL Interactivo)

```bash
# Abrir shell interactiva
php artisan tinker

# Ahora puedes ejecutar código PHP directamente
>>> $user = App\Models\User::first();
>>> $user->email
"john@example.com"
>>> $user->update(['name' => 'Jane']);
>>> $user->save();
```

---

## Ejemplo Completo: Sistema de Notificaciones

```php
// Crear comando personalizado
// php artisan make:command SendDailyNotifications

// app/Console/Commands/SendDailyNotifications.php
class SendDailyNotifications extends Command {
    protected $signature = 'notifications:send {--force}';
    protected $description = 'Send daily digest notifications to users';

    public function handle() {
        $users = User::where('notifications_enabled', true)->get();

        $bar = $this->withProgressBar($users);

        foreach ($users as $user) {
            Notification::send($user, new DailyDigest());
            $bar->advance();
        }

        $bar->finish();
        $this->info("\nNotifications sent!");
    }
}

// Registrar en scheduler
// app/Console/Kernel.php
protected function schedule(Schedule $schedule) {
    $schedule->command('notifications:send')
        ->dailyAt('08:00')
        ->onOneServer();  // Solo en un servidor
}

// Ejecutar
// php artisan notifications:send
// O automáticamente cada día a las 8 AM via cron
```

---

## Resumen: Artisan Power

✅ **Ventajas:**
- Generación automática de código (scaffolding)
- Tareas programadas sin cron manual
- Migración de BD con versionado
- REPL interactivo (Tinker)
- Debugging tools integrados

✅ **Comandos Esenciales:**
```bash
php artisan serve              # Dev
php artisan migrate            # Schema
php artisan make:model ...     # Generate
php artisan db:seed            # Populate
php artisan tinker             # REPL
php artisan schedule:run       # Cron
```

Artisan = La CLI más poderosa de PHP. ⌨️✨
