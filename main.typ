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

En la introducción dijimos que definir un lenguaje es especificar su sintaxis y
su semántica. Este capítulo hace eso para el cálculo lambda, que llamamos
lambda_flechita una vez que le ponemos tipos. Primero damos la *sintaxis* de los
términos y el mecanismo de *sustitución* que los hace funcionar. Después buscamos
un *significado* para los programas, para lo cual necesitaremos una estructura
matemática particular —la semántica denotacional, siguiendo a Reynolds
@reynolds1998theories—. Recién entonces introducimos el *sistema de tipos* y la
*igualdad* entre términos tipados, y cerramos viendo cómo se interpretan los
tipos.

== Sintaxis del cálculo lambda
<sec-sintaxis>

Los términos del cálculo lambda se construyen con tres operaciones. Una
*variable* sirve para referirnos a un valor. Una *abstracción* $lambda x. t$ es
una función sin nombre, con parámetro $x$ y cuerpo $t$. Y una *aplicación*
$t space @ space r$ usa $t$ como función y $r$ como argumento. No hay nada más: todo
programa de este lenguaje se arma combinando estas tres piezas. Con tan poco se
puede expresar mucho: como muestra Reynolds @reynolds1998theories, con el cálculo
lambda se pueden construir los números naturales, los booleanos y sus operaciones.

=== Variables sin nombre

En el cálculo lambda habitual las variables tienen nombre. Consideremos la
identidad $lambda x. x$: la $x$ está *ligada* —la introduce el $lambda$— y cada
ocurrencia suya en el cuerpo se refiere a ese ligador. Es la misma idea que los
parámetros de una función en un lenguaje de programación. Para evaluar
$(lambda x. x) space 0$ hay que ejecutar el cuerpo $x$ recordando que $x$ está ligada al
valor $0$; ese "recuerdo" —la asignación de valores a las variables— es lo que
llamaremos *contexto* (o entorno). El resultado es $0$.

El problema aparece cuando una variable libre se cruza con un ligador. Evaluemos
$(lambda x. lambda y. x) space y$: la $y$ del argumento viene de afuera, es libre, mientras que
la $x$ del cuerpo está ligada por el $lambda x$ más externo. Al reemplazar $x$ por $y$ en el
cuerpo $lambda y. x$ obtenemos $lambda y. y$, que ya no es lo que queríamos: la $y$ libre
quedó *capturada* por el $lambda y$ interior. Lo correcto es renombrar la ligadura y
obtener, por ejemplo, $lambda z. y$. Evitar esta captura en cada sustitución es
engorroso.

Una representación *sin nombres* resuelve el problema de raíz: si las variables
son índices, no hay nombres que capturar. En este trabajo usamos esa
representación, los llamados índices de de Bruijn @barendregt1984lambda.

La idea es que una variable no se identifica por un nombre sino por su
*posición*: un número que indica cuántos ligadores hay que cruzar para llegar al
ligador que la introduce. Para no tener que manejar numerales, escribimos ese
número en notación unaria con dos símbolos: $sans("q")$ representa el índice $0$
(el ligador más cercano) y $sans("p")$ es el *sucesor*. Así, $sans("q")$ es la
suposición más reciente, $sans("q") sans("p")$ la anterior, $sans("q") sans("p") sans("p")$
la anterior a esa, y así sucesivamente. En definitiva, las variables se
identifican con

$ sans("q"), space sans("q") sans("p")^1, space sans("q") sans("p")^2, space . . . $

donde la notación $sans("p")^i$ denota la composición $i$ veces de $sans("p")$
consigo misma:

$ sans("p")^i = cases(
  sans(id) & "si" i = 0,
  sans("p") & "si" i = 1,
  sans("p") sans("p")^(i-1) & "si" i > 1
) $

Es decir, $sans("q") sans("p")^i$ es la variable de índice $i$, contando ligadores
desde adentro hacia afuera.

Con esta convención la identidad se escribe $lambda sans("q")$: la única
variable del cuerpo es $sans("q")$, es decir, la introducida por el único
$lambda$. La función constante $lambda x. lambda y. x$ se escribe $lambda lambda (sans("q") sans("p"))$:
aquí $sans("q") sans("p")$ mira dos ligadores hacia atrás y encuentra el primero.
La aplicación de la identidad a sí misma se escribe $(lambda sans("q")) space @ space (lambda sans("q"))$.

La sintaxis abstracta de los términos queda resumida en la gramática

$ "Term" in.rev t ::= sans("q") sans("p")^i | lambda t | t space @ space t $

donde $i$ recorre los números naturales: la primera alternativa son las
variables, la segunda las abstracciones y la tercera las aplicaciones.

== Sustituciones
<sec-sustituciones>

Para calcular con el cálculo lambda hace falta *sustituir*. Pensemos qué debería
dar la identidad aplicada a un argumento: $(lambda sans("q")) space @ space r$ debería dar $r$,
porque la identidad devuelve su argumento. En general, aplicar una abstracción
$lambda t$ a un argumento $r$ da el cuerpo $t$ con la variable $sans("q")$ reemplazada por $r$.
Formalicemos esa operación.

Una *sustitución* $sigma$ asigna un término a cada variable: a la variable
$i$-ésima le corresponde un término $sigma_i$. Aplicar $sigma$ a un término $t$,
escrito $t space sigma$, reemplaza cada variable libre de $t$ por su imagen. Las
sustituciones se construyen con cinco operaciones: la *identidad* $id$ deja cada
variable en su lugar; la sustitución *vacía* $chevron chevron.r$ no asigna nada; la *composición*
$sigma space delta$ (por yuxtaposición) encadena dos sustituciones; la *extensión* $(sigma, t)$
agrega $t$ como imagen de la variable más reciente; y $sans("p")$ es la sustitución de
*debilitamiento* (*shifting*), que desplaza en uno los índices de las variables.

Aplicar una sustitución a un término se resuelve con los axiomas de la
@intro_subterm:

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(sub-id)")
      $ frac(, t space id = t) $
    ],
    [
      #smallcaps("(sub-ass)")
      $ frac(, t space (sigma space delta) = (t space sigma) space delta) $
    ],
    [
      #smallcaps("(snd-sub)")
      $ frac(, sans("q") space (sigma, t) = t) $
    ],
    [
      #smallcaps("(abs-sub)")
      $ frac(, (lambda t) space sigma = lambda (t space (sigma space sans("p"), sans("q")))) $
    ],
    [
      #smallcaps("(app-sub)")
      $ frac(, (t space @ space r) space sigma = (t space sigma) space @ space (r space sigma)) $
    ],
  ),
  caption: [Sustitución aplicada a términos en lambda_flechita.]
)<intro_subterm>

La regla #smallcaps("(sub-id)") dice que la identidad no cambia nada, y
#smallcaps("(sub-ass)") que aplicar la composición de dos sustituciones es lo
mismo que aplicarlas una tras otra. Las otras tres describen cómo la sustitución
"atraviesa" los constructores de términos. La única sutileza está en
#smallcaps("(abs-sub)"): para sustituir dentro de una abstracción hay que hacer
*lifting* de la sustitución —componerla con $sans("p")$—, de modo que las variables
libres no queden capturadas por el nuevo ligador. En particular,
#smallcaps("(snd-sub)") dice que $sans("q")$ reemplazada con el par $(sigma, t)$ da $t$.

La sustitución de una sola variable es un caso particular: $t space (id, r)$ manda
$sans("q")$ a $r$ y a cada $sans("q") sans("p")^(i+1)$ a $sans("q") sans("p")^i$. Por ejemplo,
$(lambda sans("q")) space @ space r$ se reduce a $sans("q") space (id, r)$, y #smallcaps("(snd-sub)") da $r$: la
identidad aplicada a $r$ da $r$.

La composición de sustituciones es asociativa y tiene a la identidad como
elemento neutro; con estas leyes, las sustituciones forman una categoría de
contextos. No listamos aquí todas esas leyes: las reglas de la @intro_subterm
son las que usaremos. En la @sec-tipos les damos tipos a estas sustituciones;
en particular, el debilitamiento $sans("p")$ es lo que permite tipar las variables de índice
mayor.

== Semántica denotacional
<sec-semantica-denotacional>

Queremos darle un significado matemático a cada término. La idea natural es que
una abstracción $lambda t$ denote una *función*, y que una aplicación
$t space @ space r$ denote la *aplicación* de la función denotada por $t$ al valor
denotado por $r$. Pero esta idea choca con una dificultad.

Supongamos que hubiera un conjunto $S$ de valores con la propiedad de que toda
función de $S$ en $S$ es también un valor, es decir, tal que $S arrow S subset.eq S$. A
partir de una función $f in S arrow S$ cualquiera, definamos $p in S arrow S$ por
$p space x = f space (x space x)$. Como $p in S arrow S subset.eq S$, el propio $p$ es un valor y
podemos aplicárselo a sí misma: $p space p = f space (p space p)$. Es decir, $p space p$ es un
valor que $f$ deja fijo: si las funciones son valores, *toda* función de $S$ en
$S$ tiene un punto fijo. Pero eso es falso apenas $S$ tiene dos elementos: la
función que intercambia dos valores no deja ninguno fijo. Contradicción
@reynolds1998theories.

El cálculo lambda puede *escribir* este argumento. Si la función $f$ está denotada
por el término $e$, el término $lambda (e space @ space (sans("q") space @ space sans("q")))$ denota la
función $p$, y por lo tanto el término

$ (lambda (e space @ space (sans("q") space @ space sans("q")))) space @ space (lambda (e space @ space (sans("q") space @ space sans("q")))) $

denota $p space p$, un punto fijo de $f$. En particular, $Omega$ (de la @sec-lo-que-sale-mal) es
el caso en que $f$ es la identidad: la auto-aplicación fabrica, para cada
función, un punto fijo.

La salida, debida a Scott @scott1971continuous, es no pedir $S arrow S subset.eq S$ sobre
conjuntos arbitrarios, sino restringirnos a funciones con buenas propiedades
—las *continuas*— definidas sobre una estructura llamada *dominio*. La idea de
continuidad (que no definimos en detalle) es que la función respeta cómo se van
aproximando las computaciones: los valores de un dominio llevan un orden de
información, y una función continua respeta ese orden y los límites de cadenas.
Con esta restricción se puede construir un dominio no trivial $D$ que es isomorfo
al dominio de sus funciones continuas en sí mismo; es decir, un dominio que
resuelve la ecuación

#math.equation(block: true, numbering: "(2.1)", $ D ≈ [D arrow D] ; $)

donde $[D arrow D]$ es el dominio de las funciones continuas de $D$ en $D$. La
clave es que toda función continua sobre un dominio *sí* tiene un punto fijo, de
modo que la paradoja desaparece.

El isomorfismo (2.1) nos da dos funciones mutuamente inversas que iremos usando:
una inyección $"lam" : [D arrow D] arrow D$ que convierte una función continua en un valor, y
una proyección $phi : D arrow [D arrow D]$ que hace el camino de vuelta. Con ellas
definimos la aplicación en $D$: si $d$ es la imagen de la función $f = phi space d$,
entonces $d · e = f space e$.

Pasemos a interpretar los términos. El significado de un término depende de los
valores de sus variables libres, así que fijamos un *entorno*, una función
$eta : "Var" arrow D$ que asigna a cada variable un valor de $D$. Interpretamos cada
término como una función que, dado un entorno, produce un valor:

$ [| sans("q") sans("p")^i |] space eta = eta (i) $

$ [| t space @ space r |] space eta = phi ([|t|] space eta) ([|r|] space eta) $

$ [| lambda t |] space eta = "lam" (a ↦ [|t|] space (eta, a)) . $

Desglosemos estas ecuaciones. La primera es trivial: una variable denota lo que
el entorno le asigna. En la segunda, $[|t|] space eta$ y $[|r|] space eta$ son elementos de
$D$ (el codominio de la interpretación); $phi ([|t|] space eta)$ es la función continua que
ese valor representa, y aplicársela a $[|r|] space eta$ da el valor de la aplicación. En la
tercera, $a ↦ [|t|] space (eta, a)$ es una función de $D$ en $D$ que a cada $a in D$ le
asigna el valor de $t$ en el entorno extendido con $a$ en la primera posición, y
$"lam"$ la inyecta en $D$.

== Lo que sale mal sin tipos
<sec-lo-que-sale-mal>

Sin tipos, nada impide escribir una función que se aplica a sí misma. Sea
$Delta = lambda (sans("q") space @ space sans("q"))$, es decir, la función $lambda x. x space x$. Es un
término perfectamente válido desde el punto de vista sintáctico. El problema
aparece al *usarlo*: el término

$ Omega = Delta space @ space Delta = (lambda (sans("q") space @ space sans("q"))) space @ space (lambda (sans("q") space @ space sans("q"))) $

se reduce a sí mismo. En efecto, aplicar $Delta$ a $Delta$ consiste en
reemplazar cada $sans("q")$ de su cuerpo por el argumento $Delta$, y volvemos a
obtener exactamente $Omega$. El cálculo no termina: $Omega$ es un programa que
gira para siempre sin producir ningún resultado.

No se trata de un detalle menor. Vimos en la @sec-semantica-denotacional que la
auto-aplicación es la fuente de una paradoja análoga a la de Russell, y que darle
un significado matemático a un lenguaje que la permite obliga a salir de la
teoría de conjuntos ingenua. El sistema de tipos de la @sec-tipos resuelve el
problema de otra manera: simplemente rechaza términos como $Delta$.

== Sistema de tipos
<sec-tipos>

El sistema de tipos de lambda_flechita rechaza términos
como $Delta$ asignando un *tipo* a cada término bien formado. La gramática
abstracta de los tipos es

$ "Type" in.rev A, B ::= ★ | A arrow B $

es decir, un tipo es el tipo unitario $★$ o un espacio de funciones $A arrow B$.

¿Qué significa tipar? Intuitivamente, asignarle un tipo a cada término
guiándonos por su forma. Pensemos en la identidad $lambda sans("q")$. Su tipo, si lo
tiene, tendrá que ser una flecha $A arrow B$, porque una abstracción denota una
función. Pero, ¿cuáles son $A$ y $B$? El cuerpo es la variable $sans("q")$, que apunta
a la suposición que el propio $lambda$ introduce: el tipo del argumento $A$ queda
determinado por esa suposición, y podría ser cualquiera. Como el cuerpo *es* esa
variable, el tipo del resultado $B$ coincide con $A$; es decir, $lambda sans("q")$ tiene
tipo $A arrow A$ para cualquier tipo $A$. Lo importante es que el tipo de una
variable no está en la variable misma, sino en la suposición a la que apunta. Por
eso, para tipar hay que recordar el tipo de cada suposición en alcance, y ese
registro es el *contexto*.

El contexto es necesario precisamente para las variables libres. En
$lambda sans("q")$ no hay ninguna: el único $sans("q")$ apunta al $lambda$ que lo
liga, así que puede tiparse sin suponer nada. En cambio
$lambda ((sans("q") sans("p")) space @ space sans("q"))$ —el término $lambda x. y space x$— tiene libre a
$sans("q") sans("p")$ (la $y$), que apunta fuera del $lambda$: para tiparlo hay que
saber el tipo de $y$, y esa información solo puede venir de una suposición del
contexto.

Un *contexto* $Gamma$ es una lista de tipos que registra las suposiciones en
alcance. El contexto vacío se denota $diamond.small$, y extender $Gamma$ con una
suposición de tipo $A$ se escribe $Gamma .A$. Como las variables son índices de
de Bruijn, no hace falta nombrarlas: la suposición más reciente es la primera del
contexto, y $sans("q") sans("p")^i$ se refiere al tipo en la posición $i$.

El juicio $Gamma tack.r t : A$ dice que $t$ tiene tipo $A$ en el contexto $Gamma$, y el
juicio $Gamma tack.r sigma : Delta$ dice que $sigma$ es una *sustitución* que asigna a cada
variable de $Delta$ un término bien tipado bajo $Gamma$. Las sustituciones se forman
con las reglas de la @intro_subs:

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(id-subs)")
      $ frac(, Gamma tack.r id_Gamma : Gamma) $
    ],
    [
      #smallcaps("(empty-subs)")
      $ frac(, Gamma tack.r chevron chevron.r : diamond.small) $
    ],
    [
      #smallcaps("(comp-subs)")
      $ frac(Sigma tack.r sigma : Gamma quad Delta tack.r delta : Sigma, Delta tack.r sigma space delta : Gamma) $
    ],
    [
      #smallcaps("(ext-subs)")
      $ frac(Delta tack.r sigma : Gamma quad Delta tack.r t : A, Delta tack.r (sigma, t) : Gamma .A) $
    ],
    [
      #smallcaps("(fst-subs)")
      $ frac(, Gamma .A tack.r sans("p") : Gamma) $
    ],
  ),
  caption: [Reglas de formación de sustituciones en lambda_flechita.]
)<intro_subs>

La regla #smallcaps("(id-subs)") da la identidad; #smallcaps("(empty-subs)"), la
sustitución vacía; #smallcaps("(comp-subs)"), la composición; #smallcaps("(ext-subs)"),
la extensión; y #smallcaps("(fst-subs)"), la sustitución de debilitamiento $sans("p")$,
que desplaza en uno los índices de las variables de $Gamma$.

Las reglas de tipado de términos son cuatro y se muestran en la @intro_terms:

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(var)")
      $ frac(, Gamma .A tack.r sans("q") : A) $
    ],
    [
      #smallcaps("(subs-term)")
      $ frac(Gamma tack.r sigma : Delta quad Delta tack.r t : A, Gamma tack.r t space sigma : A) $
    ],
    [
      #smallcaps("(abs)")
      $ frac(Gamma .A tack.r t : B, Gamma tack.r lambda t : A arrow B) $
    ],
    [
      #smallcaps("(app)")
      $ frac(Gamma tack.r t : A arrow B quad Gamma tack.r r : A, Gamma tack.r t space @ space r : B) $
    ],
  ),
  caption: [Reglas de tipado de lambda_flechita.]
)<intro_terms>

La regla #smallcaps("(var)") tipa la variable más reciente $sans("q")$ con el tipo de la
última suposición, y #smallcaps("(subs-term)") permite aplicar una sustitución a un
término bien tipado. Las otras dos son las habituales: #smallcaps("(abs)") forma
una abstracción y #smallcaps("(app)") una aplicación.

Observemos que las variables de índice mayor no necesitan una regla propia. Por
#smallcaps("(fst-subs)"), $sans("p")$ es una sustitución $Gamma .A tack.r sans("p") : Gamma$, y
#smallcaps("(subs-term)") permite aplicársela a un término. En general, la variable
$sans("q") sans("p")^i$ es $sans("q")$ con la sustitución $sans("p")^i$ (la composición $i$ veces de $sans("p")$
consigo misma) aplicada.

Veamos la deducción completa del tipo de un término con una variable libre.
Para $lambda ((sans("q") sans("p")) space @ space sans("q"))$ —el término $lambda x. y space x$— bajo un
contexto con una única suposición de tipo $A arrow B$, el árbol de derivación es

#let infer(label, conclusion, premises: none) = context {
  let pw = if premises != none { measure(premises).width } else { 0pt }
  let cw = measure(conclusion).width
  let w = if pw > cw { pw } else { cw }

  let lab = smallcaps(label)
  let lw = measure(lab).width
  let lh = measure(lab).height

  let bar = box(width: w, height: lh)[
    #place(left + horizon, dx: w - 0.3em, lab)
    #align(horizon, line(length: 90%, stroke: 0.7pt))
  ]

  stack(
    dir: ttb,
    spacing: 0.5em,
    ..(if premises != none {
      (box(width: w, align(center, premises)),)
    } else {
      ()
    }),
    bar,
    box(width: w, align(center, conclusion)),
  )
}

#figure(
  align(center, infer(
    "(abs)",
    $(A arrow B) tack.r lambda ((sans("q") sans("p")) space @ space sans("q")) : A arrow B$,
    premises: infer(
      "(app)",
      $(A arrow B) .A tack.r (sans("q") sans("p")) space @ space sans("q") : B$,
      premises: stack(
        dir: ltr,
        spacing: 2em,
        infer(
          "(subs-term)",
          $(A arrow B) .A tack.r sans("q") sans("p") : A arrow B$,
          premises: stack(
            dir: ltr,
            spacing: 1.5em,
            infer("", $(A arrow B) .A tack.r sans("p") : A arrow B$),
            infer("(var)", $(A arrow B) tack.r sans("q") : A arrow B$),
          ),
        ),
        infer("(var)", $(A arrow B) .A tack.r sans("q") : A$),
      ),
    ),
  )),
  caption: [Árbol de derivación para $lambda x. y space x$.],
)

_Explicación del ejemplo paso a paso:_ la variable $sans("q")$ recibe el tipo
$A arrow B$ por #smallcaps("(var)") (es la única suposición del contexto), y se la
debilita a $sans("q") sans("p")$, la $y$, aplicándole la sustitución $sans("p")$ con
#smallcaps("(subs-term)") (y #smallcaps("(fst-subs)")). La $x$, en cambio, es la variable más
reciente y recibe el tipo $A$ por #smallcaps("(var)"). Con #smallcaps("(app)") se deduce
que $(sans("q") sans("p")) space @ space sans("q")$, es decir $y space x$, tiene tipo $B$. Finalmente,
#smallcaps("(abs)") liga la $x$: como el cuerpo tiene tipo $B$ bajo la suposición extra
$A$, la abstracción $lambda x. y space x$ tiene tipo $A arrow B$ bajo la suposición $y : A arrow B$.

La identidad es tipable con cualquier tipo: $diamond.small tack.r lambda sans("q") : ★ arrow ★$
(la regla #smallcaps("(abs)") con $A = B = ★$ y la regla #smallcaps("(var)")).
En cambio $Delta = lambda (sans("q") space @ space sans("q"))$ no es tipable: para aplicar $sans("q")$ a
$sans("q")$ haría falta que la variable tuviera, al mismo tiempo, un tipo función
$A arrow B$ y el tipo de su argumento $A$, lo que ninguna regla permite. El
sistema de tipos cumple así su cometido: los términos "problemáticos" quedan
afuera.

== Igualdad de términos
<sec-igualdad>

Dos términos tipados se consideran *iguales* según una teoría ecuacional que
codifica el comportamiento de las funciones. Las dos reglas principales son la
*beta*, que describe la aplicación, y la *eta*, que describe la extensionalidad.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(beta)")
      $ frac(
          Gamma tack.r lambda t : A arrow B quad Gamma tack.r r : A,
          Gamma tack.r (lambda t) space @ space r = t space (id_Gamma, r) : B
        ) $
    ],
    [
      #smallcaps("(eta)")
      $ frac(
          Gamma tack.r t : A arrow B,
          Gamma tack.r lambda ((t sans("p")) space @ space sans("q")) = t : A arrow B
        ) $
    ],
  ),
  caption: [Reglas de igualdad de términos en lambda_flechita.]
)

La regla #smallcaps("(beta)") dice que aplicar una abstracción a un argumento es
sustituir el argumento por la variable ligada: el lado derecho $t space (id_Gamma, r)$
es, como vimos en la @sec-sustituciones, el resultado de reemplazar $sans("q")$ por $r$
en $t$. La regla #smallcaps("(eta)") dice que toda función es igual a la
abstracción que la aplica a su argumento: dos funciones son iguales si coinciden
en todo argumento.

Sobre estas dos reglas la igualdad se cierra como una *congruencia*, con las
reglas de la @congruencia: las tres primeras hacen de ella una relación de
equivalencia, y las dos últimas la hacen compatible con los constructores.

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(refl)")
      $ frac(Gamma tack.r t : A, Gamma tack.r t = t : A) $
    ],
    [
      #smallcaps("(sym)")
      $ frac(Gamma tack.r t = r : A, Gamma tack.r r = t : A) $
    ],
    [
      #smallcaps("(trans)")
      $ frac(Gamma tack.r t = r : A quad Gamma tack.r r = s : A, Gamma tack.r t = s : A) $
    ],
    [
      #smallcaps("(cong-app)")
      $ frac(Gamma tack.r t = t' : A arrow B quad Gamma tack.r r = r' : A, Gamma tack.r t space @ space r = t' space @ space r' : B) $
    ],
    [
      #smallcaps("(cong-abs)")
      $ frac(Gamma .A tack.r t = t' : B, Gamma tack.r lambda t = lambda t' : A arrow B) $
    ],
  ),
  caption: [Reglas de congruencia de la igualdad de términos en lambda_flechita.]
)<congruencia>

Las reglas #smallcaps("(refl)"), #smallcaps("(sym)") y #smallcaps("(trans)")
dicen que la igualdad es reflexiva, simétrica y transitiva. Las reglas
#smallcaps("(cong-app)") y #smallcaps("(cong-abs)") dicen que la igualdad se
propaga por cualquier contexto: si dos funciones son iguales y dos argumentos son
iguales, sus aplicaciones son iguales; y si dos cuerpos son iguales, sus
abstracciones también. Así el lenguaje admite un razonamiento ecuacional
estándar.

Por ejemplo, la identidad aplicada a sí misma devuelve la identidad. En
$(lambda sans("q")) space @ space (lambda sans("q"))$, el $lambda sans("q")$ de la izquierda tiene tipo
$(★ arrow ★) arrow (★ arrow ★)$, y el de la derecha, al igual que el resultado, tipo $★ arrow ★$.
La regla #smallcaps("(beta)") aplicada a esta redex da la igualdad
$(lambda sans("q")) space @ space (lambda sans("q")) = sans("q") space (id_diamond.small, lambda sans("q"))$, y
#smallcaps("(snd-sub)") de la @sec-sustituciones da $sans("q") space (id_diamond.small, lambda sans("q")) = lambda sans("q")$.
Reuniendo ambos pasos con #smallcaps("(trans)"):

#figure(
  align(center, infer(
    "(trans)",
    $diamond.small tack.r (lambda sans("q")) space @ space (lambda sans("q")) = lambda sans("q") : ★ arrow ★$,
    premises: stack(
      dir: ltr,
      spacing: 2em,
      infer(
        "(beta)",
        $diamond.small tack.r (lambda sans("q")) space @ space (lambda sans("q")) = sans("q") space (id_diamond.small, lambda sans("q")) : ★ arrow ★$,
      ),
      infer(
        "(snd-sub)",
        $diamond.small tack.r sans("q") space (id_diamond.small, lambda sans("q")) = lambda sans("q") : ★ arrow ★$,
      ),
    ),
  )),
  caption: [La identidad aplicada a sí misma es la identidad.],
)

El paso #smallcaps("(snd-sub)") es la resolución de la sustitución de la
@sec-sustituciones: la sustitución $(id_diamond.small, lambda sans("q"))$ envía la variable $sans("q")$ al
término $lambda sans("q")$.

== Semántica del sistema tipado
<sec-semantica-tipada>

Para cerrar el capítulo, extendemos la semántica denotacional a los términos
*tipados*. La idea es interpretar cada tipo $A$ como un conjunto $[|A|] subset.eq D$ de
valores "bien comportados" y comprobar que todo término bien tipado denota, para
entornos apropiados, un valor dentro de la interpretación de su tipo.

$ [|★|] = {★} $

$ [|A arrow B|] = { d in D | d · e in [|B|] "para todo" e in [|A|] } $

El tipo unitario $★$ se interpreta como el conjunto $ {★} $, de un único elemento,
y el tipo función $A arrow B$ como el conjunto de valores $d$ que, aplicados a
cualquier elemento de $[|A|]$, producen un elemento de $[|B|]$. En otras palabras,
$[|A arrow B|]$ es el conjunto de las funciones que respetan las interpretaciones.

Un contexto $Gamma = A_1 . A_2 . . . . A_n$ se interpreta como el producto
$[|Gamma|] = [|A_1|] times ... times [|A_n|]$: un entorno semántico asigna a cada
variable un valor del tipo correspondiente. La corrección de la interpretación se
establece por inducción sobre las derivaciones de tipado:

_Lema (Solidez)._ Si $Gamma tack.r t : A$, entonces $[|t|] space eta in [|A|]$ para todo
entorno $eta in [|Gamma|]$.

Es decir, el sistema de tipos garantiza que un programa bien tipado nunca sale de
la interpretación de su tipo, sin importar cómo se instancien sus variables. Hay
una sutileza que conviene señalar: una *variable* de tipo función debe denotar
una función, y no un valor atómico. Resolver esto —interpretar cada variable con
la expansión adecuada a su tipo— es parte del trabajo del capítulo
@cap-reificacion, donde además la reificación devuelve el término de vuelta a la
sintaxis.

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

Caracterizamos el conjunto de términos en forma normal. La forma de
las formas normales, en el contexto del cálculo lambda no tipado con variables nombradas,
es $λ x_1 .λ x_2 . . . . λ x_n .(. . . ((y space t_1) space t_2) . . .) space t_m$,
donde $m ⩾ 0, n ⩾ 0$, y cada $t_i$ tiene también esa forma; es fácil ver que la siguiente
gramática captura esos términos.

$ "Ne" in.rev k ::= x | k space @ space v $
$ "Nf" in.rev v ::= lambda x.v | k . $

Después de reemplazar variables indexadas por variables nombradas en esa gramática
llegamos a la definición de formas normales y términos neutrales.

_Definición_ 1 (Términos neutrales y formas normales).

$ "Ne" in.rev k ::= sans("q") | sans("q") sans("p")^(i+1) | k space @ space v $
$ "Nf" in.rev v ::= lambda x.v | k . $

=== Qué significa normalizar
<sec-normalizar>

Normalizar un término es reducirlo a *forma normal*: aplicar reducciones hasta
que ya no quede ningún redex. Un *redex* es una subexpresión de la forma
$(lambda t) space @ space r$, y contraerla consiste en reemplazarla por $t space (id, r)$, el
cuerpo $t$ con la variable $sans("q")$ sustituida por el argumento $r$; esta es la regla
beta de la @sec-igualdad. Escribimos $t arrow.long.r t'$ cuando $t'$ se obtiene de $t$ contrayendo
uno de sus redex.

Por ejemplo, la identidad aplicada a sí misma se reduce en un paso a la
identidad:

$ (lambda sans("q")) space @ space (lambda sans("q")) space arrow.long.r space sans("q") space (id, lambda sans("q")) = lambda sans("q") . $

El resultado no tiene redex: según la Definición 1 es una forma normal. No todo
término alcanza una: el término $Omega$ de la @sec-lo-que-sale-mal se reduce a sí mismo y
nunca llega a una forma normal.

Normalizar sirve para decidir la igualdad. La reducción es *confluente*: si un
término alcanza una forma normal, esta es única, con independencia del orden en
que se contraigan los redex. Por lo tanto, dos términos son iguales en la teoría
de la @sec-igualdad exactamente cuando se reducen a la misma forma normal; así, un
procedimiento que produzca formas normales es un procedimiento que decide
igualdades.

El procedimiento que acabamos de describir es *sintáctico*: mueve símbolos
aplicando una regla de reescritura. El resto del capítulo describe una manera
*semántica* de obtener la forma normal —la normalización por evaluación— que
explota la semántica denotacional del capítulo @cap-definicion.

=== Un modelo adecuado para NbE

Nuestro modelo para la normalización se basa en un dominio [@abramsky1994handbook, @scott1971continuous, @smth1982category] procedente de la
solución D de la siguiente ecuación de dominios

#math.equation(block: true, numbering: "(3.1)", $ D ≈ [D → D] ⊕ "Nat"_⊥ ⊕ D × D ; $)

En el capítulo @cap-definicion usamos el dominio $D ≈ [D arrow D]$, en el que todo
valor es una función. Eso basta para *evaluar*: una variable denota lo que el
entorno le asigna y una aplicación denota la aplicación de una función. Pero no
basta para *reificar*, es decir, para volver de la semántica a la sintaxis. Para
leer de vuelta un valor como término necesitamos distinguir en el dominio dos
clases de objetos que $[D arrow D]$ no puede representar: las *variables* y las
*aplicaciones neutrales*.

Una variable, como $sans("q")$, es un átomo que no es una función; para reificarla
hay que poder reconocerla como tal. Reservamos entonces un componente plano de
naturales $"Nat"_⊥$, cuyos elementos escribimos $"Var" space i$ y representan la variable
de índice $i$. Una aplicación neutral —un término que no es una abstracción pero
tampoco se reduce, como una variable aplicada a argumentos— tampoco es una
función; la representamos con un par $"App" space d space d'$, que da el componente $D times D$.
Todo elemento de $D$ que no es $bot$ pertenece a alguno de estos componentes;
escribimos

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
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

$ R_j ("App" d d') = (R_j d) space @ space (R_j d') $
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
