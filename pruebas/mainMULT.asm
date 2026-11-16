; =====================================================================
; Programa Principal: main.asm
; Descripción: Pide dos números, llama a MULT_SUMA y muestra el resultado.
; =====================================================================

.ORIG x3000
.EXTERNAL MULT_SUMA      ; Declara que MULT_SUMA está en otro archivo

    ; --- Pedir primer número ---
    LEA R0, MSG1
    PUTS
    IN                   ; Lee un caracter del teclado (se guarda en R0)
    ADD R0, R0, #-16
    ADD R0, R0, #-16
    ADD R0, R0, #-16     ; Convertir de ASCII a entero
    ST R0, NUM1          ; Guardar en memoria

    ; --- Pedir segundo número ---
    LEA R0, MSG2
    PUTS
    IN                   ; Lee un caracter del teclado (se guarda en R0)
    ADD R0, R0, #-16
    ADD R0, R0, #-16
    ADD R0, R0, #-16     ; Convertir de ASCII a entero
    
    ; --- Preparar argumentos y llamar a la subrutina ---
    ADD R1, R0, #0       ; R1 = Multiplicador
    LD R0, NUM1          ; R0 = Multiplicando
    JSR MULT_SUMA        ; Llamada a la subrutina externa

    ; --- Mostrar resultado en pantalla ---
    ST R0, RESULTADO     ; Guardamos el resultado en memoria (por si acaso)
    
    LEA R0, MSG_RES      ; Imprimir texto "Resultado: "
    PUTS
    
    LD R0, RESULTADO     ; Recuperar el resultado numérico
    JSR PRINT_NUM        ; Llamar a la rutina que imprime números
    
    LEA R0, NEWLINE      ; Imprimir salto de línea
    PUTS

    HALT

; =====================================================================
; Subrutina local: PRINT_NUM
; Entrada: R0 = Número entero a imprimir (0 a 99)
; Modifica: R0, R1, R2, R3
; =====================================================================
PRINT_NUM
    ; Guardar registros (incluyendo R7 porque es una subrutina)
    ST R1, P_SAVE_R1
    ST R2, P_SAVE_R2
    ST R3, P_SAVE_R3
    ST R7, P_SAVE_R7

    ; Comprobar si el número es menor a 10
    LD R1, NEG_TEN
    ADD R2, R0, R1
    BRn UN_DIGITO        ; Si R0 - 10 < 0, es de un solo dígito

    ; --- Lógica para 2 dígitos (10 a 99) ---
    ADD R2, R0, #0       ; R2 = Copia del número
    AND R1, R1, #0       ; R1 = Contador de decenas = 0

BUCLE_DECENAS
    ADD R2, R2, #-10     ; Restar 10 al número
    ADD R1, R1, #1       ; Incrementar contador de decenas
    ADD R3, R2, #-10     ; Comprobar si podemos restar otra decena
    BRzp BUCLE_DECENAS   ; Si R2 - 10 >= 0, repetir

    ; Al salir del bucle: R1 = decenas, R2 = unidades
    
    ; Imprimir decenas
    ADD R0, R1, #15
    ADD R0, R0, #15
    ADD R0, R0, #15      ; Convertir a ASCII (+48)
	ADD R0, R0, #3      ; Convertir a ASCII (+48)
    OUT
    
    ; Imprimir unidades
    ADD R0, R2, #15
    ADD R0, R0, #15
    ADD R0, R0, #15      ; Convertir a ASCII (+48)
	ADD R0, R0, #3
    OUT
    BRnzp FIN_PRINT

    ; --- Lógica para 1 dígito (0 a 9) ---
UN_DIGITO
    ADD R0, R0, #15
    ADD R0, R0, #15
    ADD R0, R0, #15      ; Convertir a ASCII (+48)
	ADD R0, R0, #3      ; Convertir a ASCII (+48)
    OUT

FIN_PRINT
    ; Restaurar registros
    LD R1, P_SAVE_R1
    LD R2, P_SAVE_R2
    LD R3, P_SAVE_R3
    LD R7, P_SAVE_R7
    RET

; --- Zona de datos del programa principal ---
MSG1      .STRINGZ "Ingrese el primer numero (0-9): "
MSG2      .STRINGZ "\nIngrese el segundo numero (0-9): "
MSG_RES   .STRINGZ "\nResultado: "
NEWLINE   .STRINGZ "\n"

NUM1      .FILL #0
RESULTADO .FILL #0

NEG_TEN   .FILL #-10

; Variables para guardar registros en la rutina PRINT_NUM
P_SAVE_R1 .FILL #0
P_SAVE_R2 .FILL #0
P_SAVE_R3 .FILL #0
P_SAVE_R7 .FILL #0

.END