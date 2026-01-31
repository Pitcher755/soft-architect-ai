# 📚 Ontología del Proyecto y Lenguaje Ubicuo

Este documento define los términos fundamentales que **SoftArchitect AI** y el Equipo Humano usarán para comunicarse. Evita ambigüedades.

## Conceptos Nucleares (Meta-System)

### **Tech Pack**
Un conjunto curado de reglas, estructuras de carpetas y snippets de código para una tecnología específica (ej: `python-fastapi`). Es la "fuente de verdad" técnica.

### **Gate (Puerta de Calidad)**
Punto de control obligatorio al final de cada Fase. El sistema valida automáticamente la existencia y calidad de los documentos requeridos antes de desbloquear la siguiente fase.

### **Golden Template**
Plantilla maestra ubicada en `01-TEMPLATES`. Contiene la estructura ideal de un documento. La IA debe rellenar los huecos (`{{VAR}}`) sin alterar la estructura.

### **Context Window**
La totalidad de la información que la IA "conoce" sobre el proyecto en un momento dado. Se alimenta de los archivos `.md` generados en la carpeta `context/`.

## Definiciones de Ingeniería

### **Snapshot**
Estado congelado del proyecto en un momento del tiempo (ej: MVP, V1).

### **Artifact (Artefacto)**
Cualquier archivo generado por el proceso (Documento, Diagrama, Código).

### **Hardening**
Proceso de asegurar el sistema. En SoftArchitect, aplicamos hardening *antes* de escribir código (en la fase de diseño).
