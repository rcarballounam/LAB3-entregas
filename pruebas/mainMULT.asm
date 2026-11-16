; =====================================================================
; Programa Principal: main.asm
; Descripción: Pide dos números por teclado, llama a MULT_SUMA y guarda.
; =====================================================================

.ORIG x3000
.EXTERNAL MULT_SUMA      ; ★ El ensamblador sabe que MULT_SUMA está en otro archivo ★

    ; --- Pedir primer número ---
    LEA R0, MSG1
    PUTS
    IN                   ; Lee un caracter del teclado. Se guarda en R0.
    ADD R0, R0, #-16
    ADD R0, R0, #-16
    ADD R0, R0, #-16     ; Convertir ASCII a entero (restar 48)
    ST R0, NUM1          ; Guardar NUM1 en memoria

    ; --- Pedir segundo número ---
    LEA R0, MSG2
    PUTS
    IN                   ; Lee un caracter del teclado. Se guarda en R0.
    ADD R0, R0, #-16
    ADD R0, R0, #-16
    ADD R0, R0, #-16     ; Convertir ASCII a entero (restar 48)
    
    ; --- Preparar argumentos para la subrutina ---
    ADD R1, R0, #0       ; R1 = Multiplicador (el segundo número)
    LD R0, NUM2          ; R0 = Multiplicando (el primer número guardado)

    ; --- Llamar a la subrutina externa ---
    JSR MULT_SUMA        ; El linker resolverá la dirección a x4000

    ; --- Guardar resultado y terminar ---
    ST R0, RESULTADO     ; Guardar el resultado en memoria
    HALT

; --- Zona de datos del programa principal ---
MSG1      .STRINGZ "Ingrese el primer numero (0-9): "
MSG2      .STRINGZ "\nIngrese el segundo numero (0-9): "
NUM1      .FILL #0
NUM2      .FILL #0
RESULTADO .FILL #0       ; Acá quedará el resultado (ej: 4 * 3 = x000C)

.END