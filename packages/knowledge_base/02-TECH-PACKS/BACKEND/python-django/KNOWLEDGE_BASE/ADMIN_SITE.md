# 🛠️ Django Admin: Power Tool for Operations

> **Versión:** Django 4.2+
> **Propósito:** Panel de administración ultra-poderoso (la "Killer Feature" de Django)
> **Público:** Administradores, Ops, Product Managers (sin código)
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Por Qué Django Admin es Especial](#por-qué-django-admin-es-especial)
2. [Configuración Básica](#configuración-básica)
3. [Personalización de Lista](#personalización-de-lista)
4. [Búsqueda y Filtrado](#búsqueda-y-filtrado)
5. [Actions Personalizadas](#actions-personalizadas)
6. [Inline Editing](#inline-editing)
7. [Permisos y Seguridad](#permisos-y-seguridad)
8. [Advanced Customization](#advanced-customization)

---

## Por Qué Django Admin es Especial

### Admin Automático (Cero Código)

```python
from django.contrib import admin
from .models import Product

# ✅ Con una sola línea, tienes CRUD completo
admin.site.register(Product)

# Resultado: Acceder a /admin/app/product/
# - Listar productos
# - Crear nuevo
# - Editar existente
# - Eliminar
# TODO GRATIS 🎁
```

### Comparación con Competidores

| Feature | Django | Rails | Otros |
|:---|:---:|:---:|:---:|
| **Admin generado** | ✅ Automático | ❌ Requiere código | ❌ Requiere código |
| **Permisos builtin** | ✅ | ⚠️ | ⚠️ |
| **Bulk actions** | ✅ | ❌ | ❌ |
| **Search** | ✅ | ❌ | ❌ |
| **Filtering** | ✅ | ❌ | ❌ |

**Conclusión:** Django Admin = **10 horas ahorradas por proyecto**.

---

## Configuración Básica

### ModelAdmin Simple

```python
from django.contrib import admin
from .models import Product, Category

@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    # Columnas a mostrar en la lista
    list_display = ('id', 'name', 'price', 'stock', 'is_active', 'created_at')

    # Ordenamiento por defecto
    ordering = ['-created_at']

    # Paginación
    list_per_page = 50

    # Campos solo lectura
    readonly_fields = ('id', 'created_at', 'updated_at')

    # Campos en la vista de edición
    fields = ('name', 'price', 'stock', 'category', 'is_active', 'created_at')

    # Organizar campos en secciones
    fieldsets = (
        ('Información Básica', {
            'fields': ('name', 'price')
        }),
        ('Inventario', {
            'fields': ('stock', 'sku'),
            'classes': ('collapse',)  # Desplegable
        }),
        ('Metadatos', {
            'fields': ('id', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )


@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'slug')
```

**Resultado:** Panel profesional sin escribir ni una línea de frontend. ✨

---

## Personalización de Lista

### list_display: Columnas Personalizadas

```python
class ProductAdmin(admin.ModelAdmin):
    list_display = (
        'name',
        'price_formatted',      # Método personalizado
        'stock_status',         # Método personalizado
        'category_link',        # Link a otra entidad
        'created_date_short',   # Formato corto
    )

    def price_formatted(self, obj):
        """Mostrar precio en rojo si está bajo"""
        return format_html(
            '<span style="color: red; font-weight: bold;">${}</span>',
            obj.price
        )
    price_formatted.short_description = 'Price'

    def stock_status(self, obj):
        """Color según nivel de stock"""
        if obj.stock < 10:
            color = 'red'
            status = 'LOW'
        elif obj.stock < 50:
            color = 'orange'
            status = 'MEDIUM'
        else:
            color = 'green'
            status = 'OK'

        return format_html(
            '<span style="color: {}; font-weight: bold;">{}</span>',
            color, status
        )
    stock_status.short_description = 'Stock Level'

    def category_link(self, obj):
        """Link clicable a la categoría"""
        from django.urls import reverse
        url = reverse('admin:app_category_change', args=[obj.category.id])
        return format_html('<a href="{}">{}</a>', url, obj.category.name)
    category_link.short_description = 'Category'

    def created_date_short(self, obj):
        """Mostrar fecha en formato corto"""
        return obj.created_at.strftime('%Y-%m-%d')
    created_date_short.short_description = 'Created'
```

**Resultado:** Lista visualmente potente con información inmediata. 🎨

---

## Búsqueda y Filtrado

### search_fields: Búsqueda Full-Text

```python
class ProductAdmin(admin.ModelAdmin):
    search_fields = [
        'name',              # Búsqueda exacta
        'description',       # Busca en descripción
        'sku',              # SKU
        'category__name',   # Búsqueda en FK (category.name)
    ]
    # Resultado: Caja de búsqueda que filtra en tiempo real

    # Búsqueda avanzada con operadores
    search_help_text = "Search by name, description or category. Use 'price:>100' for advanced queries"
```

### list_filter: Filtros Dinámicos

```python
class ProductAdmin(admin.ModelAdmin):
    list_filter = [
        'is_active',         # Filter por booleano
        'category',          # Filter por FK
        'created_at',        # Filter por fecha (auto genera: Today, Past 7 days, etc)
    ]

    # Filtros personalizados
    from django.contrib.admin import SimpleListFilter

    class PriceRangeFilter(SimpleListFilter):
        title = 'Price Range'
        parameter_name = 'price_range'

        def lookups(self, request, model_admin):
            return [
                ('budget', 'Under $50'),
                ('mid', '$50-$200'),
                ('premium', 'Over $200'),
            ]

        def queryset(self, request, queryset):
            if self.value() == 'budget':
                return queryset.filter(price__lt=50)
            elif self.value() == 'mid':
                return queryset.filter(price__range=(50, 200))
            elif self.value() == 'premium':
                return queryset.filter(price__gt=200)

    list_filter = ['is_active', 'category', 'created_at', PriceRangeFilter]
```

---

## Actions Personalizadas

### Bulk Actions: Operaciones Masivas

```python
class ProductAdmin(admin.ModelAdmin):
    actions = [
        'mark_active',
        'mark_inactive',
        'export_csv',
        'clear_stock',
    ]

    @admin.action(description='Mark selected products as ACTIVE')
    def mark_active(self, request, queryset):
        """Activar productos en bulk"""
        updated_count = queryset.update(is_active=True)
        self.message_user(
            request,
            f'{updated_count} products activated'
        )

    @admin.action(description='Mark selected products as INACTIVE')
    def mark_inactive(self, request, queryset):
        """Desactivar productos en bulk"""
        updated_count = queryset.update(is_active=False)
        self.message_user(
            request,
            f'{updated_count} products deactivated'
        )

    @admin.action(description='Export selected to CSV')
    def export_csv(self, request, queryset):
        """Exportar a CSV"""
        import csv
        from django.http import HttpResponse

        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="products.csv"'
        writer = csv.writer(response)
        writer.writerow(['ID', 'Name', 'Price', 'Stock'])

        for product in queryset:
            writer.writerow([product.id, product.name, product.price, product.stock])

        return response

    @admin.action(description='Clear stock (0)')
    def clear_stock(self, request, queryset):
        """⚠️ Operación peligrosa - requiere confirmación"""
        if 'apply' in request.POST:
            # Confirmación ya hecha
            queryset.update(stock=0)
            self.message_user(request, 'Stock cleared')
            return None

        # Pedir confirmación
        return render(request, 'admin/confirm_action.html', {
            'title': 'Clear Stock',
            'message': 'This will set stock to 0 for all selected products',
            'queryset': queryset,
        })
```

**Resultado:** Operaciones masivas sin tocar la BD manualmente. 🚀

---

## Inline Editing

### Editar Registros Hijos Dentro del Padre

```python
from django.contrib import admin
from .models import Order, OrderItem, Product

# Inline: OrderItems dentro de Order
class OrderItemInline(admin.TabularInline):
    model = OrderItem
    fields = ('product', 'quantity', 'price', 'subtotal')
    readonly_fields = ('subtotal',)
    extra = 1  # Mostrar 1 fila vacía para agregar nuevo item

    def subtotal(self, obj):
        return obj.quantity * obj.price


class OrderAdmin(admin.ModelAdmin):
    list_display = ('id', 'user', 'status', 'total', 'created_at')

    # Mostrar items inline
    inlines = [OrderItemInline]

    # Evitar que se editen estos campos aquí (editar en producto)
    readonly_fields = ('total', 'created_at')

    fieldsets = (
        ('Order Info', {
            'fields': ('user', 'status', 'created_at', 'total')
        }),
        ('Items', {
            'fields': ()  # Los items van en inline
        }),
    )


admin.site.register(Order, OrderAdmin)
```

**Resultado:** Crear/editar órdenes y sus items en una sola pantalla. 📋

---

## Permisos y Seguridad

### Permisos Automáticos

Django crea automáticamente:
- `add_product` (crear)
- `change_product` (editar)
- `delete_product` (eliminar)
- `view_product` (solo leer)

```python
class ProductAdmin(admin.ModelAdmin):
    def has_delete_permission(self, request):
        """Solo superusuarios pueden eliminar"""
        return request.user.is_superuser

    def has_add_permission(self, request):
        """Solo staff puede crear"""
        return request.user.is_staff

    def get_readonly_fields(self, request):
        """Admin ve todo, staff no puede editar precio"""
        if request.user.is_superuser:
            return []
        return ['price', 'sku']


# En Django:
from django.contrib.auth.models import Permission
# Asignar permisos a usuarios/grupos desde Django shell
user.user_permissions.add(Permission.objects.get(codename='change_product'))
```

---

## Advanced Customization

### Cambiar Template del Admin

```python
class ProductAdmin(admin.ModelAdmin):
    change_list_template = 'admin/product/change_list.html'
    change_form_template = 'admin/product/change_form.html'

    # Pasar contexto adicional al template
    def changelist_view(self, request, extra_context=None):
        extra_context = extra_context or {}
        extra_context['custom_data'] = 'valor'
        return super().changelist_view(request, extra_context)


# Template personalizado (admin/product/change_list.html):
{% extends 'admin/change_list.html' %}

{% block result_list %}
    <h2>Custom Dashboard</h2>
    {{ custom_data }}
    {{ block.super }}  <!-- Mostrar tabla original -->
{% endblock %}
```

### Métodos en Modelo para Admin

```python
class Product(models.Model):
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return self.name

    @admin.display(description='Price (formatted)')
    def price_admin(self):
        return f"${self.price:.2f}"

    @admin.display(boolean=True, description='In Stock')
    def in_stock(self):
        return self.stock > 0
```

---

## Ejemplo Completo: E-commerce Admin

```python
from django.contrib import admin
from django.utils.html import format_html
from .models import Category, Product, Order, OrderItem

@admin.register(Category)
class CategoryAdmin(admin.ModelAdmin):
    list_display = ('name', 'product_count')

    def product_count(self, obj):
        return obj.products.count()
    product_count.short_description = '# Products'


class OrderItemInline(admin.TabularInline):
    model = OrderItem
    extra = 0
    readonly_fields = ('subtotal',)

    def subtotal(self, obj):
        return obj.quantity * obj.price


@admin.register(Order)
class OrderAdmin(admin.ModelAdmin):
    list_display = ('order_id', 'customer', 'status_badge', 'total', 'created_at')
    list_filter = ('status', 'created_at')
    search_fields = ('user__email', 'id')

    inlines = [OrderItemInline]

    fieldsets = (
        ('Order', {'fields': ('user', 'status', 'created_at')}),
        ('Total', {'fields': ('total',)}),
    )

    readonly_fields = ('created_at', 'total')

    actions = ['mark_shipped', 'mark_delivered']

    def order_id(self, obj):
        return f"#{obj.id}"

    def status_badge(self, obj):
        colors = {
            'PENDING': 'orange',
            'PAID': 'blue',
            'SHIPPED': 'purple',
            'DELIVERED': 'green',
        }
        return format_html(
            '<span style="background-color: {}; color: white; padding: 3px 10px; border-radius: 3px;">{}</span>',
            colors.get(obj.status, 'gray'),
            obj.get_status_display()
        )
    status_badge.short_description = 'Status'

    @admin.action(description='Mark as shipped')
    def mark_shipped(self, request, queryset):
        queryset.update(status='SHIPPED')
        self.message_user(request, 'Orders marked as shipped')

    @admin.action(description='Mark as delivered')
    def mark_delivered(self, request, queryset):
        queryset.update(status='DELIVERED')
        self.message_user(request, 'Orders marked as delivered')


@admin.register(Product)
class ProductAdmin(admin.ModelAdmin):
    list_display = ('name', 'price', 'stock_status', 'category')
    list_filter = ('category', 'created_at')
    search_fields = ('name', 'sku')
    readonly_fields = ('created_at',)

    fieldsets = (
        ('Información', {'fields': ('name', 'category', 'price')}),
        ('Inventario', {'fields': ('stock', 'sku')}),
        ('Estado', {'fields': ('is_active', 'created_at')}),
    )

    def stock_status(self, obj):
        if obj.stock > 50:
            color = 'green'
        elif obj.stock > 10:
            color = 'orange'
        else:
            color = 'red'
        return format_html(
            '<span style="color: {};">{}</span>',
            color, f"{obj.stock} units"
        )
```

---

## Resumen: Django Admin Power

✅ **Ventajas:**
- Generado automáticamente (cero overhead)
- Seguro (permisos integrados)
- Poderoso (bulk actions, inlines, filtering)
- Personalizable (sin límites)

❌ **Limitaciones:**
- No es un CMS visual completo
- Para UX avanzada requiere desarrollo custom

**Uso:** Perfecto para admin panels internos, ops tools. 🛠️✨
