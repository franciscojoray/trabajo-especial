// =============================================================================
// template.typ — Plantilla para Trabajo Especial de Licenciatura
// Facultad de Matemática, Astronomía, Física y Computación (FAMAF)
// Universidad Nacional de Córdoba (UNC)
// =============================================================================

#let thesis(
  title: "",
  subtitle: "",
  author: "",
  director: "",
  co-director: none,
  year: "",
  abstract-es: none,
  clasificación: [],
  palabras-clave: [],
  abstract-en: none,
  body,
) = {

  show heading.where(level: 4): set text(
    weight: "regular",
    style: "italic",
  )
  show heading.where(level: 4): it => {
    it.body + []
  }

  show "lambda_flechita": _ => {
    box[
      $lambda^arrow$
    ]
  }

  show regex("App|Ctx|Term|Type"): it => {
    set text(font: "DejaVu Sans Mono")
    it
  }

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
    size: 12pt,
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
          [Capítulo #counter(heading).display()]
          linebreak()
        }
        text(it.body)
        v(0.3em)
        line(length: 100%, stroke: 1.5pt)
      }
    )
  }

  show heading.where(level: 2): it => {
    v(1em)
    block(below: auto, {
      set text(size: 13pt, weight: "bold")
      it
    })
  }

  show heading.where(level: 3): it => {
    v(0.8em)
    block(below: auto, {
      set text(size: 11pt, weight: "bold", style: "italic")
      it
    })
  }

  // --------------------------------------------------------------------------
  // Math
  // --------------------------------------------------------------------------
  set math.equation(numbering: none)

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

  // ==========================================================================
  // TITLE PAGE
  // ==========================================================================
  page(
    margin: (top: 2cm, bottom: 2cm, left: 3cm, right: 2.5cm),
    {
      set align(center)

      v(0.5cm)
      text(size: 18pt, weight: "bold",
        "Universidad Nacional de Córdoba"
      )
      v(0.2cm)
      text(size: 10pt, weight: "bold",
        smallcaps[
          Facultad de Matemática, Astronomía, Física y Computación
      ]
      )
      v(1.5cm)

      // Institution logo
      image("images/unc-logo.png", width: 4cm)

      // Title
      text(size: 20pt, weight: "bold", title)
      if subtitle != "" {
        v(0em)
        text(size: 10pt, subtitle)
      }
      v(2cm)

      // Author
      align(right, box(width: 50%)[
        #set align(center)
        #text(size: 9pt, weight: "bold", smallcaps[Formalización de Normalización por Evaluación para Cálculo Lambda Simplemente Tipado en Coq])

        #text(size: 9pt, style: "italic", "Autor: " + author)

        #text(size: 9pt, style: "italic", "Director: " + director)
      ])

      v(3cm)
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
      align(bottom)[
        #text(size: 9pt, weight: "bold", "Clasificación:")

        #clasificación

        #text(size: 9pt, weight: "bold", "Palabras clave:")

        #palabras-clave
      ]
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
        set text(size: 9pt)
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
          line(length: 100%, stroke: 0.4pt)
        }
      }
    },
    footer: context {
      let page-num = counter(page).get().first()
      if calc.rem(page-num, 2) == 0 {
        align(left, text(size: 9pt,
          counter(page).display()
        ))
      } else {
        align(right, text(size: 9pt,
          counter(page).display()
        ))
      }
    },
  )

  counter(page).update(1)

  body
}
