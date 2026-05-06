import argparse
import re
import sys

from isa import BinaryManager, Instruction, Opcode

MEMORY_SIZE = 2048


def translate(source_code: str) -> tuple[list[int], int]:
    """Транслирует исходный код в машинный."""
    code_lines = source_code.splitlines()

    macros = {}
    labels = {}
    memory = [0] * MEMORY_SIZE

    pc = 0
    section = ".text"
    parsed_instructions = []
    include_code = True

    for line in code_lines:
        line = line.split(';')[0].strip()
        if not line:
            continue

        if line.startswith('%ifdef'):
            macro_name = line.split()[1]
            include_code = macro_name in macros
            continue
        elif line == '%else':
            include_code = not include_code
            continue
        elif line == '%endif':
            include_code = True
            continue

        if not include_code:
            continue

        if line.startswith('%define'):
            parts = line.split()
            if len(parts) >= 3:
                macros[parts[1]] = parts[2]
            continue

        if line in (".data", ".text"):
            section = line
            continue

        if line.startswith(".org"):
            pc = int(line.split()[1], 0)
            continue

        if ':' in line and '"' not in line.split(':')[0]:
            label, rest = line.split(':', 1)
            labels[label.strip()] = pc
            line = rest.strip()
            if not line:
                continue

        if section == ".data":
            if line.startswith(".num"):
                val_str = line.split(maxsplit=1)[1].strip()
                val_str = macros.get(val_str, val_str)
                memory[pc] = int(val_str, 0)
                pc += 1

            elif line.startswith(".pstr"):
                match = re.search(r'"(.*)"', line)
                if match:
                    val = match.group(1)
                    memory[pc] = len(val)
                    pc += 1
                    for char in val:
                        memory[pc] = ord(char)
                        pc += 1
            continue

        if section == ".text":
            parts = line.split(maxsplit=1)
            opcode = parts[0].upper()
            operand_str = parts[1].strip() if len(parts) > 1 else ""

            parsed_instructions.append((pc, opcode, operand_str))
            pc += 1


    for addr, opcode, operand_str in parsed_instructions:
        operand_val = 0

        if operand_str:
            if operand_str in macros:
                operand_val = int(macros[operand_str], 0)
            elif operand_str in labels:
                operand_val = labels[operand_str]
            else:
                try:
                    operand_val = int(operand_str, 0)
                except ValueError:
                    raise ValueError(f"Unknown label or invalid integer: '{operand_str}' "
                                     f"at pc={addr}") from None

        try:
            opcode_obj = Opcode[opcode]
        except KeyError:
            raise ValueError(f"Unknown instruction: '{opcode}' at pc={addr}") from None

        memory[addr] = Instruction(opcode_obj, operand_val).encode()

    if "_start" not in labels:
        raise ValueError("Start label '_start' is missed!")

    return memory, labels["_start"]


def main(source_file: str, target_file: str) -> None:
    with open(source_file, encoding="utf-8") as f:
        source_code = f.read()

    try:
        memory, start_address = translate(source_code)
    except Exception as e:
        print(f"Compilation error:\n{e}")
        sys.exit(1)

    BinaryManager.write_binary(target_file, memory, start_address)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Stack Machine Translator")
    parser.add_argument("code", help="Your program (.asm)")
    parser.add_argument("binary_file", help="File for compiled code (.bin)")
    args = parser.parse_args()
    main(args.code, args.binary_file)
