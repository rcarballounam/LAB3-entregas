import unittest
from pathlib import Path

from src.assembler.assembler import assemble_project_file


class BenchmarkLinkTests(unittest.TestCase):
    def test_main_grupo27_matches_reference_hex(self):
        repository = Path(__file__).resolve().parents[1]
        benchmark = repository / "benchmark"
        generated = assemble_project_file(benchmark / "main_grupo27.asm", "hex").split()
        reference = (benchmark / "ensambladodereferencia_columna.hex").read_text(
            encoding="ascii"
        ).split()

        self.assertEqual(generated, reference)


if __name__ == "__main__":
    unittest.main()
