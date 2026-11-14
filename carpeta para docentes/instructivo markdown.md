# INSTRUCTIVO PARA AGENTE DE VS CODE — LABORATORIO 3: ISA, ENSAMBLADOR Y SIMULADOR FUNCIONAL

## 0. Propósito del instructivo

Este documento define cómo debe trabajar un agente de IA dentro de Visual Studio Code para completar el Laboratorio N° 3 de Arquitectura de Computadoras a partir de una base de código provista por el usuario, que incluye **todos los archivos assembly que forman el benchmark de la calculadora**.

El objetivo final es entregar:

1. Una **especificación de ISA** basada en LC-3 expandida a opcode de 5 bits.
2. Un **ensamblador** para esa ISA.
3. Un **simulador funcional** de núcleo de ejecución.
4. La **integración del benchmark** compuesto por los archivos assembly provistos.
5. Validación funcional, métricas de desempeño y documentación.

El agente debe trabajar **por fases**, **deteniéndose al final de cada una** para reportar y pedir aprobación explícita antes de continuar.

---

## 1. Rol y reglas generales del agente

Actuá como un agente de ingeniería de software supervisado. Tu trabajo es planificar, implementar, probar y documentar, pero **no avanzar de fase sin autorización humana**.

### Reglas obligatorias

- **Planificar antes de codificar.** La primera fase es obligatoria y termina con una parada.
- **No destruir información.** No ejecutes `rm`, `git reset --hard`, `git clean -fdx`, sobrescrituras masivas ni comandos destructivos sin aprobación explícita.
- **No exponer secretos.** No leas, imprimas ni envíes credenciales, tokens, claves API, datos personales ni información privada.
- **No instalar dependencias ni acceder a red** sin aprobación del usuario.
- **Trabajá en una rama Git** si el repositorio ya está inicializado. Si no lo está, proponé inicializarlo, pero no lo hagas sin autorización.
- **Preservá los archivos originales del benchmark.** Si necesitás modificarlos, hacé copia, documentá el motivo y pedí aprobación.
- **Mantené trazabilidad:** cada cambio debe quedar documentado en `docs/BITACORA.md` y en el reporte de fase.
- **No inventes requisitos faltantes.** Si falta información, escribí preguntas concretas y detenete.
- **No implementes por hardware** raíz cuadrada, potenciación, exponencial, logaritmo, trigonométricas, inversas, hiperbólicas ni factorial. Esas funciones deben resolverse por software/algoritmos en assembly, no como instrucciones de hardware.
- **No uses emulación de punto flotante en el assembly del benchmark.** El workload debe operar en punto fijo.
- **El simulador no debe aceptar assembly directo como entrada.** Debe recibir código máquina en binario, hexadecimal o decimal. El assembly se procesa con el ensamblador.
- **No es obligatoria una interfaz gráfica.** Se prioriza CLI, archivos y resultados reproducibles.
- **Documentá endianness, alineación, formato de instrucciones, formatos Q y convenciones de I/O** en la especificación de ISA.

---

## 2. Entradas esperadas

El usuario proveerá una base de código con:

- Archivos `.asm` del benchmark de la calculadora.
- Posibles macros, directivas, etiquetas, `.EXTERNAL`, datos en punto fijo y rutinas de funciones elementales.
- Posible documentación parcial o archivos de configuración.

Antes de escribir código, el agente debe **inventariar** todo:

- Lista de archivos assembly.
- Punto de entrada del programa principal.
- Rutinas exportadas/importadas con `.EXTERNAL`.
- Convenciones de llamada, registros usados, pila o memoria de datos.
- Formatos Q usados por cada rutina.
- Entradas y salidas esperadas de cada función.
- Códigos de TRAP o mecanismos de I/O usados.
- Restricciones de alineación y tamaño.

---

## 3. Fase 0 — Planificación obligatoria y parada

**Objetivo:** comprender el repositorio y producir un plan antes de modificar código.

### Actividades

1. Leer este instructivo y los PDFs de referencia disponibles en el repositorio.
2. Recorrer el árbol de archivos.
3. Identificar todos los `.asm` del benchmark y su rol.
4. Detectar directivas usadas: `.ORIG`, `.END`, `.FILL`, `.BLKW`, `.STRINGZ`, `.EXTERNAL`, macros, pseudo-operaciones, etc.
5. Detectar el punto de entrada y el flujo principal de la calculadora.
6. Identificar formatos Q, rangos y precisiones declaradas o inferidas.
7. Identificar convenciones de llamada, registros, memoria de datos y salidas.
8. Detectar ambigüedades y riesgos.
9. Crear `docs/PLAN.md` con:
   - Mapa del repositorio.
   - Inventario de archivos assembly.
   - Funcionalidad esperada del benchmark.
   - Borrador de arquitectura de software: ensamblador, linker/.EXTERNAL, simulador, pruebas.
   - Fases propuestas con entregables y criterios de aceptación.
   - Riesgos y preguntas abiertas.
   - Estrategia de pruebas y métricas.
10. Crear `docs/BITACORA.md` con la primera entrada.

### Restricciones

- En esta fase **no modifiques código funcional**.
- Solo se permite crear documentación en `docs/`.

### Salida obligatoria de la fase

El agente debe responder con:

- Resumen de hallazgos.
- Archivos creados.
- Preguntas abiertas.
- Propuesta de plan.
- Frase explícita: **“Fase 0 completada. Espero aprobación para continuar con la Fase 1.”**

**DETENERSE. No continuar hasta recibir aprobación.**

---

## 4. Fase 1 — Especificación de ISA

**Objetivo:** definir formalmente la nueva ISA antes de implementar ensamblador y simulador.

### Requisitos mínimos obligatorios

La ISA debe:

- Usar instrucciones de **16 bits** con **opcode fijo de 5 bits**.
- Permitir hasta **32 instrucciones editables**.
- Operar sobre **registros de 16 bits**.
- Tener **capacidad byte addressable** sobre `2^16` direcciones de memoria.
- Incluir instrucciones de movimiento de memoria para:
  - cargar byte bajo,
  - cargar byte alto,
  - cargar palabra completa de 16 bits,
  - guardar byte bajo,
  - guardar byte alto,
  - guardar palabra completa de 16 bits.
- Aceptar enteros con signo de **8 y 16 bits**.
- Incluir salto condicional con flags **N, Z, P** y, opcionalmente, flags adicionales como **V** o **C**.
- Incluir salto a subrutina con guardado de **PC+2**.
- Incluir salto incondicional sin guardar PC+2 y mecanismo de retorno de subrutina.
- Incluir **TRAP**.
- Definir modos de direccionamiento, cantidad de registros y formatos de instrucción.
- No requerir compatibilidad hacia atrás con LC-3, pero sí conservar la funcionalidad equivalente.

### Actividades

1. Crear `docs/ISA.md` con:
   - Tabla de opcodes de 5 bits.
   - Formato binario de cada instrucción.
   - Registros y flags.
   - Modos de direccionamiento.
   - Endianness para instrucciones y palabras.
   - Memoria: mapa, pila, datos, I/O, TRAP.
   - Alineación: instrucciones en direcciones pares, PC += 2.
   - Comportamiento ante salto a dirección impar.
   - Convención de llamada a subrutinas.
   - Mecanismo `.EXTERNAL`.
   - Instrucciones de carga/guardado byte bajo, byte alto y palabra completa.
   - Semántica de flags.
2. Crear `docs/ISA_OPCODES.md` o una tabla equivalente si el detalle es extenso.
3. Actualizar `docs/PLAN.md` si la especificación cambia el plan.

### Salida obligatoria de la fase

Reportar:

- Archivos creados/modificados.
- Tabla resumida de opcodes.
- Decisiones tomadas.
- Preguntas abiertas.
- Frase: **“Fase 1 completada. Espero aprobación para continuar con la Fase 2.”**

**DETENERSE.**

---

## 5. Fase 2 — Ensamblador

**Objetivo:** implementar un ensamblador separado del núcleo de ejecución.

### Requisitos

El ensamblador debe:

- Recibir un archivo de texto con assembly.
- Devolver al menos uno de estos formatos: **binario** o **hexadecimal**.
- Los **primeros dos bytes** de la salida deben corresponder a la **dirección de origen** del programa.
- Soportar operaciones básicas de LC-3 y las nuevas instrucciones de la ISA.
- Soportar `.EXTERNAL`.
- Soportar pseudo-operaciones básicas y las que el grupo haya definido.
- Garantizar que todas las instrucciones comiencen en dirección par.
- Insertar **NOP/padding** cuando sea necesario para mantener alineación.
- Detectar errores de sintaxis, símbolos indefinidos, rangos inválidos y alineación inválida.
- Emitir mensajes de error claros con archivo y línea.

### Actividades

1. Crear estructura de carpetas, por ejemplo:
   - `src/assembler/`
   - `tests/assembler/`
2. Implementar:
   - Lexer/tokenizador.
   - Parser de líneas, etiquetas, directivas y operandos.
   - Tabla de símbolos.
   - Resolución de `.EXTERNAL`.
   - Codificación de instrucciones.
   - Salida binaria/hexadecimal con origen.
   - Manejo de alineación y padding.
3. Crear pruebas unitarias con casos mínimos:
   - Instrucción simple.
   - Etiquetas y saltos.
   - `.EXTERNAL`.
   - Datos y `.FILL`.
   - Alineación impar.
4. Documentar en `docs/ASSEMBLER.md`:
   - Sintaxis soportada.
   - Directivas.
   - Formato de salida.
   - Ejemplos.
   - Limitaciones.

### Salida obligatoria de la fase

Reportar:

- Archivos creados.
- Comandos de uso.
- Pruebas ejecutadas y resultados.
- Errores conocidos.
- Frase: **“Fase 2 completada. Espero aprobación para continuar con la Fase 3.”**

**DETENERSE.**

---

## 6. Fase 3 — Simulador funcional: núcleo de ejecución

**Objetivo:** implementar el núcleo del simulador que ejecuta código máquina de la nueva ISA.

### Requisitos

El simulador debe:

- Recibir un archivo de entrada con el benchmark en binario, hexadecimal o decimal. **No assembly directo.**
- Ejecutar el programa.
- Devolver:
  - resultados de los cómputos de la calculadora para cada función evaluada,
  - cantidad de instrucciones ejecutadas,
  - uso de memoria.
- Tener memoria byte-addressable de `2^16` direcciones.
- Usar registros de 16 bits.
- Incrementar PC de a 2 por instrucción.
- Implementar flags N, Z, P y las adicionales definidas.
- Implementar TRAP.
- Implementar salto a subrutina con guardado de PC+2.
- Implementar retorno de subrutina.
- Implementar salto incondicional sin guardar PC+2.
- Detectar salto a dirección impar y terminar con mensaje de excepción.
- No requerir interfaz gráfica.

### Actividades

1. Crear `src/simulator/`.
2. Implementar:
   - Carga de memoria desde archivo.
   - Decodificación y ejecución de instrucciones.
   - Registros, flags, PC, memoria.
   - TRAP y I/O mínima.
   - Contadores de instrucciones y memoria.
   - Manejo de errores.
3. Crear CLI reproducible:
   - `simulator --input <archivo> --format <bin|hex|dec>`
   - Salida a consola y/o archivo.
4. Crear pruebas con programas pequeños codificados a mano.
5. Documentar en `docs/SIMULATOR.md`.

### Salida obligatoria de la fase

Reportar:

- Archivos creados.
- Formato de entrada/salida.
- Pruebas ejecutadas.
- Métricas obtenidas en pruebas mínimas.
- Frase: **“Fase 3 completada. Espero aprobación para continuar con la Fase 4.”**

**DETENERSE.**

---

## 7. Fase 4 — Integración del benchmark

**Objetivo:** ensamblar y ejecutar todos los archivos assembly provistos por el usuario.

### Actividades

1. Inventariar nuevamente los `.asm` y confirmar dependencias.
2. Ensamblar cada archivo.
3. Resolver `.EXTERNAL` mediante linker o tabla de símbolos externos, según se haya definido.
4. Integrar el programa principal de la calculadora.
5. Ejecutar el benchmark completo en el simulador.
6. Verificar que las salidas coincidan con lo esperado o con una referencia en lenguaje de alto nivel.
7. Registrar:
   - instrucciones ejecutadas,
   - uso de memoria,
   - precisión observada,
   - errores de alineación,
   - símbolos externos no resueltos.
8. Documentar en `docs/BENCHMARK.md`.

### Salida obligatoria de la fase

Reportar:

- Lista de archivos integrados.
- Problemas de integración.
- Resultados preliminares.
- Frase: **“Fase 4 completada. Espero aprobación para continuar con la Fase 5.”**

**DETENERSE.**

---

## 8. Fase 5 — Validación funcional y depuración

**Objetivo:** asegurar que el benchmark funciona correctamente y que el simulador refleja la ISA.

### Actividades

1. Crear una matriz de pruebas por función/rutina:
   - Entrada.
   - Formato Q esperado.
   - Salida esperada.
   - Tolerancia/precisión.
   - Instrucciones ejecutadas.
2. Comparar contra referencias en lenguaje de alto nivel.
3. Probar casos límite:
   - valores mínimos y máximos,
   - overflow/underflow,
   - signo,
   - alineación,
   - `.EXTERNAL` no resuelto,
   - saltos a direcciones impares,
   - instrucciones de byte bajo/alto.
4. Depurar errores en assembly y en el simulador.
5. Actualizar `docs/BITACORA.md`.

### Salida obligatoria de la fase

Reportar:

- Matriz de pruebas.
- Fallos encontrados y corregidos.
- Fallos pendientes.
- Frase: **“Fase 5 completada. Espero aprobación para continuar con la Fase 6.”**

**DETENERSE.**

---

## 9. Fase 6 — Métricas, optimización y análisis

**Objetivo:** medir el desempeño del benchmark y documentar resultados.

### Métricas mínimas

- Cantidad de instrucciones ejecutadas.
- Uso de memoria.
- Precisión alcanzada por función.
- Formato Q usado, rango y precisión.
- Comparación contra línea base si existe.

### Actividades

1. Ejecutar el benchmark completo con entradas representativas.
2. Registrar métricas en `docs/METRICS.md`.
3. Identificar cuellos de botella.
4. Proponer optimizaciones, pero **no aplicarlas sin aprobación** si cambian el benchmark o la ISA.
5. Actualizar documentación.

### Salida obligatoria de la fase

Reportar:

- Tabla de métricas.
- Conclusiones.
- Propuestas de optimización.
- Frase: **“Fase 6 completada. Espero aprobación para continuar con la Fase 7.”**

**DETENERSE.**

---

## 10. Fase 7 — Documentación final y entrega

**Objetivo:** dejar el proyecto reproducible y documentado.

### Entregables

- `README.md` con instalación, uso y comandos.
- `docs/ISA.md`.
- `docs/ASSEMBLER.md`.
- `docs/SIMULATOR.md`.
- `docs/BENCHMARK.md`.
- `docs/METRICS.md`.
- `docs/BITACORA.md`.
- `docs/PLAN.md` actualizado.
- Informe final con:
  - decisiones de diseño,
  - problemas y soluciones,
  - resultados,
  - métricas,
  - limitaciones.

### Salida obligatoria de la fase

Reportar:

- Lista de entregables.
- Comandos para reproducir.
- Riesgos residuales.
- Frase: **“Fase 7 completada. Proyecto listo para revisión final.”**

**DETENERSE.**

---

## 11. Formato obligatorio de reporte al final de cada fase

Cada vez que termines una fase, respondé con esta estructura:

```text
FASE: <número y nombre>
ESTADO: completada / bloqueada
ARCHIVOS CREADOS:
- ...
ARCHIVOS MODIFICADOS:
- ...
PRUEBAS EJECUTADAS:
- ...
RESULTADOS:
- ...
RIESGOS / PROBLEMAS:
- ...
PREGUNTAS ABIERTAS:
- ...
PRÓXIMO PASO PROPUESTO:
- ...
ACCIÓN REQUERIDA DEL USUARIO:
- Revisar y responder "APROBADO FASE X" para continuar.