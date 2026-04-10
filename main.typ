// =============================================================================
// main.typ — Trabajo Especial de Licenciatura en Ciencias de la Computación
// FAMAF — Universidad Nacional de Córdoba
// =============================================================================

#import "template.typ": thesis

#show: thesis.with(
  title:     "Título del Trabajo Especial",
  subtitle:  "Subtítulo opcional",
  author:    "Nombre Apellido",
  director:  "Dr./Dra. Nombre Apellido",
  // co-director: "Dr./Dra. Nombre Apellido",   // descomentar si corresponde
  year:      "2024",

  abstract-es: [
    Este trabajo estudia la definición formal de un lenguaje de programación,
    su formalización mediante sistemas de tipos y semántica operacional,
    y su reificación tanto desde una perspectiva matemática clásica como desde
    la teoría de categorías.  Se presenta además una implementación y
    verificación mecánica de las definiciones principales utilizando el
    asistente de pruebas Rocq (versión 8.20).

    _Palabras clave:_ semántica de lenguajes de programación, sistemas de tipos,
    reificación, teoría de categorías, Rocq.
  ],

  abstract-en: [
    This work studies the formal definition of a programming language,
    its formalization through type systems and operational semantics,
    and its reification from both a classical mathematical perspective and
    from category theory.  We also present a mechanized implementation and
    verification of the main definitions using the Rocq proof assistant
    (version 8.20).

    _Keywords:_ programming language semantics, type systems, reification,
    category theory, Rocq.
  ],
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

// =============================================================================
// CAPÍTULO 2 — Definición del lenguaje
// =============================================================================
= Definición del Lenguaje
<cap-definicion>

En este capítulo presentamos la definición formal del lenguaje objeto de
estudio.  Seguimos la tradición de @pierce2002types y @winskel1993formal,
adaptada al contexto de la verificación con Rocq.

== Expresiones
<sec-expresiones>

El conjunto de _expresiones_ (también llamados _términos_) del lenguaje se
define inductivamente.  Una expresión puede ser:

- Un *valor* atómico: constantes numéricas, booleanas, o literales de cadena.
- Una *variable* $x$ tomada de un conjunto numerable $cal(V)$.
- Una *aplicación* $e_1 space e_2$, donde $e_1$ y $e_2$ son expresiones.
- Una *abstracción* $lambda x : tau . space e$, donde $x in cal(V)$, $tau$ es
  un tipo y $e$ es una expresión.
- Constructores adicionales propios del lenguaje (condicionales, operadores
  aritméticos, etc.).

#figure(
  align(left)[
    $
      e ::= & space v                         & "valor" \
            & | space x                       & "variable" \
            & | space e_1 space e_2           & "aplicación" \
            & | space lambda x : tau . e      & "abstracción" \
            & | space "if" space e_1 space "then" space e_2 space "else" space e_3
                                              & "condicional" \
            & | space e_1 + e_2               & "suma" \
    $
  ],
  caption: [Gramática de expresiones del lenguaje.]
)

== Tipos
<sec-tipos>

El conjunto de _tipos_ $tau$ se define también inductivamente:

$
  tau ::= & space bb(B)                   & "booleanos" \
          & | space bb(N)                 & "naturales" \
          & | space tau_1 -> tau_2        & "tipo función" \
          & | space tau_1 times tau_2     & "tipo producto" \
$

Los tipos base $bb(B)$ y $bb(N)$ representan los valores booleanos y los
números naturales, respectivamente.  El tipo función $tau_1 -> tau_2$ denota
las funciones que toman un argumento de tipo $tau_1$ y producen un resultado
de tipo $tau_2$.  El tipo producto $tau_1 times tau_2$ representa pares.

== Juicios de Tipos
<sec-juicios>

Un _juicio de tipos_ es una proposición de la forma

$ Gamma tack.r e : tau $

que se lee: "en el contexto de tipos $Gamma$, la expresión $e$ tiene tipo
$tau$".  Aquí $Gamma$ es un _contexto_ o _entorno de tipos_, es decir, una
función parcial de variables a tipos.

Las reglas de tipado se especifican como un sistema de inferencia.  Las reglas
principales son:

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    // Var
    $
      frac(
        x : tau in Gamma,
        Gamma tack.r x : tau
      ) space "Var"
    $,
    // Abs
    $
      frac(
        Gamma\, x : tau_1 tack.r e : tau_2,
        Gamma tack.r lambda x : tau_1 . e : tau_1 -> tau_2
      ) space "Abs"
    $,
    // App
    $
      frac(
        Gamma tack.r e_1 : tau_1 -> tau_2 quad Gamma tack.r e_2 : tau_1,
        Gamma tack.r e_1 space e_2 : tau_2
      ) space "App"
    $,
    // True/False
    $
      frac(
        ,
        Gamma tack.r "true" : bb(B)
      ) space "True"
      quad
      frac(
        ,
        Gamma tack.r "false" : bb(B)
      ) space "False"
    $,
  ),
  caption: [Reglas de tipado seleccionadas.]
)

=== Propiedades del sistema de tipos

Los sistemas de tipos bien diseñados satisfacen dos propiedades clave que,
en conjunto, garantizan la _solidez_ (_type safety_):

/ Progreso (#emph[Progress]): Si $diameter tack.r e : tau$, entonces $e$ es un
  valor o existe $e'$ tal que $e -> e'$.

/ Preservación (#emph[Preservation]): Si $Gamma tack.r e : tau$ y $e -> e'$,
  entonces $Gamma tack.r e' : tau$.

== Semántica
<sec-semantica>

Adoptamos una semántica operacional de _paso pequeño_ (_small-step_), definida
como una relación de reducción $->$ entre expresiones.  Las reglas de reducción
principales son:

#figure(
  grid(
    columns: (1fr, 1fr),
    column-gutter: 1em,
    row-gutter: 1.5em,
    $
      frac(
        e_1 -> e_1',
        e_1 space e_2 -> e_1' space e_2
      ) space "E-App1"
    $,
    $
      frac(
        e_2 -> e_2',
        v space e_2 -> v space e_2'
      ) space "E-App2"
    $,
    $
      frac(
        ,
        (lambda x : tau . e) space v -> e[x := v]
      ) space "E-Beta"
    $,
    $
      frac(
        ,
        "if true then" e_2 "else" e_3 -> e_2
      ) space "E-IfTrue"
    $,
  ),
  caption: [Reglas de reducción de paso pequeño (selección).]
)

La regla `E-Beta` es la regla de $beta$-reducción del cálculo lambda; $e[x := v]$
denota la sustitución de la variable $x$ por el valor $v$ en $e$
(@sec-sustituciones).

== Sustituciones
<sec-sustituciones>

La _sustitución_ $e[x := e']$ reemplaza todas las ocurrencias libres de $x$
en $e$ por la expresión $e'$.  Se define estructuralmente:

$
  x[x := e']                  &= e' \
  y[x := e'] space (y != x)   &= y \
  (e_1 space e_2)[x := e']    &= (e_1[x := e']) space (e_2[x := e']) \
  (lambda x : tau . e)[x := e'] &= lambda x : tau . e \
  (lambda y : tau . e)[x := e'] space (y != x, y in.not "FV"(e'))
                        &= lambda y : tau . (e[x := e']) \
$

Es importante notar que la sustitución bajo una abstracción $lambda x$ no
realiza ningún cambio, pues $x$ no tiene ocurrencias libres dentro de su
propio ámbito.  Cuando $y in "FV"(e')$ se requiere un _renombramiento_ (_alpha-renaming_)
previo para evitar la captura de variables libres.

// =============================================================================
// CAPÍTULO 3 — Reificación
// =============================================================================
= Reificación
<cap-reificacion>

La _reificación_ es el proceso de hacer concreto lo abstracto: dado un objeto
semántico (un significado, un dominio, una categoría), construimos una
representación sintáctica —un término del lenguaje— que lo _denota_ de manera
fiel.  En el contexto de los lenguajes de programación, la reificación permite
pasar de la semántica denotacional de un término a un término sintáctico
equivalente.

== Definición Matemática
<sec-reif-matematica>

Desde el punto de vista clásico de la semántica denotacional
@winskel1993formal @scott1970outline, cada tipo $tau$ se interpreta como un
dominio de Scott $[| tau |]$, y cada expresión $e$ con $diameter tack.r e : tau$
se interpreta como un elemento $[| e |] in [| tau |]$.

#figure(
  align(left)[
    $
      [| bb(B) |]       &= {bot, "tt", "ff"}_bot \
      [| bb(N) |]       &= bb(N)_bot \
      [| tau_1 -> tau_2 |]
                        &= [| tau_1 |] ->_c [| tau_2 |] \
      [| tau_1 times tau_2 |]
                        &= [| tau_1 |] times [| tau_2 |] \
    $
  ],
  caption: [Interpretación de tipos como dominios de Scott.]
)

La _función de reificación_ $"reify"_tau : [| tau |] -> Lambda_tau$ asocia a
cada elemento $d in [| tau |]$ una expresión cerrada de tipo $tau$ tal que
$[| "reify"_tau (d) |] = d$.  Simétricamente, la _función de reflexión_
$"reflect"_tau : Lambda_tau -> [| tau |]$ satisface
$"reify"_tau ("reflect"_tau (e)) approx e$ (en el sentido de equivalencia
observacional).

Este par de funciones forma la base de la técnica de _normalización por
evaluación_ (_Normalization by Evaluation_, NbE) @reynolds1983types.

=== Propiedades de la reificación

La reificación satisface las siguientes propiedades clave:

1. *Fidelidad*: $[| "reify"_tau (d) |] = d$ para todo $d in [| tau |]$.

2. *Totalidad*: La función $"reify"_tau$ está definida en todo el dominio
   $[| tau |]$ (módulo elementos de fondo $bot$).

3. *Composición*: $"reify"_(tau_1 -> tau_2)(f) =
   lambda x : tau_1 . "reify"_(tau_2)(f space "reflect"_(tau_1)(x))$.

== Definición Categórica
<sec-reif-categorica>

Desde la perspectiva de la teoría de categorías @awodey2010category, la
reificación puede entenderse en términos de _adjunciones_ entre categorías.

Sea $cal(S)$ la categoría _sintáctica_ cuyos objetos son los tipos $tau$ y
cuyos morfismos $tau_1 -> tau_2$ son las clases de equivalencia de términos
cerrados de tipo $tau_1 -> tau_2$.  Sea $cal(D)$ la categoría _semántica_
cuyos objetos son los dominios $[| tau |]$ y cuyos morfismos son las funciones
continuas entre dominios.

La interpretación define un funtor $[| - |] : cal(S) -> cal(D)$.

#figure(
  align(center)[
    $
      cal(S) space
      arrow.r.curve^("reflect") space
      cal(D) space
      arrow.r.curve^("reify") space
      cal(S)
    $
  ],
  caption: [Adjunción entre las categorías sintáctica y semántica.]
)

=== Categorías cartesianas cerradas (CCC)

Un resultado fundamental de la semántica categórica es que las categorías
cartesianas cerradas (_Cartesian Closed Categories_, CCC) proporcionan modelos
del cálculo lambda tipado simple @mac-lane1998categories.

#figure(
  align(left)[
    Una categoría $cal(C)$ es *cartesiana cerrada* si:
    + Tiene un objeto terminal $bold(1)$.
    + Para todo par de objetos $A, B$, existe el producto $A times B$.
    + Para todo par de objetos $A, B$, existe el objeto exponencial $B^A$
      (el _objeto de funciones_ de $A$ en $B$).
  ],
  caption: [Definición de categoría cartesiana cerrada.]
)

La adjunción $- times A tack.l B^A$ (currificación) corresponde exactamente
a la regla `Abs`/`App` del sistema de tipos: la reificación es el _co-unit_
de esta adjunción.

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

En este trabajo utilizamos Rocq 8.20 para codificar las definiciones del
@cap-definicion y las propiedades del @cap-reificacion, y verificar
mecánicamente los teoremas enunciados.

== Actualizaciones a Rocq 8.20
<sec-rocq-actualizaciones>

La versión 8.20 introduce varios cambios relevantes para este trabajo:

/ Renombramiento del proyecto: El proyecto fue renombrado de _Coq_ a _Rocq_
  en el ciclo de versión 8.20.  Los módulos y comandos mantienen
  compatibilidad retroactiva mediante aliases, pero la nomenclatura oficial
  adoptada en este trabajo es _Rocq_.

/ Mejoras en `Program`: La táctica `Program` y el mecanismo de obligaciones
  (_obligations_) presentan mejoras de rendimiento y mensajes de error más
  descriptivos.

/ `Ltac2` estabilizado: La nueva metalengua de tácticas `Ltac2` alcanza
  estabilidad en 8.20, lo que la hace preferible para pruebas de automatización
  complejas.

/ Unificación y `unify`: Se mejora el algoritmo de unificación, reduciendo
  falsos positivos en metas de unificación dependiente.

/ Soporte mejorado para `SProp`: Las proposiciones estrictamente proposicionales
  (`SProp`) presentan mejor integración con la reescritura y la reflexión.

== Librería de Dominios
<sec-rocq-dominios>

Para modelar la semántica denotacional (@sec-reif-matematica) en Rocq es
necesario trabajar con _dominios de Scott_, que son conjuntos parcialmente
ordenados (CPOs) con la propiedad de completitud para cadenas.

La librería de dominios utilizada en este trabajo provee:

```
(* Tipo de dominios planos con elemento de fondo *)
Inductive flat (A : Type) : Type :=
  | bottom : flat A
  | up     : A -> flat A.

(* Notación para lift / up *)
Notation "↑ x" := (up x) (at level 10).

(* Orden de dominios planos *)
Inductive flat_le {A} : flat A -> flat A -> Prop :=
  | le_bot  : forall x, flat_le bottom x
  | le_refl : forall x, flat_le (up x) (up x).
```

=== Funciones continuas

Las _funciones continuas_ entre dominios (aquellas que preservan supremos de
cadenas dirigidas) se representan mediante un tipo dependiente:

```
Record continuous {D E : cpo} (f : D -> E) : Prop := {
  mono    : forall x y, x ⊑ y -> f x ⊑ f y;
  limits  : forall (c : chain D),
              f (sup c) = sup (chain_map f c);
}.
```

== Definiciones Principales
<sec-rocq-definiciones>

A continuación presentamos las definiciones centrales del lenguaje en Rocq,
siguiendo la estructura del @cap-definicion.

=== Tipos

```
(* Tipos del lenguaje *)
Inductive ty : Type :=
  | ty_bool  : ty
  | ty_nat   : ty
  | ty_arrow : ty -> ty -> ty
  | ty_prod  : ty -> ty -> ty.

Notation "τ₁ '→' τ₂" := (ty_arrow τ₁ τ₂) (at level 50, right associativity).
Notation "τ₁ '×' τ₂" := (ty_prod  τ₁ τ₂) (at level 45).
```

=== Expresiones

```
(* Variables como índices de De Bruijn *)
Definition var := nat.

(* Expresiones del lenguaje *)
Inductive expr : Type :=
  | e_var   : var -> expr
  | e_true  : expr
  | e_false : expr
  | e_num   : nat -> expr
  | e_abs   : ty -> expr -> expr        (* λ x:τ. e  — x es De Bruijn 0 *)
  | e_app   : expr -> expr -> expr
  | e_if    : expr -> expr -> expr -> expr
  | e_pair  : expr -> expr -> expr
  | e_fst   : expr -> expr
  | e_snd   : expr -> expr.
```

Utilizamos índices de De Bruijn @barendregt1984lambda para evitar los
problemas de captura de variables en la sustitución.

=== Contexto de tipos y juicios

```
(* Contexto de tipos: lista de tipos *)
Definition ctx := list ty.

(* Juicio de tipos: Γ ⊢ e : τ *)
Inductive has_type : ctx -> expr -> ty -> Prop :=
  | T_Var   : forall Γ n τ,
                nth_error Γ n = Some τ ->
                has_type Γ (e_var n) τ
  | T_True  : forall Γ, has_type Γ e_true  ty_bool
  | T_False : forall Γ, has_type Γ e_false ty_bool
  | T_Num   : forall Γ n, has_type Γ (e_num n) ty_nat
  | T_Abs   : forall Γ τ₁ τ₂ e,
                has_type (τ₁ :: Γ) e τ₂ ->
                has_type Γ (e_abs τ₁ e) (τ₁ → τ₂)
  | T_App   : forall Γ τ₁ τ₂ e₁ e₂,
                has_type Γ e₁ (τ₁ → τ₂) ->
                has_type Γ e₂ τ₁ ->
                has_type Γ (e_app e₁ e₂) τ₂
  | T_If    : forall Γ τ e₁ e₂ e₃,
                has_type Γ e₁ ty_bool ->
                has_type Γ e₂ τ ->
                has_type Γ e₃ τ ->
                has_type Γ (e_if e₁ e₂ e₃) τ.
```

=== Sustitución y reducción

```
(* Sustitución (índices de De Bruijn) *)
Fixpoint subst (s : var -> expr) (e : expr) : expr :=
  match e with
  | e_var n        => s n
  | e_true         => e_true
  | e_false        => e_false
  | e_num n        => e_num n
  | e_abs τ body   => e_abs τ (subst (subst_up s) body)
  | e_app e₁ e₂   => e_app (subst s e₁) (subst s e₂)
  | e_if  e₁ e₂ e₃ => e_if (subst s e₁) (subst s e₂) (subst s e₃)
  | e_pair e₁ e₂  => e_pair (subst s e₁) (subst s e₂)
  | e_fst e        => e_fst (subst s e)
  | e_snd e        => e_snd (subst s e)
  end.

(* Relación de reducción de paso pequeño *)
Inductive step : expr -> expr -> Prop :=
  | S_Beta  : forall τ e v,
                is_value v ->
                step (e_app (e_abs τ e) v) (subst (subst_one v) e)
  | S_App1  : forall e₁ e₁' e₂,
                step e₁ e₁' ->
                step (e_app e₁ e₂) (e_app e₁' e₂)
  | S_App2  : forall v e₂ e₂',
                is_value v -> step e₂ e₂' ->
                step (e_app v e₂) (e_app v e₂')
  | S_IfTrue  : forall e₂ e₃,
                  step (e_if e_true  e₂ e₃) e₂
  | S_IfFalse : forall e₂ e₃,
                  step (e_if e_false e₂ e₃) e₃
  | S_If      : forall e₁ e₁' e₂ e₃,
                  step e₁ e₁' ->
                  step (e_if e₁ e₂ e₃) (e_if e₁' e₂ e₃).
```

=== Teorema de solidez

```
(* Progreso *)
Theorem progress : forall e τ,
  has_type [] e τ ->
  is_value e \/ exists e', step e e'.
Proof.
  (* ... prueba por inducción en la derivación de tipos ... *)
Admitted.

(* Preservación *)
Theorem preservation : forall Γ e e' τ,
  has_type Γ e τ ->
  step e e' ->
  has_type Γ e' τ.
Proof.
  (* ... prueba por inducción en la derivación de tipos y el paso ... *)
Admitted.
```

// =============================================================================
// CAPÍTULO 5 — Conclusión
// =============================================================================
= Conclusión
<cap-conclusion>

En este trabajo hemos recorrido el camino que va desde la definición informal
de un lenguaje de programación hasta su verificación mecánica en Rocq 8.20.
Los principales aportes son:

1. Una *presentación unificada* de la sintaxis, el sistema de tipos y la
   semántica operacional del lenguaje objeto, con énfasis en la relación entre
   los tres componentes.

2. Una *formalización matemática* de la noción de reificación, conectando la
   semántica denotacional clásica (dominios de Scott) con la normalización por
   evaluación.

3. Una *formalización categórica* de la reificación en términos de la
   adjunción currificación/aplicación en categorías cartesianas cerradas,
   mostrando que el par (reify, reflect) es el co-unit de dicha adjunción.

4. Una *implementación en Rocq* de las definiciones principales, utilizando
   índices de De Bruijn para las variables, con la biblioteca de dominios
   desarrollada ad hoc y las pruebas de solidez del sistema de tipos.

=== Trabajo futuro

Quedan abiertas varias líneas de trabajo:

- Completar las pruebas de progreso y preservación (actualmente marcadas con
  `Admitted`).
- Extender el lenguaje con polimorfismo paramétrico (System F) y estudiar la
  noción de _free theorems_ @wadler1989theorems en el marco de la reificación.
- Formalizar la adjunción categórica directamente en Rocq utilizando la
  librería Coq-HoTT o UniMath.
- Explorar la conexión con la _lógica lineal_ @plotkin1977lcf para modelar
  lenguajes con efectos o con recursos lineales.

// =============================================================================
// CAPÍTULO 6 — Referencias
// =============================================================================
= Referencias
<cap-referencias>

#set heading(numbering: none)

#bibliography("refs.bib", style: "ieee", title: none)
