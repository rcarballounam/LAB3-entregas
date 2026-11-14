# PLAN DE TRABAJO — LABORATORIO 3: ISA, ENSAMBLADOR Y SIMULADOR FUNCIONAL

## 1. Mapa del repositorio

El repositorio contiene varias entregas de grupos de laboratorio, cada una con un conjunto de archivos Assembly LC-3 y documentos de apoyo. La estructura principal es:

- `README.md`: resumen del repositorio.
- `carpeta para docentes/`: instrucciones y material de referencia del docente.
- `grupo01` a `grupo30`: entregas individuales por grupo.
- Dentro de cada grupo hay archivos `.asm`, README y, en algunos casos, subdirectorios de pruebas, módulos y programas principales.

### Inventario de archivos assembly observados

Se detectaron 81 archivos `.asm` en el repositorio, con patrones típicos de LC-3:

- `grupo01/cordic_division.asm`
- `grupo03/...` (multiplicación, simulador LC3, web-LC3)
- `grupo04/...` (formato Q, potencia)
- `grupo05/...` (multiplicaciones sucesivas, potencia)
- `grupo06/...` (exponencial, punto fijo)
- `grupo07/...` (MCD, MCM, punto fijo)
- `grupo09/...` (sqrt, helpers de lectura/escritura)
- `grupo10/division.asm`
- `grupo11/tp_formatoq.asm`
- `grupo12/subrutina_grupo_12.asm`
- `grupo14/...` (log Borchardt, Lab3a)
- `grupo15/...` (Q3.12/Q7.8, pruebas)
- `grupo18/...` (Booth, main, proyecto completo)
- `grupo19/...` (Lab3a, CORDIC multiply)
- `grupo20/...` (reducción de argumento CORDIC)
- `grupo21/...` (laboratorio 3, estructura no detallada)
- `grupo22/...` (pruebas de assembly, tabla sin/cos)
- `grupo23/...` (asm de lab3a y módulo sqrt)
- `grupo24/...` (punto 1 assembly, conversor)
- `grupo27/...` (menú, conversión Q, validación de entrada/salida, subrutinas)
- `grupo30/...` (punto fijo, seno Chebyshev/Pade)

## 2. Hallazgos de análisis preliminar

### 2.1. El benchmark no está unificado

No hay un único programa principal del benchmark dentro del repositorio raíz. En cambio, cada grupo aporta un conjunto de archivos que implementan funciones de cálculo diversas, como:

- multiplicación y división
- CORDIC
- raíz cuadrada
- funciones exponenciales/logarítmicas
- conversión entre formatos Q
- suma/resta/mul de punto fijo
- validación de entrada/salida y manejo de I/O

Esto sugiere que la base de código funciona como un conjunto de benchmarks parciales o pruebas de laboratorio, que luego deben integrarse en una ISA más general y en un simulador funcional común.

### 2.2. Patrones LC-3 detectados

Se observaron directivas y construcciones típicas de LC-3, incluyendo:

- `.ORIG`, `.END`
- `.FILL`, `.BLKW`
- `.STRINGZ`
- `.EXTERNAL`
- JSR, JSRR, RET
- BR, BRn, BRz, BRp, BRnzp
- TRAP para entrada/salida
- uso de registros R0-R7
- convenciones de llamada con salvado/restauración de R7

### 2.3. Formatos Q y punto fijo

Se detectan múltiples representaciones en punto fijo, por ejemplo:

- Q7.8
- Q3.12
- Q8.7
- Q12.4 / derivados
- conversiones explícitas entre formatos

Numerosos archivos muestran cálculos con máscara, redondeo, overflow y validación de signos, por ejemplo en `grupo11/tp_formatoq.asm`, `grupo30/lab3a_puntos_3_y_4.asm`, `grupo09/sqrt_nr_q8.asm` y `grupo27/...`.

### 2.4. Punto de entrada y flujo principal

No existe un punto de entrada único a nivel global. Algunos programas contienen un `main.asm` o un módulo principal con `.ORIG x3000` y llamadas a rutinas externas usando `.EXTERNAL` y `JSRR Rn`.

Ejemplos relevantes:

- `grupo18/main.asm` usa `.EXTERNAL BOOTH-MULT_BOOTH` y `JSRR R5`.
- `grupo27/main_menu/...` incluye varias subrutinas de lectura/escritura y conversiones.
- `grupo19/Lab3b/CORDIC_mul.asm` y `CORDIC_mul_horner.asm` tienen flujo principal para entrada de datos y cálculo.

## 3. Funcionalidad esperada del benchmark

El benchmark propuesto por el instructivo parece estar compuesto por una colección de rutinas de cálculo en punto fijo, con un conjunto de funciones elementales que deben integrarse dentro de una ISA extendida, un ensamblador y un simulador funcional.

Las funciones observadas apuntan a un “calculadora” o conjunto de primitivas de uso académico, con soporte para:

- multiplicación
- división
- suma/resta en formatos Q
- conversión entre formatos Q
- raíz cuadrada
- reducciones trigonométricas / CORDIC
- exponenciales y logaritmos
- manejo de entrada/salida en consola

## 4. Arquitectura de software propuesta

### 4.1. Módulos a implementar

1. ISA extendida
   - definición formal de opcodes, registros, flags, formatos de instrucción, memoria, endianness y TRAP.

2. Ensamblador
   - parseo de sintaxis LC-3 extendida
   - símbolos, etiquetas, `.EXTERNAL`, directivas y resolución de referencias
   - salida binaria/hexadecimal con origen

3. Linker / resolución de símbolos externos
   - reemplazo de `.EXTERNAL` y unificación de módulos

4. Simulador funcional
   - carga de memoria, decodificación, ejecución, flags y manejo de errores
   - soporte a código máquina (no assembly directo)

5. Integración del benchmark
   - ensamblar los archivos de funciones y ejecutar el conjunto completo

6. Validación y métricas
   - pruebas unitarias, comparación contra referencia en C/alto nivel, reportes de precisión y consumo

### 4.2. Riesgos y ambigüedades

- El repositorio tiene muchos programas aislados, no un único benchmark compilable.
- Algunas rutas tienen nombres con espacios o caracteres especiales (`grupo27`, `Lab 3a`), lo que exige manejo cuidadoso en scripts y en paths del entorno.
- Algunas implementaciones parecen estar incompletas o variantes de prueba, no necesariamente la versión definitiva.
- La ISA hipotética no está definida aún; deberemos hacerlo formalmente antes de implementar el ensamblador y el simulador.
- Debe respetarse la prohibición de emular punto flotante en el assembly del benchmark: se requieren algoritmos en punto fijo.

## 5. Fases propuestas

### Fase 0 — Planificación y análisis
- Inventario del repositorio y detección de patrones.
- Creación de `docs/PLAN.md` y `docs/BITACORA.md`.
- Criterio de aceptación: documento con mapa, riesgos, preguntas abiertas y propuesta general.

### Fase 1 — Especificación de ISA
- Definición de registros, opcodes, endianness, memoria, salto condicional, TRAP y convenciones.
- Criterio de aceptación: documento `docs/ISA.md` con tabla de opcodes y semántica formal.

### Fase 2 — Ensamblador
- Implementación del lexer/parser, símbolo table y codificación.
- Criterio de aceptación: pruebas básicas de ensamblado y manejo de errores.

### Fase 3 — Simulador funcional
- Implementación del núcleo de ejecución y carga de memoria.
- Criterio de aceptación: programas pequeños ejecutados y resultados reproducibles.

### Fase 4 — Integración del benchmark
- Ensamblado y ejecución de los archivos provistos.
- Criterio de aceptación: listado de archivos integrados y resultados preliminares.

### Fase 5 — Validación funcional y depuración
- Pruebas por función, comparaciones con referencia y corrección de errores.

### Fase 6 — Métricas y optimización
- Registro de desempeño, memoria, precisión e instrucciones ejecutadas.

### Fase 7 — Documentación final y entrega
- README y documentación final de uso, diseño, resultados y métricas.

## 6. Estrategia de pruebas y métricas

Se usará un enfoque incremental:

- pruebas unitarias pequeñas sobre instrucciones aisladas,
- validación de módulos por función (multiplicación, división, sqrt, etc.),
- comparación con resultados esperados y/o modelos de referencia en C,
- métricas de instrucciones ejecutadas, uso de memoria y precisión en punto fijo,
- registros de fallos y correcciones en `docs/BITACORA.md`.

## 7. Preguntas abiertas

1. ¿Debe el proyecto quedar centrado en una única ISA nueva o se aceptará una variante inspirada en LC-3 con extensiones específicas?
2. ¿Se integra el benchmark completo, o se prioriza un subconjunto representativo de funciones?
3. ¿Hay documentos o PDFs de referencia más específicos dentro del repositorio que deban considerarse como fuente de verdad?
4. ¿Se desea una solución de CLI simple o una estructura modular más extensa para pruebas?
5. ¿La validación final debe usar un benchmark completo de todos los grupos o una selección representativa?

## 8. Fase 1 — Especificación de ISA

Se define la ISR lineal del proyecto como una extensión de LC-3 con opcode fijo de 5 bits, registros de 16 bits, acceso byte-addressable a 64 KiB, soporte para `LDBL`/`LDBH`/`LDW` y `STBL`/`STBH`/`STW`, condiciones N/Z/P, flujo de subrutinas con `JSR`/`RET` y compatibilidad con el patrón de llamadas del grupo 27.

La entrega de la fase 1 queda documentada en:

- `docs/ISA.md`
- `docs/ISA_OPCODES.md`

Con esta definición, el proyecto queda preparado para continuar con el ensamblador y el simulador funcional sin ambigüedades sobre registros, memoria, flags, direcciones, endian y convenios del benchmark.

## 9. Conclusión preliminar

El repositorio presenta una base rica de trabajos de laboratorio en Assembly LC-3 con múltiples funciones matemáticas y conversiones de formato Q. La tarea más importante antes de codificar es definir una ISA unificada y un plan de integración del benchmark, porque actualmente hay diversidad de programas pero no un único punto de entrada ni una especificación común.

La Fase 1 ya quedó documentada con una propuesta formal de ISA compatible con el benchmark del grupo 27 y con las funciones del repositorio. El siguiente paso natural es la implementación del ensamblador, siempre y cuando se confirme la aprobación del usuario.
