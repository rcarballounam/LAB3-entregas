# BITÁCORA DE TRABAJO — LABORATORIO 3

## 2026-11-14 — Fase 0: planificación inicial

### Objetivo
Recorrer la base de código, detectar el benchmarking de funciones en assembly y preparar la estructura documental para el trabajo posterior.

### Actividades realizadas
- Se leyó el instructivo de trabajo del agente.
- Se recorrió el árbol del repositorio para detectar grupos y archivos de entregas.
- Se identificaron 81 archivos `.asm` distribuidos por grupos.
- Se detectaron patrones típicos de LC-3: `.ORIG`, `.END`, `.FILL`, `.BLKW`, `.STRINGZ`, `.EXTERNAL`, `JSR`, `BR`, `RET`, `TRAP`.
- Se revisaron ejemplos de programas principales con llamadas a rutinas externas y conversiones en punto fijo.
- Se creó la carpeta `docs/` y se comenzaron los documentos de planificación y trazabilidad.

### Hallazgos principales
- El repositorio no presenta un único benchmark integrado; hay múltiples entregas por grupo.
- Los archivos Assembly implementan funciones matemáticas y de punto fijo (multiplicación, división, sqrt, CORDIC, conversiones Q, etc.).
- Hay una clara estructura de LC-3 extendida con directivas y subrutinas externas, aunque aún no existe una ISA única formalizada.
- La base de trabajo es suficiente para diseñar una ISA nueva, un ensamblador y un simulador funcional, pero requiere una fase de especificación formal antes de implementar código.

### Documentos creados
- `docs/PLAN.md`
- `docs/BITACORA.md`

### Riesgos / observaciones
- La base del benchmark no es un único programa sino un conjunto de entregas y variantes paralelas.
- Hay nombres y rutas con espacios o caracteres no estándar que exigirán cuidado.
- Faltan una especificación formal de ISA y una integración clara de benchmark; esta es la tarea central de las fases posteriores.

### Estado
La Fase 0 queda completada en términos de inventario, análisis y preparación del plan. Se espera aprobación para continuar con la Fase 1.

## 2026-11-14 — Fase 1: especificación de ISA extendida

### Objetivo
Definir formalmente la ISA del laboratorio, con opcodes de 5 bits, registros de 16 bits, memoria byte-addressable, flags, subrutinas y convenios de benchmark aplicables al grupo 27 y a las rutinas externas.

### Actividades realizadas
- Se analizó el patrón del benchmark principal del grupo 27, especialmente el menú, los valores pasados por `R0`/`R1` y la forma de invocar subrutinas por `JSRR`.
- Se diseñó una ISA basada en LC-3, pero con 5 bits de opcode, memoria 64 KiB byte-addressable y operaciones explícitas para bytes y palabras.
- Se documentaron los registos, semántica de flags, endianness, direccionamiento, manejo de TRAP y convenciones de `.EXTERNAL`.
- Se preparó la tabla resumida de opcodes para ensamblador y simulador.

### Resultados principales
- Se define la ISA para un sistema de 16 bits con 32 opcodes máximos.
- Se incorporan accesos explícitos a byte bajo, byte alto y palabra completa.
- Se conservan `BR`, `JMP`, `JSR`, `JSRR`, `RET` y `TRAP`, con enfoques compatibles con la lógica del repositorio.
- Se aclara que el benchmark del grupo 27 usa `R0`/`R1` para argumentos de entrada y un mecanismo de menú/verbosidad para integrar funciones de distintos grupos.

### Documentos creados
- `docs/ISA.md`
- `docs/ISA_OPCODES.md`

### Riesgos / observaciones
- La ISA no es retrocompatible con el hardware LC-3 original; se propone una extensión funcionalmente equivalente, no idéntica.
- La memoria y el endianness deben respetarse de forma estricta para evitar inconsistencias entre assembler y simulador.
- La integración del benchmark requiere que el assembler y el linker resuelvan símbolos externos y formateos Q con reglas explícitas.

### Estado
La Fase 1 queda definida y documentada. Se espera aprobación para continuar con la Fase 2.

## 2026-11-14 — Fase 2: ensamblador y validación inicial

### Objetivo
Implementar la base del ensamblador para la ISA propuesta y validar que soporte los patrones reales del benchmark principal del grupo 27.

### Actividades realizadas
- Se desarrolló el módulo `src/assembler/assembler.py` con soporte para `.ORIG`, `.END`, `.FILL`, `.BLKW`, `.STRINGZ`, `.EXTERNAL`, etiquetas y resolución básica de expresiones.
- Se agregaron pruebas unitarias en `tests/test_assembler.py` para instrucciones simples, etiquetas, `.EXTERNAL`, `.STRINGZ`, renombrado de alias de TRAP y soporte de etiquetas en línea independiente.
- Se ajustó el parser para aceptar etiquetas en formato típico de benchmark (`main` en línea propia) y pseudo-instrucciones LC-3 como `PUTS`, `OUT`, `GETC` e `IN`.
- Se validó la compilación del programa principal del benchmark `benchmark/main.asm` y se confirmaron patrones clave del grupo 27 (llamadas mediante `JSRR`, datos `.FILL`, referencias externas y formato de menú/verbosidad).

### Resultados principales
- El ensamblador ya procesa instrucciones básicas del benchmark y genera salida en hexadecimal reproducible.
- La soporta caracteres y símbolos frecuentes del benchmark: etiquetas sin dos puntos, expresiones con restas de símbolos, variables externas y datos de punto fijo.
- La validación actual confirma que el módulo de ensamblado está listo para soportar la integración posterior del simulador y del benchmark completo.

### Riesgos / observaciones
- Algunos archivos del benchmark están diseñados como fragmentos de biblioteca o subrutinas y no son programas autocontenidos (`.ORIG` ausente), por lo que deben integrarse mediante un linker o conjunto de ensamblaje controlado.
- La etapa siguiente requiere validar la ejecución del simulador sobre código máquina generado desde el benchmark real, no sólo las pruebas unitarias del ensamblador.

### Estado
Se concreta la base funcional de la Fase 2 y queda lista para seguir con la Fase 3 del simulador funcional.

### Corrección posterior — etiquetas y `:`
- Se reprodujo el error al ensamblar `benchmark/conversor_lc3_max.asm`: el parser interpretaba el carácter `:` dentro del literal `.STRINGZ "Hexadecimal: "` como separador de etiqueta.
- Se limitó la detección de etiquetas con `:` al primer token de la línea y se agregó una prueba de regresión.
- Validación: las 6 pruebas unitarias pasan y `benchmark/conversor_lc3_max.asm` ensambla correctamente.

### Salida a archivo
- La CLI genera automáticamente un archivo de salida junto al `.asm`: `.hex` por defecto, o `.bin`/`.dec` al elegir esos formatos.
- Se incluye el valor `.ORIG` como primer word para identificar la dirección de carga del programa.
- Se documentó el uso en `docs/ASSEMBLER.md` y se agregó una prueba de generación del archivo `.hex`.
- Validación tras el cambio: 7 pruebas unitarias pasan; la dirección de origen también queda al inicio en los formatos binario y decimal.
- La salida a archivo se ajustó para escribir un valor hexadecimal por línea, incluyendo `.ORIG` como primera línea.

### Conversor de hexadecimal en fila a columna
- Se creó `scripts/hex_a_columna.py` para transformar archivos hexadecimales de una fila en una palabra de 16 bits por línea, sin modificar el archivo fuente.
- Se validó sobre `benchmark/ensambladodereferencia.hex`: convirtió 8058 palabras en 8058 líneas.
- Validación unitaria: 10 pruebas pasan.

### Enlazado recursivo de `.EXTERNAL`
- Se implementó `ProjectLinker` para resolver `MODULO-SIMBOLO`, localizar módulos por nombre de archivo o alias `g27_`, cargar dependencias transitivas desde `lib` y reubicar cada unidad después de la anterior.
- Los externos sin definición ahora producen un error; ya no se codifican silenciosamente como cero.
- Se corrigió el reconocimiento de etiquetas cuyo nombre empieza con `R`, necesario para exportar `Reduccion_Argumento`.
- Se corrigió el direccionamiento para usar direcciones LC-3 por palabra y se ordenó la carga por niveles: dependencias directas antes de las transitivas.
- Validación unitaria e integración: 15 pruebas pasan, incluidos casos de enlace directo, transitivo, reubicación, orden de dependencias y comparación exacta del benchmark.
- El benchmark se enlaza con los 37 módulos requeridos desde `benchmark/lib`, genera 8058 palabras y coincide palabra por palabra con `benchmark/ensambladodereferencia_columna.hex`.
