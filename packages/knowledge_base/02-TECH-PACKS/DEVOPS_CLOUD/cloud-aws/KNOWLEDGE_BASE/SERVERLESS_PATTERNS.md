# ⚡ AWS Serverless Patterns: Lambda vs Fargate

> **Región Default:** us-east-1 (N. Virginia)
> **Filosofía:** "No provisiones lo que no usas."
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Principios Serverless](#principios-serverless)
2. [AWS Lambda](#aws-lambda)
3. [AWS Fargate](#aws-fargate)
4. [API Gateway Integration](#api-gateway-integration)
5. [Decision Matrix](#decision-matrix)
6. [Cost Optimization](#cost-optimization)

---

## Principios Serverless

### ¿Qué es "Serverless"?

```
Provisioning Manual (VM)
  ↓ (Abstraído)
Containerización (Docker)
  ↓ (Abstraído)
Serverless (Solo código)

Promesa: "Escala automática, pagas por uso, cero mantenimiento"
Realidad: "Es más complicado, pero más barato si lo usas bien"
```

### Modelo Mental: Event-Driven

```yaml
Event Source (API, S3, DynamoDB, SQS)
  ↓
Trigger automático
  ↓
Tu función se ejecuta
  ↓
Termina (o timea)
  ↓
Pagas solo por tiempo de ejecución
```

---

## AWS Lambda

### Anatomía Completa

```yaml
# Serverless Framework / SAM syntax (recomendado)
AWSTemplateFormatVersion: '2010-09-09'
Transform: AWS::Serverless-2016-10-31

Resources:
  ProcessOrderFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: process-order
      Runtime: python3.12
      Handler: index.handler
      CodeUri: src/

      # Timeout CRÍTICO (15 min max)
      Timeout: 60  # segundos
      MemorySize: 256  # MB

      # Capas (dependencies)
      Layers:
        - !Ref PythonDependenciesLayer

      # Trigger: API Gateway
      Events:
        OrderApi:
          Type: HttpApi
          Properties:
            Path: /order
            Method: POST
            ApiId: !Ref OrderApi

      # Variables de entorno
      Environment:
        Variables:
          DB_CONNECTION_STRING: !GetAtt Database.Endpoint.Address
          SQS_QUEUE_URL: !Ref OrderQueue

      # Políticas de IAM (mínimo necesario)
      Policies:
        - Version: '2012-10-17'
          Statement:
            - Effect: Allow
              Action: dynamodb:PutItem
              Resource: !GetAtt OrderTable.Arn
            - Effect: Allow
              Action: sqs:SendMessage
              Resource: !GetAtt OrderQueue.Arn

  # Layer de dependencias (reutilizable)
  PythonDependenciesLayer:
    Type: AWS::Lambda::LayerVersion
    Properties:
      LayerName: python-deps
      Content:
        S3Bucket: !Ref LambdaBucket
        S3Key: layers/python-deps.zip
      CompatibleRuntimes:
        - python3.12

  # API Gateway (HTTP API es más rápida que REST API)
  OrderApi:
    Type: AWS::Serverless::HttpApi
    Properties:
      StageName: prod
      CorsConfiguration:
        AllowOrigins: ['*']
        AllowMethods: [GET, POST, PUT, DELETE]
        AllowHeaders: ['Content-Type', 'Authorization']
```

### Anatomía de una Función Lambda

```python
# src/index.py
import json
import boto3
import os
from datetime import datetime

dynamodb = boto3.resource('dynamodb')
sqs = boto3.client('sqs')

table = dynamodb.Table(os.environ['ORDERS_TABLE'])
queue_url = os.environ['SQS_QUEUE_URL']

def handler(event, context):
    """
    Entry point de una Lambda.

    Args:
        event: Datos del trigger (body, path params, headers, etc)
        context: Metadata (request ID, remaining time, etc)

    Returns:
        dict: {statusCode, body, headers}
    """

    try:
        # Parsear input
        body = json.loads(event.get('body', '{}'))
        order_id = body.get('order_id')
        amount = body.get('amount')

        if not order_id or not amount:
            return error_response(400, "Missing order_id or amount")

        # Validar
        if amount < 0.01:
            return error_response(400, "Amount must be > 0.01")

        # Guardar en DynamoDB
        table.put_item(
            Item={
                'order_id': order_id,
                'amount': amount,
                'status': 'PENDING',
                'created_at': datetime.now().isoformat()
            }
        )

        # Enviar a SQS para procesamiento asincrónico
        sqs.send_message(
            QueueUrl=queue_url,
            MessageBody=json.dumps({
                'order_id': order_id,
                'amount': amount
            })
        )

        # Respuesta success
        return success_response(200, {
            'order_id': order_id,
            'status': 'PENDING'
        })

    except Exception as e:
        print(f"ERROR: {str(e)}")  # CloudWatch Logs
        return error_response(500, "Internal server error")

def success_response(status_code, body):
    return {
        'statusCode': status_code,
        'body': json.dumps(body),
        'headers': {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        }
    }

def error_response(status_code, message):
    return {
        'statusCode': status_code,
        'body': json.dumps({'error': message}),
        'headers': {'Content-Type': 'application/json'}
    }
```

### Cold Starts (El Problema)

```
1er request → Inicializar runtime (Python, Node, etc) → ~2s extra
Requests posteriores → Reutilizar container → <100ms

Problema: En aplicaciones con tráfico impredecible (ej: API pública),
el primer request recibe siempre 2s de latencia.
```

### Soluciones para Cold Starts

#### 1. Provisioned Concurrency

```yaml
# SAM / CloudFormation
ProvisionedConcurrentExecutions: 5

# Mantiene 5 containers "calientes" siempre
# Costo: 0.015 USD/hour/concurrency (~$54/mes para 5)
# Valor: Sin cold starts
```

#### 2. Scheduled Warmup (Ping)

```python
# Crear función Lambda separada que hace ping cada 5 minutos
import requests
import json

def warmer(event, context):
    """Keep Lambda warm"""
    if event.get('source') == 'aws.events':
        # Ping a la función principal
        response = requests.get(
            'https://api.example.com/health',
            timeout=5
        )
        print(f"Warmup: {response.status_code}")

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Warmed up'})
        }
```

#### 3. Usar Docker Image en lugar de ZIP

```yaml
# Para tiempos de inicio más predecibles
Type: AWS::Serverless::Function
Properties:
  PackageType: Image  # vs Zip
  DockerContext: .
  DockerTag: latest
```

---

## AWS Fargate

### Cuándo Usar Fargate (vs Lambda)

```
Lambda:
  ✅ Funciones cortas (<15 min)
  ✅ Tráfico impredecible (bursty)
  ✅ Eventos discretos (S3, SNS, API calls)
  ✅ APIs simples
  ❌ Procesos de larga duración
  ❌ Aplicaciones stateful complejas

Fargate:
  ✅ Aplicaciones Docker completas
  ✅ Procesos >15 minutos
  ✅ Tráfico predecible (streaming, workers)
  ✅ No necesita reescribir código
  ✅ Más debugging-friendly
  ❌ Costo en idle (pagas aunque no haya requests)
  ❌ Escala más lentamente que Lambda
```

### Anatomía de Task Definition (Fargate)

```yaml
# CloudFormation / Terraform
Resources:
  TaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: my-api
      NetworkMode: awsvpc  # CRÍTICO para Fargate
      RequiresCompatibilities: [FARGATE]
      Cpu: 256  # CPU units
      Memory: 512  # MB

      # Registrar imagen Docker
      ContainerDefinitions:
        - Name: my-app
          Image: 123456789.dkr.ecr.us-east-1.amazonaws.com/my-app:v1

          # Puerto
          PortMappings:
            - ContainerPort: 8000
              Protocol: tcp

          # Logs a CloudWatch
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: !Ref TaskLogGroup
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: ecs

          # Health check
          HealthCheck:
            Command:
              - CMD-SHELL
              - curl -f http://localhost:8000/health || exit 1
            Interval: 30
            Timeout: 5
            Retries: 2
            StartPeriod: 60

          # Variables de entorno
          Environment:
            - Name: DATABASE_URL
              Value: !Sub postgresql://user:pass@${RDS.Endpoint.Address}:5432/db
```

### Desplegar Task en Fargate (ECS Service)

```yaml
Resources:
  Service:
    Type: AWS::ECS::Service
    Properties:
      Cluster: production
      TaskDefinition: !Ref TaskDefinition
      DesiredCount: 3  # Réplicas
      LaunchType: FARGATE

      # Networking
      NetworkConfiguration:
        AwsvpcConfiguration:
          Subnets:
            - subnet-12345
            - subnet-67890
          SecurityGroups:
            - sg-app-security-group
          AssignPublicIp: DISABLED  # Usar NAT Gateway

      # Load Balancer (obligatorio)
      LoadBalancers:
        - ContainerName: my-app
          ContainerPort: 8000
          TargetGroupArn: !Ref TargetGroup

      # Auto-scaling
      DeploymentConfiguration:
        MaximumPercent: 200  # 200% durante actualización
        MinimumHealthyPercent: 100  # 100% siempre disponible

  # Auto Scaling Group (opcional)
  ServiceScaling:
    Type: AWS::ApplicationAutoScaling::ScalableTarget
    Properties:
      MaxCapacity: 10
      MinCapacity: 2
      ResourceId: !Sub service/production/${Service.Name}
      RoleARN: arn:aws:iam::ACCOUNT:role/ecsAutoscaleRole
      ScalableDimension: ecs:service:DesiredCount
      ServiceNamespace: ecs

  # Policy: Escalar si CPU > 70%
  ScalingPolicy:
    Type: AWS::ApplicationAutoScaling::ScalingPolicy
    Properties:
      PolicyName: cpu-scaling
      PolicyType: TargetTrackingScaling
      ScalingTargetId: !Ref ServiceScaling
      TargetTrackingScalingPolicyConfiguration:
        TargetValue: 70
        PredefinedMetricSpecification:
          PredefinedMetricType: ECSServiceAverageCPUUtilization
```

---

## API Gateway Integration

### HTTP API vs REST API

```
REST API (Legacy)
  ✅ Muy flexible
  ✅ Request/Response transforms
  ❌ Más cara ($3.50 por millón de requests)
  ❌ Latencia variable

HTTP API (Moderno)
  ✅ Más barata ($0.90 por millón)
  ✅ Latencia predecible
  ✅ Soporte CORS integrado
  ❌ Menos features que REST API
  → RECOMENDADO para la mayoría de casos
```

### Configuración HTTP API

```yaml
Resources:
  HttpApi:
    Type: AWS::Serverless::HttpApi
    Properties:
      StageName: prod

      # CORS Configuration
      CorsConfiguration:
        AllowOrigins:
          - https://app.example.com
          - https://admin.example.com
        AllowMethods:
          - GET
          - POST
          - PUT
          - DELETE
        AllowHeaders:
          - Content-Type
          - Authorization
          - X-Amz-Date
        MaxAge: 300

      # Rate Limiting (Throttling)
      RouteSettings:
        'POST /order':
          ThrottlingSettings:
            BurstLimit: 100
            RateLimit: 50  # 50 requests per second

      # Security: API Key
      Auth:
        ApiKeyRequired: true
        Authorizers:
          JwtAuthorizer:
            FunctionArn: !GetAtt AuthorizerFunction.Arn

  # Lambda para autorización JWT
  AuthorizerFunction:
    Type: AWS::Serverless::Function
    Properties:
      FunctionName: jwt-authorizer
      Runtime: python3.12
      Handler: authorizer.handler
      CodeUri: src/
      Environment:
        Variables:
          JWT_SECRET: !Sub '{{resolve:secretsmanager:jwt-secret}}'

  # Rutas
  OrderRoute:
    Type: AWS::Serverless::Api
    Properties:
      StageName: prod
      Auth:
        Authorizers:
          JwtAuth:
            FunctionArn: !GetAtt AuthorizerFunction.Arn
            Identity:
              ReauthorizeEvery: 300  # Cache 5 minutos
      Models:
        OrderRequest:
          type: object
          properties:
            order_id:
              type: string
            amount:
              type: number
              minimum: 0.01
          required: [order_id, amount]
```

---

## Decision Matrix

### Lambda vs Fargate vs EC2

```
┌─────────────────────────────────────────────────────────────────┐
│ Característica         │ Lambda   │ Fargate  │ EC2       │
├────────────────────────┼──────────┼──────────┼───────────┤
│ Timeout                │ 15 min   │ Ilimitado│ Ilimitado │
│ Startup                │ 1-2s     │ 1-2 min  │ Mins-hrs  │
│ Coste en idle          │ $0       │ $$       │ $$$       │
│ Documentación          │ Excelente│ Muy buena│ Muy buena │
│ Debugging              │ Difícil  │ Medio    │ Fácil     │
│ Escalado               │ Automático│ Automático│ Manual    │
│ Code portability       │ Baja     │ Alta     │ Alta      │
│ Costo por 1M requests  │ $0.20    │ $-       │ $-        │
│ Mejor para             │ APIs     │ Workers  │ Monolitos │
│                        │ eventos  │ Apps     │ Custom    │
└────────────────────────┴──────────┴──────────┴───────────┘
```

---

## Cost Optimization

### Estrategias Reales

#### 1. Memoria Correcta (No sobre-provisionar)

```python
# ❌ INCORRECTO: 3008 MB (máximo)
# Cuesta 3x más pero probablemente no lo necesites

# ✅ CORRECTO: Medir con CloudWatch
# - Ver Memory Used en logs
# - Provisionar 20% más
# - Ajustar regularmente

# Lambda: Costo = (GB-seconds) × tarifa
# Más memoria = Ejecución más rápida (CPU sube automático)
# Pero: Si la función es I/O-bound (espera DB), memoria extra no ayuda
```

#### 2. Reserved Concurrency

```yaml
# Si sabes que siempre necesitas 10 lambdas en paralelo
ReservedConcurrentExecutions: 10
# Costo: ~$0.015/hour/concurrency en US

# Beneficio: Garantizado que tendrás capacidad
# Evita "too many requests" de throttling
```

#### 3. Usar SQS/SNS en lugar de invocar Lambda directamente

```
Directo (Síncrono):
  API → Lambda → Lambda → Lambda
  Si cada Lambda tarda 1s, total = 3s latencia

Con colas (Asincrónico):
  API → SQS (respuesta inmediata)
  Lambda Consumer → procesa de la cola en paralelo
  Cliente pollea estado posterior
```

#### 4. Caching en API Gateway

```yaml
Routes:
  '/user/{id}':
    Method: GET
    Integration:
      CachingEnabled: true
      CacheTtlInSeconds: 300  # 5 minutos
      CacheDataEncrypted: true
```

---

## Resumen: Serverless Mastery

✅ **Reglas Inmutables:**
- Lambda para <15 min, eventos, APIs
- Fargate para Docker, long-running, tráfico predecible
- HTTP API para endpoints nuevos (más barata que REST)
- OIDC + Secrets Manager para credenciales
- CloudWatch Logs para debugging

✅ **Checklist de Producción:**
- [ ] Timeout configurable (no default 3s)
- [ ] Memory optimizado (CloudWatch metrics)
- [ ] Provisioned Concurrency si crítico
- [ ] Monitoring: Duration, errors, throttles
- [ ] Dead Letter Queues (DLQ) para fallos
- [ ] Canary deployments (SAM -Canaries flag)

AWS Serverless es el futuro del cloud. ⚡✨
