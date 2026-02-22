---
marp: true
theme: default
class: invert
size: 16:9
style: |
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;800&display=swap');

  section {
    font-family: 'Inter', sans-serif;
    background-color: #0B101E; /* Midnight */
    /* Un sutil degradado de fondo para dar profundidad */
    background-image: radial-gradient(circle at 10% 20%, rgba(59, 130, 246, 0.1) 0%, transparent 40%), radial-gradient(circle at 90% 80%, rgba(167, 139, 250, 0.1) 0%, transparent 40%);
    color: #F8FAFC;
  }

  h1 { font-size: 65px; font-weight: 800; margin-bottom: 10px; color: #F8FAFC; border: none; text-shadow: 0 0 20px rgba(59, 130, 246, 0.5); }
  h1 strong { color: #3B82F6; }

  h2 { font-size: 42px; font-weight: 800; color: #F8FAFC; border-bottom: 2px solid #334155; padding-bottom: 15px; margin-bottom: 35px; text-shadow: 0 0 10px rgba(248, 250, 252, 0.3); }

  h3 { font-size: 26px; color: #F8FAFC; margin-bottom: 15px; margin-top: 0; }

  p, ul, li { font-size: 22px; color: #94A3B8; line-height: 1.6; }
  li { margin-bottom: 12px; }
  strong { color: #E2E8F0; }

  /* --- TARJETAS CON EFECTO GLOW --- */
  .card {
    background-color: #111827;
    border: 1px solid #334155;
    border-radius: 16px;
    padding: 25px;
    /* Sombra base suave */
    box-shadow: 0 15px 35px -10px rgba(0,0,0,0.5);
  }

  /* Tarjetas de Problema/Solución con Glow */
  .card-problem { border-color: rgba(239,68,68,0.5) !important; background: rgba(239,68,68,0.05) !important; box-shadow: 0 0 40px -10px rgba(239,68,68,0.3) !important; }
  .card-solution { border-color: rgba(52,211,153,0.5) !important; background: rgba(52,211,153,0.05) !important; box-shadow: 0 0 40px -10px rgba(52,211,153,0.3) !important; }

  /* Tarjetas de Arquitectura con Glow superior */
  .arch-blue { border-top: 4px solid #3B82F6 !important; box-shadow: 0 -10px 40px -10px rgba(59, 130, 246, 0.3), 0 15px 35px -10px rgba(0,0,0,0.5) !important; }
  .arch-teal { border-top: 4px solid #2DD4BF !important; box-shadow: 0 -10px 40px -10px rgba(45, 212, 191, 0.3), 0 15px 35px -10px rgba(0,0,0,0.5) !important; }
  .arch-purple { border-top: 4px solid #A78BFA !important; box-shadow: 0 -10px 40px -10px rgba(167, 139, 250, 0.3), 0 15px 35px -10px rgba(0,0,0,0.5) !important; }
  .arch-rag { border: 1px solid #3B82F6 !important; box-shadow: 0 0 60px rgba(59, 130, 246, 0.25) !important; margin-top: 40px; }

  /* Tarjetas de Fases con Glow lateral */
  /* El truco es una sombra negativa en el eje X para que brille el borde izquierdo */
  .phase-1 { border-left: 6px solid #FBBF24 !important; box-shadow: -15px 0 40px -10px rgba(251, 191, 36, 0.3), 0 15px 35px -10px rgba(0,0,0,0.3) !important; }
  .phase-2 { border-left: 6px solid #34D399 !important; box-shadow: -15px 0 40px -10px rgba(52, 211, 153, 0.3), 0 15px 35px -10px rgba(0,0,0,0.3) !important; }
  .phase-3 { border-left: 6px solid #2DD4BF !important; box-shadow: -15px 0 40px -10px rgba(45, 212, 191, 0.3), 0 15px 35px -10px rgba(0,0,0,0.3) !important; }
  .phase-4 { border-left: 6px solid #F472B6 !important; box-shadow: -15px 0 40px -10px rgba(244, 114, 182, 0.3), 0 15px 35px -10px rgba(0,0,0,0.3) !important; }
  .phase-5 { border-left: 6px solid #A78BFA !important; box-shadow: -15px 0 40px -10px rgba(167, 139, 250, 0.3), 0 15px 35px -10px rgba(0,0,0,0.3) !important; }
  .phase-6 { border-left: 6px solid #94A3B8 !important; box-shadow: -15px 0 40px -10px rgba(148, 163, 184, 0.3), 0 15px 35px -10px rgba(0,0,0,0.3) !important; }

  /* Grids y Layouts */
  .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 40px; align-items: start; }
  .grid-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 25px; }

  /* Galería de Imágenes con Glow */
  .gallery { display: flex; flex-wrap: wrap; gap: 20px; justify-content: center; margin-top: 20px; }
  .gallery img { width: 30%; border-radius: 8px; border: 2px solid #334155; object-fit: cover; transition: transform 0.3s; }
  /* Simulamos el glow de colores en las imágenes */
  .img-blue { border-color: #3B82F6 !important; box-shadow: 0 0 25px rgba(59, 130, 246, 0.4) !important; }
  .img-purple { border-color: #8B5CF6 !important; box-shadow: 0 0 25px rgba(139, 92, 246, 0.4) !important; }
  .img-orange { border-color: #F97316 !important; box-shadow: 0 0 25px rgba(249, 115, 22, 0.4) !important; }
  .img-pink { border-color: #EC4899 !important; box-shadow: 0 0 25px rgba(236, 72, 153, 0.4) !important; }
  .img-violet { border-color: #7C3AED !important; box-shadow: 0 0 25px rgba(124, 58, 237, 0.4) !important; }
  .img-cyan { border-color: #06B6D4 !important; box-shadow: 0 0 25px rgba(6, 182, 212, 0.4) !important; }

  /* Etiquetas y Utilidades */
  .badge { display: inline-block; background: rgba(59, 130, 246, 0.15); border: 1px solid rgba(59, 130, 246, 0.4); color: #60A5FA; padding: 6px 18px; border-radius: 20px; font-size: 14px; font-weight: bold; text-transform: uppercase; letter-spacing: 2px; margin-bottom: 20px; box-shadow: 0 0 20px rgba(59, 130, 246, 0.3); }
  .center { text-align: center; }
  .footer { position: absolute; bottom: 25px; left: 70px; font-size: 16px; color: #475569; }
---

<div class="center" style="margin-top: 40px;">
  <img src="assets/Logo.png" width="160" style="margin-bottom: 20px; filter: drop-shadow(0 0 30px rgba(59,130,246,0.4));" />
  <br>
  <div class="badge">Trabajo de Fin de Máster</div>
  <h1>SoftArchitect <strong>AI</strong></h1>
  <p style="font-size: 32px; color: #E2E8F0; margin-top: 10px; text-shadow: 0 0 10px rgba(255,255,255,0.2);">Tu Arquitecto de Software Local.</p>
  <p style="font-size: 22px; color: #64748B;">De una idea vaga a la arquitectura completa antes de escribir código.</p>
</div>

<div class="footer">Javier Fernández | Presentación TFM</div>

---

## El Abismo del Diseño

<div class="grid-2">
  <div>
    <p>El lienzo en blanco detiene la innovación.</p>
    <ul>
      <li><strong style="color: #F87171;">Parálisis de definición:</strong> El 60% de los proyectos sufren retrasos en la concepción inicial.</li>
      <li><strong style="color: #F87171;">Desconexión técnica:</strong> Documentación estática que rara vez refleja la arquitectura real.</li>
      <li><strong style="color: #F87171;">Privacidad Comprometida:</strong> IAs en la nube exponen propiedad intelectual corporativa.</li>
    </ul>
  </div>
  <div class="card card-problem">
    <h3 style="color: #F87171;">El Problema Principal</h3>
    <p style="font-size: 20px;">La industria necesita documentar rápido, pero externalizar el contexto a APIs públicas es un riesgo de seguridad inasumible para proyectos serios.</p>
  </div>
</div>

---

## La Solución: SoftArchitect AI

<div class="grid-2">
  <div>
    <ul>
      <li><strong style="color: #34D399;">Diseño dirigido por IA:</strong> Plataforma híbrida. Orquestación paso a paso mediante prompts.</li>
      <li><strong style="color: #34D399;">Privacidad 100% Local:</strong> Un LLM ejecutándose íntegramente en el hardware del usuario.</li>
      <li><strong style="color: #34D399;">Salida Estandarizada:</strong> Generación automatizada de 24 documentos técnicos.</li>
    </ul>
  </div>
  <div class="card card-solution">
    <h3 style="color: #34D399;">El Resultado</h3>
    <p style="font-size: 20px;">Pasar de una simple frase a un repositorio con C4 Models, esquemas JSON y flujos de usuario en <strong>menos de 15 minutos</strong>.</p>
  </div>
</div>

---

## Arquitectura Técnica Híbrida

<div class="grid-3">
  <div class="card arch-blue">
    <h3 style="color: #60A5FA; font-size: 22px;">1. Frontend (Flutter)</h3>
    <p style="font-size: 18px;">App Desktop nativa con Riverpod. Gestión de estado fluida, renderizado de Markdown y diagramas Mermaid en tiempo real.</p>
  </div>
  <div class="card arch-teal">
    <h3 style="color: #2DD4BF; font-size: 22px;">2. Backend (FastAPI)</h3>
    <p style="font-size: 18px;">Orquestador en Python. Control de Server-Sent Events (SSE) y pipeline asíncrono robusto.</p>
  </div>
  <div class="card arch-purple">
    <h3 style="color: #A78BFA; font-size: 22px;">3. Capa de IA (RAG)</h3>
    <p style="font-size: 18px;"><strong>Llama 3 (8B):</strong> Razonamiento local. <br><strong>ChromaDB:</strong> Base vectorial para contexto histórico.</p>
  </div>
</div>

---

## Interfaz de Usuario Desktop

<p class="center" style="margin-bottom: 20px; font-size: 20px;">Un entorno de desarrollo familiar con explorador de archivos y previsualización en vivo.</p>

<div class="gallery">
  <img src="assets/screenshots/screen1.png" class="img-blue" />
  <img src="assets/screenshots/screen2.png" class="img-purple" />
  <img src="assets/screenshots/screen3.png" class="img-orange" />
  <img src="assets/screenshots/screen4.png" class="img-pink" />
  <img src="assets/screenshots/screen5.png" class="img-violet" />
  <img src="assets/screenshots/screen6.png" class="img-cyan" />
</div>

---

## El Corazón del Sistema: Motor RAG

<div class="card arch-rag">
  <h3 style="color: #E2E8F0;">⚡ Retrieval-Augmented Generation</h3>
  <p>El modelo de lenguaje no parte de cero. Utiliza una base de conocimiento especializada inyectada en cada iteración:</p>
  <br>
  <ul>
    <li>Inyección estricta de plantillas en el prompt.</li>
    <li>Arquitectura Limpia forzada (Clean Architecture, Microservicios).</li>
    <li><strong>Resultado:</strong> Cero alucinaciones. Adherencia a los estándares de la industria.</li>
  </ul>
</div>

---

## El Workflow (Fases 1 a 3)

<div class="grid-3" style="margin-top: 50px;">
  <div class="card phase-1">
    <h3 style="color: #FBBF24; font-size: 22px;">01. CONTEXTO</h3>
    <p style="font-size: 18px;">Definición de objetivos, visión de negocio, lenguaje del dominio y viaje del usuario.</p>
  </div>
  <div class="card phase-2">
    <h3 style="color: #34D399; font-size: 22px;">02. REQUISITOS</h3>
    <p style="font-size: 18px;">Especificaciones técnicas, historias de usuario estructuradas (JSON) y seguridad.</p>
  </div>
  <div class="card phase-3">
    <h3 style="color: #2DD4BF; font-size: 22px;">03. ARQUITECTURA</h3>
    <p style="font-size: 18px;">Estructura del sistema, diagrama de directorios, base de datos y ADRs.</p>
  </div>
</div>

---

## El Workflow (Fases 4 a 6)

<div class="grid-3" style="margin-top: 50px;">
  <div class="card phase-4">
    <h3 style="color: #F472B6; font-size: 22px;">04. UX / UI</h3>
    <p style="font-size: 18px;">Sistemas de diseño visual, paletas de colores, flujos de usuario y accesibilidad.</p>
  </div>
  <div class="card phase-5">
    <h3 style="color: #A78BFA; font-size: 22px;">05. PLANIFICACIÓN</h3>
    <p style="font-size: 18px;">Planificación de Sprints, estrategia de CI/CD, infraestructura y DevOps.</p>
  </div>
  <div class="card phase-6">
    <h3 style="color: #94A3B8; font-size: 22px;">06. ROOT (NÚCLEO)</h3>
    <p style="font-size: 18px;">Generación de archivos núcleo del repositorio y perfiles de los agentes de IA.</p>
  </div>
</div>

---

## Conclusiones y Roadmap

<div class="grid-2">
  <div class="card" style="border-top: 4px solid #3B82F6;">
    <h3 style="color: #60A5FA;">Estado Actual (MVP)</h3>
    <p style="font-size: 20px;">Viabilidad técnica demostrada.</p>
    <ul style="font-size: 18px;">
      <li>Generación secuencial de 24 docs.</li>
      <li>Persistencia local.</li>
      <li>Compatibilidad con Microservicios.</li>
    </ul>
  </div>
  <div class="card phase-3" style="border-top: 4px solid #2DD4BF; border-left: 1px solid #334155;">
    <h3 style="color: #2DD4BF;">Backlog Futuro</h3>
    <ul style="font-size: 18px;">
      <li><strong>Scaffolding:</strong> Exportación a código real.</li>
      <li><strong>Sincronización:</strong> Jira / GitHub Issues.</li>
      <li><strong>Multimodal:</strong> Interpretar bocetos a mano.</li>
    </ul>
  </div>
</div>
