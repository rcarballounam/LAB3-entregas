import argparse
import re
import sys
from pathlib import Path
from typing import Optional, Sequence


HEX_WORD = re.compile(r"(?:0[xX])?([0-9A-Fa-f]{1,4})\Z")


def convert_hex_to_column(source: str | Path, destination: str | Path | None = None) -> Path:
    source_path = Path(source)
    if destination is None:
        destination_path = source_path.with_name(f"{source_path.stem}_columna{source_path.suffix}")
    else:
        destination_path = Path(destination)

    if source_path.resolve() == destination_path.resolve():
        raise ValueError("El archivo de salida no puede ser el mismo que el de entrada.")

    tokens = source_path.read_text(encoding="utf-8-sig").split()
    if not tokens:
        raise ValueError("El archivo de entrada no contiene valores hexadecimales.")

    words = []
    for index, token in enumerate(tokens, start=1):
        match = HEX_WORD.fullmatch(token)
        if match is None:
            raise ValueError(f"Token hexadecimal inválido en la posición {index}: {token!r}")
        words.append(f"{int(match.group(1), 16):04X}")

    destination_path.write_text("\n".join(words) + "\n", encoding="ascii")
    return destination_path


def main(argv: Optional[Sequence[str]] = None) -> int:
    parser = argparse.ArgumentParser(
        description="Convierte valores hexadecimales en una fila a una columna."
    )
    parser.add_argument("source", help="Archivo hexadecimal de entrada")
    parser.add_argument(
        "-o", "--output",
        help="Archivo de salida (por defecto agrega _columna al nombre de entrada)",
    )
    args = parser.parse_args(argv)

    try:
        output_path = convert_hex_to_column(args.source, args.output)
    except (OSError, ValueError) as exc:
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"Archivo generado: {output_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
