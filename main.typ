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

Definimos el lenguaje en etapas. Primero presentamos la *sintaxis* de los
términos, todavía sin tipos, y el mecanismo de *sustitución* que les da su
comportamiento operativo. Luego damos una *semántica denotacional* para ese
cálculo sin tipos, siguiendo el enfoque de Reynolds @reynolds1998theories, que
explica por qué la auto-aplicación es problemática y cómo un dominio resuelve la
dificultad. Recién después introducimos el *sistema de tipos* y la *igualdad*
entre términos tipados, y cerramos el capítulo mostrando cómo se interpretan los
tipos en el mundo semántico. A lo largo del capítulo seguimos, en lo esencial,
las definiciones formalizadas en Rocq (capítulo @cap-rocq).

== Sintaxis del cálculo lambda
<sec-sintaxis>

Los términos del cálculo lambda se construyen con tres operaciones. Una
*variable* es una referencia a una suposición ya hecha; una *abstracción*
$lambda t$ introduce una suposición nueva y la deja disponible en el término
$t$; una *aplicación* $"App" t space r$ usa $t$ como función y $r$ como
argumento. No hay nada más: todo programa de este lenguaje es una combinación
finita de estas tres piezas.

=== Variables sin nombre

En el cálculo lambda habitual las variables tienen nombre y la identidad se
escribe $lambda x.x$: la variable $x$ está *ligada* por el $lambda$ y cada
ocurrencia suya se refiere a ese ligador. En este trabajo usamos una
representación *sin nombres*, los llamados índices de de Bruijn
@barendregt1984lambda, que es la que resulta natural a la hora de formalizar el
lenguaje en Rocq.

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
La aplicación de la identidad a sí misma se escribe $"App" (lambda sans("q")) (lambda sans("q"))$.

La sintaxis abstracta de los términos queda resumida en la gramática

$ "Term" in.rev t ::= sans("q") sans("p")^i | lambda t | "App" t space t $

donde $i$ recorre los números naturales: la primera alternativa son las
variables, la segunda las abstracciones y la tercera las aplicaciones.

=== Lo que sale mal sin tipos

Sin tipos, nada impide escribir una función que se aplica a sí misma. Sea
$Delta = lambda ("App" sans("q") sans("q"))$, es decir, la función $lambda x. x space x$. Es un
término perfectamente válido desde el punto de vista sintáctico. El problema
aparece al *usarlo*: el término

$ Omega = "App" space Delta space Delta = "App" (lambda ("App" sans("q") sans("q"))) (lambda ("App" sans("q") sans("q"))) $

se reduce a sí mismo. En efecto, aplicar $Delta$ a $Delta$ consiste en
reemplazar cada $sans("q")$ de su cuerpo por el argumento $Delta$, y volvemos a
obtener exactamente $Omega$. El cálculo no termina: $Omega$ es un programa que
gira para siempre sin producir ningún resultado.

No se trata de un detalle menor. Veremos en la @sec-semantica-denotacional que
la auto-aplicación es la fuente de una paradoja análoga a la de Russell, y que
darle un significado matemático a un lenguaje que la permite obliga a salir de
la teoría de conjuntos ingenua. El sistema de tipos de la @sec-tipos resuelve el
problema de otra manera: simplemente rechaza términos como $Delta$.

== Sustituciones
<sec-sustituciones>

Calcular con el cálculo lambda es sustituir. La regla que define la aplicación,
la llamada *beta-reducción*, dice que $"App" (lambda t) space r$ se reduce a $t$
con cada ocurrencia de $sans("q")$ reemplazada por $r$; escribiremos ese
resultado $t space (id, r)$, anticipando la notación de sustituciones explícitas
que introducimos enseguida.

Una *sustitución* $sigma$ es una asignación de términos a variables: a la
variable $i$-ésima le corresponde un término $sigma_i$. Aplicar $sigma$ a un
término $t$, escrito $t space sigma$, reemplaza cada variable libre de $t$ por su
imagen según $sigma$. La sustitución identidad $id$ deja cada variable como
está.

La única dificultad técnica es que las variables libres deben "levantarse" cuando
la sustitución atraviesa un ligador. Si queremos sustituir dentro de $lambda t$,
las variables libres de $t$ se refieren a ligadores que están *afuera* del
$lambda$; al aplicar $sigma$ bajo el ligador, esos índices deben desplazarse una
posición para no quedar capturados por el nuevo ligador. Esta operación de
*debilitamiento* es el $sans("p")$ que ya conocemos, y en Rocq corresponde al
renombrado y al operador de *lifting* de sustituciones.

La sustitución de una sola variable es un caso particular: $t space (id, r)$ es la
sustitución que manda $sans("q")$ a $r$ y a cada $sans("q") sans("p")^(i+1)$ a $sans("q") sans("p")^i$.
Por ejemplo, $"App" (lambda sans("q")) space r$ se reduce a $sans("q") space (id, r) = r$: la
identidad aplicada a $r$ da $r$.

Las sustituciones se componen, y la composición es asociativa y tiene a la
identidad como elemento neutro. Estas leyes, junto con las reglas de beta y eta
que presentamos en la @sec-igualdad, forman la teoría ecuacional del lenguaje.
No detallamos aquí todas las ecuaciones; las necesarias para razonar sobre los
programas se concentran en esa sección.

== Semántica denotacional
<sec-semantica-denotacional>

Damos ahora un significado matemático a los términos del cálculo *sin tipos*.
La intuición es directa: una aplicación debería denotar la aplicación de una
función a un argumento, y una abstracción debería denotar una función. La
dificultad es que, sin tipos, esta intuición choca con una paradoja.

Supongamos que existe un conjunto $S$ de valores tal que toda función de $S$ en
$S$ es a su vez un valor, es decir, tal que $S arrow S subset.eq S$. Entonces toda
función $f in S arrow S$ tiene un punto fijo: tomamos una función $p in S arrow S$
cualquiera que cumpla $p space x = f space (x space x)$ y observamos que
$p space p = f space (p space p)$. Pero si $S$ tiene al menos dos elementos, hay
funciones $S arrow S$ sin punto fijo (por ejemplo, la que intercambia dos
elementos). Contradicción @reynolds1998theories.

El cálculo lambda puede *escribir* esta paradoja. Si la función $f$ está denotada
por un término $e$, el término $lambda ("App" e space ("App" sans("q") sans("q")))$ denota la
función $p$, y por lo tanto

$ "App" (lambda ("App" e space ("App" sans("q") sans("q")))) (lambda ("App" e space ("App" sans("q") sans("q")))) $

denota un punto fijo de $f$. En particular $Omega$ (de la @sec-sintaxis) es el
caso en que $f$ es la identidad: el cálculo produce, para cada función, un punto
fijo.

La solución de Scott @scott1971continuous consiste en no pedir $S arrow S subset.eq S$ sobre
conjuntos arbitrarios, sino restringirse a funciones *continuas* sobre un
*dominio*. Se demuestra que existe un dominio no trivial $D$ que es isomorfo al
dominio de sus funciones continuas en sí mismo; es decir, un dominio que resuelve
la ecuación

#math.equation(block: true, numbering: "(2.1)", $ D ≈ [D arrow D] ; $)

donde $[D arrow D]$ es el dominio de las funciones continuas de $D$ en $D$. Como
toda función continua sobre un dominio tiene un punto fijo, la paradoja
desaparece: ya no se puede fabricar una función sin punto fijo.

El isomorfismo (2.1) nos da dos funciones mutuamente inversas que iremos usando:
una inyección $"lam" : [D arrow D] arrow D$ que convierte una función continua en un
valor, y una proyección $phi : D arrow [D arrow D]$ que hace el camino de vuelta. Con
ellas definimos la aplicación en $D$ como $d · e = (phi space d) space e$.

El significado de un término depende de los valores de sus variables libres. Un
*entorno* $eta$ asigna a cada variable un valor de $D$. Interpretamos entonces
cada término como una función que, dado un entorno, produce un valor:

$ [| sans("q") sans("p")^i |] space eta = eta (i) $

$ [| "App" t space r |] space eta = phi ([|t|] space eta) ([|r|] space eta) $

$ [| lambda t |] space eta = "lam" (a ↦ [|t|] space (eta, a)) . $

La primera ecuación dice que una variable denota lo que el entorno le asigna.
La segunda interpreta una aplicación: se le aplica $phi$ al valor denotado por
$t$ para obtener una función, y esa función se aplica al valor denotado por $r$.
La tercera interpreta una abstracción
como la función que a cada $a$ le asigna el valor de $t$ en el entorno extendido
con $a$ en la primera posición.

== Sistema de tipos
<sec-tipos>

El sistema de tipos del lenguaje, que llamamos lambda_flechita, rechaza términos
como $Delta$ asignando un *tipo* a cada término bien formado. La gramática
abstracta de los tipos es

$ "Type" in.rev A, B ::= ★ | A arrow B $

es decir, un tipo es el tipo unitario $★$ o un espacio de funciones $A arrow B$.

Un *contexto* $Gamma$ es una lista de tipos que registra las suposiciones en
alcance. El contexto vacío se denota $diamond.small$, y extender $Gamma$ con una
suposición de tipo $A$ se escribe $Gamma .A$. Como las variables son índices de
de Bruijn, no hace falta nombrarlas: la suposición más reciente es la primera del
contexto, y $sans("q") sans("p")^i$ se refiere al tipo en la posición $i$.

El juicio $Gamma tack.r t : A$ dice que $t$ tiene tipo $A$ en el contexto $Gamma$.
Sus reglas son tres y se muestran en la @intro_terms.

#figure(
  grid(
    columns: (1fr, 1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    [
      #smallcaps("(var)")
      $ frac(, Gamma .A tack.r sans("q") : A) $
    ],
    [
      #smallcaps("(abs)")
      $ frac(Gamma .A tack.r t : B, Gamma tack.r lambda t : A arrow B) $
    ],
    [
      #smallcaps("(app)")
      $ frac(Gamma tack.r t : A arrow B quad Gamma tack.r r : A, Gamma tack.r "App" t space r : B) $
    ],
  ),
  caption: [Reglas de tipado de lambda_flechita.]
)<intro_terms>

La regla #smallcaps("(var)") tipa la variable más reciente con el tipo de la
última suposición. La regla #smallcaps("(abs)") dice que si el cuerpo de una
abstracción tiene tipo $B$ bajo una suposición extra de tipo $A$, entonces la
abstracción tiene tipo $A arrow B$. La regla #smallcaps("(app)") exige que la
función tenga tipo $A arrow B$ y el argumento tipo $A$, y da tipo $B$ al
resultado.

La identidad es tipable con cualquier tipo: $diamond.small tack.r lambda sans("q") : ★ arrow ★$
(la regla #smallcaps("(abs)") con $A = B = ★$ y la regla #smallcaps("(var)")).
En cambio $Delta = lambda ("App" sans("q") sans("q"))$ no es tipable: para aplicar $sans("q")$ a
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
          Gamma tack.r "App" (lambda t) space r = t space (id_Gamma, r) : B
        ) $
    ],
    [
      #smallcaps("(eta)")
      $ frac(
          Gamma tack.r t : A arrow B,
          Gamma tack.r lambda ("App" (t sans("p")) sans("q")) = t : A arrow B
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
      $ frac(Gamma tack.r t = t' : A arrow B quad Gamma tack.r r = r' : A, Gamma tack.r "App" t space r = "App" t' space r' : B) $
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

== Semántica del sistema tipado
<sec-semantica-tipada>

Para cerrar el capítulo, extendemos la semántica denotacional a los términos
*tipados*. La idea es interpretar cada tipo $A$ como un conjunto $[|A|] subset.eq D$ de
valores "bien comportados" y comprobar que todo término bien tipado denota, para
entornos apropiados, un valor dentro de la interpretación de su tipo.

$ [|★|] = 1 $

$ [|A arrow B|] = { d in D | d · e in [|B|] "para todo" e in [|A|] } $

El tipo unitario $★$ se interpreta como el objeto terminal $1$ (un único valor),
y el tipo función $A arrow B$ como el conjunto de valores $d$ que, aplicados a
cualquier elemento de $[|A|]$, producen un elemento de $[|B|]$. En otras palabras,
$[|A arrow B|]$ es el conjunto de las funciones que respetan las interpretaciones.

Un contexto $Gamma = A_1 . A_2 . . . . A_n$ se interpreta como el producto
$[|Gamma|] = [|A_1|] times ... times [|A_n|]$: un entorno semántico asigna a cada
variable un valor del tipo correspondiente. Se demuestra por inducción sobre las
derivaciones que la interpretación es *sólida*:

_Solidez._ Si $Gamma tack.r t : A$, entonces $[|t|] space eta in [|A|]$ para todo
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
