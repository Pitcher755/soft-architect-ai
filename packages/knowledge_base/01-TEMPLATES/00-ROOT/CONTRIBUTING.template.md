# 🤝 Guía de Contribución para {{PROJECT_NAME}}

¡Gracias por querer contribuir! Para mantener la calidad y la arquitectura de este proyecto, seguimos reglas estrictas.

## 1. Flujo de Trabajo (GitFlow)
* **Rama Principal:** `develop` (No hacer push directo).
* **Rama Estable:** `main` (Solo para releases).
* **Ramas de Feature:** `feature/nombre-descriptivo`.
* **Ramas de Fix:** `fix/nombre-del-bug`.

### Crear una nueva feature
```bash
git checkout develop
git checkout -b feature/{{FEATURE_NAME_EXAMPLE}}
```

## 2. Estándares de Commit
Usamos Conventional Commits. Mensajes en {{PRIMARY_LANGUAGE}} (o Inglés si se define en RULES).

```
feat: añadir endpoint de login

fix: corregir error en validación de email

docs: actualizar diagrama de arquitectura

style: formato de código (ruff/prettier)

refactor: optimizar consulta SQL
```

## 3. Reglas de Pull Request (PR)
* **Título:** Debe seguir Conventional Commits.
* **Descripción:** Enlazar la User Story (ej: Closes #HU-1.2).
* **Tests:** No se aprueba PR si baja el coverage del 80%.
* **Docs:** Si cambias lógica, actualiza `context/`.

## 4. Reporte de Bugs
Usa la plantilla de Issues proporcionada. Incluye:

* Pasos para reproducir.
* Comportamiento esperado vs real.
* Logs o capturas de pantalla.
