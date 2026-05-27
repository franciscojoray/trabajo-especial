# trabajo-especial

Plantilla en [Typst](https://typst.app/) para el Trabajo Especial de
Licenciatura en Ciencias de la Computación —
[FAMAF](https://www.famaf.unc.edu.ar/), Universidad Nacional de Córdoba.

## Estructura del documento

| Capítulo | Título |
|---|---|
| 1 | Introducción |
| 1.1 | ¿Qué es definir un lenguaje? |
| 1.2 | ¿Qué es y para qué formalizamos? |
| 2 | Definición del lenguaje (Expresiones, Tipos, Juicios de tipos, Semántica, Sustituciones) |
| 3 | Reificación |
| 3.1 | Definición Matemática |
| 3.2 | Definición Categórica |
| 4 | Rocq |
| 4.0 | Actualizaciones a Rocq 8.20 |
| 4.1 | Librería de dominios |
| 4.2 | Definiciones principales |
| 5 | Conclusión |
| 6 | Referencias |

## Archivos

| Archivo | Descripción |
|---|---|
| `main.typ` | Documento principal |
| `template.typ` | Plantilla de estilo (FAMAF/UNC) |
| `refs.bib` | Bibliografía en formato BibTeX |

## Compilación

### Requisitos

- [Typst](https://typst.app/) ≥ 0.11

### Compilar el PDF

```bash
typst compile main.typ
```

El PDF resultante se guarda como `main.pdf` en el mismo directorio.

### Modo observador (recarga automática)

```bash
typst watch main.typ
```

## Personalización

Editar el bloque `#show: thesis.with(...)` al comienzo de `main.typ` para
cambiar el título, autor, director y año:

```typst
#show: thesis.with(
  title:    "Título del Trabajo Especial",
  subtitle: "Subtítulo opcional",
  author:   "Nombre Apellido",
  director: "Dr./Dra. Nombre Apellido",
  year:     "2024",
  ...
)
```

## Licencia

MIT