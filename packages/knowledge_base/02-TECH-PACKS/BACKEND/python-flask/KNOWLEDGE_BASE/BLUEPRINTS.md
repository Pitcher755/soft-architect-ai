# 🗺️ Flask Blueprints: Modularización y Escalabilidad

> **Versión:** Flask 2.3+
> **Patrón:** Blueprints para organización modular
> **Objetivo:** Evitar app.py gigante, escalar a múltiples dominios
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [¿Por Qué Blueprints?](#por-qué-blueprints)
2. [Blueprint Básico](#blueprint-básico)
3. [Estructura por Dominio](#estructura-por-dominio)
4. [Templates y Statics en Blueprints](#templates-y-statics)
5. [Error Handlers en Blueprints](#error-handlers)
6. [URL Prefixes y Namespaces](#url-prefixes-y-namespaces)
7. [Ejemplo Completo: E-commerce](#ejemplo-completo)

---

## ¿Por Qué Blueprints?

### ❌ INCORRECTO: Todo en app.py

```python
# app.py (500+ líneas, caótico)
from flask import Flask, request, jsonify

app = Flask(__name__)

# AUTENTICACIÓN
@app.route('/login', methods=['POST'])
def login():
    # ...

@app.route('/logout', methods=['POST'])
def logout():
    # ...

# USUARIOS
@app.route('/users', methods=['GET'])
def list_users():
    # ...

@app.route('/users', methods=['POST'])
def create_user():
    # ...

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id):
    # ...

# PRODUCTOS
@app.route('/products', methods=['GET'])
def list_products():
    # ...

# ... 200 más ...
```

**Problemas:**
1. ❌ Archivo gigante (>500 líneas)
2. ❌ Imposible entender la estructura
3. ❌ Difícil mantener / reutilizar
4. ❌ Cambios rompen todo

---

## Blueprint Básico

### ✅ CORRECTO: Separar por Dominio

```python
# app/blueprints/auth.py
from flask import Blueprint, request, jsonify

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    # Lógica de login
    return {'access_token': 'token123'}

@auth_bp.route('/logout', methods=['POST'])
def logout():
    return {'message': 'Logged out'}


# app/blueprints/users.py
from flask import Blueprint, request, jsonify

users_bp = Blueprint('users', __name__)

@users_bp.route('/', methods=['GET'])
def list_users():
    # Listar usuarios
    return {'users': []}

@users_bp.route('/', methods=['POST'])
def create_user():
    data = request.json
    # Crear usuario
    return {'id': 1}, 201

@users_bp.route('/<int:user_id>', methods=['GET'])
def get_user(user_id):
    return {'id': user_id, 'name': 'John'}


# app/__init__.py (Application Factory)
from flask import Flask

def create_app():
    app = Flask(__name__)

    # Registrar blueprints
    from app.blueprints.auth import auth_bp
    from app.blueprints.users import users_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(users_bp, url_prefix='/users')

    return app
```

**Resultado:**
- `/auth/login` (desde auth_bp)
- `/auth/logout` (desde auth_bp)
- `/users/` (desde users_bp)
- `/users/<id>` (desde users_bp)

---

## Estructura por Dominio

### Patrón Domain-Driven Design

```
app/
├── __init__.py
├── config.py
├── extensions.py
│
├── blueprints/
│   ├── __init__.py
│   ├── auth/
│   │   ├── __init__.py        # Define auth_bp
│   │   ├── routes.py          # @auth_bp.route()
│   │   ├── models.py          # User model
│   │   └── services.py        # AuthService
│   │
│   ├── products/
│   │   ├── __init__.py
│   │   ├── routes.py
│   │   ├── models.py
│   │   └── services.py
│   │
│   └── orders/
│       ├── __init__.py
│       ├── routes.py
│       ├── models.py
│       └── services.py
│
├── shared/
│   ├── models.py              # Shared models (User, etc)
│   ├── database.py
│   └── utils.py
```

### Implementación

```python
# app/blueprints/auth/__init__.py
from flask import Blueprint

auth_bp = Blueprint(
    'auth',
    __name__,
    template_folder='templates',
    static_folder='static'
)

from . import routes  # Importar después de definir blueprint


# app/blueprints/auth/routes.py
from flask import request, jsonify
from . import auth_bp
from .services import AuthService

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    token = AuthService.login(data['email'], data['password'])
    return {'access_token': token}


# app/blueprints/auth/services.py
from flask_jwt_extended import create_access_token
from app.shared.models import User

class AuthService:
    @staticmethod
    def login(email, password):
        user = User.query.filter_by(email=email).first()
        if not user:
            raise ValueError('User not found')
        # Verificar password...
        token = create_access_token(identity=user.id)
        return token


# app/blueprints/auth/models.py
# (Usualmente va en app/shared/models.py para compartir)


# app/__init__.py
def create_app():
    app = Flask(__name__)

    # Importar y registrar todos los blueprints
    from app.blueprints.auth import auth_bp
    from app.blueprints.products import products_bp
    from app.blueprints.orders import orders_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(products_bp, url_prefix='/products')
    app.register_blueprint(orders_bp, url_prefix='/orders')

    return app
```

---

## Templates y Statics en Blueprints

### Carpetas locales por Blueprint

```
app/blueprints/products/
├── __init__.py
├── routes.py
├── templates/
│   └── products/
│       ├── list.html
│       └── detail.html
└── static/
    ├── css/
    │   └── products.css
    └── js/
        └── products.js
```

### Definir en Blueprint

```python
# app/blueprints/products/__init__.py
from flask import Blueprint

products_bp = Blueprint(
    'products',
    __name__,
    template_folder='templates',      # Carpeta local
    static_folder='static',           # Carpeta local
    static_url_path='/static/products'  # URL pública
)


# app/blueprints/products/routes.py
from flask import render_template
from . import products_bp

@products_bp.route('/')
def list_products():
    # Buscar template en blueprints/products/templates
    return render_template('products/list.html')

@products_bp.route('/<int:product_id>')
def detail_product(product_id):
    return render_template('products/detail.html', product_id=product_id)
```

---

## Error Handlers en Blueprints

### Manejo de Errores por Blueprint

```python
# app/blueprints/auth/routes.py
from flask import jsonify
from . import auth_bp
from .exceptions import AuthError, InvalidCredentials

# Error handler específico del blueprint
@auth_bp.errorhandler(AuthError)
def handle_auth_error(e):
    return jsonify({'error': str(e)}), 401

@auth_bp.errorhandler(InvalidCredentials)
def handle_invalid_credentials(e):
    return jsonify({'error': 'Invalid credentials'}), 400

@auth_bp.route('/login', methods=['POST'])
def login():
    try:
        # ...
        raise InvalidCredentials('Bad password')
    except InvalidCredentials:
        # Manejo automático por error handler
        pass


# app/blueprints/auth/exceptions.py
class AuthError(Exception):
    pass

class InvalidCredentials(AuthError):
    pass
```

---

## URL Prefixes y Namespaces

### Evitar Colisiones de Nombres

```python
# app/__init__.py
def create_app():
    app = Flask(__name__)

    # Cada blueprint tiene un namespace único
    from app.blueprints.auth import auth_bp
    from app.blueprints.users import users_bp

    # auth_bp tiene namespace 'auth'
    app.register_blueprint(auth_bp, url_prefix='/auth')

    # users_bp tiene namespace 'users'
    app.register_blueprint(users_bp, url_prefix='/users')

    return app


# Usar namespace en templates/redirects
from flask import url_for

# Generar URL con namespace
url_for('auth.login')    # /auth/login
url_for('users.list_users')  # /users/
url_for('users.get_user', user_id=1)  # /users/1
```

---

## Ejemplo Completo: E-commerce

```python
# app/blueprints/products/routes.py
from flask import Blueprint, request, jsonify
from app.extensions import db
from app.shared.models import Product

products_bp = Blueprint('products', __name__)

@products_bp.route('/', methods=['GET'])
def list_products():
    """List all products with pagination"""
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)

    pagination = Product.query.paginate(page=page, per_page=per_page)

    return {
        'items': [p.to_dict() for p in pagination.items],
        'total': pagination.total,
        'pages': pagination.pages,
        'current_page': page
    }

@products_bp.route('/', methods=['POST'])
def create_product():
    """Create new product"""
    data = request.json

    product = Product(
        name=data['name'],
        price=data['price'],
        stock=data.get('stock', 0)
    )
    db.session.add(product)
    db.session.commit()

    return product.to_dict(), 201

@products_bp.route('/<int:product_id>', methods=['GET'])
def get_product(product_id):
    """Get product by ID"""
    product = Product.query.get_or_404(product_id)
    return product.to_dict()

@products_bp.route('/<int:product_id>', methods=['PUT'])
def update_product(product_id):
    """Update product"""
    product = Product.query.get_or_404(product_id)
    data = request.json

    product.name = data.get('name', product.name)
    product.price = data.get('price', product.price)
    product.stock = data.get('stock', product.stock)

    db.session.commit()
    return product.to_dict()

@products_bp.route('/<int:product_id>', methods=['DELETE'])
def delete_product(product_id):
    """Delete product"""
    product = Product.query.get_or_404(product_id)
    db.session.delete(product)
    db.session.commit()
    return '', 204


# app/blueprints/orders/routes.py
from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from app.extensions import db
from app.shared.models import Order, OrderItem

orders_bp = Blueprint('orders', __name__)

@orders_bp.route('/', methods=['GET'])
@jwt_required()
def list_user_orders():
    """List current user's orders"""
    user_id = get_jwt_identity()
    orders = Order.query.filter_by(user_id=user_id).all()
    return {'orders': [o.to_dict() for o in orders]}

@orders_bp.route('/', methods=['POST'])
@jwt_required()
def create_order():
    """Create new order"""
    user_id = get_jwt_identity()
    data = request.json

    order = Order(user_id=user_id)
    db.session.add(order)

    # Add items
    for item_data in data.get('items', []):
        item = OrderItem(
            order=order,
            product_id=item_data['product_id'],
            quantity=item_data['quantity']
        )
        db.session.add(item)

    db.session.commit()
    return order.to_dict(), 201


# app/__init__.py
from flask import Flask
from app.extensions import db, jwt

def create_app():
    app = Flask(__name__)
    app.config.from_object('app.config.DevelopmentConfig')

    # Init extensions
    db.init_app(app)
    jwt.init_app(app)

    # Register blueprints
    from app.blueprints.auth import auth_bp
    from app.blueprints.products import products_bp
    from app.blueprints.orders import orders_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(products_bp, url_prefix='/products')
    app.register_blueprint(orders_bp, url_prefix='/orders')

    return app
```

---

## Resumen: Blueprints Masterclass

✅ **Ventajas:**
- Organización clara por dominio
- Reutilizable (un blueprint puede registrarse múltiples veces)
- Error handling específico
- Templates y statics locales

✅ **Mejores Prácticas:**
- 1 dominio = 1 blueprint
- URL prefix = namespace
- Servicios en carpeta separada
- Models compartidos en shared/

Flask Blueprints = Modularización sin complejidad. 🗺️✨
