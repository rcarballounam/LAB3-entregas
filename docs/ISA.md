# ISA DEL LABORATORIO 3 — LC3 EXTENDIDA CON OPCODE DE 5 BITS

## 1. Objetivo de la ISA

La ISA de referencia para este proyecto es una versión extendida de LC-3, conservando la lógica de registros, condiciones y llamadas a subrutinas, pero con una organización más explícita para:

- instrucciones con opcode fijo de 5 bits,
- registro de 16 bits,
- memoria byte-addressable de 2^16 direcciones,
- punto fijo Qm.n y enteros de 8 y 16 bits,
- acceso a bytes bajos/altos y palabras completas,
- salto condicional con N/Z/P, con V y C como flags opcionales,
- control de subrutinas y TRAP,
- compatibilidad con el benchmark del grupo 27 y sus rutinas externas.

La especificación se orienta a un simulador funcional y a un ensamblador que usen archivos `.asm` de estilo LC-3, con un linker de símbolos externos y con convenios de benchmark definidos en memoria y registros.

## 2. Modelo de registros

La ISA usa una arquitectura de registros visibles por software:

- R0-R7: 8 registros generales de 16 bits.
- PC: Program Counter, 16 bits, apunta a la instrucción actual.
- SP: stack pointer, puede mapearse en R6 si se desea compatibilidad LC-3.
- LR: link register, puede mapearse en R7 si se desea compatibilidad LC-3.

Convención para benchmark:

- R0: primer argumento o valor de retorno principal.
- R1: segundo argumento.
- R2-R5: argumentos adicionales o temporarios.
- R6: pila / stack pointer, si se utiliza.
- R7: registro de retorno de subrutina (`JSR`, `JSRR`) y de llamada al TRAP.

La semántica de registros es little-endian a nivel de acceso de bytes, pero la palabra completa en un registro siempre se interpreta como un valor 16-bit sin signo o con signo según la instrucción.

## 3. Formato base de instrucción

Todas las instrucciones tienen 16 bits:

- bits [15:11]: opcode, 5 bits.
- bits [10:0]: campos dependientes de la instrucción.

El campo de opcode permite hasta 32 instrucciones. En esta ISA, se reservan algunas para uso futuro y se definen las necesarias para el benchmark.

La alineación es obligatoria:

- cada instrucción debe comenzar en dirección par,
- PC se incrementa en 2 por instrucción,
- una instrucción en dirección impar es una excepción de ejecución.

## 4. Arquitectura de memoria

### 4.1. Dirección y tamaño

- Direcciónable: 16 bits => 65.536 ubicaciones.
- Modelo: byte-addressable.
- Capacidad total: 64 KiB.
- Cada dirección de byte tiene un valor de 8 bits.
- Las palabras de 16 bits ocupan dos bytes consecutivos.

### 4.2. Endianness

Se define little-endian para la memoria:

- palabra W en dirección A = byte bajo en A, byte alto en A+1.
- ejemplo: `0x1234` almacenado en memoria como `{0x34, 0x12}`.

Esto aplica a:

- `.FILL` de 16 bits,
- registros de 16 bits,
- memoria de datos y tablas,
- carga/almacenamiento de palabra completa.

### 4.3. Alineación

- instrucciones a dirección par.
- acceso a palabra de 16 bits solo en direcciones pares.
- acceso a byte puede ser en cualquier dirección.
- si un salto intenta apuntar a una dirección impar, se genera excepción y se aborta la ejecución.

### 4.4. Mapa de memoria sugerido

La memoria no requiere una implementación hardware rígida, pero se recomienda este esquema lógico:

- 0x0000 - 0x00FF: área reservada / sistema
- 0x0100 - 0x7FFF: datos del programa y tablas
- 0x8000 - 0xBFFF: pila y temporarios
- 0xC000 - 0xFDFF: espacio del benchmark / rutinas
- 0xFE00 - 0xFEFF: área de TRAP / E/S
- 0xFF00 - 0xFFFF: vectores de interrupción y TRAP

La pila puede crecer hacia direcciones menores. Para compatibilidad con LC-3, el stack pointer puede apuntar a la parte alta de memoria, y `CALL/RET` pueden salvar `PC+2` en R7 o en memoria.

## 5. Flags y semántica de condición

La ISA incluye flags de estado:

- N: negativo (valor del resultado < 0)
- Z: cero (valor del resultado == 0)
- P: positivo (valor del resultado > 0)
- V: overflow aritmético opcional
- C: carry / borrow opcional

Las instrucciones aritméticas actualizan los flags N/Z/P; si se habilita la detección de overflow, también pueden actualizar V y C.

Semántica del benchmark:

- `BR` evalúa los flags N, Z, P según el resultado del último cálculo.
- Condiciones de salto son obligatorias: `N`, `Z`, `P`, con combinaciones permitidas:
  - `BR` con máscara de condición en bits [10:9]
  - `BRnz`, `BRnp`, `BRzp`, etc.
- `V` y `C` se usan como flags opcionales para overflow y carry en multiplicaciones y sumas de punto fijo.

## 6. Modos de direccionamiento

La ISA soporta los siguientes modos:

### 6.1. Inmediato / literal

- valor inmediato de 5 o 6 bits en el campo de instrucción
- usado para `ADDI`, `ANDI`, `LDI`, `TRAP`, `BR`, `JSR`

### 6.2. Registro directo

- operandos en Rn
- se usa para `MOV`, `ADD`, `SUB`, `AND`, `OR`, `XOR`, `NOT`, `SHL`, `SHR`, `CMP`

### 6.3. Registro indirecto con desplazamiento

- `LDR`, `STR`, `LDB` / `STB` con base en un registro y offset inmediato
- útil para acceder a estructuras, arrays y variables estáticas

### 6.4. PC-relative

- `LD`, `ST`, `BR`, `JSR`, `LEA`
- el desplazamiento se calcula relativo a PC y escala en 2 bytes

### 6.5. Byte addressing

- `LDBL` y `STBL`: acceden al byte bajo de la palabra
- `LDBH` y `STBH`: acceden al byte alto de la palabra
- `LDW` y `STW`: acceden a palabra completa

## 7. Convenio de subrutinas

La llamada a subrutina usa la esencia del LC-3 moderno:

- `JSR` / `JSRR`: guarda `PC + 2` en R7.
- `RET`: vuelve a la dirección guardada en R7.
- el código caller preserva R0-R5 según convención del benchmark; R7 se pisa por la propia llamada.

En el benchmark del grupo 27:

- `R0` y `R1` son usados para argumentos de entrada.
- `R0` suele devolver el resultado principal.
- Los valores en `Qm.n` se pasan como palabras 16 bits.
- Cuando se requiere un resultado de doble palabra (por ejemplo Q15.16), se usan dos registros o un par de palabras consecutivas.

## 8. Instrucciones de carga/almacenamiento de bytes y palabras

### 8.1. `LDBL` — Load Byte Low

- carga el byte bajo de la palabra desde memoria a un registro de 16 bits
- se extiende el signo según convención de enteros de 8 bits con signo

Ejemplo:

- dirección base en R2
- `LDBL R0, R2, #0` -> `R0 = sign_extend(mem[R2])` (byte bajo)

### 8.2. `LDBH` — Load Byte High

- carga el byte alto desde memoria a un registro de 16 bits
- también se extiende el signo para enteros de 8 bits con signo

### 8.3. `LDW` — Load Word

- carga una palabra de 16 bits en un registro de 16 bits
- la dirección base debe ser par
- la operación es equivalente a `LDR` con offset 0 o a una carga directa de 16 bits

### 8.4. `STBL` — Store Byte Low

- almacena el byte bajo del registro en memoria
- la dirección puede ser cualquier byte

### 8.5. `STBH` — Store Byte High

- almacena el byte alto del registro en memoria

### 8.6. `STW` — Store Word

- almacena la palabra completa de 16 bits en memoria
- la dirección debe ser par

Nota: la lógica de bytes bajos y altos permite implementar formatos `Q7.8`, `Q3.12` o conversiones entre formatos sin emulación de punto flotante.

## 9. Soporte para enteros de 8 y 16 bits

La ISA debe operar con representaciones enteras tanto de 8 bits como de 16 bits.

- entero 8 bits con signo: rango [-128, 127]
- entero 8 bits sin signo: rango [0, 255]
- entero 16 bits con signo: rango [-32768, 32767]
- entero 16 bits sin signo: rango [0, 65535]

Reglas:

- las operaciones de byte usan sign-extension cuando el operando es un entero con signo
- las operaciones de palabra trabajan en 16 bits con wraparound y flags
- conversiones `Qm.n` se realizan por shift y redondeo, no por punto flotante

## 10. Formatos Q y convenciones del benchmark

El benchmark del grupo 27 usa notación de punto fijo `Qm.n`, con `n` indicando la cantidad de bits fraccionales y `m = 16 - n` para un entero de 16 bits. Se asume el caso general:

- Q7.8: 8 bits enteros y 8 bits fraccionales
- Q3.12: 3 bits enteros y 12 fraccionales
- Q15.16: 2 palabras para entero + fracción, también llamado DQ15.16

En el benchmark, los valores se pasan con signos en 16-bit y las funciones realizan conversiones mediante mascaras, corrimientos y ajustes.

La ISA debe soportar las siguientes operaciones con punto fijo:

- suma/resta de valores en el mismo formato Q
- multiplicación con corrección de formato
- división con normalización del resultado
- conversiones Qm.n a Q15.16 y viceversa
- validación de overflow y underflow por comparación con rangos

## 11. Instrucciones base propuestas

La siguiente tabla resume la ISA mínima que debe soportar el ensamblador y el simulador funcional.

| Opcode | Mnemonico | Descripción |
|---|---|---|
| 0x00 | NOP | No operation |
| 0x01 | MOV | Copia registro a registro |
| 0x02 | ADD | Suma registro + registro |
| 0x03 | ADDI | Suma registro + inmediato |
| 0x04 | SUB | Resta registro - registro |
| 0x05 | AND | AND bit a bit |
| 0x06 | OR | OR bit a bit |
| 0x07 | XOR | XOR bit a bit |
| 0x08 | NOT | Negación bit a bit |
| 0x09 | SHL | Shift lógico/aritmético izquierdo |
| 0x0A | SHR | Shift lógico/aritmético derecho |
| 0x0B | CMP | Comparación |
| 0x0C | LD | Carga directa PC-relative |
| 0x0D | LDI | Carga indirecta |
| 0x0E | LDR | Carga con base + offset |
| 0x0F | LEA | Carga dirección efectiva |
| 0x10 | ST | Almacena directa |
| 0x11 | STI | Almacena indirecta |
| 0x12 | STR | Almacena con base + offset |
| 0x13 | LDBL | Carga byte bajo |
| 0x14 | LDBH | Carga byte alto |
| 0x15 | LDW | Carga palabra completa |
| 0x16 | STBL | Guarda byte bajo |
| 0x17 | STBH | Guarda byte alto |
| 0x18 | STW | Guarda palabra completa |
| 0x19 | BR | Salto condicional |
| 0x1A | JMP | Salto indirecto |
| 0x1B | JSR | Salto a subrutina |
| 0x1C | JSRR | Salto a subrutina indirecta |
| 0x1D | RET | Retorno de subrutina |
| 0x1E | TRAP | Trap de sistema |
| 0x1F | RESERVADO | Uso futuro / reservado |

## 12. Encodings orientativos

### 12.1. Formato tipo R

Operandos en registros y un inmediato corto:

- bits [15:11]: opcode
- bits [10:9]: DR / cond
- bits [8:6]: SR1
- bits [5:3]: SR2 / opcional
- bits [2:0]: inmediato u opcional

Se usa para `MOV`, `ADD`, `SUB`, `AND`, `OR`, `XOR`, `NOT`, `SHL`, `SHR`, `CMP`.

### 12.2. Formato tipo I / inmediato

- bits [15:11]: opcode
- bits [10:9]: dst o cond
- bits [8:0]: inmediato o desplazamiento

Se usa para `ADDI`, `ANDI`, `LD`, `ST`, `BR`, `JSR`, `LEA`.

### 12.3. Formato tipo memoria

- bits [15:11]: opcode
- bits [10:9]: DR / SR
- bits [8:6]: base register
- bits [5:0]: offset o modo especial

Se usa para `LDR`, `STR`, `LDBL`, `LDBH`, `LDW`, `STBL`, `STBH`, `STW`.

### 12.4. Formato salto

- `BR`: compone la máscara condicional en bits [10:9]
- `JMP`: usa un registro base en bits [8:6]
- `JSR`: usa bit de modo y desplazamiento relativo al PC
- `JSRR`: usa registro objetivo en bits [8:6]

## 13. Manejo de salto a dirección impar

Si la dirección de destino de un salto o retorno cae en una posición impar:

- se debe generar un error de ejecución llamado `ODD_ADDRESS_EXCEPTION`
- el simulador debe terminar la ejecución con un mensaje claro
- no debe continuar en memoria con direccionamiento de byte inconsistente

Esto preserva la integridad de la ISA y reduce errores de alineación.

## 14. `.EXTERNAL` y el linker

La base de benchmark del grupo 27 usa llamadas a subrutinas externas a través de `.EXTERNAL` y `JSRR` sobre punteros. La ISA debe definir cómo se resuelven estos símbolos:

- `.EXTERNAL NAME-LABEL`: indica que el símbolo bárbaro será definido por otra unidad de compilación o módulo
- el assembler genera una tabla de símbolos externos
- el linker resuelve una referencia relativa a la dirección absoluta del símbolo
- la operación final puede expresarse como:

  `LD Rn, sub_symbol`
  `JSRR Rn`

En la práctica del benchmark, esto se ve como:

- `EXTERNAL MAIN_MENU_PROGRESO-MAIN_MENU`
- `sub_main_menu .FILL MAIN_MENU_PROGRESO-MAIN_MENU`
- `LD R1, sub_main_menu`
- `JSRR R1`

## 15. Normas para el simulador

El simulador funcional debe:

- recibir código máquina en binario, hexadecimal o decimal
- cargar memoria de 64 KiB
- decodificar instrucciones por opcode en 5 bits
- ejecutar operaciones en regs 16-bit
- actualizar N/Z/P y flags opcionales V/C
- detectar salto a dirección impar, overflow y tamaño inválido
- soportar `TRAP` con un vector mínimo para salida y pausa

## 16. Requerimientos de validación para esta ISA

El ensamblador y el simulador deben validar:

- opcode fuera de rango
- registros inexistentes
- offset fuera de rango
- acceso a palabra no alineada
- símbolo externo sin resolver
- salto a dirección impar
- inmediato fuera del ancho de campo
- bytes altos/bajos con endian no consistente

## 17. Decisiones de diseño tomadas

1. Se mantiene la familia LC-3 de registros y de llamadas a subrutinas, por compatibilidad con el benchmark y con la mayor parte del código Assembly del repositorio.
2. Se define un opcode de 5 bits para permitir un máximo de 32 instrucciones, compatible con un modelo de ejecución simple.
3. Se agregan instrucciones explícitas para byte low, byte high y word access para soportar formatos Q y arreglos de datos del benchmark.
4. Se otorga soporte para `TRAP`, `.EXTERNAL` y `JSR/RET` para que el benchmark de grupo 27 pueda seguir integrando subrutinas de otros grupos.
5. Se definen puntualmente restricciones de alineación y endianness para no depender del comportamiento implícito del simulador.

## 18. Conclusión

La ISA propuesta es una evolución de LC-3 con opcode fijo de 5 bits, accesos byte y palabra, soporte para punto fijo Qm.n y compatibilidad con el patrón de ejecución del benchmark del grupo 27. Su diseño es suficiente para que el ensamblador y el simulador puedan operar de forma reproducible, con una trazabilidad clara y con una base que permite escalar a la integración completa del laboratorio.
