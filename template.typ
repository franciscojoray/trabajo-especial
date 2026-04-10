// =============================================================================
// template.typ — Plantilla para Trabajo Especial de Licenciatura
// Facultad de Matemática, Astronomía, Física y Computación (FAMAF)
// Universidad Nacional de Córdoba (UNC)
// =============================================================================

// Shared color constants
#let color-primary = rgb("#003366")
#let color-text-muted = rgb("#444444")
#let color-rule-light = rgb("#cccccc")
#let color-page-num = rgb("#666666")

#let thesis(
  title: "",
  subtitle: "",
  author: "",
  director: "",
  co-director: none,
  year: "",
  abstract-es: none,
  abstract-en: none,
  body,
) = {

  // --------------------------------------------------------------------------
  // Document metadata
  // --------------------------------------------------------------------------
  set document(title: title, author: author)

  // --------------------------------------------------------------------------
  // Page layout
  // --------------------------------------------------------------------------
  set page(
    paper: "a4",
    margin: (top: 3cm, bottom: 3cm, left: 3.5cm, right: 2.5cm),
    numbering: none,
  )

  // --------------------------------------------------------------------------
  // Text & fonts
  // --------------------------------------------------------------------------
  set text(
    font: "New Computer Modern",
    size: 11pt,
    lang: "es",
  )

  set par(justify: true, leading: 0.65em)

  // --------------------------------------------------------------------------
  // Headings
  // --------------------------------------------------------------------------
  set heading(numbering: "1.1")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)
    v(1.5em)
    block(
      width: 100%,
      below: 0.8em,
      {
        set text(size: 16pt, weight: "bold")
        if it.numbering != none {
          text(fill: color-primary)[Capítulo #counter(heading).display()]
          linebreak()
        }
        text(fill: color-primary, it.body)
        v(0.3em)
        line(length: 100%, stroke: 1.5pt + color-primary)
      }
    )
  }

  show heading.where(level: 2): it => {
    v(1em)
    block(below: 0.5em, {
      set text(size: 13pt, weight: "bold")
      it
    })
  }

  show heading.where(level: 3): it => {
    v(0.8em)
    block(below: 0.4em, {
      set text(size: 11pt, weight: "bold", style: "italic")
      it
    })
  }

  // --------------------------------------------------------------------------
  // Math
  // --------------------------------------------------------------------------
  set math.equation(numbering: "(1)")

  // --------------------------------------------------------------------------
  // Figures & tables
  // --------------------------------------------------------------------------
  set figure(gap: 0.8em)

  // --------------------------------------------------------------------------
  // Code blocks
  // --------------------------------------------------------------------------
  show raw.where(block: true): it => block(
    fill: luma(245),
    inset: 8pt,
    radius: 4pt,
    width: 100%,
    text(font: "DejaVu Sans Mono", size: 9pt, it),
  )

  show raw.where(block: false): it => box(
    fill: luma(245),
    inset: (x: 3pt, y: 1pt),
    radius: 2pt,
    text(font: "DejaVu Sans Mono", size: 9pt, it),
  )

  // --------------------------------------------------------------------------
  // Links
  // --------------------------------------------------------------------------
  show link: set text(fill: color-primary)

  // ==========================================================================
  // TITLE PAGE
  // ==========================================================================
  page(
    margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 2.5cm),
    {
      set align(center)

      // Institution logo placeholder
      v(0.5cm)
      text(size: 13pt, weight: "bold", fill: color-primary,
        "UNIVERSIDAD NACIONAL DE CÓRDOBA"
      )
      linebreak()
      text(size: 12pt, fill: color-primary,
        "Facultad de Matemática, Astronomía, Física y Computación"
      )
      v(0.3cm)
      line(length: 80%, stroke: 1pt + color-primary)
      v(1.5cm)

      // Work type
      text(size: 12pt, style: "italic",
        "Trabajo Especial de Licenciatura en Ciencias de la Computación"
      )
      v(1.5cm)

      // Title
      text(size: 22pt, weight: "bold", fill: color-primary, title)
      if subtitle != "" {
        v(0.6cm)
        text(size: 15pt, fill: color-text-muted, subtitle)
      }
      v(2cm)

      // Author
      grid(
        columns: (1fr, 1fr),
        align: (right + top, left + top),
        column-gutter: 0.5em,
        {
          text(size: 11pt, weight: "bold", "Autor: ")
        },
        {
          text(size: 11pt, author)
        },
        {
          text(size: 11pt, weight: "bold", "Director: ")
        },
        {
          text(size: 11pt, director)
        },
        if co-director != none {
          text(size: 11pt, weight: "bold", "Co-director: ")
        },
        if co-director != none {
          text(size: 11pt, co-director)
        },
      )

      v(2cm)
      line(length: 60%, stroke: 0.5pt)
      v(0.5cm)
      text(size: 11pt, "Córdoba, Argentina — " + year)
    }
  )

  // ==========================================================================
  // ABSTRACT (Español)
  // ==========================================================================
  if abstract-es != none {
    page({
      v(2cm)
      align(center, text(size: 14pt, weight: "bold", "Resumen"))
      v(1cm)
      set text(size: 10.5pt)
      abstract-es
    })
  }

  // ==========================================================================
  // ABSTRACT (English)
  // ==========================================================================
  if abstract-en != none {
    page({
      v(2cm)
      align(center, text(size: 14pt, weight: "bold", "Abstract"))
      v(1cm)
      set text(size: 10.5pt)
      abstract-en
    })
  }

  // ==========================================================================
  // TABLE OF CONTENTS
  // ==========================================================================
  page(
    numbering: "i",
    {
      v(1cm)
      align(center, text(size: 14pt, weight: "bold", fill: color-primary,
        "Índice"
      ))
      v(0.8cm)
      outline(
        indent: auto,
        depth: 3,
      )
    }
  )

  // ==========================================================================
  // BODY
  // ==========================================================================
  set page(
    numbering: "1",
    header: context {
      let page-num = counter(page).get().first()
      if page-num > 1 {
        set text(size: 9pt, fill: color-page-num)
        let h = query(selector(heading.where(level: 1)).before(here()))
        if h.len() > 0 {
          let current = h.last()
          grid(
            columns: (1fr, auto),
            align: (left, right),
            emph(current.body),
            counter(page).display(),
          )
          v(-0.3em)
          line(length: 100%, stroke: 0.4pt + color-rule-light)
        }
      }
    },
    footer: context {
      let page-num = counter(page).get().first()
      if calc.rem(page-num, 2) == 0 {
        align(left, text(size: 9pt, fill: color-page-num,
          counter(page).display()
        ))
      } else {
        align(right, text(size: 9pt, fill: color-page-num,
          counter(page).display()
        ))
      }
    },
  )

  counter(page).update(1)

  body
}
