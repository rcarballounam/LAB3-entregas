import tempfile
import unittest
from pathlib import Path

from src.assembler.assembler import (
    AssemblerError,
    assemble_project_file,
    assemble_source,
    main,
)


class AssemblerTests(unittest.TestCase):
    def test_simple_add_and_halt(self):
        source = ".ORIG x3000\nADD R0,R0,#1\nHALT\n.END\n"
        self.assertEqual(assemble_source(source, "hex"), "3000 1021 F025")
        self.assertEqual(assemble_source(source, "bin").split()[0], "0011000000000000")
        self.assertEqual(assemble_source(source, "dec").split()[0], "12288")
        self.assertEqual(assemble_source(source, "obj"), bytes.fromhex("30001021F025"))

    def test_label_and_fill(self):
        source = ".ORIG x3000\nLD R0 VAR\nBRnzp DONE\nVAR .FILL #7\nDONE HALT\n.END\n"
        self.assertEqual(assemble_source(source, "hex"), "3000 2001 0E01 0007 F025")

    def test_unresolved_external_is_reported(self):
        source = ".ORIG x3000\n.EXTERNAL FOO\nLD R0 FOO\nJSR FOO\n.END\n"
        with self.assertRaisesRegex(AssemblerError, "símbolo externo no resuelto"):
            assemble_source(source, "hex")

    def test_string_literal_is_encoded(self):
        source = '.ORIG x3000\n.STRINGZ "A"\n.END\n'
        self.assertEqual(assemble_source(source, "hex"), "3000 0041 0000")

    def test_bare_label_and_puts_alias(self):
        source = '.ORIG x3000\nmain\nPUTS\n.END\n'
        self.assertEqual(assemble_source(source, "hex"), "3000 F022")

    def test_label_starting_with_r_is_not_treated_as_a_register(self):
        source = ".ORIG x3000\nREDUCCION_START\nADD R0,R0,#1\nBR REDUCCION_START\n.END\n"
        self.assertEqual(assemble_source(source, "hex"), "3000 1021 0FFE")

    def test_colon_inside_string_does_not_break_label(self):
        source = '.ORIG x3000\nLEA R0, LABEL\nPUTS\nLABEL .STRINGZ "Hexadecimal: "\n.END\n'
        words = assemble_source(source, "hex").split()
        self.assertEqual(words[:3], ["3000", "E001", "F022"])
        self.assertEqual(words[3], "0048")

    def test_cli_writes_hex_file_with_origin(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            source_path = Path(temp_dir) / "programa.asm"
            output_path = Path(temp_dir) / "programa.hex"
            source_path.write_text(".ORIG x3000\nHALT\n.END\n", encoding="utf-8")

            self.assertEqual(main([str(source_path)]), 0)
            self.assertEqual(output_path.read_text(encoding="ascii"), "3000\nF025\n")

    def test_cli_writes_binary_lc3_object_file(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            source_path = Path(temp_dir) / "programa.asm"
            output_path = Path(temp_dir) / "programa.obj"
            source_path.write_text(".ORIG x3000\nHALT\n.END\n", encoding="utf-8")

            self.assertEqual(main([str(source_path), "--format", "obj"]), 0)
            self.assertEqual(output_path.read_bytes(), bytes.fromhex("3000F025"))

    def test_project_linker_resolves_external_and_includes_module(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            project = Path(temp_dir)
            library = project / "lib"
            library.mkdir()
            source_path = project / "main.asm"
            source_path.write_text(
                ".ORIG x3000\n.EXTERNAL helper-ENTRY\n"
                "pointer .FILL helper-ENTRY\nHALT\n.END\n",
                encoding="utf-8",
            )
            (library / "helper.asm").write_text(
                ".ORIG x4000\nENTRY ADD R0,R0,#1\nRET\n.END\n",
                encoding="utf-8",
            )

            output = assemble_project_file(source_path, "hex").split()

            self.assertEqual(output, ["3000", "3002", "F025", "1021", "C1C0"])
            self.assertEqual(main([str(source_path)]), 0)
            self.assertEqual(
                (project / "main.hex").read_text(encoding="ascii").split(),
                output,
            )
            self.assertEqual(
                assemble_project_file(source_path, "obj"),
                bytes.fromhex("30003002F0251021C1C0"),
            )

    def test_project_linker_resolves_unqualified_external_by_unique_symbol(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            project = Path(temp_dir)
            library = project / "lib"
            library.mkdir()
            source_path = project / "main.asm"
            source_path.write_text(
                ".ORIG x3000\n.EXTERNAL MULT_SUMA\n"
                ".FILL MULT_SUMA\n.END\n",
                encoding="utf-8",
            )
            (library / "multiply.asm").write_text(
                ".ORIG x4000\nMULT_SUMA RET\n.END\n",
                encoding="utf-8",
            )

            output = assemble_project_file(source_path, "hex").split()

            self.assertEqual(output, ["3000", "3001", "C1C0"])

    def test_project_linker_resolves_transitive_external(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            project = Path(temp_dir)
            library = project / "lib"
            library.mkdir()
            source_path = project / "main.asm"
            source_path.write_text(
                ".ORIG x3000\n.EXTERNAL helper-ENTRY\n"
                ".FILL helper-ENTRY\n.END\n",
                encoding="utf-8",
            )
            (library / "helper.asm").write_text(
                ".EXTERNAL leaf-LEAF\nENTRY .FILL leaf-LEAF\nRET\n.END\n",
                encoding="utf-8",
            )
            (library / "leaf.asm").write_text(
                "LEAF ADD R0,R0,#1\n.END\n",
                encoding="utf-8",
            )

            output = assemble_project_file(source_path, "hex").split()

            self.assertEqual(output, ["3000", "3001", "3003", "C1C0", "1021"])

    def test_project_linker_places_direct_dependencies_before_transitive_ones(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            project = Path(temp_dir)
            library = project / "lib"
            library.mkdir()
            source_path = project / "main.asm"
            source_path.write_text(
                ".ORIG x3000\n.EXTERNAL first-ENTRY second-ENTRY\n"
                ".FILL first-ENTRY\n.FILL second-ENTRY\n.END\n",
                encoding="utf-8",
            )
            (library / "first.asm").write_text(
                ".EXTERNAL leaf-LEAF\nENTRY .FILL leaf-LEAF\n.END\n",
                encoding="utf-8",
            )
            (library / "second.asm").write_text(
                "ENTRY ADD R0,R0,#1\n.END\n",
                encoding="utf-8",
            )
            (library / "leaf.asm").write_text(
                "LEAF RET\n.END\n",
                encoding="utf-8",
            )

            output = assemble_project_file(source_path, "hex").split()

            self.assertEqual(output, ["3000", "3002", "3003", "3004", "1021", "C1C0"])


if __name__ == "__main__":
    unittest.main()
