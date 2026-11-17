# Simulador funcional LC-3

El simulador ejecuta archivos `.obj` binarios producidos por el ensamblador del
repositorio. El formato contiene la dirección de origen seguida por palabras
LC-3 de 16 bits en big-endian.

Desde la raíz del repositorio:

```powershell
python "src\simulador funcional\simulador.py" ruta\al\programa.obj
```

En una terminal de Windows, `GETC` lee una tecla al presionarla, sin esperar
Enter ni mostrar eco. La tecla Enter se normaliza a salto de línea (`x000A`),
como esperan las rutinas `GETLINE` del benchmark. `OUT` muestra inmediatamente
el byte bajo de `R0` y no solicita entrada. `IN` conserva el comportamiento del
OS: muestra el prompt, lee una tecla y la repite como eco. Para proporcionar
texto de entrada automáticamente:

```powershell
python "src\simulador funcional\simulador.py" ruta\al\programa.obj --input "42"
```

La ejecución termina al ejecutar `HALT`. Para limitar programas que no terminan:

```powershell
python "src\simulador funcional\simulador.py" ruta\al\programa.obj --max-steps 500000
```

Se implementan las instrucciones LC-3 codificadas actualmente por el ensamblador
y las rutinas TRAP del OS de `src\simulador funcional\OS.asm`: `GETC` (x20),
`OUT` (x21), `PUTS` (x22), `IN` (x23), `PUTSP` (x24) y `HALT` (x25). Los TRAP
se emulan en el simulador; el archivo `OS.asm` documenta los vectores, los
servicios y los efectos visibles para el programa, pero no es necesario
ensamblarlo ni cargarlo junto con el `.obj`.

La máquina sigue el modelo LC-3 del ensamblador: memoria direccionada por
palabras de 16 bits, PC incrementado de a una palabra y direcciones `.ORIG` como
`x3000`. Esto es deliberadamente compatible con los `.obj` existentes. No es el
modelo byte-addressable de la ISA extendida descrita en `docs\ISA.md`.
