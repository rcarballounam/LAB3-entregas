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
