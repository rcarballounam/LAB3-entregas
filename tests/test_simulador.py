import importlib.util
import io
import sys
import tempfile
import types
import unittest
from contextlib import redirect_stdout
from pathlib import Path
from unittest.mock import Mock, patch

from src.assembler.assembler import assemble_source


REPOSITORY = Path(__file__).resolve().parents[1]
SIMULATOR_PATH = REPOSITORY / "src" / "simulador funcional" / "simulador.py"
SPEC = importlib.util.spec_from_file_location("lc3_simulador", SIMULATOR_PATH)
SIMULATOR = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = SIMULATOR
SPEC.loader.exec_module(SIMULATOR)


class SimulatorTests(unittest.TestCase):
    def make_simulator(self, source, input_text=""):
        output = io.StringIO()
        simulator = SIMULATOR.LC3(
            input_stream=io.StringIO(input_text),
            output_stream=output,
        )
        simulator.load_object(assemble_source(source, "obj"))
        return simulator, output

    def test_runs_arithmetic_branch_memory_and_subroutine_in_assembler_object(self):
        source = (
            ".ORIG x3000\n"
            "AND R0, R0, #0\n"
            "BRz SET_VALUE\n"
            "ADD R0, R0, #1\n"
            "SET_VALUE ADD R0, R0, #5\n"
            "JSR DOUBLE\n"
            "ST R0, RESULT\n"
            "HALT\n"
            "DOUBLE ADD R0, R0, R0\n"
            "RET\n"
            "RESULT .FILL #0\n"
            ".END\n"
        )
        simulator, output = self.make_simulator(source)

        simulator.run()

        self.assertEqual(simulator.memory[0x3009], 10)
        self.assertTrue(simulator.halted)
        self.assertEqual(output.getvalue(), "\nHALT\n")

    def test_cli_executes_assembler_object_file(self):
        source = ".ORIG x3000\nADD R0, R0, #7\nHALT\n.END\n"
        with tempfile.TemporaryDirectory() as temp_dir:
            object_path = Path(temp_dir) / "program.obj"
            object_path.write_bytes(assemble_source(source, "obj"))
            output = io.StringIO()

            with redirect_stdout(output):
                result = SIMULATOR.main([str(object_path)])

        self.assertEqual(result, 0)
        self.assertEqual(output.getvalue(), "\nHALT\n")

    def test_os_traps_getc_puts_putsp_and_halt(self):
        source = (
            ".ORIG x3000\n"
            "LEA R0, MESSAGE\n"
            "PUTS\n"
            "GETC\n"
            "OUT\n"
            "LEA R0, PACKED\n"
            "TRAP x24\n"
            "HALT\n"
            'MESSAGE .STRINGZ "Ready: "\n'
            "PACKED .FILL x4241\n"
            ".FILL x0000\n"
            ".END\n"
        )
        simulator, output = self.make_simulator(source, input_text="x")

        simulator.run()

        self.assertEqual(output.getvalue(), "Ready: xAB\nHALT\n")
        self.assertEqual(simulator.memory[simulator.registers[0]], 0x4241)

    def test_in_trap_uses_os_prompt_and_echoes_character(self):
        simulator, output = self.make_simulator(
            ".ORIG x3000\nIN\nHALT\n.END\n",
            input_text="q",
        )

        simulator.run()

        self.assertEqual(output.getvalue(), "Enter a character: q\nHALT\n")
        self.assertEqual(simulator.registers[0], ord("q"))

    def test_getc_reads_a_key_without_echo_or_line_input_in_windows_terminal(self):
        terminal = io.StringIO()
        terminal.isatty = lambda: True
        getwch = Mock(return_value="k")
        msvcrt = types.ModuleType("msvcrt")
        msvcrt.getwch = getwch
        output = io.StringIO()

        with patch.object(SIMULATOR.sys, "platform", "win32"):
            with patch.object(SIMULATOR.sys, "stdin", terminal):
                with patch.dict(sys.modules, {"msvcrt": msvcrt}):
                    simulator = SIMULATOR.LC3(output_stream=output)
                    simulator._execute_trap(0x20)

        self.assertEqual(simulator.registers[0], ord("k"))
        self.assertEqual(output.getvalue(), "")
        getwch.assert_called_once_with()

    def test_out_displays_r0_without_reading_input(self):
        simulator, output = self.make_simulator(
            ".ORIG x3000\nLD R0, LETTER\nOUT\nHALT\n"
            "LETTER .FILL x0058\n.END\n"
        )

        simulator.run()

        self.assertEqual(output.getvalue(), "X\nHALT\n")

    def test_enter_ends_getline_instead_of_rewriting_the_prompt(self):
        source = (
            ".ORIG x3000\n"
            "READ GETC\n"
            "ADD R1, R0, #-10\n"
            "BRz DONE\n"
            "OUT\n"
            "BR READ\n"
            "DONE HALT\n"
            ".END\n"
        )
        simulator, output = self.make_simulator(source, input_text="\r")

        simulator.run()

        self.assertEqual(output.getvalue(), "\nHALT\n")

    def test_rejects_malformed_and_oversized_objects(self):
        simulator = SIMULATOR.LC3(output_stream=io.StringIO())
        with self.assertRaisesRegex(SIMULATOR.SimulatorError, "impar"):
            simulator.load_object(bytes.fromhex("300000"))
        with self.assertRaisesRegex(SIMULATOR.SimulatorError, "excede"):
            simulator.load_object(bytes.fromhex("FFFF00000000"))


if __name__ == "__main__":
    unittest.main()
