# 🏭 Flask Application Factory Pattern

> **Versión:** Flask 2.3+
> **Patrón:** Factory Pattern para instancias de app
> **Objetivo:** Evitar estado global, permitir múltiples instancias
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [El Problema: Global State](#el-problema-global-state)
2. [La Solución: create_app()](#la-solución-createapp)
3. [Estructura de Proyecto](#estructura-de-proyecto)
4. [Configuración Ambiente](#configuración-ambiente)
5. [Inicializar Extensiones](#inicializar-extensiones)
6. [Blueprints en Factory](#blueprints-en-factory)
7. [Testing con Factory](#testing-con-factory)
8. [Ejemplo Completo](#ejemplo-completo)

---

## El Problema: Global State

### ❌ INCORRECTO: Crear app Globalmente

```python
# app.py (❌ ANTI-PATRÓN)
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://...'
app.config['JWT_SECRET_KEY'] = 'secret123'

db = SQLAlchemy(app)
jwt = JWTManager(app)

@app.route('/users')
def list_users():
    users = db.session.query(User).all()
    return {'users': [u.to_dict() for u in users]}

if __name__ == '__main__':
    app.run()
```

**Problemas:**
1. ❌ **Imposible testear:** No puedes crear múltiples instancias de app con configuración diferente
2. ❌ **Imposible desplegar:** ¿Testing env? ¿Production env? Todo mezclado
3. ❌ **Acoplamiento:** Las extensiones (DB, JWT) dependen de la app global
4. ❌ **Concurrencia:** Si corres múltiples workers, comparten estado

---

## La Solución: create_app()

### ✅ CORRECTO: Application Factory

```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager

db = SQLAlchemy()
jwt = JWTManager()

def create_app(config_name='development'):
    """Fábrica de aplicaciones"""
    app = Flask(__name__)

    # Cargar configuración según ambiente
    if config_name == 'development':
        app.config.from_object('app.config.DevelopmentConfig')
    elif config_name == 'production':
        app.config.from_object('app.config.ProductionConfig')
    elif config_name == 'testing':
        app.config.from_object('app.config.TestingConfig')

    # Inicializar extensiones CON la app
    db.init_app(app)
    jwt.init_app(app)

    # Registrar blueprints
    from app.blueprints.auth import auth_bp
    from app.blueprints.api import api_bp
    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(api_bp, url_prefix='/api')

    # Crear tablas (solo en dev/test)
    with app.app_context():
        db.create_all()

    return app
```

**Ventajas:**
- ✅ Múltiples instancias con diferente configuración
- ✅ Fácil de testear
- ✅ Despliegue flexible
- ✅ Extensiones desacopladas

---

## Estructura de Proyecto

```
app/
├── __init__.py              # Extensiones + create_app()
├── config.py                # Configuraciones por ambiente
├── models.py                # ORM Models
├── extensions.py            # Inicialización de extensiones
│
├── blueprints/
│   ├── __init__.py
│   ├── auth.py              # Rutas de autenticación
│   ├── api.py               # Rutas API
│   └── admin.py             # Rutas de admin
│
├── services/
│   ├── user_service.py      # Lógica de negocio
│   └── auth_service.py
│
└── utils/
    ├── decorators.py        # Decoradores personalizados
    └── validators.py        # Validaciones

wsgi.py                       # Entry point para Gunicorn
tests/
├── conftest.py              # Fixtures pytest
├── test_auth.py
└── test_api.py
```

---

## Configuración Ambiente

### Configuraciones por Entorno

```python
# app/config.py
import os
from datetime import timedelta

class Config:
    """Base configuration"""
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(hours=1)
    SECRET_KEY = os.environ.get('SECRET_KEY', 'dev-secret-key')


class DevelopmentConfig(Config):
    """Development environment"""
    DEBUG = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///dev.db'
    SQLALCHEMY_ECHO = True  # Log todas las queries


class ProductionConfig(Config):
    """Production environment"""
    DEBUG = False
    SQLALCHEMY_DATABASE_URI = os.environ['DATABASE_URL']
    SQLALCHEMY_POOL_SIZE = 10
    SQLALCHEMY_POOL_RECYCLE = 3600  # Reciclar conexiones cada hora


class TestingConfig(Config):
    """Testing environment"""
    DEBUG = True
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'  # BD en RAM
    JWT_ACCESS_TOKEN_EXPIRES = timedelta(seconds=10)  # TTL corto para tests
```

### Cargar Configuración desde Env

```python
# .env (no commitear)
FLASK_ENV=development
DATABASE_URL=postgresql://user:pass@localhost/mydb
SECRET_KEY=my-secret-key

# app/__init__.py
from dotenv import load_dotenv
load_dotenv()
```

---

## Inicializar Extensiones

### Sin Pasar app (Lazy Initialization)

```python
# app/extensions.py
from flask_sqlalchemy import SQLAlchemy
from flask_jwt_extended import JWTManager
from flask_cors import CORS

db = SQLAlchemy()
jwt = JWTManager()
cors = CORS()


# app/__init__.py
def create_app(config_name='development'):
    app = Flask(__name__)
    # ... load config ...

    # Inicializar extensiones AQUÍ
    db.init_app(app)
    jwt.init_app(app)
    cors.init_app(app)

    return app
```

**Ventaja:** Las extensiones no conocen a `app` globalmente. Permite testing.

---

## Blueprints en Factory

### Registrar Blueprints en create_app()

```python
# app/blueprints/auth.py
from flask import Blueprint, request, jsonify
from app.services.auth_service import AuthService

auth_bp = Blueprint('auth', __name__)

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.json
    token = AuthService.login(data['email'], data['password'])
    return {'access_token': token}


# app/blueprints/api.py
from flask import Blueprint
from app.models import User

api_bp = Blueprint('api', __name__)

@api_bp.route('/users', methods=['GET'])
def list_users():
    users = User.query.all()
    return {'users': [u.to_dict() for u in users]}


# app/__init__.py
def create_app(config_name='development'):
    app = Flask(__name__)
    # ... config ...

    # Registrar blueprints
    from app.blueprints.auth import auth_bp
    from app.blueprints.api import api_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(api_bp, url_prefix='/api')

    return app
```

---

## Testing con Factory

### Crear Instancia de Test

```python
# tests/conftest.py
import pytest
from app import create_app, db

@pytest.fixture
def app():
    """Crear app de test"""
    app = create_app('testing')

    with app.app_context():
        db.create_all()
        yield app
        db.session.remove()
        db.drop_all()


@pytest.fixture
def client(app):
    """Cliente HTTP para tests"""
    return app.test_client()


@pytest.fixture
def runner(app):
    """CLI runner para tests"""
    return app.test_cli_runner()


# tests/test_auth.py
def test_login(client):
    """Test endpoint /auth/login"""
    response = client.post('/auth/login', json={
        'email': 'test@example.com',
        'password': 'password123'
    })
    assert response.status_code == 200
    assert 'access_token' in response.json


def test_list_users(client):
    """Test endpoint /api/users"""
    response = client.get('/api/users')
    assert response.status_code == 200
    assert 'users' in response.json
```

---

## Ejemplo Completo

### Estructura Completa

```python
# wsgi.py (Entry point para Gunicorn)
import os
from app import create_app

app = create_app(os.environ.get('FLASK_ENV', 'production'))

if __name__ == '__main__':
    app.run()


# app/__init__.py
from flask import Flask
from app.extensions import db, jwt, cors
from app.config import DevelopmentConfig, ProductionConfig, TestingConfig

def create_app(config_name='development'):
    app = Flask(__name__)

    # Load config
    configs = {
        'development': DevelopmentConfig,
        'production': ProductionConfig,
        'testing': TestingConfig,
    }
    app.config.from_object(configs.get(config_name, DevelopmentConfig))

    # Initialize extensions
    db.init_app(app)
    jwt.init_app(app)
    cors.init_app(app)

    # Register blueprints
    from app.blueprints.auth import auth_bp
    from app.blueprints.api import api_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(api_bp, url_prefix='/api')

    # Create tables
    with app.app_context():
        db.create_all()

    # Register error handlers
    @app.errorhandler(404)
    def not_found(error):
        return {'error': 'Not found'}, 404

    @app.errorhandler(500)
    def server_error(error):
        return {'error': 'Server error'}, 500

    return app


# app/models.py
from app.extensions import db

class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(255), nullable=False)

    def to_dict(self):
        return {'id': self.id, 'email': self.email}


# app/services/auth_service.py
from flask_jwt_extended import create_access_token
from werkzeug.security import check_password_hash
from app.models import User

class AuthService:
    @staticmethod
    def login(email, password):
        user = User.query.filter_by(email=email).first()
        if not user or not check_password_hash(user.password_hash, password):
            raise ValueError('Invalid credentials')

        access_token = create_access_token(identity=user.id)
        return access_token


# Despliegue
# gunicorn wsgi:app --workers 4 --bind 0.0.0.0:5000
```

---

## Resumen: Application Factory

✅ **Ventajas:**
- Múltiples instancias de app
- Fácil testear (config independiente)
- Flexible para despliegue
- Extensiones desacopladas

⚠️ **Nota:** Flask es flexible (no lo obliga), pero factory es la mejor práctica.

**Recomendación:** Siempre usar `create_app()`. 🏭✨
