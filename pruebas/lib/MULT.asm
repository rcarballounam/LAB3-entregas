; =====================================================================
; Módulo: mult_suma.asm
; Descripción: Multiplicación por sumas sucesivas.
; Entradas: R0 = Multiplicando, R1 = Multiplicador (enteros positivos)
; Salida:   R0 = Producto
; Convención: Callee-saved (preserva R1 y R2 en memoria estática)
; =====================================================================

.ORIG x4000              ; Origen arbitrario para el módulo
MULT_SUMA
    ; --- Prólogo: Guardar registros callee-saved ---
    ST R1, SAVE_R1
    ST R2, SAVE_R2

    ; --- Inicialización ---
    AND R2, R2, #0       ; R2 = Acumulador (Resultado) = 0
    
    ; Verificar si el multiplicador es 0 o negativo (para evitar bucles infinitos)
    ADD R3, R1, #0
    BRnz FIN_MULT        ; Si R1 <= 0, el resultado es 0

BUCLE_MULT
    ADD R2, R2, R0       ; Resultado = Resultado + Multiplicando
    ADD R1, R1, #-1      ; Decrementar contador
    BRp BUCLE_MULT       ; Repetir mientras R1 > 0

FIN_MULT
    ; --- Epílogo: Preparar salida y restaurar registros ---
    ADD R0, R2, #0       ; Mover resultado a R0 (registro de salida)
    
    LD R1, SAVE_R1       ; Restaurar R1 original
    LD R2, SAVE_R2       ; Restaurar R2 original
    RET                  ; Retornar al llamador

; --- Zona de datos locales ---
SAVE_R1 .FILL #0
SAVE_R2 .FILL #0

.END