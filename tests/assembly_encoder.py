REG_COMMANDS = ['add', 'sub', 'mul']
MEM_COMMANDS = ['ldb', 'ldw', 'stb', 'stw']
CTRL_COMMANDS = ['beq', 'jmp']


def padded_with_zeros(num):
    """
    Pad a number with zeros.
    :param num: int, number to pad with zeros.
    :return: string, contains num padded with zeros.
    """
    s = str(num)
    max_len = len('0xffffffff')

    if len(s) != max_len:
        padding_zeros = max_len - len(s)
        s = s[:2] + ('0' * padding_zeros) + s[2:]

    return s


def encode_reg_instr(instr):
    """
    Encode an R-type instruction as a number.
    :param instr: list, R-type instruction operands, e.g. ['add', 'r1', 'r2', 'r3']
    :return: int, encoded instruction.
    """
    hex_instr = 0

    # Decode.
    cmd = instr[0]
    dst = instr[1]
    src_1 = instr[2]
    src_2 = instr[3]

    # Encode opcode.
    if cmd == 'add':
        hex_instr += 0x0 << 25
    elif cmd == 'sub':
        hex_instr += 0x1 << 25
    else:
        hex_instr += 0x2 << 25

    # Encode destination register.
    dst_reg = int(''.join(c for c in dst if c.isdigit()), 10)
    hex_instr += dst_reg << 20

    # Encode first source register.
    src_1_reg = int(''.join(c for c in src_1 if c.isdigit()), 10)
    hex_instr += src_1_reg << 15

    # Encode second source register.
    src_2_reg = int(''.join(c for c in src_2 if c.isdigit()), 10)
    hex_instr += src_2_reg << 10

    return hex_instr


def encode_mem_instr(instr):
    """
    Encode an M-type instruction as a number.
    :param instr: list, M-type instruction operands, e.g. ['ldw', 'r1', 'r2', '10']
    :return: int, encoded instruction.
    """
    hex_instr = 0

    # Decode.
    cmd = instr[0]
    dst = instr[1]
    src = instr[2]
    off = instr[3]

    # Encode opcode.
    if cmd == 'ldb':
        hex_instr += 0x10 << 25
    elif cmd == 'ldw':
        hex_instr += 0x11 << 25
    elif cmd == 'stb':
        hex_instr += 0x12 << 25
    else:
        hex_instr += 0x13 << 25

    # Encode destination register.
    dst_reg = int(''.join(c for c in dst if c.isdigit()), 10)
    hex_instr += dst_reg << 20

    # Encode source register.
    src_reg = int(''.join(c for c in src if c.isdigit()), 10)
    hex_instr += src_reg << 15

    # Encode offset.
    off_val = int(off, 16)
    hex_instr += off_val

    return hex_instr


def encode_ctrl_instr(instr):
    """
    Encode a branch or jump instruction as a number.
    :param instr: list, instruction operands, e.g. ['beq', 'r1', 'r2', '10']
    :return: int, encoded instruction.
    """
    hex_instr = 0

    # BEQ and JMP have different encodings. Consider both cases.
    if instr[0] == 'beq':
        # Encode opcode.
        hex_instr += 0x30 << 25

        # Encode first source register.
        src_1_reg = int(''.join(c for c in instr[1] if c.isdigit()), 10)
        hex_instr += src_1_reg << 15

        # Encode second source register.
        src_2_reg = int(''.join(c for c in instr[2] if c.isdigit()), 16)
        hex_instr += src_2_reg << 10

        # Encode offset.
        off_val = int(instr[3], 16)
        off_low = off_val & 0x03ff
        off_hi = off_val & 0x7c00
        hex_instr += off_hi << 20
        hex_instr += off_low

    else:
        # Encode opcode.
        hex_instr += 0x31 << 25

        # Encode source register.
        src_reg = int(''.join(c for c in instr[1] if c.isdigit()), 16)
        hex_instr += src_reg << 15

        # Encode offset.
        off_val = int(instr[2], 16)
        off_low = off_val & 0x003ff
        off_med = off_val & 0x07c00
        off_hi = off_val & 0xf8000
        hex_instr += off_hi << 20
        hex_instr += off_med << 10
        hex_instr += off_low
    return hex_instr


def assembly_to_hex(instr):
    """
    Encode a human-readable string containing assembly instruction as a hex instruction.
    :param instr: string, instruction to encode.
    :return: int, encoded instruction.
    """
    operands = instr.replace(',', '').split()
    hex_instr = 0
    cmd = operands[0]

    if cmd in REG_COMMANDS:
        hex_instr = encode_reg_instr(operands)
    elif cmd in MEM_COMMANDS:
        hex_instr = encode_mem_instr(operands)
    elif cmd in CTRL_COMMANDS:
        hex_instr = encode_ctrl_instr(operands)
    else:
        print('Invalid instruction: ' + instr)
        exit(1)

    return hex_instr


def generate_imem_content(filename):
    """
    Parse a text file with assembly instructions and generate instruction memory content in hex.
    :param filename: Name of the file to parse.
    """
    with open(filename, 'r') as f:
        instructions = f.readlines()

    hex_instructions = []
    hex_instructions_len = 0
    for instruction in instructions:
        hex_instructions.append(assembly_to_hex(instruction))
        hex_instructions_len += 1

    with open('instructions.txt', 'w') as f:
        for i in range(256):
            hex_to_write = hex(hex_instructions[i % hex_instructions_len])
            f.write(padded_with_zeros(hex_to_write) + '\n')


def main():
    generate_imem_content('assembly_instructions.txt')


if __name__ == '__main__':
    main()
