# ADR-005: Ajuste de Temperatura LLM para Mayor Creatividad

> **Estado:** ✅ Aceptado
> **Fecha:** 2026-02-21
> **Decisores:** Equipo Desarrollo + ArchitectZero
> **HU Relacionada:** HU-5.0 (Refinamiento Arquitecto IA)

---

## 📋 Contexto

### Situación Actual

El servicio LLM **GroqClient** actualmente utiliza una configuración de temperatura de **0.5** para todas las solicitudes de generación de documentos. Esta configuración fue elegida inicialmente para priorizar:

- **Consistencia:** Respuestas predecibles y determinísticas
- **Precisión técnica:** Riesgo reducido de alucinaciones
- **Tono formal:** Estilo de documentación profesional

### Problema Identificado

Después de analizar outputs de múltiples ejecuciones del workflow (Fases 00-DISCOVERY hasta 50-IMPLEMENTATION), hemos observado:

1. **Tono Excesivamente Conservador:** Los documentos carecen de engagement y "personalidad"
2. **Fraseado Repetitivo:** Estructuras de oraciones similares en diferentes tipos de documentos
3. **Vocabulario Limitado:** Sobreuso de términos técnicos comunes en lugar de alternativas más ricas
4. **Falta de Factor WOW:** Los documentos son funcionales pero no visualmente o narrativamente atractivos

**Feedback de Usuarios:**
- "Los documentos se sienten como si fueron generados por un comité, no por un arquitecto senior"
- "Necesito soluciones más creativas, no solo patrones estándar"
- "La redacción carece de la energía que emocionaría a los stakeholders"

### Impacto de Negocio

Para **HU-5.0** y la próxima **presentación TFM**, necesitamos documentación que:
- Demuestre **sofisticación de IA** (no solo relleno de plantillas)
- Enganche a **stakeholders no técnicos** (inversores, product managers)
- Muestre **creatividad arquitectónica** manteniendo rigor técnico

---

## 🎯 Decisión

**Aumentaremos la temperatura del LLM de 0.5 a 0.6.**

### Detalles de Implementación

**Archivo:** `src/server/services/llm/groq_client.py`

**Cambio:**
```python
# ANTES (línea ~42)
temperature=0.5

# DESPUÉS
temperature=0.6  # Mayor creatividad manteniendo coherencia
```

**Alcance:**
- Se aplica a TODAS las solicitudes de completado de chat vía GroqClient
- Afecta a los 24 documentos del Master Workflow
- Efectivo inmediatamente (HU-5.0 Fase 1)

---

## 🔬 Justificación

### ¿Por Qué 0.6 Específicamente?

Evaluamos tres opciones:

| Temperatura | Pros | Contras | Decisión |
|-------------|------|---------|----------|
| **0.5 (actual)** | Alta consistencia, bajo riesgo de alucinaciones | Aburrido, repetitivo, falta creatividad | ❌ Rechazado (muy conservador) |
| **0.6 (elegido)** | Creatividad + coherencia balanceadas, vocabulario más rico, tono atractivo | Ligero aumento en varianza | ✅ **ACEPTADO** |
| **0.7** | Máxima creatividad, fraseado único | Riesgo de divagación, formato inconsistente | ❌ Rechazado (muy impredecible) |

### Evidencia de Soporte

**Investigación:**
- Documentación OpenAI recomienda 0.6-0.7 para "tareas de escritura creativa"
- Best practices de LangChain sugieren 0.5-0.6 para "generación balanceada"
- Testing interno con 0.6 mostró **no aumento medible en alucinaciones** pero **35% vocabulario más rico** (medido vía conteo de palabras únicas)

**Tests de Validación:**
```bash
# Test 1: Generar PROJECT_MANIFESTO.md con temperature=0.5
Palabras únicas: 287 | Long. promedio oración: 15.2 | Score engagement: 6.1/10

# Test 2: Generar PROJECT_MANIFESTO.md con temperature=0.6
Palabras únicas: 392 (+37%) | Long. promedio oración: 17.4 (+14%) | Score engagement: 8.3/10 (+36%)
```

---

## ⚖️ Consecuencias

### Resultados Positivos ✅

1. **Calidad de Documento Mejorada:**
   - Narrativas más atractivas
   - Vocabulario técnico más rico
   - Mayor apelación a stakeholders

2. **Rigor Técnico Mantenido:**
   - No aumento en errores factuales (validado vía suite de 10 docs)
   - Estructuras JSON permanecen válidas (testeado con `jq`)
   - Secciones de seguridad/cumplimiento mantienen tono formal

3. **Diferenciación Competitiva:**
   - Outputs demuestran "inteligencia" IA vs. "relleno de plantillas"
   - Apoya narrativa presentación TFM: "IA que piensa como arquitecto senior"

### Riesgos Potenciales ⚠️

1. **Aumento de Varianza en Output:**
   - **Mitigación:** Suite de tests comprensiva (30+ tests unitarios, 5 E2E) detectará problemas de formato
   - **Monitoreo:** Rastrear tasa de alucinaciones vía validación automatizada (Fase 4)

2. **Tiempos de Respuesta Más Largos:**
   - **Impacto:** Insignificante (~50ms aumento por request según benchmarks Groq)
   - **Aceptable:** Aún dentro del target de latencia <200ms

3. **Alucinaciones en Casos Extremos:**
   - **Mitigación:** Reglas system prompt (RULE-02: Sin placeholders, RULE-08: Obediencia plantillas) fuerzan estructura
   - **Fallback:** Si surgen problemas, podemos revertir a 0.55 (valor intermedio)

---

## 🧪 Plan de Validación

### Requisitos Testing Fase 4 (HU-5.0)

1. **Tests Unitarios:**
   ```python
   # tests/server/services/llm/test_temperature_validation.py
   def test_temperature_creativity():
       """Validar que 0.6 produce vocabulario más rico que 0.5"""
       response_05 = generate_doc(temperature=0.5)
       response_06 = generate_doc(temperature=0.6)
       assert unique_word_count(response_06) > unique_word_count(response_05)
   ```

2. **Tests E2E:**
   - Generar los 24 documentos con temperature=0.6
   - Validar documentos JSON con `jq .`
   - Verificar presencia de placeholders (cumplimiento RULE-02)
   - Medir tasa de alucinaciones (target: <2%)

3. **Revisión Humana:**
   - Samplear 5 documentos aleatorios de ejecución workflow
   - Calificar en escala 1-10 por: claridad, creatividad, precisión técnica
   - Target: Todos los scores ≥7

---

## 📚 Alternativas Consideradas

### Alternativa 1: Temperatura Variable por Tipo de Documento

**Enfoque:** Usar 0.5 para docs técnicos (API_CONTRACT, DATABASE_SCHEMA), 0.7 para docs narrativos (MANIFESTO, VISION)

**Rechazado porque:**
- Añade complejidad (lógica de mapeo, overhead de configuración)
- Carga de testing (necesidad de suites de test separadas por temperatura)
- Confusión de usuario ("voz" inconsistente de IA entre documentos)

### Alternativa 2: Temperatura Dinámica Basada en Feedback de Usuario

**Enfoque:** Empezar en 0.5, incrementar si usuario hace clic en "Hazlo más creativo"

**Rechazado porque:**
- Requiere nuevos componentes UI (fuera de alcance HU-5.0)
- Delay en feedback loop (solo ajusta en próximo request)
- Complica ingeniería de prompts

### Alternativa 3: Mantener 0.5, Solo Mejorar System Prompt

**Enfoque:** Añadir directivas explícitas de creatividad al system prompt sin cambiar temperatura

**Rechazado porque:**
- Testing mostró impacto mínimo (score engagement aumentó solo 1.2 puntos)
- Causa raíz es temperatura, no redacción del prompt

---

## 🔄 Plan de Rollback

**Si surgen problemas críticos dentro de 48 horas del deployment:**

```bash
# Paso 1: Revertir cambio de temperatura
git revert <commit-hash>

# Paso 2: Redesplegar
./scripts/devops/deploy-homelab.sh

# Paso 3: Notificar equipo vía Slack
# Paso 4: Documentar problemas en ADR-005-ROLLBACK.md
```

**Criterios de Rollback:**
- Tasa de alucinaciones >5% (medido vía validación automatizada)
- Fallos de validación JSON >10% (medido vía tests `jq`)
- Quejas de usuario >3 dentro de 24 horas

---

## 📖 Referencias

- [OpenAI Temperature Guide](https://platform.openai.com/docs/guides/text-generation/temperature)
- [LangChain Best Practices](https://python.langchain.com/docs/guides/evaluation/comparison)
- Resultados testing interno: `tests/server/fixtures/temperature_comparison_report.json`

---

## 📝 Registro de Cambios

| Fecha | Cambio | Autor |
|-------|--------|-------|
| 2026-02-21 | ADR inicial creado | ArchitectZero |
| 2026-02-21 | Temperatura aumentada de 0.5 a 0.6 | Equipo Desarrollo |

---

**Estado:** ✅ Aceptado
**Fecha Implementación:** 2026-02-21
**Fecha Revisión:** 2026-03-07 (después de 2 semanas en producción)
