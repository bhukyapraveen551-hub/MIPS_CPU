import re

# Define opcodes
opcodes = {
    "ADD": "000000",
    "SUB": "000001",
    "AND": "000010",
    "OR":  "000011",
    "SLT": "000100",
    "MUL": "000101",
    "HLT": "111111",
    "LW":  "001000",
    "SW":  "001001",
    "ADDI": "001010",
    "SUBI": "001011",
    "SLTI": "001100",
    "BNEQZ": "001101",
    "BEQZ": "001110",
    "NOP": "000111"
    }

def reg_bin(reg_name):
    num = int(reg_name[1:])  # Remove 'R' and convert
    return format(num, '05b')

def to_bin(value, bits):
    valuin=int(value)
    if(valuin<0):
        valuin=255+1+valuin
    return format(int(valuin), f'0{bits}b')

def parse_instruction(line):
    line = line.strip()
    if not line or line.startswith("#"):  # skip empty lines and comments
        return None

    parts = re.split(r'[,\s()]+', line.upper())
    instr = parts[0]

    if instr in {"ADD", "SUB", "AND", "OR", "SLT", "MUL"}:
        rd, rs1, rs2 = map(reg_bin, parts[1:4])
        bin_instr = opcodes[instr] + rs1 + rd + rs2 + ('0' * 11)

    elif instr in {"SW"}:
        rt = reg_bin(parts[1])
        base = reg_bin(parts[2])
        offset = to_bin(parts[3], 8)
        bin_instr = opcodes[instr] + base + ('0'*5) + rt + offset + ('0' * 3)

    elif instr in {"ADDI","SUBI","SLTI"}:
        rt = reg_bin(parts[1])
        base = reg_bin(parts[2])
        offset = to_bin(parts[3], 8)
        bin_instr = opcodes[instr] + base + rt + ('0'*5) + offset + ('0' * 3)

    elif instr in {"LW"}:
        rt = reg_bin(parts[1])
        base = reg_bin(parts[2])
        offset = to_bin(parts[3], 8)
        bin_instr = opcodes[instr] + base + rt +('0'*5) + offset + ('0' * 3)

    elif instr in {"BEQZ","BNEQZ"}:
        rt = reg_bin(parts[1])
        k=int(parts[2])
        k= k -3 
        offset = to_bin(k, 8)
        bin_instr = opcodes[instr] + rt +('0'*10) + offset + ('0' * 3)

    elif instr == "HLT":
        bin_instr = opcodes[instr] + ('0' * 26)

    elif instr == "NOP":
        bin_instr = opcodes[instr] + ('0' * 26)        

    else:
        raise ValueError(f"Unknown instruction: {instr}")

    return format(int(bin_instr, 2), '08X')  # Convert 32-bit binary to 8-digit hex

def assemble_file(input_file, output_file="data.dat"):
    with open(input_file, 'r') as infile:
        lines = infile.readlines()

    hex_lines = []
    for line in lines:
        try:
            hex_line = parse_instruction(line)
            if hex_line:
                hex_lines.append(hex_line)
        except Exception as e:
            print(f"Error in line: {line.strip()} => {e}")

    with open(output_file, 'w') as outfile:
        for hex_line in hex_lines:
            outfile.write(hex_line + '\n')

    print(f"Assembly complete. Output written to {output_file}")
assemble_file("program.asm")