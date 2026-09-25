// =============================================================================
// main.typ — Trabajo Especial de Licenciatura en Ciencias de la Computación
// FAMAF — Universidad Nacional de Córdoba
// =============================================================================

#import "template.typ": thesis

#show: thesis.with(
  title:     smallcaps[Trabajo Especial],
  subtitle:  "Presentado ante la Facultad de Matemática, Astronomía y Física como parte de
los requerimientos para la obtención del grado de Licenciado en Ciencias de la
Computación.",
  author:    "Francisco José Joray",
  director:  "Alejandro Emilio Gadea",
  // co-director: "Dr./Dra. Nombre Apellido",   // descomentar si corresponde
  year:      "2026",

  abstract-es: [
    En 1991 Berger y Schwichtenberg [Ber] mostraron que se puede normalizar expresiones del
    cálculo lambda a través de la semántica. Para ello se usa un dominio semántico particular y
    se define una función de reificación que mapea (algunos) elementos semánticos a términos
    en forma normal. En 2007, Abel [Abel] y coautores mostraron que la Normalización por
    Evaluación (NbE) se puede extender a sistemas con tipos dependientes. Recientemente se
    ha formalizado NbE en Coq [Paw] usando una representación directa de los valores
    semánticos y no a través de dominios obtenidos a través de la solución de funciones
    recursivas de dominios. En este trabajo final se busca explorar la formalización en Coq de
    NbE para el cálculo lambda simplemente tipado usando una biblioteca que permite obtener
    soluciones de dominios.
  ],

  clasificación: [
    F.. - Semantics of Programming Languages - Denotational semantics.
    #linebreak()
    F.. - Mathematical Logic - Lambda calculus and related systems.],

  palabras-clave: [Semántica de lenguajes de programación, Sistemas de tipos,
    Reificación, Categorías, Rocq.]
)

// =============================================================================
// CAPÍTULO 1 — Introducción
// =============================================================================
= Introducción

Este trabajo especial explora la definición formal de un lenguaje de
programación, su formalización a través de sistemas de tipos y semántica
operacional, y la noción de _reificación_ abordada tanto desde la matemática
clásica como desde la teoría de categorías.  Finalmente se presentan las
definiciones principales codificadas y verificadas en el asistente de pruebas
Rocq 8.20.

El objetivo central es mostrar cómo los conceptos abstractos que surgen al
_definir_ un lenguaje pueden trasladarse, de manera rigurosa, a una
implementación verificada mecánicamente, cerrando así el ciclo entre teoría
y práctica.

== ¿Qué es definir un lenguaje?
<sec-que-es-definir>

Definir un lenguaje de programación implica especificar, de manera precisa y
sin ambigüedad, dos dimensiones fundamentales:

+ *Sintaxis*: el conjunto de programas bien formados, habitualmente dado por
  una gramática libre de contexto.

+ *Semántica*: el significado de cada programa bien formado, que puede
  expresarse de múltiples maneras (semántica operacional, denotacional,
  axiomática, etc.).

Una definición informal (en prosa o con ejemplos) es útil como punto de
partida, pero resulta insuficiente a la hora de razonar sobre propiedades del
lenguaje como la solidez del sistema de tipos, la terminación de la evaluación
o la corrección de una optimización.  La formalización brinda las herramientas
necesarias para tales razonamientos.

En este trabajo adoptamos un enfoque _sintáctico_ o de _teoría de tipos_: el
lenguaje queda determinado por sus _expresiones_ (términos), sus _tipos_, los
_juicios de tipos_ que relacionan términos con tipos, y las _reglas de
reducción_ que definen la evaluación.

== ¿Qué es y para qué formalizamos?
<sec-para-que-formalizamos>

Formalizar significa trasladar conceptos matemáticos o informales a un sistema
formal —usualmente una lógica o un sistema de tipos— en el que las
proposiciones y sus pruebas puedan ser verificadas mecánicamente.

Las razones principales para formalizar un lenguaje de programación son:

/ Corrección: Podemos probar que el lenguaje satisface propiedades deseadas
  (e.g.\ el teorema de progreso y preservación, o _type safety_) en lugar de
  simplemente asumirlas.

/ Comunicación inequívoca: Una especificación formal elimina la ambigüedad
  propia del lenguaje natural y sirve como contrato entre diseñadores,
  implementadores y usuarios del lenguaje.

/ Base para herramientas: Compiladores, intérpretes y analizadores estáticos
  pueden derivarse (o verificarse) directamente a partir de la especificación
  formal.

/ Desarrollo guiado por tipos: En sistemas como Rocq, la formalización misma
  es el programa: los tipos son las especificaciones y los términos bien
  tipados son los programas correctos por construcción.

== Formalización matemática y asistentes de prueba
<sec-formalizacion-matematica>

La formalización matemática puede entenderse como la mecanización de un
sistema deductivo: una teoría se expresa mediante un lenguaje preciso, axiomas
y reglas de inferencia, y una demostración se convierte en una secuencia de
transformaciones sintácticas que puede ser revisada automáticamente
@gunther2019. Esto establece un puente entre la práctica matemática y la
computación: la computadora no sólo permite ejecutar cálculos extensos, sino
también comprobar que cada paso de una prueba respeta las reglas previamente
establecidas.

Esta comprobación se apoya en un núcleo pequeño y confiable que verifica las
pruebas aceptadas por el sistema. La confianza no depende entonces de aceptar
como correcta toda la implementación del asistente, sino de revisar el
mecanismo fundamental que comprueba los términos y las derivaciones. El
asistente de prueba añade una dimensión interactiva: además de verificar una
prueba terminada, puede ayudar a construirla, administrar objetivos y
reutilizar resultados ya formalizados.

Los asistentes de prueba no comparten necesariamente la misma base lógica.
Entre las alternativas se encuentran la lógica de orden superior, la teoría de
tipos simples, las teorías de tipos dependientes y la teoría de conjuntos.
Estas elecciones implican un equilibrio entre expresividad, automatización y
la facilidad con que puede analizarse la corrección del propio sistema
@gunther2019. En este trabajo elegimos Rocq, basado en el Cálculo de
Construcciones Inductivas, porque permite expresar las definiciones del
lenguaje junto con sus propiedades y verificar sus pruebas dentro de un mismo
marco formal.

Esta perspectiva también aclara el propósito de los capítulos siguientes. La
definición del lenguaje no queda sólo como una descripción matemática externa:
se traduce a tipos inductivos, funciones y juicios que Rocq puede comprobar.
Del mismo modo, la semántica y la reificación se presentan como
construcciones formales sobre las que pueden enunciarse y demostrarse
propiedades, en lugar de quedar únicamente como una explicación informal.

// =============================================================================
// CAPÍTULO 2 — Definición del lenguaje
// =============================================================================
= Definición del Lenguaje
<cap-definicion>

== Sintaxis de lambda_flechita
<sec-sintaxis>

La teoría lambda_flechita posee cuatro _sorts_: contextos, tipos, sustituciones y términos; sus reglas introductorias se presentan en la @intro_sorts.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(ctx-sort)")
      $
        frac(
          ,
          "Ctx es un tipo"
        )
      $
    ],
    [
      #smallcaps("(subs-sort)")
      $
        frac(
          Gamma\, Delta in "Ctx",
          Gamma arrow Delta "es un tipo"
        )
      $
    ],
    [
      #smallcaps("(type-sort)")
      $
        frac(
          ,
          "Type es un tipo"
        )
      $
    ],
    [
      smallcaps("(term-sort)")
      $
        frac(
          Gamma in "Ctx" quad A in "Type",
          "Term"(Gamma, A) "es un tipo"
        )
      $
    ],
  ),
  caption: [Reglas introductorias para los _sorts_ de lambda_flechita.]
)<intro_sorts>

=== Reglas introductorias

==== Contextos
Un contexto corresponde a una lista de suposiciones. El contexto vacío
se denota por $diamond.small$; a veces escribimos $tack.r t : A$ en lugar de $diamond.small tack.r t : A$. Si ya hemos hecho algunas suposiciones, digamos $Gamma$, entonces podemos hacer más; dado que los tipos actúan como suposiciones, podemos extender $Gamma$ con un tipo $A$: este contexto se escribe $Gamma .A$.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(empty-ctx)")
      $
        frac(
          ,
          diamond.small in "Ctx"
        )
      $
    ],
    [
      #smallcaps("(ext-ctx)")
      $
        frac(
          Gamma in "Ctx" quad A in "Type",
          Gamma .A in "Ctx"
        )
      $
    ],
  ),
)

Usualmente, cuando se agrega la suposición $A$ al contexto $Gamma$ (léase «$Gamma$ se extiende
con el tipo $A$»), esta nueva suposición recibe un nombre. Por supuesto, dicho nombre debe ser
fresco respecto de los nombres de las demás suposiciones en $Gamma$. En nuestro cálculo no
hay necesidad de nombrar las suposiciones, ya que se referencian mediante índices de de Bruijn.


==== Sustituciones
Las reglas introductorias de los operadores para sustituciones se muestran
en la @intro_subs Una sustitución $sigma in Gamma -> Delta$ puede entenderse como
una asignación de términos bien tipados bajo $Gamma$ a las suposiciones de $Delta$.
Otra lectura posible, proveniente del origen categórico de las sustituciones explícitas [],
es que una sustitución $sigma in Gamma -> Delta$ es un morfismo en la categoría de contextos
(lo que también explica que $sigma$ pueda pensarse como un mapeo
$"Term"(Delta, A) -> "Term"(Gamma, A)$).

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(id-subs)")
      $
        frac(
          Gamma in "Ctx",
          id_Gamma in Gamma arrow Gamma
        )
      $
    ],
    [
      #smallcaps("(empty-subs)")
      $
        frac(
          Gamma in "Ctx",
          chevron chevron.r in Gamma arrow diamond.small
        )
      $
    ],
  ),
)
#figure(
  grid(
    row-gutter: 1.5em,
    [
      #smallcaps("(comp-subs)")
      $
        frac(
          Gamma\, Delta\, Sigma in "Ctx" quad delta in Delta arrow Sigma quad sigma in Sigma arrow Gamma,
          sigma space delta in Delta arrow Gamma
        )
      $
    ],
    [
      #smallcaps("(ext-subs)")
      $
        frac(
          Gamma\, Delta in "Ctx" quad sigma in Delta arrow Gamma quad A in "Type" quad t in "Term"(Delta, A),
          (sigma, t) in Delta arrow Gamma .A
        )
      $
    ],
    [
      #smallcaps("(fst-subs)")
      $
        frac(
          Gamma in "Ctx" quad A in "Type",
          sans("p") in Gamma .A arrow Gamma
        )
      $
    ]
  ),
  caption: [Reglas introductorias para las sustituciones en lambda_flechita]
)<intro_subs>

Los operadores pueden entenderse fácilmente usando la primera lectura: la sustitución
identidad $id_Gamma$ mapea cada variable a sí misma. La sustitución vacía $chevron chevron.r$
no debe mapear ninguna variable a nada. La composición se escribe como yuxtaposición; el
operador de extensión, denotado mediante emparejamiento, hace patente que las
sustituciones asignan términos bien tipados bajo un contexto a variables en otro. Finalmente,
$sans("p")$ es la operación de _shifting_, también llamada sustitución de _weakening_, necesaria
al extender un contexto con una nueva suposición.


==== Tipos
Consideramos sólo un tipo básico $N$ y la formación de espacios de funciones no dependientes, $A arrow B$.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(iota-I)")
      $
        frac(
          ,
          N in "Type"
        )
      $
    ],
    [
      #smallcaps("(Fun-I)")
      $
        frac(
          A in "Type" quad B in "Type",
          A arrow B in "Type"
        )
      $
    ],
  ),
)


==== Términos
Las reglas introductorias para los términos se presentan en la @intro_terms. Nótese
la regla #smallcaps("(subs-term)") para aplicar sustituciones a términos; en esta regla $t$ es un término con variables bajo $Delta$ y $sigma$ asigna términos,
tipados bajo $Gamma$, a esas variables; así, tras aplicar $sigma$ a $t$ obtenemos un término
bien tipado bajo $Gamma$.

Como explicamos, usamos una variante de los índices unarios de
de Bruijn: $sans("q")$ corresponde a $0$ y el sucesor de $n$ se obtiene aplicando la
sustitución $sans("p")$ a $n$; por ejemplo, la penúltima suposición se referencia mediante $sans("q") sans("p")$, la anterior mediante $(sans("q") sans("p")) sans("p")$, y así sucesivamente.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(hyp)")
      $
        frac(
          Gamma in "Ctx" quad A in "Type",
          sans("q") in "Term"(Gamma .A, A)
        )
      $
    ],
    [
      #smallcaps("(Abs-I)")
      $
        frac(
          Gamma in "Ctx" quad A in "Type" quad t in "Term"(Gamma .A, B),
          lambda t in "Term"(Gamma, A arrow B)
        )
      $
    ],
  ),
)
#figure(
  grid(
    row-gutter: 1.5em,
    [
      #smallcaps("(App-I)")
      $
        frac(
          Gamma in "Ctx" quad A in "Type" quad A\, B in "Type" quad t in "Term"(Gamma, A arrow B) quad r in "Term"(Gamma, A),
          "App" t space r in "Term"(Gamma, B)
        )
      $
    ],
    [
      #smallcaps("(subs-term)")
      $
        frac(
          Gamma\, Delta in "Ctx" quad A in "Type" quad sigma in Gamma arrow Delta quad t in "Term"(Delta, A),
          t sigma in "Term"(Gamma, A)
        )
      $
    ]
  ),
  caption: [Términos de lambda_flechita]
)<intro_terms>


=== Axiomas
==== Igualdad de términos
El primer conjunto de axiomas corresponde a las reglas $(beta)$ y $(eta)$ de igualdad de términos.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(beta)")
      $
        frac(
          Gamma tack.r lambda t: A arrow B quad Gamma tack.r r: A,
          Gamma tack.r "App" (lambda t) space r = t space (id_Gamma, r): B
        )
      $
    ],
    [
      #smallcaps("(eta)")
      $
        frac(
          Gamma tack.r t: A arrow B,
          Gamma tack.r lambda ("App" (t sans("p")) sans("q")) = t: A arrow B
        )
      $
    ],
  ),
)

==== Sustituciones en términos
Las siguientes reglas axiomatizan la sustitución.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(sub-ass)")
      $
        frac(
          Sigma tack.r t: A quad Sigma tack.r sigma: Delta quad Gamma tack.r delta: Delta,
          Gamma tack.r t space (sigma space delta) = (t space sigma) space delta: A
        )
      $
    ],
    [
      #smallcaps("(sub-id)")
      $
        frac(
          Gamma tack.r t: A,
          Gamma tack.r t space id_Gamma = t: A
        )
      $
    ],
    [
      #smallcaps("(snd-sub)")
      $
        frac(
          Gamma tack.r t: A quad Gamma tack.r sigma: Delta,
          Gamma tack.r sans("q") space (sigma, t) = t: A
        )
      $
    ],
    [
      #smallcaps("(abs-sub)")
      $
        frac(
          Delta tack.r lambda t: A arrow B quad Gamma tack.r sigma: Delta,
          Gamma tack.r (lambda t) space sigma = lambda (t space (sigma space sans("p"), sans("q"))): A arrow B
        )
      $
    ],
  ),
)
#figure(
  grid(
    row-gutter: 1.5em,
    [
      #smallcaps("(app-sub)")
      $
        frac(
          Delta tack.r t: A arrow B quad Delta tack.r r: A quad Gamma tack.r sigma: Delta,
          Gamma tack.r ("App" t space r) space sigma = "App" (t space sigma) space (r space sigma): B
        )
      $
    ],
  ),
)

==== Sustituciones
Las siguientes reglas pueden entenderse como la teoría ecuacional
de una categoría con productos finitos: asociatividad de la composición, la
identidad como elemento neutro de la composición, la propiedad universal del
objeto terminal y propiedades de los productos binarios: postcomposición con
la primera proyección, identidad para productos y postcomposición con un
morfismo mediador hacia un objeto producto.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(sub-ass)")
      $
        frac(
          Theta tack.r sigma: sigma quad Sigma tack.r delta: Delta quad Gamma tack.r gamma: Delta,
          Gamma tack.r (sigma space delta) space gamma = sigma space (delta space gamma)
        )
      $
    ],
    [
      #smallcaps("(sub-empty)")
      $
        frac(
          Gamma tack.r sigma: diamond.small,
          Gamma tack.r chevron chevron.r space sigma = chevron chevron.r: diamond.small
        )
      $
    ],
    [
      #smallcaps("(sub-idl)")
      $
        frac(
          Gamma tack.r sigma: Delta,
          Gamma tack.r id_Gamma space sigma = sigma: Delta
        )
      $
    ],
    [
      #smallcaps("(sub-idr)")
      $
        frac(
          Gamma tack.r sigma: Delta,
          Gamma tack.r sigma space id_Delta = sigma: Delta
        )
      $
    ],
    [
      #smallcaps(("(sub-id-empty)"))
      $
        frac(
          ,
          diamond.small tack.r id_diamond.small = chevron chevron.r: diamond.small 
        )
      $
    ],
    [
      #smallcaps(("(sub-id-ext)"))
      $
        frac(
          ,
          Gamma .A tack.r id_(Gamma .A) = (sans("p"), sans("q")): Gamma .A
        )
      $
    ],
    [
      #smallcaps(("(sub-fst)"))
      $
        frac(
          Gamma tack.r t: A quad Gamma tack.r sigma: Delta,
          Gamma tack.r sans("p") space (sigma, t) = sigma: Delta
        )
      $
    ],
    [
      #smallcaps(("(sub-map)"))
      $
        frac(
          Gamma tack.r t: A quad Gamma tack.r sigma: Delta quad Sigma tack.r delta: Delta,
          Gamma tack.r (sigma, t) space delta = (sigma space delta, t space delta): Sigma .A
        )
      $
    ],
  ),
)

==== Congruencia
Los dos últimos grupos de reglas corresponden a la reflexividad, simetría,
transitividad y clausura contextual de la igualdad.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(refl)")
      $
        frac(
          Gamma tack.r t: A,
          Gamma tack.r t = t: A
        )
      $
    ],
    [
      #smallcaps("(refl-subs)")
      $
        frac(
          Gamma tack.r sigma: Delta,
          Gamma tack.r sigma = sigma: Delta
        )
      $
    ],
    [
      #smallcaps("(sym)")
      $
        frac(
          Gamma tack.r t = r: A,
          Gamma tack.r r = t: A
        )
      $
    ],
    [
      #smallcaps("(sym-subs)")
      $
        frac(
          Gamma tack.r sigma = sigma': Delta,
          Gamma tack.r sigma' = sigma: Delta
        )
      $
    ],
    [
      #smallcaps("(trans)")
      $
        frac(
          Gamma tack.r t = r: A quad Gamma tack.r r = s: A,
          Gamma tack.r t = s: A
        )
      $
    ],
    [
      #smallcaps("(trans-subs)")
      $
        frac(
          Gamma tack.r sigma = delta: Delta quad Gamma tack.r delta = gamma: Delta,
          Gamma tack.r sigma = gamma: Delta
        )
      $
    ],
  )
)

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(cong-app)")
      $
        frac(
          Gamma tack.r t = t': A quad Gamma tack.r r = r': A,
          Gamma tack.r "App" t space r = "App" t' space r': A
        )
      $
    ],
    [
      #smallcaps("(cong-abs)")
      $
        frac(
          Gamma .A tack.r t = t': B,
          Gamma tack.r lambda t = lambda t': A arrow B
        )
      $
    ],
  )
)
#figure(
  grid(
    row-gutter: 1.5em,
    [
      #smallcaps("(cong-subs)")
      $
        frac(
          Delta tack.r t = t': A quad Gamma tack.r sigma = sigma': Delta,
          Gamma tack.r t space sigma = t' space sigma': A
        )
      $
    ],
  ),
)
#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(cong-map)")
      $
        frac(
          Gamma tack.r t = t': A quad Gamma tack.r sigma = sigma': Delta,
          Gamma tack.r (sigma, t) = (sigma', t'): Delta .A
        )
      $
    ],
    [
      #smallcaps("(cong-comp)")
      $
        frac(
          Gamma .A tack.r sigma = sigma': Delta quad Gamma tack.r delta = delta': Sigma,
          Gamma tack.r sigma space delta = sigma' space delta': Sigma
        )
      $
    ],
  )
)

// =============================================================================
// CAPÍTULO 3 — Reificación
// =============================================================================
= Reificación
<cap-reificacion>

== Normalización por Evaluación: Usando Semántica para Normalizar

Berger y Schwichtenberg @berger1991inverse notaron que se puede establecer un cierto modelo
del cual extraer formas normales. Esta técnica, llamada Normalización por Evaluación (NbE),
utiliza conceptos semánticos en lugar de sintácticos, como
en métodos más tradicionales donde se habla de secuencias de reducción y
similares. La idea de NbE es construir un modelo tal que se pueda volver de la
semántica a la sintaxis; es decir, no solo se tiene la función de evaluación $[|\_|]$ sino
también una función de _reificación_ $R(\_) ∈ union.big_A D_A → Λ$, véase @nbe. Si esta función de reificación
mapea elementos en la imagen de $[|\_|]$ a términos en forma normal, entonces
podemos componer las dos funciones y obtener una forma normal para cada término. La
función de reificación será útil si podemos probar que la composición de las
dos funciones mapea términos a su forma normal; es decir, necesitamos una prueba que
$t = R([|t|])$ sea demostrable en el sistema formal. Para usar NbE para decidir
la igualdad en una teoría necesitamos otra propiedad: si $t = t'$ es demostrable, entonces
necesitamos saber que $R([|t|]) ≡ R([|t'|])$.

#figure(
  image("images/nbe.png"),
  caption: [Normalización por Evaluación],
)<nbe>

=== Propiedades del sistema formal

En nuestra codificación las variables de de Bruijn pueden identificarse con
$sans("q"), sans("q") sans("p")^1, sans("p")^2, . . .$
donde la notación $sans("p")^i$ denota la composición $i$ veces de $sans("p")$ consigo misma:

$ sans("p")^i = cases(
  sans(id) & "si" i = 0,
  sans("p") & "si" i = 1,
  sans("p") sans("p")^(i-1) & "si" i > 1
) $

Finalmente caracterizamos el conjunto de términos en forma normal. La forma de
las formas normales, en el contexto del cálculo lambda no tipado con variables nombradas,
es $λ x_1 .λ x_2 . . . . λ x_n .(. . . ((y space t_1) space t_2) . . .) space t_m$,
donde $m ⩾ 0, n ⩾ 0$, y cada $t_i$ tiene también esa forma; es fácil ver que la siguiente
gramática captura esos términos.

$ "Ne" in.rev k ::= x | "App" k space v $
$ "Nf" in.rev v ::= lambda x.v | k . $

Después de reemplazar variables indexadas por variables nombradas en esa gramática
llegamos a la definición de formas normales y términos neutrales.

_Definición_ 1 (Términos neutrales y formas normales).

$ "Ne" in.rev k ::= sans("q") | sans("q") sans("p")^(i+1) | "App" k space v $
$ "Nf" in.rev v ::= lambda x.v | k . $

=== Un modelo adecuado para NbE

Nuestro modelo para la normalización se basa en un dominio [@abramsky1994handbook, @scott1971continuous, @smth1982category] procedente de la
solución D de la siguiente ecuación de dominios

#math.equation(block: true, numbering: "(3.1)", $ D ≈ OO ⊕ D × D ⊕ [D → D] ⊕ "Var"_⊥ ⊕ D × D ; $)

donde Var es un conjunto numerable (escribimos $x_i$ y asumimos $x_i != x_j$ si $i != j$, para
$i, j in NN$), $OO = {bot, top}$ (llamado el espacio de Sierpinski), $[D arrow D]$ es el conjunto de
funciones continuas de $D$ a $D$, y $D times D$ es el producto cartesiano de $D$
consigo mismo. El conjunto Var se considera un pre-dominio plano. Todo elemento de $D$
que no es $bot$ es un elemento de algún componente de la suma aplastada en el
lado derecho de la Eq. 3.1; en tal caso escribimos $top in D$ para $top in OO$ y

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      $
        "pair": D × D → D
      $
    ],
    [
      $
        "lam": [D → D] → D
      $
    ],
    [
      $
        "Var": NN → D
      $
    ],
    [
      $
        "App": D × D → D
      $
    ],
  )
)

==== Reificación
Definimos una función parcial de lectura inversa R que, dado un elemento
de D, devuelve un término del cálculo. Esta función es similar a la función de lectura
inversa introducida por Grégoire y Leroy @gregoire2002compiled para definir un procedimiento de normalización
por medio de un evaluador. Cuando el evaluador devuelve una abstracción
λx.t, la función de lectura inversa crea una nueva abstracción λy.v, donde v es la forma normal que resulta de la evaluación y de leer de vuelta el término (λx.t) ỹ; la
constante ỹ es posteriormente sustituida por y por la función de lectura inversa. En nuestro caso, en
un elemento de D de la forma lam f, la función f puede pensarse como el
normalizador del cuerpo de alguna abstracción, por lo que solo necesitamos aplicar f para
obtener un valor que pueda ser reificado.

_Definición_ 2 (Función de reificación).

$ R_j ("App" d d') = "App" (R_j d) (R_j d') $
$ R_j ("lam" f) = λ(R_(j+1) (f("Var" j))) $
$ R_j ("Var" i) = cases(
  sans("q") & "si" i <= j+1,
  sans("q") sans("p")^(i-(j+1)) & "si" i > j+1
) $

Para ser precisos, la función de reificación $R$
es el menor punto fijo de un funcional adecuado $ F : (NN × D → "Terms"_⊥ ) → (NN × D → "Terms"_⊥ ) $

Esta formulación no es sólo una manera abstracta de escribir las tres
ecuaciones anteriores. La reificación es una función parcial: algunos elementos
de $D$ no corresponden a un término que pueda leerse de vuelta, y por eso su
codominio debe incluir el elemento de indefinición $bot$ de
$("Terms"_⊥)$. Además, la reificación de una abstracción vuelve a llamar a la
misma función sobre el cuerpo de la función semántica, y la reificación de una
aplicación la vuelve a llamar sobre sus dos componentes. Por lo tanto, las
ecuaciones definen una función recursiva, no una definición por casos finita.

El funcional $F$ recibe una aproximación $f$ de la función de reificación y
produce una aproximación mejor: en el caso de una variable devuelve el término
correspondiente; en el caso de una abstracción aplica la función semántica a una
variable fresca, reifica el resultado en el contexto extendido y construye una
abstracción; en el caso de una aplicación reifica ambos operandos y construye
un término aplicado. Si alguna de esas operaciones encuentra $bot$, el
resultado también es $bot$.

El menor punto fijo $R = "lfp"(F)$ es entonces la solución definida por esas
ecuaciones que contiene exactamente la información obtenida por aproximaciones
finitas. Es el menor punto fijo porque no se agregan términos que no puedan
justificarse mediante un número finito de pasos de lectura inversa; las partes
que no pueden calcularse permanecen indefinidas. Finalmente, el teorema de
punto fijo de la semántica de dominios garantiza que este menor punto fijo
existe cuando $F$ es continuo, que es precisamente la propiedad que se verifica
para la construcción formal utilizada en el capítulo siguiente.

// =============================================================================
// CAPÍTULO 4 — Rocq
// =============================================================================
= Rocq
<cap-rocq>

Rocq (anteriormente conocido como Coq) es un asistente de pruebas interactivo
basado en el Cálculo de Construcciones Inductivas (CIC)
@coquand1988calculus @rocq2024.  Permite tanto la definición de funciones y
predicados matemáticos como la verificación de sus propiedades mediante
pruebas formales.

En este trabajo utilizamos Rocq 8.20 para codificar las definiciones de la
@cap-definicion y la @cap-reificacion.

== Librería de Dominios
<sec-rocq-dominios>

== Actualizaciones a Rocq 8.20
<sec-rocq-actualizaciones-8.20>

La biblioteca CoqDomains @benton2012formalizing fue desarrollada originalmente
para Coq 8.3/8.4 con SSReflect incluido en la distribución. Para utilizarla en
Rocq 8.20 fue necesario actualizar dependencias y varios comandos y tácticas
que dejaron de estar disponibles:

+ *Dependencia de mathcomp*: SSReflect (`ssreflect`, `ssrnat`, `ssrbool`, `eqtype`, `seq`, `ssrfun`) ya no se distribuye con Coq sino en el paquete separado `mathcomp`; los `Require Export ssreflect …` se reemplazaro por `From mathcomp Require Export …`.

+ *Cambios en la API de mathcomp 2.x*: el constructor `Pack` de las estructuras canónicas de `eqtype` pasó a requerir un envoltorio `Class` (`Equality.Pack (Equality.Class (Equality.Mixin …))`), y `EqMixin` se renombró a `Equality.Mixin` (`Finmap.v`).

+ *Comandos eliminados en Coq 8.20*: `Implicit Arguments` → `Arguments … {…}` (o `: clear implicits`); `Arguments Scope` → `Arguments … _%_scope`; `Hint Resolve …` ahora exige base explícita (`: core`); `Save.` requiere un nombre o se usa `Qed.`.

+ *Cambios en tácticas*: la reescritura de igualdades de setoide con `rewrite -> …` se reemplazó por `setoid_rewrite` (`MetricRec.v`, `uniirec.v`, `uniisound.v`, `typedsoundness.v`), y la táctica `Rewrites`(eliminada) por `rewrite` (`unii.v`, `typedlambda.v`).

+ *Ajustes puntuales*: `projT1` → `proj1_sig` (`PredomSum.v`), `Variable` → `Parameter` dentro de `Module Type` (`uniirec.v`), y adaptación de los patrones `let: Pack …` y `exist …` (`Categories.v`, `NSetoid.v`).

+ *Sistema de compilación*: se reemplazó el `Makefile` generado a mano por un
  `_CoqProject` (`-R . Coqdomains`) compilado con `coq_makefile -f _CoqProject`.

== Actualizaciones a Rocq 9.0.1
<sec-rocq-actualizaciones-9.0.1>

Sólo fue necesario corregir el lema `findom_ind` (`Finmap.v:479`): la antigua reescritura de tácticas `-> (proj2 (andP (proj2 (andP X'))))` dependía de que `andP/reflect` se desplegara en un subtérmino sintácticamente coincidente, lo que falló con `ssreflect` integrado en la `Stdlib` de `Rocq 9.0.1`. Fue reemplazado por:

```rocq
move/andP: X' => [/andP [Xa Xs] /andP [Xb Xu]]. rewrite Xs Xu. by [].
```

Esto descompone `X'` en sus conjunciones booleanas a través de las vistas `andP` y reescribe `sorted/uniq` directamente; el resto de la prueba permanece intacto.

== Definiciones Principales
<sec-rocq-definiciones>

A continuación presentamos las definiciones centrales del lenguaje en Rocq,
siguiendo la estructura de la @cap-definicion.

=== Entornos

```
  Definition Env := nat.
```

=== Variables

```
  Inductive Var : Env -> Type :=
  | ZVAR : forall E, Var (S E)
  | SVAR : forall E, Var E -> Var (S E)
  .
```

=== Valores y Expresiones

```
  (** *Definition 36: Syntax *)
  Inductive Term E :=
  | VAR : Var E     -> Term E
  | FUN : Term E.+1 -> Term E
  | APP : Term E    -> Term E -> Term E
  .
```

=== Tipos y Contextos

```
  (** *Definition 3.5: Types and contexts *)
  Inductive LType :=
  | FunTy  : LType -> LType -> LType
  | UnitTy : LType
  .

  Definition LCtx (E : Env) := t LType E.
```

  La función `lookupType` recupera del contexto el tipo asociado a una variable
  de de Bruijn. Su recursión sigue simultáneamente la estructura de la variable
  y la del vector que representa al contexto.

  ```rocq
  Definition lookupType :=
  fix nth_fix {E} (Γ : t LType E) (v : Var E) {struct Γ} : LType :=
  match v in Var E' return t LType E' -> LType with
  | ZVAR _ => fun Γ' =>
    caseS (fun _ _ => LType) (fun θ n t => θ) Γ'
  | SVAR _ v' => fun Γ' =>
    (caseS (fun E' _ => Var E' -> LType)
      (fun _ n Γ'' w => nth_fix Γ'' w) Γ') v'
  end Γ.
  ```

  === Juicios de tipado

  El tipo inductivo `TypeJudge` codifica las tres reglas de tipado del lenguaje.
  Una prueba de `Γ t⊢ t ⦂ θ` es, por construcción, una derivación de que el
  término `t` tiene tipo `θ` bajo el contexto `Γ`.

  ```rocq
  Reserved Notation "Γ 't⊢' t ⦂ θ"
    (at level 201, no associativity).

  Inductive TypeJudge :
    forall (E : Env), LCtx E -> Term E -> LType -> Type :=
  | VarRule : forall (E : Env) (Γ : LCtx E) (v : Var E),
    (Γ t⊢ VAR v ⦂ lookupType Γ v)
  | FunRule : forall (E : Env) (Γ : LCtx E)
    (e : Term E.+1) (θ' θ : LType),
    ((θ' × Γ) t⊢ e ⦂ θ) ->
    (Γ t⊢ λ e ⦂ (θ' ⇥ θ))
  | AppRule : forall (E : Env) (Γ : LCtx E)
    (t t' : Term E) (θ θ' : LType),
    (Γ t⊢ t ⦂ (θ' ⇥ θ)) ->
    (Γ t⊢ t' ⦂ θ') ->
    (Γ t⊢ t @ t' ⦂ θ)
  where "Γ t⊢ t ⦂ θ" := (TypeJudge Γ t θ).
  ```

  === Dominio semántico

  La biblioteca construye una solución `DInf` para una ecuación recursiva de
  dominios. El predominio de valores `VInf` separa los naturales, las funciones
  continuas y los pares. Los morfismos `Roll` y `Unroll` exhiben el isomorfismo
  entre `DInf` y `VInf`.

  ```rocq
  Parameter DInf : cpoType.

  Definition VInf :=
    discrete_cpoType nat +
    (DInf -=> DInf _BOT) +
    (DInf * DInf).

  Parameter Roll   : VInf =-> DInf.
  Parameter Unroll : DInf =-> VInf.

  Parameter RU_id : Roll << Unroll =-= Id.
  Parameter UR_id : Unroll << Roll =-= Id.
  ```

  Las inyecciones que se utilizan en la semántica y en la reificación son:

  ```rocq
  Definition inNat : nat_cpoType =-> VInf :=
    in1 (A := nat_cpoType + (DInf -=> DInf _BOT))
        (B := DInf * DInf) <<
    in1 (A := nat_cpoType) (B := DInf -=> DInf _BOT).

  Definition inFun : (DInf -=> DInf _BOT) =-> VInf :=
    in1 (A := nat_cpoType + (DInf -=> DInf _BOT))
        (B := DInf * DInf) <<
    in2 (A := nat_cpoType) (B := DInf -=> DInf _BOT).

  Definition inPair : (DInf * DInf) =-> VInf :=
    in2 (A := nat_cpoType + (DInf -=> DInf _BOT))
        (B := DInf * DInf).
  ```

  === Semántica de entornos, variables y términos

  Un entorno semántico es un producto iterado de valores. Por ello, la semántica
  de la variable más reciente es la segunda proyección y la de una variable
  sucesora descarta primero el último componente del entorno.

  ```rocq
  Fixpoint SemEnv E : cpoType :=
    match E with
    | O   => One
    | S E => SemEnv E * VInf
    end.

  Fixpoint SemVar E (v : Var E) : SemEnv E =-> VInf :=
    match v with
    | ZVAR _   => pi2
    | SVAR _ v => SemVar v << pi1
    end.
  ```

  Para interpretar una abstracción, `F` transforma la semántica de su cuerpo en
  una función del dominio. Para la aplicación, `AppOp` extrae el componente
  funcional del primer operando y lo aplica al segundo; `kleisli` propaga la
  posible indefinición.

  ```rocq
  Definition F (E : Env) (SemE : SemEnv E.+1 =-> VInf _BOT) :
      SemEnv E -=> (DInf -=> DInf _BOT) :=
    exp_fun
      (kleisli (eta << Roll) <<
       SemE << (Id >< Unroll)).

  Definition VInfToFun :
      VInf -=> (DInf -=> DInf _BOT) _BOT :=
    [| [| const _ PBot, eta |] , const _ PBot |].

  Definition AppOp {E : Env}
      (d1 : SemEnv E =-> VInf _BOT)
      (d2 : SemEnv E =-> VInf _BOT) :
      SemEnv E =-> VInf _BOT :=
    kleisli ((KLEISLI (eta << Unroll)) << (KLEISLIL ev) <<
      <| VInfToFun << pi1 (A := VInf) (B := VInf),
         Roll << pi2 (A := VInf) (B := VInf) |>) <<
    uncurry (Smash VInf VInf) << <| d1, d2 |>.

  Reserved Notation "⟦ t '⟧'" (at level 1, no associativity).

  Fixpoint SemT E (t : Term E) : SemEnv E =-> VInf _BOT :=
    match t return SemEnv E =-> VInf _BOT with
    | VAR m     => eta << SemVar m
    | FUN e     => eta << inFun << (F ⟦ e ⟧)
    | APP t1 t2 => AppOp ⟦ t1 ⟧ ⟦ t2 ⟧
    end
  where "⟦ t ⟧" := (SemT t).
  ```

  === Reificación

  Para cada entorno no vacío, `DVar` convierte un natural en una variable de de
  Bruijn. Los índices fuera del entorno se saturan en la variable más reciente;
  en los demás casos se construye la cantidad correspondiente de sucesores.
  `FVar` compone esta operación con el constructor de términos.

  ```rocq
  Canonical Structure expr (E : Env) :=
    Eval hnf in discrete_cpoType (Term E).

  Definition DVAR (E : Env) :
      discrete_cpoType (Var E) =-> discrete_cpoType (Term E).
    apply SimpleUOp.
    apply VAR.
  Defined.

  Definition DFUN (E : Env) :
      discrete_cpoType (Term E.+1) =-> discrete_cpoType (Term E).
    apply SimpleUOp.
    apply FUN.
  Defined.

  Fixpoint DVar (E : Env) : nat_cpoType -> Var (S E) :=
    match E with
    | O => fun n => ZVAR O
    | S E' => fun n =>
        match Coq.Init.Nat.leb (S E') n with
        | true  => ZVAR (S E')
        | false => SVAR (DVar E' n)
        end
    end.

  Definition DVARc (E : Env) :
      nat_cpoType =-> discrete_cpoType (Var (S E)).
    apply SimpleUOp.
    apply DVar.
  Defined.

  Definition FVar (E : Env) :
      nat_cpoType =-> discrete_cpoType (Term (S E)) :=
    DVAR E.+1 << DVARc E.
  ```

  Al reificar una función se introduce una variable fresca. `RecUpe` debilita
  el término reificado antes de construir la abstracción, preservando así los
  índices de las variables que ya estaban en alcance.

  ```rocq
  Fixpoint RecV (E : Env) (v : Var E) : Var E.+1 :=
    match v in Var E' return Var E'.+1 with
    | ZVAR E'   => ZVAR (E'.+1)
    | SVAR E' x => @SVAR (E'.+1) (@RecV E' x)
    end.

  Definition RecUpe (E : Env) : Term E -> Term E.+1 :=
    renT (@RecV E).

  Definition RecUp (E : Env) :
      discrete_cpoType (Term E) =->
      discrete_cpoType (Term E.+1).
    apply SimpleUOp.
    apply RecUpe.
  Defined.
  ```

  Los casos funcional y de aplicación implementan, respectivamente, las dos
  primeras ecuaciones de la Definición 2 de la @cap-reificacion. En `FunCase`,
  la función semántica se aplica a la variable fresca `inNat E`; en `AppCase`,
  ambos componentes se reifican y luego se combinan mediante `APP`.

  ```rocq
  Definition FunCase (E : Env) :
      (VInf -=> discrete_cpoType (Term E.+1) _BOT) *
      (DInf -=> DInf _BOT) =->
      discrete_cpoType (Term E.+1) _BOT.
    refine (ccomp _ _).
    Focus 2.
    refine (PROD_fun _ _).
    apply pi1.
    apply (kleisli (eta << Unroll) << ev <<
      <| pi2 (A := VInf -=> discrete_cpoType (Term E.+1) _BOT),
         const _ (Roll (inNat E)) |>).
    refine (ccomp _ _).
    apply (kleisli (eta << DFUN E.+1)).
    refine (ccomp _ _).
    apply (kleisli (eta << RecUp (E.+1))).
    refine (ccomp _ _).
    apply (ev (A := VInf _BOT)
              (B := discrete_cpoType (Term E.+1) _BOT)).
    refine (PROD_fun _ _).
    apply (KLEISLI << pi1 (B := VInf _BOT)).
    apply (pi2 (A := VInf -=>
      discrete_cpoType (Term E.+1) _BOT)).
  Defined.

  Definition DAPP (E : Env) :
      (discrete_cpoType (Term E) * discrete_cpoType (Term E)) =->
      discrete_cpoType (Term E).
    apply (SimpleBOp (A := Term E) (B := Term E)
                     (C := discrete_cpoType (Term E))).
    apply (@APP E).
  Defined.

  Definition AppCase (E : Env) :
      (VInf -=> discrete_cpoType (Term E.+1) _BOT) *
      (DInf * DInf) =->
      discrete_cpoType (Term E.+1) _BOT.
    refine (ccomp _ _).
    apply (kleisli (eta << DAPP E.+1)).
    refine (ccomp _ _).
    apply (uncurry (Smash
      (discrete_cpoType (Term E.+1))
      (discrete_cpoType (Term E.+1)))).
    refine (PROD_fun _ _).
    refine (ccomp _ _).
    apply (ev (A := VInf _BOT)
              (B := discrete_cpoType (Term E.+1) _BOT)).
    refine (PROD_fun _ _).
    apply (KLEISLI << pi1 (B := DInf * DInf)).
    apply (eta << Unroll << pi1 << pi2).
    refine (ccomp _ _).
    apply (ev (A := VInf _BOT)
              (B := discrete_cpoType (Term E.+1) _BOT)).
    refine (PROD_fun _ _).
    apply (KLEISLI << pi1 (B := DInf * DInf)).
    apply (eta << Unroll << pi2 << pi2).
  Defined.
  ```

  Para reunir esos casos se usa el morfismo distributivo `dist`, que transforma
  un producto con una suma en una suma de productos.

  ```rocq
  Definition dist {A B C : cpoType} :
      (A * (B + C)) =-> ((A * B) + (A * C)).
    assert (H : (B + C) =-> (A -=> ((A * B) + (A * C)))).
    refine (SUM_fun _ _).
    apply (CURRY (D0 := B)).
    refine (ccomp _ _). apply (in1 (A := A * B)).
    refine (PROD_fun _ _). apply pi2. apply pi1.
    apply (CURRY (D0 := C)).
    refine (ccomp _ _). apply (in2 (B := A * C)).
    refine (PROD_fun _ _). apply pi2. apply pi1.
    apply ((UNCURRY H) << <| pi2, pi1 |>).
  Defined.
  ```

  Finalmente, `Rrec` reúne mediante coproductos los casos de variable, función y
  aplicación. La función `R` es el menor punto fijo de ese funcional; no existen
  términos cerrados en el lenguaje considerado, por lo que para el entorno vacío
  la reificación es siempre indefinida.

  ```rocq
  Definition Rrec (E : Env) :
      (VInf -=> discrete_cpoType (Term (S E)) _BOT) =->
      (VInf -=> discrete_cpoType (Term (S E)) _BOT).
  Proof.
    refine (exp_fun _).
    refine (ccomp _ _).
    Focus 2.
    apply dist.
    refine (ccomp _ _).
    Focus 2.
    refine (SUM_fun _ _).
    refine (ccomp _ _).
    apply (in1 (B :=
      (VInf -=> discrete_cpoType (Term (S E)) _BOT) *
      (DInf * DInf))).
    apply dist.
    apply in2.
    refine (SUM_fun (SUM_fun _ _) _).
    apply (eta << FVar E << pi2).
    apply FunCase.
    apply AppCase.
  Defined.

  Definition R (E : Env) :
      VInf =-> discrete_cpoType (Term E) _BOT :=
    match E with
    | O   => const _ PBot
    | S E => fixp (Rrec E)
    end.
  ```

// =============================================================================
// CAPÍTULO 5 — Conclusión
// =============================================================================
= Conclusión
<cap-conclusion>

// =============================================================================
// CAPÍTULO 6 — Referencias
// =============================================================================
= Referencias
<cap-referencias>

#set heading(numbering: none)

#bibliography("refs.bib", style: "ieee", title: none)
