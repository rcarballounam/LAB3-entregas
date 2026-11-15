import tempfile
import unittest
from pathlib import Path

from scripts.hex_a_columna import convert_hex_to_column


class HexToColumnTests(unittest.TestCase):
    def test_converts_row_to_normalized_hex_column(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            source = Path(temp_dir) / "input.hex"
            source.write_text("3000 0e01 0x2\n", encoding="ascii")

            output = convert_hex_to_column(source)

            self.assertEqual(output.name, "input_columna.hex")
            self.assertEqual(output.read_text(encoding="ascii"), "3000\n0E01\n0002\n")

    def test_rejects_non_hex_tokens(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            source = Path(temp_dir) / "input.hex"
            source.write_text("3000 XYZ", encoding="ascii")

            with self.assertRaisesRegex(ValueError, "posición 2"):
                convert_hex_to_column(source)

    def test_does_not_overwrite_source(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            source = Path(temp_dir) / "input.hex"
            source.write_text("3000 F025", encoding="ascii")

            with self.assertRaisesRegex(ValueError, "mismo que el de entrada"):
                convert_hex_to_column(source, source)


if __name__ == "__main__":
    unittest.main()
