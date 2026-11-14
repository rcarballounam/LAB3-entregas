# TABLA DE OPCODES — ISA DEL LABORATORIO 3

## 1. Resumen de opcodes (5 bits)

La ISA usa un opcode fijo de 5 bits en los bits [15:11]. Con 5 bits, el rango válido es 0..31.

| Opcode (binario) | Opcode (hex) | Mnemonico | Uso principal |
|---|---:|---|---|
| 00000 | 0x00 | NOP | No operation |
| 00001 | 0x01 | MOV | Copia valor entre registros |
| 00010 | 0x02 | ADD | Suma de registros |
| 00011 | 0x03 | ADDI | Suma con inmediato |
| 00100 | 0x04 | SUB | Resta |
| 00101 | 0x05 | AND | AND bit a bit |
| 00110 | 0x06 | OR | OR bit a bit |
| 00111 | 0x07 | XOR | XOR bit a bit |
| 01000 | 0x08 | NOT | Negación bit a bit |
| 01001 | 0x09 | SHL | Desplazamiento izquierdo |
| 01010 | 0x0A | SHR | Desplazamiento derecho |
| 01011 | 0x0B | CMP | Comparación |
| 01100 | 0x0C | LD | Carga PC-relative |
| 01101 | 0x0D | LDI | Carga indirecta |
| 01110 | 0x0E | LDR | Carga con base + offset |
| 01111 | 0x0F | LEA | Carga dirección efectiva |
| 10000 | 0x10 | ST | Store directo |
| 10001 | 0x11 | STI | Store indirecto |
| 10010 | 0x12 | STR | Store con base + offset |
| 10011 | 0x13 | LDBL | Load byte low |
| 10100 | 0x14 | LDBH | Load byte high |
| 10101 | 0x15 | LDW | Load word |
| 10110 | 0x16 | STBL | Store byte low |
| 10111 | 0x17 | STBH | Store byte high |
| 11000 | 0x18 | STW | Store word |
| 11001 | 0x19 | BR | Branch condicional |
| 11010 | 0x1A | JMP | Jump indirecto |
| 11011 | 0x1B | JSR | Jump to subroutine |
| 11100 | 0x1C | JSRR | Jump indirect to subroutine |
| 11101 | 0x1D | RET | Return |
| 11110 | 0x1E | TRAP | Sistema / E/S |
| 11111 | 0x1F | RESERVADO | Uso futuro |

## 2. Opcodes de control y flujo

### `BR` — branch condicional

- opcode: `11001` (`0x19`)
- formato: `N/Z/P` + desplazamiento relativo
- bits relevantes:
  - [15:11] = `11001`
  - [10:9] = máscara de condición (`N`, `Z`, `P`)
  - [8:0] = PCoffset9

Ejemplo:

- `BRnzp label` -> máscara `111`
- `BRz done` -> máscara `010`

### `JMP` — jump indirecto

- opcode: `11010` (`0x1A`)
- formato: registro base
- útil para retorno de subrutina y saltos indirectos

### `JSR` — jump to subroutine

- opcode: `11011` (`0x1B`)
- guarda `PC + 2` en `R7`
- usa offset relativo al `PC`

### `JSRR` — jump indirect to subroutine

- opcode: `11100` (`0x1C`)
- usa un registro que contiene la dirección objetivo
- guarda `PC + 2` en `R7`

### `RET` — return

- opcode: `11101` (`0x1D`)
- semántica: `PC <- R7`
- equivalentemente, `JMP R7`

## 3. Opcodes load/store para memoria

### `LD` / `ST`

- `LD`: `01100` (`0x0C`)
- `ST`: `10000` (`0x10`)
- direccionamiento PC-relative

### `LDI` / `STI`

- `LDI`: `01101` (`0x0D`)
- `STI`: `10001` (`0x11`)
- direccionamiento indirecto vía memoria

### `LDR` / `STR`

- `LDR`: `01110` (`0x0E`)
- `STR`: `10010` (`0x12`)
- direccionamiento base + offset

### `LDBL` / `LDBH` / `LDW`

- `LDBL`: `10011` (`0x13`)
- `LDBH`: `10100` (`0x14`)
- `LDW`: `10101` (`0x15`)
- acceso a byte bajo, byte alto y palabra completa

### `STBL` / `STBH` / `STW`

- `STBL`: `10110` (`0x16`)
- `STBH`: `10111` (`0x17`)
- `STW`: `11000` (`0x18`)
- almacenamiento de bytes y palabra

## 4. Opcodes aritméticos y lógicos

- `ADD` / `ADDI`: `00010` / `00011`
- `SUB`: `00100`
- `AND` / `ANDI`: `00101` + inmediato si se requiere
- `OR`, `XOR`: `00110`, `00111`
- `NOT`: `01000`
- `SHL`, `SHR`: `01001`, `01010`
- `CMP`: `01011`
- `MOV`: `00001`

## 5. Semántica de flags

Todas las instrucciones aritméticas, lógicas y comparativas deben actualizar `N`, `Z` y `P`:

- si resultado < 0 => N = 1
- si resultado == 0 => Z = 1
- si resultado > 0 => P = 1

Las instrucciones orientadas a punto fijo o a suma/resta de bytes pueden actualizar `V` y `C` cuando el hardware lo soporte. Se recomienda la siguiente convención:

- `V`: overflow aritmético
- `C`: carry-out o borrow

## 6. Registro de retorno y TRAP

### `TRAP`

- opcode: `11110` (`0x1E`)
- usa un vector del tipo 8-bit para seleccionar la subrutina del sistema
- se guarda `PC + 2` en `R7` antes de ir al servicio

Ejemplo de servicios mínimos:

- `TRAP 0x20`: salida por consola
- `TRAP 0x21`: lectura de carácter
- `TRAP 0x22`: pausa / esperar tecla

## 7. Reglas de alineación y errores

- todas las instrucciones deben estar en direcciones pares
- `LDW` y `STW` requieren que la dirección base sea par
- un salto a dirección impar genera excepción
- el ensamblador no debe aceptar código no alineado sin padding válido

## 8. Comentario sobre compatibilidad con LC-3

La ISA propuesta mantiene la sensación de LC-3: registros R0-R7, instrucciones de flujo, puntaje de flags, `JSR`/`RET`, carga/almacenamiento de memoria y acceso dirigido por registro. Sin embargo, la diferencia principal es que el opcode es fijo de 5 bits y la memoria y los accesos a bytes se vuelven explícitos y documentados para el benchmark de punto fijo.
