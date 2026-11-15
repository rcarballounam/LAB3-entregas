        .ORIG x3000

; ==========================================================
; PUNTEROS A DATOS
; ==========================================================

PUNTERO_RESULTADO_SENO       .FILL RESULTADO_SENO
PUNTERO_RESULTADO_COSENO     .FILL RESULTADO_COSENO

PUNTERO_PI       .FILL PI_SOBRE_2
PUNTERO_ANGULO   .FILL ANGULO_PRUEBA

; ==========================================================
; SUBRUTINA: GUARDAR_ANGULO
;
; ENTRADA:
; R0 = Angulo Q3.12
;
; OBJETIVO:
; Guardar el angulo recibido en ANGULO_PRUEBA.
;
; PRESERVA:
; R1-R5 y R6.
; R7 no necesita guardarse porque esta rutina
; no realiza llamadas anidadas.
; ==========================================================

GUARDAR_ANGULO

        ; Guardar registros utilizados.
        ADD R6, R6, #-1
        STR R1, R6, #0

        ADD R6, R6, #-1
        STR R2, R6, #0

        ADD R6, R6, #-1
        STR R3, R6, #0

        ADD R6, R6, #-1
        STR R4, R6, #0

        ADD R6, R6, #-1
        STR R5, R6, #0

        ; Obtener la direccion del angulo.
        LEA R5, PUNTERO_ANGULO
        LDR R5, R5, #0

        ; Guardar el valor recibido en R0.
        STR R0, R5, #0

        ; Restaurar registros.
        LDR R5, R6, #0
        ADD R6, R6, #1

        LDR R4, R6, #0
        ADD R6, R6, #1

        LDR R3, R6, #0
        ADD R6, R6, #1

        LDR R2, R6, #0
        ADD R6, R6, #1

        LDR R1, R6, #0
        ADD R6, R6, #1

        RET

; ==========================================================
; INTERFAZ PUBLICA: SENO_TABLA
;
; ENTRADA:
; R0 = Angulo en Q3.12.
;
; SALIDA:
; R0 = Seno en Q1.14.
;
; PRESERVA:
; R1-R5, R6 y R7.
; ==========================================================

SENO_TABLA

        ; Guardar registros del programa llamador.

        ADD R6, R6, #-1
        STR R1, R6, #0

        ADD R6, R6, #-1
        STR R2, R6, #0

        ADD R6, R6, #-1
        STR R3, R6, #0

        ADD R6, R6, #-1
        STR R4, R6, #0

        ADD R6, R6, #-1
        STR R5, R6, #0

        ADD R6, R6, #-1
        STR R7, R6, #0

        ; Guardar el angulo recibido en R0.

        LEA R4, PUNTERO_ANGULO
        LDR R4, R4, #0
        STR R0, R4, #0

        ; Ejecutar el algoritmo completo.

        JSR CALCULAR_AMBOS

        ; Recuperar el resultado del seno.

        LEA R4, PUNTERO_RESULTADO_SENO
        LDR R4, R4, #0
        LDR R0, R4, #0

        ; Restaurar registros del llamador.

        LDR R7, R6, #0
        ADD R6, R6, #1

        LDR R5, R6, #0
        ADD R6, R6, #1

        LDR R4, R6, #0
        ADD R6, R6, #1

        LDR R3, R6, #0
        ADD R6, R6, #1

        LDR R2, R6, #0
        ADD R6, R6, #1

        LDR R1, R6, #0
        ADD R6, R6, #1

        RET


; ==========================================================
; INTERFAZ PUBLICA: COSENO_TABLA
;
; ENTRADA:
; R0 = Angulo en Q3.12.
;
; SALIDA:
; R0 = Coseno en Q1.14.
;
; PRESERVA:
; R1-R5, R6 y R7.
; ==========================================================

COSENO_TABLA

        ; Guardar registros del programa llamador.

        ADD R6, R6, #-1
        STR R1, R6, #0

        ADD R6, R6, #-1
        STR R2, R6, #0

        ADD R6, R6, #-1
        STR R3, R6, #0

        ADD R6, R6, #-1
        STR R4, R6, #0

        ADD R6, R6, #-1
        STR R5, R6, #0

        ADD R6, R6, #-1
        STR R7, R6, #0

        ; Guardar el angulo recibido en R0.

        LEA R4, PUNTERO_ANGULO
        LDR R4, R4, #0
        STR R0, R4, #0

        ; Ejecutar el algoritmo completo.

        JSR CALCULAR_AMBOS

        ; Recuperar el resultado del coseno.

        LEA R4, PUNTERO_RESULTADO_COSENO
        LDR R4, R4, #0
        LDR R0, R4, #0

        ; Restaurar registros del llamador.

        LDR R7, R6, #0
        ADD R6, R6, #1

        LDR R5, R6, #0
        ADD R6, R6, #1

        LDR R4, R6, #0
        ADD R6, R6, #1

        LDR R3, R6, #0
        ADD R6, R6, #1

        LDR R2, R6, #0
        ADD R6, R6, #1

        LDR R1, R6, #0
        ADD R6, R6, #1

        RET


; ==========================================================
; SUBRUTINA PRINCIPAL: CALCULAR_AMBOS
;
; ENTRADA:
; ANGULO_PRUEBA = Angulo Q3.12 recibido desde R0.
;
; SALIDAS EN MEMORIA:
; RESULTADO_SENO
; RESULTADO_COSENO
;
; PRESERVA:
; R1-R5 y R7.
; R6 recupera su valor original.
;
; R0 se utiliza como registro de trabajo.
; ==========================================================

CALCULAR_AMBOS

        ; Guardar el contexto del programa llamador.

        ADD R6, R6, #-1
        STR R1, R6, #0

        ADD R6, R6, #-1
        STR R2, R6, #0

        ADD R6, R6, #-1
        STR R3, R6, #0

        ADD R6, R6, #-1
        STR R4, R6, #0

        ADD R6, R6, #-1
        STR R5, R6, #0

        ; Guardar R7 porque el algoritmo utiliza JSR.

        ADD R6, R6, #-1
        STR R7, R6, #0

        ; Comienzo del algoritmo original.

        AND R1, R1, #0

        ; Recuperar la dirección de PI/2.
        LEA R4, PUNTERO_PI
        LDR R4, R4, #0

        ; Recuperar la dirección del ángulo de entrada.
        LEA R5, PUNTERO_ANGULO
        LDR R5, R5, #0

        ; Cargar el ángulo Q3.12.
        LDR R0, R5, #0

; --------------------------------------------------
; COMPROBACIÓN DE CASOS ESPECIALES
; --------------------------------------------------

COMPROBAR_CERO
        BRz CASO_ESPECIAL_CERO ; LDR actualizó NZP: si R0=0, es caso especial

COMPROBAR_90
        LDR R5, R4, #0 ; Cargar PI/2
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R0, R5 ; Comparar ángulo con PI/2
        BRz CASO_ESPECIAL_90

COMPROBAR_180
        LDR R5, R4, #1 ; Cargar PI
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R0, R5 ; Comparar ángulo con PI
        BRz CASO_ESPECIAL_180

COMPROBAR_270
        LDR R5, R4, #2 ; Cargar 3PI/2
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R0, R5 ; Comparar ángulo con 3PI/2
        BRz CASO_ESPECIAL_270

COMPROBAR_360
        LDR R5, R4, #3 ; Cargar 2PI
        NOT R5, R5
        ADD R5, R5, #1
        ADD R5, R0, R5 ; Comparar ángulo con 2PI
        BRz CASO_ESPECIAL_360

; --------------------------------------------------
; DETERMINACIÓN DEL CUADRANTE
; --------------------------------------------------

COMPROBAR_CUADRANTE_1
        LDR R5, R4, #0 ; Cargar PI/2
        NOT R5, R5
        ADD R5, R5, #1
        ADD R2, R0, R5 ; Comparar ángulo con PI/2
        BRn CUADRANTE_1

COMPROBAR_CUADRANTE_2
        LDR R5, R4, #1 ; Cargar PI
        NOT R5, R5
        ADD R5, R5, #1
        ADD R2, R0, R5 ; Comparar ángulo con PI
        BRn CUADRANTE_2

COMPROBAR_CUADRANTE_3
        LDR R5, R4, #2 ; Cargar 3PI/2
        NOT R5, R5
        ADD R5, R5, #1
        ADD R2, R0, R5 ; Comparar ángulo con 3PI/2
        BRn CUADRANTE_3

COMPROBAR_CUADRANTE_4
        AND R1, R1, #0
        ADD R1, R1, #4 ; Identificar cuadrante 4
        BR CALCULAR_REFERENCIA_4

; --------------------------------------------------
; CÁLCULO DEL ÁNGULO DE REFERENCIA
; --------------------------------------------------

CUADRANTE_1
        AND R1, R1, #0
        ADD R1, R1, #1 ; Identificar cuadrante 1
        ADD R2, R0, #0 ; Referencia = ángulo original
        BR CALCULAR_COFUNCION

CUADRANTE_2
        AND R1, R1, #0
        ADD R1, R1, #2 ; Identificar cuadrante 2
        LDR R2, R4, #1 ; Cargar PI
        NOT R2, R2
        ADD R2, R2, #1
        ADD R2, R0, R2 ; Calcular ángulo - PI
        NOT R2, R2
        ADD R2, R2, #1 ; Referencia = PI - ángulo
        BR CALCULAR_COFUNCION

CUADRANTE_3
        AND R1, R1, #0
        ADD R1, R1, #3 ; Identificar cuadrante 3
        LDR R2, R4, #1 ; Cargar PI
        NOT R2, R2
        ADD R2, R2, #1
        ADD R2, R0, R2 ; Referencia = ángulo - PI
        BR CALCULAR_COFUNCION

CALCULAR_REFERENCIA_4
        LDR R2, R4, #3 ; Cargar 2PI
        NOT R2, R2
        ADD R2, R2, #1
        ADD R2, R0, R2 ; Calcular ángulo - 2PI
        NOT R2, R2
        ADD R2, R2, #1 ; Referencia = 2PI - ángulo

; --------------------------------------------------
; CÁLCULO DEL ÁNGULO COMPLEMENTARIO
; --------------------------------------------------

CALCULAR_COFUNCION
        LDR R3, R4, #0 ; Cargar PI/2
        NOT R3, R3
        ADD R3, R3, #1
        ADD R3, R2, R3 ; Calcular referencia - PI/2
        NOT R3, R3
        ADD R3, R3, #1 ; Cofunción = PI/2 - referencia
        BR DETERMINAR_SIGNOS

; --------------------------------------------------
; DETERMINACIÓN DE SIGNOS PARA CASOS NORMALES
; --------------------------------------------------

DETERMINAR_SIGNOS
        ADD R5, R1, #-1
        BRz SIGNOS_CUADRANTE_1

        ADD R5, R1, #-2
        BRz SIGNOS_CUADRANTE_2

        ADD R5, R1, #-3
        BRz SIGNOS_CUADRANTE_3

        BR SIGNOS_CUADRANTE_4

SIGNOS_CUADRANTE_1
        AND R0, R0, #0
        ADD R0, R0, #1 ; Signo del seno = +1
        AND R4, R4, #0
        ADD R4, R4, #1 ; Signo del coseno = +1
        BR GUARDAR_SIGNOS

SIGNOS_CUADRANTE_2
        AND R0, R0, #0
        ADD R0, R0, #1 ; Signo del seno = +1
        AND R4, R4, #0
        ADD R4, R4, #-1 ; Signo del coseno = -1
        BR GUARDAR_SIGNOS

SIGNOS_CUADRANTE_3
        AND R0, R0, #0
        ADD R0, R0, #-1 ; Signo del seno = -1
        AND R4, R4, #0
        ADD R4, R4, #-1 ; Signo del coseno = -1
        BR GUARDAR_SIGNOS

SIGNOS_CUADRANTE_4
        AND R0, R0, #0
        ADD R0, R0, #-1 ; Signo del seno = -1
        AND R4, R4, #0
        ADD R4, R4, #1 ; Signo del coseno = +1
        BR GUARDAR_SIGNOS

; --------------------------------------------------
; DETERMINACIÓN DE SIGNOS PARA CASOS ESPECIALES
; --------------------------------------------------

CASO_ESPECIAL_CERO
        AND R1, R1, #0
        AND R2, R2, #0
        AND R0, R0, #0
        ADD R4, R0, #1

; Referencia del seno = 0.
        AND R2, R2, #0

; Referencia del coseno = 90 grados.
        LEA R5, PI_SOBRE_2
        LDR R3, R5, #0

        BR GUARDAR_SIGNOS

CASO_ESPECIAL_90
        AND R1, R1, #0
        AND R3, R3, #0
        AND R0, R0, #0
        ADD R0, R0, #1
        AND R4, R4, #0

; Referencia del seno = 90 grados.
        LEA R5, PI_SOBRE_2
        LDR R2, R5, #0

; Referencia del coseno = 0.
        AND R3, R3, #0

        BR GUARDAR_SIGNOS

CASO_ESPECIAL_180
        AND R1, R1, #0
        AND R0, R0, #0
        AND R4, R4, #0
        ADD R4, R4, #-1

; Referencia del seno = 0.
        AND R2, R2, #0

; Referencia del coseno = 90 grados.
        LEA R5, PI_SOBRE_2
        LDR R3, R5, #0

        BR GUARDAR_SIGNOS

CASO_ESPECIAL_270
        AND R1, R1, #0
        AND R3, R3, #0
        AND R0, R0, #0
        ADD R0, R0, #-1
        AND R4, R4, #0

; Referencia del seno = 90 grados.
        LEA R5, PI_SOBRE_2
        LDR R2, R5, #0

; Referencia del coseno = 0.
        AND R3, R3, #0

        BR GUARDAR_SIGNOS

CASO_ESPECIAL_360
        AND R1, R1, #0
        AND R0, R0, #0
        AND R4, R4, #0
        ADD R4, R4, #1

; Referencia del seno = 0.
        AND R2, R2, #0

; Referencia del coseno = 90 grados.
        LEA R5, PI_SOBRE_2
        LDR R3, R5, #0

; ==========================================================
; GUARDAR REFERENCIAS Y SIGNOS
; ==========================================================

GUARDAR_SIGNOS

; Guardar referencia del seno.

        LEA R5, REFERENCIA_SENO_PRUEBA
        STR R2, R5, #0

; Guardar referencia del coseno.

        LEA R5, REFERENCIA_COSENO_PRUEBA
        STR R3, R5, #0

; Guardar signo del seno.

        LEA R5, SIGNO_SENO
        STR R0, R5, #0

; Guardar signo del coseno.

        LEA R5, SIGNO_COSENO
        STR R4, R5, #0

; Continuar con el cálculo de índices de la Prueba 8.

        BR CALCULO_SENO
        
; ==========================================================
; PRIMER CALCULO: INDICE DEL SENO
; ==========================================================

; ----------------------------------------------------------
; CARGA DE LA REFERENCIA DEL SENO
; ----------------------------------------------------------

CALCULO_SENO
        LEA R5, REFERENCIA_SENO_PRUEBA
        LDR R0, R5, #0

; ----------------------------------------------------------
; INICIALIZACION DEL ACUMULADOR DE 32 BITS
;
; R2:R1 representa el acumulador:
; R2 = palabra alta
; R1 = palabra baja
; ----------------------------------------------------------

        AND R1, R1, #0
        AND R2, R2, #0

; ----------------------------------------------------------
; MULTIPLICACION POR 58671
;
; Se procesan los bits del multiplicador desde el bit 15
; hasta el bit 0.
;
; Por cada bit:
; 1. Se duplica el acumulador de 32 bits.
; 2. Si el bit vale 1, se suma la referencia.
; ----------------------------------------------------------

; BIT 15 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 14 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 13 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 12 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 11 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 10 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 9 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 8 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 7 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 6 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 5 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 4 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 3 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 2 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 1 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 0 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; ----------------------------------------------------------
; ALMACENAMIENTO DEL PRODUCTO DEL SENO
; ----------------------------------------------------------

        LEA R5, PRODUCTO_SENO_BAJO
        STR R1, R5, #0

        LEA R5, PRODUCTO_SENO_ALTO
        STR R2, R5, #0

; ----------------------------------------------------------
; CONVERSION DEL PRODUCTO A GRADOS Q8.8
;
; Para obtener Q8.8 dividimos el producto por 2^14.
;
; G_Q8.8 = (PALABRA_ALTA * 4) + BITS_15_14
;
; R4 almacena temporalmente los dos bits extraidos
; de la palabra baja.
; ----------------------------------------------------------

AND R4,R4,#0

; Comprobar bit 15 de R1
ADD R3,R1,#0
BRzp SENO_BIT_15_CERO
ADD R4,R4,#2

SENO_BIT_15_CERO

; Comprobar bit 14 de R1
ADD R3,R1,R1
BRzp SENO_BIT_14_CERO
ADD R4,R4,#1

SENO_BIT_14_CERO

; Incorporar los dos bits al resultado Q8.8
ADD R2,R2,R2
ADD R2,R2,R2
ADD R2,R2,R4

; ----------------------------------------------------------
; ALMACENAMIENTO DE LOS GRADOS Q8.8 DEL SENO
; ----------------------------------------------------------

        LEA R5, GRADOS_SENO_Q8_8
        STR R2, R5, #0

; ----------------------------------------------------------
; SEPARACION DEL INDICE Y LA FRACCION DEL SENO
;
; R2 contiene los grados en Q8.8.
; Cada resta de 256 obtiene un grado entero.
; Al finalizar:
; R4 = indice inferior (parte entera).
; R2 = fraccion (0..255).
; ----------------------------------------------------------

        LEA R5, CONSTANTE_MENOS_256
        LDR R5, R5, #0

        AND R4, R4, #0

OBTENER_INDICE_SENO

        ADD R3, R2, R5
        BRn FIN_INDICE_SENO

        ADD R2, R3, #0
        ADD R4, R4, #1

        BR OBTENER_INDICE_SENO

FIN_INDICE_SENO

; Guardar por separado el indice y la fraccion.

        LEA R5, INDICE_SENO
        STR R4, R5, #0

        LEA R5, FRACCION_SENO
        STR R2, R5, #0


; ==========================================================
; SEGUNDO CALCULO: INDICE DEL COSENO
; ==========================================================

; ----------------------------------------------------------
; CARGA DE LA REFERENCIA DEL COSENO
;
; En el programa principal esta referencia se encuentra
; en R3. Para esta prueba independiente la cargamos
; desde REFERENCIA_COSENO_PRUEBA.
; ----------------------------------------------------------

        LEA R5, REFERENCIA_COSENO_PRUEBA
        LDR R0, R5, #0

; ----------------------------------------------------------
; REINICIALIZACION DEL ACUMULADOR DE 32 BITS
;
; Es necesario comenzar desde cero porque ahora se
; procesa una referencia diferente: la del coseno.
; ----------------------------------------------------------

        AND R1, R1, #0
        AND R2, R2, #0

; ----------------------------------------------------------
; MULTIPLICACION POR 58671
; Se conserva exactamente el mismo procedimiento
; utilizado anteriormente para el indice del seno.
; ----------------------------------------------------------

; BIT 15 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 14 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 13 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 12 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 11 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 10 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 9 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 8 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 7 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 6 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 5 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 4 = 0

        JSR DOBLAR_ACUMULADOR

; BIT 3 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 2 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 1 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; BIT 0 = 1

        JSR DOBLAR_ACUMULADOR
        JSR SUMAR_REFERENCIA

; ----------------------------------------------------------
; ALMACENAMIENTO DEL PRODUCTO DEL COSENO
; ----------------------------------------------------------

        LEA R5, PRODUCTO_COSENO_BAJO
        STR R1, R5, #0

        LEA R5, PRODUCTO_COSENO_ALTO
        STR R2, R5, #0

; ----------------------------------------------------------
; CONVERSION DEL PRODUCTO A GRADOS Q8.8
; ----------------------------------------------------------

AND R4,R4,#0

; Comprobar bit 15 de R1
ADD R3,R1,#0
BRzp COSENO_BIT_15_CERO
ADD R4,R4,#2

COSENO_BIT_15_CERO

; Comprobar bit 14 de R1
ADD R3,R1,R1
BRzp COSENO_BIT_14_CERO
ADD R4,R4,#1

COSENO_BIT_14_CERO

; Incorporar los dos bits al resultado Q8.8
ADD R2,R2,R2
ADD R2,R2,R2
ADD R2,R2,R4

; ----------------------------------------------------------
; ALMACENAMIENTO DE LOS GRADOS Q8.8 DEL COSENO
; ----------------------------------------------------------

        LEA R5, GRADOS_COSENO_Q8_8
        STR R2, R5, #0

; ----------------------------------------------------------
; SEPARACION DEL INDICE Y LA FRACCION DEL COSENO
;
; R2 contiene los grados en Q8.8.
; Al finalizar:
; R4 = indice inferior (parte entera).
; R2 = fraccion (0..255).
; ----------------------------------------------------------

        LEA R5, CONSTANTE_MENOS_256
        LDR R5, R5, #0

        AND R4, R4, #0

OBTENER_INDICE_COSENO

        ADD R3, R2, R5
        BRn FIN_INDICE_COSENO

        ADD R2, R3, #0
        ADD R4, R4, #1

        BR OBTENER_INDICE_COSENO

FIN_INDICE_COSENO

; Guardar por separado el indice y la fraccion.

        LEA R5, INDICE_COSENO
        STR R4, R5, #0

        LEA R5, FRACCION_COSENO
        STR R2, R5, #0


; ==========================================================
; INTERPOLACION DEL SENO
; ==========================================================

; Preparar los datos de entrada de la rutina comun.

        LEA R5, INDICE_SENO
        LDR R0, R5, #0
        LEA R5, INDICE_INTERPOLACION
        STR R0, R5, #0

        LEA R5, FRACCION_SENO
        LDR R0, R5, #0
        LEA R5, FRACCION_INTERPOLACION
        STR R0, R5, #0

        JSR INTERPOLAR_TABLA

; Guardar el resultado interpolado del seno.

        LEA R5, RESULTADO_INTERPOLADO
        LDR R1, R5, #0
        LEA R5, RESULTADO_SENO
        STR R1, R5, #0


; ==========================================================
; INTERPOLACION DEL COSENO
; ==========================================================

        LEA R5, INDICE_COSENO
        LDR R0, R5, #0
        LEA R5, INDICE_INTERPOLACION
        STR R0, R5, #0

        LEA R5, FRACCION_COSENO
        LDR R0, R5, #0
        LEA R5, FRACCION_INTERPOLACION
        STR R0, R5, #0

        JSR INTERPOLAR_TABLA

; Guardar el resultado interpolado del coseno.

        LEA R5, RESULTADO_INTERPOLADO
        LDR R2, R5, #0
        LEA R5, RESULTADO_COSENO
        STR R2, R5, #0


; ----------------------------------------------------------
; RECUPERAR AMBOS RESULTADOS INTERPOLADOS
; ----------------------------------------------------------
;
; La interpolacion del coseno utiliza R1 y R2 como
; registros de trabajo y puede sobrescribir el seno.
;
; Por eso recuperamos ambos resultados desde memoria
; antes de aplicar los signos de cada cuadrante.
;
; R1 = Resultado interpolado del seno.
; R2 = Resultado interpolado del coseno.
; ----------------------------------------------------------

        LEA R5, RESULTADO_SENO
        LDR R1, R5, #0

        LEA R5, RESULTADO_COSENO
        LDR R2, R5, #0


; ----------------------------------------------------------
; 1. APLICAR SIGNO AL SENO
; ----------------------------------------------------------

        LEA R5, SIGNO_SENO
        LDR R3, R5, #0

; Comprobar si el signo del seno es cero.

        ADD R3, R3, #0
        BRz SENO_CERO

; Comprobar si el signo del seno es negativo.

        BRn SENO_NEGATIVO

; Si llegamos aqui, el signo es positivo.
; Por lo tanto, R1 conserva su valor original.

        BRnzp SENO_FINALIZADO


; ----------------------------------------------------------
; SENO NEGATIVO
; ----------------------------------------------------------

SENO_NEGATIVO

; Aplicar complemento a dos para cambiar el signo.

        NOT R1, R1
        ADD R1, R1, #1

        BRnzp SENO_FINALIZADO


; ----------------------------------------------------------
; SENO IGUAL A CERO
; ----------------------------------------------------------

SENO_CERO

; Forzar el resultado del seno a cero.

        AND R1, R1, #0


SENO_FINALIZADO


; ----------------------------------------------------------
; 2. APLICAR SIGNO AL COSENO
; ----------------------------------------------------------

        LEA R5, SIGNO_COSENO
        LDR R3, R5, #0

; Comprobar si el signo del coseno es cero.

        ADD R3, R3, #0
        BRz COSENO_CERO

; Comprobar si el signo del coseno es negativo.

        BRn COSENO_NEGATIVO

; Si llegamos aqui, el signo es positivo.
; Por lo tanto, R2 conserva su valor original.

        BRnzp COSENO_FINALIZADO


; ----------------------------------------------------------
; COSENO NEGATIVO
; ----------------------------------------------------------

COSENO_NEGATIVO

; Aplicar complemento a dos para cambiar el signo.

        NOT R2, R2
        ADD R2, R2, #1

        BRnzp COSENO_FINALIZADO


; ----------------------------------------------------------
; COSENO IGUAL A CERO
; ----------------------------------------------------------

COSENO_CERO

; Forzar el resultado del coseno a cero.

        AND R2, R2, #0


COSENO_FINALIZADO


; ----------------------------------------------------------
; 3. ACTUALIZAR LOS RESULTADOS EN MEMORIA
; ----------------------------------------------------------

; Guardar el seno definitivo en memoria.

        LEA R5, RESULTADO_SENO
        STR R1, R5, #0

; Guardar el coseno definitivo en memoria.

        LEA R5, RESULTADO_COSENO
        STR R2, R5, #0


; ==========================================================
; FINALIZACION DE CALCULAR_AMBOS
;
; Restaurar el contexto del programa llamador.
; ==========================================================

        ; Restaurar R7 primero.
        LDR R7, R6, #0
        ADD R6, R6, #1

        LDR R5, R6, #0
        ADD R6, R6, #1

        LDR R4, R6, #0
        ADD R6, R6, #1

        LDR R3, R6, #0
        ADD R6, R6, #1

        LDR R2, R6, #0
        ADD R6, R6, #1

        LDR R1, R6, #0
        ADD R6, R6, #1

        RET


; ==========================================================
; SUBRUTINA: DOBLAR_ACUMULADOR
;
; OBJETIVO:
; Multiplicar por dos el acumulador de 32 bits R2:R1.
;
; Se comprueba el bit 15 de R1 para detectar si debe
; transferirse un acarreo hacia la palabra alta R2.
; ==========================================================

DOBLAR_ACUMULADOR

        ADD R3, R1, #0
        BRn DOBLAR_CON_ACARREO

; Caso sin acarreo desde la palabra baja.

        ADD R1, R1, R1
        ADD R2, R2, R2

        RET

; Caso en el que el bit 15 original de R1 era 1.

DOBLAR_CON_ACARREO

        ADD R1, R1, R1
        ADD R2, R2, R2
        ADD R2, R2, #1

        RET


; ==========================================================
; SUBRUTINA: SUMAR_REFERENCIA
;
; OBJETIVO:
; Sumar R0 a la palabra baja del acumulador.
;
; Si la suma produce un acarreo unsigned, se incrementa
; la palabra alta R2.
; ==========================================================

SUMAR_REFERENCIA

        ADD R3, R1, #0
        BRn SUMAR_DESDE_NEGATIVO

; La palabra baja era menor que 32768.

        ADD R1, R1, R0

        RET

; La palabra baja era mayor o igual a 32768.
; Comprobar si la suma produce un acarreo.

SUMAR_DESDE_NEGATIVO

        ADD R1, R1, R0
        BRn FIN_SUMAR_REFERENCIA

        ADD R2, R2, #1

FIN_SUMAR_REFERENCIA

        RET


; ==========================================================
; DATOS DE PRUEBA
; ==========================================================

; Ángulo original de entrada en Q3.12.
ANGULO_PRUEBA .BLKW #1

; Constantes para determinar cuadrantes.
PI_SOBRE_2                  .FILL #6434
PI                          .FILL #12868
TRES_PI_SOBRE_2             .FILL #19302
DOS_PI                      .FILL #25736

; Referencias calculadas por la Prueba 7.
REFERENCIA_SENO_PRUEBA      .BLKW #1
REFERENCIA_COSENO_PRUEBA    .BLKW #1

; Signos calculados por la Prueba 7.
SIGNO_SENO                  .BLKW #1
SIGNO_COSENO                .BLKW #1


; ==========================================================
; CONSTANTES DE CONVERSION Y REDONDEO
; ==========================================================

CONSTANTE_128                .FILL #128
CONSTANTE_MENOS_128          .FILL #-128
CONSTANTE_MENOS_256          .FILL #-256
MASCARA_00FF                 .FILL x00FF


; ==========================================================
; RESULTADOS INTERMEDIOS DEL SENO
; ==========================================================

PRODUCTO_SENO_BAJO           .BLKW #1
PRODUCTO_SENO_ALTO           .BLKW #1

GRADOS_SENO_Q8_8             .BLKW #1
INDICE_SENO                  .BLKW #1
FRACCION_SENO                .BLKW #1


; ==========================================================
; RESULTADOS INTERMEDIOS DEL COSENO
; ==========================================================

PRODUCTO_COSENO_BAJO         .BLKW #1
PRODUCTO_COSENO_ALTO         .BLKW #1

GRADOS_COSENO_Q8_8           .BLKW #1
INDICE_COSENO                .BLKW #1
FRACCION_COSENO              .BLKW #1

; ==========================================================
; RESULTADOS DE LA CONSULTA A LA TABLA
; ==========================================================

RESULTADO_SENO       .BLKW #1
RESULTADO_COSENO     .BLKW #1

; Datos de trabajo de la interpolacion.
INDICE_INTERPOLACION         .BLKW #1
FRACCION_INTERPOLACION       .BLKW #1
VALOR_INFERIOR               .BLKW #1
DIFERENCIA_ABSOLUTA          .BLKW #1
SIGNO_INCREMENTO             .BLKW #1
PRODUCTO_INTERPOLACION_BAJO  .BLKW #1
PRODUCTO_INTERPOLACION_ALTO  .BLKW #1
COCIENTE_INTERPOLACION       .BLKW #1
RESTO_INTERPOLACION          .BLKW #1
RESULTADO_INTERPOLADO        .BLKW #1

; ==========================================================
; TABLA DE SENO EN FORMATO Q1.14
; 91 VALORES: DESDE 0 GRADOS HASTA 90 GRADOS
; ==========================================================

TABLA_SENO
        .FILL #0
        .FILL #286
        .FILL #572
        .FILL #857
        .FILL #1143
        .FILL #1428
        .FILL #1713
        .FILL #1997
        .FILL #2280
        .FILL #2563
        .FILL #2845
        .FILL #3126
        .FILL #3406
        .FILL #3686
        .FILL #3964
        .FILL #4240
        .FILL #4516
        .FILL #4790
        .FILL #5063
        .FILL #5334
        .FILL #5604
        .FILL #5872
        .FILL #6138
        .FILL #6402
        .FILL #6664
        .FILL #6924
        .FILL #7182
        .FILL #7438
        .FILL #7692
        .FILL #7943
        .FILL #8192
        .FILL #8438
        .FILL #8682
        .FILL #8923
        .FILL #9162
        .FILL #9397
        .FILL #9630
        .FILL #9860
        .FILL #10087
        .FILL #10311
        .FILL #10531
        .FILL #10749
        .FILL #10963
        .FILL #11174
        .FILL #11381
        .FILL #11585
        .FILL #11786
        .FILL #11982
        .FILL #12176
        .FILL #12365
        .FILL #12551
        .FILL #12733
        .FILL #12911
        .FILL #13085
        .FILL #13255
        .FILL #13421
        .FILL #13583
        .FILL #13741
        .FILL #13894
        .FILL #14044
        .FILL #14189
        .FILL #14330
        .FILL #14466
        .FILL #14598
        .FILL #14726
        .FILL #14849
        .FILL #14968
        .FILL #15082
        .FILL #15191
        .FILL #15296
        .FILL #15396
        .FILL #15491
        .FILL #15582
        .FILL #15668
        .FILL #15749
        .FILL #15826
        .FILL #15897
        .FILL #15964
        .FILL #16026
        .FILL #16083
        .FILL #16135
        .FILL #16182
        .FILL #16225
        .FILL #16262
        .FILL #16294
        .FILL #16322
        .FILL #16344
        .FILL #16362
        .FILL #16374
        .FILL #16382
        .FILL #16384


; ==========================================================
; SUBRUTINA: INTERPOLAR_TABLA
;
; OBJETIVO:
; Calcular la interpolacion lineal entre dos valores
; consecutivos de TABLA_SENO.
;
; ENTRADAS EN MEMORIA:
; INDICE_INTERPOLACION   = indice inferior (0..90).
; FRACCION_INTERPOLACION = fraccion Q0.8 (0..255).
;
; SALIDA EN MEMORIA:
; RESULTADO_INTERPOLADO = valor interpolado Q1.14.
;
; El calculo se realiza en el primer cuadrante. La rutina
; principal aplica posteriormente el signo del cuadrante.
; Esta rutina no realiza llamadas anidadas.
; ==========================================================

INTERPOLAR_TABLA

; ----------------------------------------------------------
; 1. OBTENER EL VALOR INFERIOR DE LA TABLA
; ----------------------------------------------------------

        LEA R5, INDICE_INTERPOLACION
        LDR R4, R5, #0

        LEA R3, TABLA_SENO
        ADD R5, R3, R4
        LDR R1, R5, #0

        LEA R5, VALOR_INFERIOR
        STR R1, R5, #0

; En el indice 90 no existe un siguiente elemento.
; La fraccion debe ser cero en este extremo: se devuelve
; directamente el ultimo valor de la tabla.

        ADD R4, R4, #-15
        ADD R4, R4, #-15
        ADD R4, R4, #-15
        ADD R4, R4, #-15
        ADD R4, R4, #-15
        ADD R4, R4, #-15
        BRnp CONTINUAR_INTERPOLACION

; Caso indice 90: devolver directamente TABLA_SENO[90].

        LEA R5, RESULTADO_INTERPOLADO
        STR R1, R5, #0
        RET

CONTINUAR_INTERPOLACION

; ----------------------------------------------------------
; 2. OBTENER EL VALOR SUPERIOR Y CALCULAR LA DIFERENCIA
; ----------------------------------------------------------

        LEA R5, INDICE_INTERPOLACION
        LDR R4, R5, #0
        ADD R4, R4, #1
        ADD R5, R3, R4
        LDR R2, R5, #0

; Diferencia = valor superior - valor inferior.

        NOT R1, R1
        ADD R1, R1, #1
        ADD R2, R2, R1

; Registrar el signo de la diferencia y obtener su magnitud.

        AND R0, R0, #0
        ADD R2, R2, #0
        BRzp DIFERENCIA_POSITIVA

        ADD R0, R0, #1
        NOT R2, R2
        ADD R2, R2, #1

DIFERENCIA_POSITIVA
        LEA R5, SIGNO_INCREMENTO
        STR R0, R5, #0

        LEA R5, DIFERENCIA_ABSOLUTA
        STR R2, R5, #0

; ----------------------------------------------------------
; 3. MULTIPLICAR LA MAGNITUD POR LA FRACCION (8 BITS)
;
; Se utiliza el esquema binario de desplazamiento y suma.
; R0 = fraccion desplazada 8 posiciones a la izquierda.
; R3 = magnitud de la diferencia.
; R2:R1 = producto unsigned de 32 bits.
; ----------------------------------------------------------

        LEA R5, FRACCION_INTERPOLACION
        LDR R0, R5, #0

        ADD R0, R0, R0
        ADD R0, R0, R0
        ADD R0, R0, R0
        ADD R0, R0, R0
        ADD R0, R0, R0
        ADD R0, R0, R0
        ADD R0, R0, R0
        ADD R0, R0, R0

        LEA R5, DIFERENCIA_ABSOLUTA
        LDR R3, R5, #0

        AND R1, R1, #0
        AND R2, R2, #0
        AND R4, R4, #0
        ADD R4, R4, #8

BUCLE_MULTIPLICACION_INTERPOLACION

; Desplazar el acumulador de 32 bits una posicion.

        ADD R5, R1, #0
        BRn DOBLAR_PRODUCTO_CON_ACARREO

        ADD R1, R1, R1
        ADD R2, R2, R2
        BRnzp COMPROBAR_BIT_FRACCION

DOBLAR_PRODUCTO_CON_ACARREO
        ADD R1, R1, R1
        ADD R2, R2, R2
        ADD R2, R2, #1

COMPROBAR_BIT_FRACCION

; El bit mas significativo de R0 representa el bit actual.

        ADD R5, R0, #0
        BRzp FIN_SUMAR_MAGNITUD

; Sumar la magnitud al acumulador de 32 bits.

        ADD R5, R1, #0
        BRn SUMAR_MAGNITUD_CON_ACARREO

        ADD R1, R1, R3
        BRnzp FIN_SUMAR_MAGNITUD

SUMAR_MAGNITUD_CON_ACARREO
        ADD R1, R1, R3
        BRn FIN_SUMAR_MAGNITUD
        ADD R2, R2, #1

FIN_SUMAR_MAGNITUD
        ADD R0, R0, R0
        ADD R4, R4, #-1
        BRp BUCLE_MULTIPLICACION_INTERPOLACION

; Guardar el producto de 32 bits.

        LEA R5, PRODUCTO_INTERPOLACION_BAJO
        STR R1, R5, #0
        LEA R5, PRODUCTO_INTERPOLACION_ALTO
        STR R2, R5, #0

; ----------------------------------------------------------
; 4. DIVIDIR EL PRODUCTO POR 256
;
; Se obtiene el cociente truncado hacia cero y el resto
; como magnitud sin signo. Como el producto se calculo
; usando magnitudes, el signo se aplica al cociente luego.
; ----------------------------------------------------------

; El byte alto de la palabra baja se extrae desplazando
; ocho veces y acumulando los bits que salen por el bit 15.

        ADD R3, R1, #0
        AND R4, R4, #0
        AND R5, R5, #0
        ADD R5, R5, #8

EXTRAER_COCIENTE_BAJO
        ADD R0, R3, #0
        BRzp BIT_COCIENTE_CERO

        ADD R4, R4, R4
        ADD R4, R4, #1
        BRnzp CONTINUAR_EXTRAER_COCIENTE

BIT_COCIENTE_CERO
        ADD R4, R4, R4

CONTINUAR_EXTRAER_COCIENTE
        ADD R3, R3, R3
        ADD R5, R5, #-1
        BRp EXTRAER_COCIENTE_BAJO

; Cociente = (palabra alta * 256) + byte extraido.

        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R2
        ADD R2, R2, R4

; R1 conserva el producto bajo original. Obtener el resto.

        LEA R5, MASCARA_00FF
        LDR R5, R5, #0
        AND R1, R1, R5

        LEA R5, RESTO_INTERPOLACION
        STR R1, R5, #0

; Aplicar al cociente el signo de la diferencia.

        LEA R5, SIGNO_INCREMENTO
        LDR R0, R5, #0
        BRz COCIENTE_POSITIVO

        NOT R2, R2
        ADD R2, R2, #1

COCIENTE_POSITIVO
        LEA R5, COCIENTE_INTERPOLACION
        STR R2, R5, #0

; ----------------------------------------------------------
; 5. SUMAR EL COCIENTE AL VALOR INFERIOR Y REDONDEAR
;
; Regla equivalente a (int16_t)(resultado + 0.5):
; incremento positivo: redondear si resto >= 128.
; incremento negativo: redondear si resto > 128.
; ----------------------------------------------------------

        LEA R5, VALOR_INFERIOR
        LDR R3, R5, #0
        ADD R3, R3, R2

        LEA R5, RESTO_INTERPOLACION
        LDR R1, R5, #0

        LEA R5, SIGNO_INCREMENTO
        LDR R0, R5, #0
        BRp REDONDEO_INCREMENTO_NEGATIVO

; Incremento positivo: resto >= 128.

        LEA R5, CONSTANTE_MENOS_128
        LDR R5, R5, #0
        ADD R1, R1, R5
        BRn GUARDAR_INTERPOLACION
        ADD R3, R3, #1
        BRnzp GUARDAR_INTERPOLACION

REDONDEO_INCREMENTO_NEGATIVO
; Incremento negativo: resto > 128.

        LEA R5, CONSTANTE_MENOS_128
        LDR R5, R5, #0
        ADD R1, R1, R5
        BRnz GUARDAR_INTERPOLACION
        ADD R3, R3, #-1

GUARDAR_INTERPOLACION
        LEA R5, RESULTADO_INTERPOLADO
        STR R3, R5, #0
        RET

        .END