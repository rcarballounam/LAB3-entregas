# Ensamblador

El ensamblador recibe un archivo de texto assembly y, desde la CLI, genera un
archivo de salida junto al archivo fuente. Por defecto, la salida es hexadecimal
(`.hex`); el primer valor es la dirección indicada por `.ORIG`, seguida del
código máquina.

Desde la raíz del repositorio:

```powershell
python src\assembler\assembler.py ruta\al\programa.asm
```

Para elegir otro formato:

```powershell
python src\assembler\assembler.py ruta\al\programa.asm --format bin
python src\assembler\assembler.py ruta\al\programa.asm --format dec
```

Las referencias `.EXTERNAL MODULO-SIMBOLO` se enlazan recursivamente con los
archivos de `lib` junto al fuente. Si la biblioteca está en otra ubicación, se
puede indicar con `--link-dir ruta\a\lib`. El enlazador busca primero un archivo
con el nombre del módulo, luego el alias `g27_` y finalmente una definición
única del símbolo exportado. Los módulos externos se reubican en orden por
niveles de dependencia, con direcciones LC-3 por palabra; sus `.ORIG` se ajustan
a la base asignada.
Un externo sin definición produce un error en lugar de generar una dirección
cero.

El nombre de salida conserva el nombre base del assembly y cambia la extensión
según el formato: `.hex`, `.bin` o `.dec`. Por ejemplo, `programa.asm` genera
`programa.hex` por defecto. El archivo pone cada valor en una línea (una sola
columna), con la dirección de origen en la primera línea.

La API `assemble_source`, `assemble_file` y `assemble_project_file` devuelve
el contenido ensamblado como texto; la generación automática del archivo ocurre
al ejecutar la CLI.

La codificación de instrucciones implementada actualmente corresponde al
subconjunto LC-3; todavía no representa por completo la ISA modificada descrita
en `ISA.md`.

## Convertir un `.hex` de una fila a una columna

Para convertir un archivo hexadecimal existente sin modificar el original:

```powershell
python scripts\hex_a_columna.py benchmark\ensambladodereferencia.hex
```

Por defecto, crea `ensambladodereferencia_columna.hex` en la misma carpeta.
También se puede indicar explícitamente el destino:

```powershell
python scripts\hex_a_columna.py entrada.hex --output salida.hex
```

El conversor valida cada palabra hexadecimal y escribe una palabra de 16 bits
por línea, en mayúsculas y con cuatro dígitos.
