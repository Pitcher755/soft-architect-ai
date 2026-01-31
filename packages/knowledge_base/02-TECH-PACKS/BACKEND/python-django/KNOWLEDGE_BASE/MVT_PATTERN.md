# 🏛️ Django MVT Pattern: Model-View-Template Clarified

> **Versión:** Django 4.2+ LTS
> **Paradigma:** Monolítico, Baterías Incluidas, MTV (Model-Template-View)
> **Filosofía:** "Convention over Configuration" + "The Framework Way"
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [La Confusión Fundamental: MVT vs MVC](#la-confusión-fundamental)
2. [Componentes de la Trinidad Django](#componentes-de-la-trinidad)
3. [Fat Models, Thin Views (Regla de Oro)](#fat-models-thin-views)
4. [Service Layer (El Patrón Híbrido)](#service-layer)
5. [Patrones de Request-Response](#patrones-de-request-response)
6. [Errores Comunes en Django](#errores-comunes)
7. [Ejemplo Completo: E-commerce](#ejemplo-completo)

---

## La Confusión Fundamental

### MVT vs MVC: Naming Problem

```
┌─────────────────────────────────────────────────────────┐
│ CONFUSIÓN: Django es MVT, pero la gente habla de MVC   │
└─────────────────────────────────────────────────────────┘

TERMINOLOGÍA ESTÁNDAR (Rails/Spring):
  Model (lógica de datos)
    ↓
  Controller (lógica de negocio)
    ↓
  View (presentación HTML)

TERMINOLOGÍA DJANGO:
  Model (lógica de datos)
    ↓
  View (lógica de negocio) ← Lo que otros llaman Controller
    ↓
  Template (presentación HTML) ← Lo que otros llaman View

REGLA: En Django, "View" = "Controller" en terminología estándar
```

### La Trinity de Django

```python
# 1. Model (models.py) - Lógica de datos & Business Rules
class Product(models.Model):
    name = models.CharField(max_length=100)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField()

# 2. View (views.py) - Lógica de negocio & Controller
def product_detail(request, product_id):
    product = Product.objects.get(id=product_id)
    return render(request, 'product.html', {'product': product})

# 3. Template (templates/product.html) - Presentación
<h1>{{ product.name }}</h1>
<p>Precio: ${{ product.price }}</p>
```

---

## Componentes de la Trinidad Django

### 1. Model (`models.py`) - La Verdad de los Datos

El Modelo es la **Single Source of Truth** para la estructura de datos.

```python
from django.db import models
from django.core.validators import MinValueValidator

class Category(models.Model):
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        verbose_name_plural = "Categories"
        ordering = ['name']

    def __str__(self):
        return self.name


class Product(models.Model):
    name = models.CharField(max_length=200)
    slug = models.SlugField(unique=True)
    description = models.TextField()
    category = models.ForeignKey(Category, on_delete=models.CASCADE, related_name='products')
    price = models.DecimalField(max_digits=10, decimal_places=2)
    stock = models.IntegerField(validators=[MinValueValidator(0)])
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['slug']),
            models.Index(fields=['category', 'is_active']),
        ]

    def __str__(self):
        return self.name

    @property
    def is_low_stock(self):
        return self.stock < 10

    def decrease_stock(self, quantity):
        """Business logic: reducir stock"""
        if self.stock < quantity:
            raise ValueError("Insufficient stock")
        self.stock -= quantity
        self.save()
```

**Meta-opciones Importantes:**
- `verbose_name_plural`: Nombre en plural para Admin
- `ordering`: Orden por defecto
- `indexes`: Índices de BD para queries frecuentes
- `constraints`: Restricciones a nivel BD

### 2. View (`views.py`) - La Lógica de Negocio

Una "View" en Django es el **Controller**. Recibe Request, procesa, devuelve Response.

#### View Basada en Función (FBV)

```python
from django.shortcuts import render, get_object_or_404, redirect
from django.http import JsonResponse
from django.views.decorators.http import require_http_methods
from django.contrib.auth.decorators import login_required

@login_required  # Solo usuarios autenticados
@require_http_methods(["GET", "POST"])  # Solo GET o POST
def product_list(request):
    if request.method == 'POST':
        # Crear nuevo producto
        name = request.POST.get('name')
        price = request.POST.get('price')
        product = Product.objects.create(name=name, price=price)
        return redirect('product_detail', pk=product.id)

    # Listar productos
    products = Product.objects.filter(is_active=True).select_related('category')
    return render(request, 'products/list.html', {'products': products})


def product_detail(request, pk):
    product = get_object_or_404(Product, pk=pk)
    related_products = product.category.products.exclude(pk=pk)[:5]
    return render(request, 'products/detail.html', {
        'product': product,
        'related_products': related_products
    })
```

#### View Basada en Clases (CBV)

```python
from django.views import View
from django.views.generic import ListView, DetailView, CreateView
from django.contrib.auth.mixins import LoginRequiredMixin
from django.urls import reverse_lazy

class ProductListView(LoginRequiredMixin, ListView):
    model = Product
    template_name = 'products/list.html'
    context_object_name = 'products'
    paginate_by = 20

    def get_queryset(self):
        # Optimizar query: select_related para FK
        return Product.objects.filter(is_active=True).select_related('category')


class ProductDetailView(DetailView):
    model = Product
    template_name = 'products/detail.html'
    context_object_name = 'product'

    def get_context_data(self, **kwargs):
        context = super().get_context_data(**kwargs)
        # Agregar contexto adicional
        context['related_products'] = self.object.category.products.exclude(pk=self.object.pk)[:5]
        return context


class ProductCreateView(LoginRequiredMixin, CreateView):
    model = Product
    fields = ['name', 'price', 'category', 'stock']
    template_name = 'products/form.html'
    success_url = reverse_lazy('product_list')

    def form_valid(self, form):
        form.instance.created_by = self.request.user
        return super().form_valid(form)
```

**Cuándo usar FBV vs CBV:**
- **FBV:** Lógica simple, controlable, fácil de debuggear
- **CBV:** Reutilizable, heredable, menos código repetitivo

### 3. Template (`templates/`)  - La Presentación

Django Template Language (DTL) es Jinja-like pero más simple.

```html
<!-- templates/products/list.html -->
{% extends "base.html" %}
{% load static %}

{% block title %}Productos{% endblock %}

{% block content %}
<div class="products-container">
    {% if products %}
        <h1>Catálogo de Productos ({{ products|length }} items)</h1>

        <div class="grid">
            {% for product in products %}
                <div class="product-card">
                    <h3><a href="{% url 'product_detail' product.pk %}">{{ product.name }}</a></h3>
                    <p class="price">${{ product.price }}</p>

                    {% if product.is_low_stock %}
                        <span class="badge alert">Stock bajo ({{ product.stock }})</span>
                    {% endif %}

                    <p class="category">{{ product.category.name }}</p>
                </div>
            {% endfor %}
        </div>
    {% else %}
        <p>No hay productos disponibles.</p>
    {% endif %}
</div>
{% endblock %}
```

---

## Fat Models, Thin Views (Regla de Oro)

### Principio: Lógica en el Modelo, No en la Vista

#### ❌ INCORRECTO: Lógica Gorda en la View

```python
def checkout(request):
    order_id = request.POST.get('order_id')
    order = Order.objects.get(id=order_id)

    # ❌ Lógica de negocio aquí (debería estar en el modelo)
    for item in order.items.all():
        product = item.product
        if product.stock < item.quantity:
            return JsonResponse({'error': 'Insufficient stock'}, status=400)
        product.stock -= item.quantity
        product.save()

    order.status = 'PAID'
    order.payment_date = timezone.now()
    order.save()

    # Side effects aquí
    send_order_email(order.user, order)
    notify_warehouse(order)

    return JsonResponse({'success': True})
```

#### ✅ CORRECTO: Lógica en el Modelo

```python
# models.py
class Order(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, default='PENDING')
    created_at = models.DateTimeField(auto_now_add=True)
    payment_date = models.DateTimeField(null=True)

    def process_payment(self):
        """Lógica de pago centralizada"""
        # Verificar stock
        for item in self.items.all():
            if item.product.stock < item.quantity:
                raise ValueError(f"Stock insuficiente para {item.product.name}")

        # Descontar stock
        for item in self.items.all():
            item.product.decrease_stock(item.quantity)

        # Marcar como pagado
        self.status = 'PAID'
        self.payment_date = timezone.now()
        self.save()

        # Notificar (side effects)
        self._send_confirmation_email()
        self._notify_warehouse()

    def _send_confirmation_email(self):
        send_order_email(self.user, self)

    def _notify_warehouse(self):
        notify_warehouse(self)


# views.py
def checkout(request):
    try:
        order = Order.objects.get(id=request.POST['order_id'])
        order.process_payment()  # ✅ Todo limpio
        return JsonResponse({'success': True})
    except ValueError as e:
        return JsonResponse({'error': str(e)}, status=400)
```

**Ventajas:**
- ✅ Lógica testeable independientemente
- ✅ Reutilizable desde diferentes views
- ✅ Más limpio y legible
- ✅ Menos duplicación

---

## Service Layer

### El Patrón Híbrido: Cuando el Modelo es Muy Gordo

Si `models.py` se vuelve un monolito (>500 líneas), extraer a un **Service Layer**.

```
Estructura:
├── models.py          # ORM, fields, validators
├── services.py        # Lógica de negocio
├── views.py           # Request/Response
└── tasks.py           # Background jobs
```

```python
# services.py - Lógica de negocio centralizada
from django.db import transaction

class OrderService:
    @transaction.atomic  # Garantizar ACID
    def process_payment(self, order_id, payment_token):
        order = Order.objects.select_for_update().get(id=order_id)

        # Validar stock
        for item in order.items.all():
            if item.product.stock < item.quantity:
                raise InsufficientStockError(item.product.name)

        # Procesar pago (3rd party)
        payment = self._charge_payment(payment_token, order.total)

        # Descontar stock
        for item in order.items.all():
            item.product.decrease_stock(item.quantity)

        # Actualizar orden
        order.status = 'PAID'
        order.payment_date = timezone.now()
        order.payment_id = payment.id
        order.save()

        # Notificaciones asincrónicas
        send_order_confirmation.delay(order.id)

        return order

    def _charge_payment(self, token, amount):
        # Llamar a Stripe/PayPal/etc
        pass


# views.py
from .services import OrderService

class CheckoutView(View):
    def post(self, request):
        try:
            order = Order.objects.get(id=request.POST['order_id'])
            service = OrderService()
            service.process_payment(order.id, request.POST['token'])
            return JsonResponse({'success': True})
        except InsufficientStockError as e:
            return JsonResponse({'error': str(e)}, status=400)
```

---

## Patrones de Request-Response

### 1. Form Handling (Validación)

```python
from django import forms
from django.views.generic import CreateView

class ProductForm(forms.ModelForm):
    class Meta:
        model = Product
        fields = ['name', 'price', 'category', 'stock']
        widgets = {
            'description': forms.Textarea(attrs={'rows': 4}),
            'price': forms.NumberInput(attrs={'step': '0.01'}),
        }

    def clean_price(self):
        price = self.cleaned_data['price']
        if price <= 0:
            raise forms.ValidationError("Price must be positive")
        return price


class ProductCreateView(CreateView):
    model = Product
    form_class = ProductForm

    def form_valid(self, form):
        form.instance.created_by = self.request.user
        return super().form_valid(form)
```

### 2. JSON API (REST)

```python
from django.views.decorators.http import require_http_methods
from django.http import JsonResponse
import json

@require_http_methods(["GET", "POST"])
def api_products(request):
    if request.method == 'GET':
        products = Product.objects.values('id', 'name', 'price')
        return JsonResponse(list(products), safe=False)

    elif request.method == 'POST':
        data = json.loads(request.body)
        product = Product.objects.create(
            name=data['name'],
            price=data['price']
        )
        return JsonResponse({'id': product.id, 'name': product.name})
```

---

## Errores Comunes en Django

### Error 1: N+1 Query Problem

```python
# ❌ INCORRECTO: Dispara N queries
for product in Product.objects.all():
    print(product.category.name)  # 1 query por producto


# ✅ CORRECTO: select_related para FK
for product in Product.objects.select_related('category'):
    print(product.category.name)  # Solo 1 query total
```

### Error 2: Usar `filter().first()` en lugar de `get()`

```python
# ❌ INCORRECTO: Genera 2 queries
product = Product.objects.filter(slug=slug).first()

# ✅ CORRECTO: Genera 1 query
product = Product.objects.get(slug=slug)  # Lanza DoesNotExist si falta
```

### Error 3: Mutable Default Arguments

```python
# ❌ INCORRECTO: El lista es compartido entre instancias
class ProductFilter:
    def __init__(self, filters=[]):
        self.filters = filters  # Compartido!

# ✅ CORRECTO:
class ProductFilter:
    def __init__(self, filters=None):
        self.filters = filters or []
```

---

## Ejemplo Completo: E-commerce

```python
# models.py
class Order(models.Model):
    STATUSES = [
        ('PENDING', 'Pending Payment'),
        ('PAID', 'Paid'),
        ('SHIPPED', 'Shipped'),
    ]
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    status = models.CharField(max_length=20, choices=STATUSES, default='PENDING')
    total = models.DecimalField(max_digits=10, decimal_places=2)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Order #{self.id}"


class OrderItem(models.Model):
    order = models.ForeignKey(Order, on_delete=models.CASCADE, related_name='items')
    product = models.ForeignKey(Product, on_delete=models.PROTECT)
    quantity = models.IntegerField()
    price = models.DecimalField(max_digits=10, decimal_places=2)


# views.py
class OrderListView(LoginRequiredMixin, ListView):
    model = Order
    template_name = 'orders/list.html'
    paginate_by = 20

    def get_queryset(self):
        return self.request.user.order_set.prefetch_related('items__product').order_by('-created_at')
```

---

## Resumen: El Camino de Django

1. **Modelo:** Define estructura + lógica de negocio
2. **View:** Recibe request, usa modelo, devuelve response
3. **Template:** Presentación del response
4. **Service Layer:** Si lógica se vuelve compleja

**Filosofía:** Django opinado → convenciones claras → desarrollo rápido. 🏛️✨
