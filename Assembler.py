import re

OPCODES = {
    "NOP":  0b000000,
    "HLT":  0b000001,
    "LOD":  0b000010,
    "STO":  0b000011,
    "LDR":  0b000100,
    "STR":  0b000101,
    "LDI":  0b000110,
    "LBI":  0b000111,
    "LPC":  0b001000,
    "LSP":  0b001001,
    "MOV":  0b001010,
    
    "ADD":  0b001011,
    "ADC":  0b001100,
    "ADI":  0b001101,
    "SUB":  0b001110,
    "SBI":  0b001111,
    "INC":  0b001101, #Psuedo-opcode
    "DEC":  0b001111, #Psuedo-opcode
    "SHL":  0b001011, #Psuedo-opcode
    "SHR":  0b010000,

    "AND":  0b010001,
    "IOR":  0b010010,
    "XOR":  0b010011,
    "NAN":  0b010100,
    "NOR":  0b010101,
    "XNO":  0b010110,
    "NOT":  0b010111,
    "CMP":  0b011000,

    "JMP":  0b011001,
    "JMR":  0b011010,
    "JEZ":  0b011011,
    "JNZ":  0b011100,
    "JEC":  0b011101,
    "JNC":  0b011110,
    "JEH":  0b011111,
    "JNH":  0b100000,
    
    "PSH":  0b100001,
    "POP":  0b100010,
    "CAL":  0b100011,
    "RET":  0b100100,
}

REGISTERS = {
    "Z": 0, #Zero Register
    "A": 1,
    "B": 2,
    "C": 3,
    "D": 4,
    "E": 5,
    "F": 6,
    "G": 7,
    "H": 8,
    "I": 9,
    "J": 10,
    "K": 11,
    "L": 12,
    "M": 13,
    "N": 14,
    "O": 15,
    "P": 16,
    "Q": 17,
    "R": 18,
    "S": 19,
    "T": 20,
    "U": 21,
    "V": 22,
    "W": 23,
    "X": 24,
    "Y": 25,
    "SP": 26, #Stack Pointer
    "PC": 27, #Program Counter
    "RET": 28, #Link Register
    "ERR": 29, #Error Register
    "SR": 30, #Status Register
    "IMR": 31, #Imidiate Register
}

REGISTERS_2 = {
    "r0": 0,
    "r1": 1,
    "r2": 2,
    "r3": 3,
    "r4": 4,
    "r5": 5,
    "r6": 6,
    "r7": 7,
    "r8": 8,
    "r9": 9,
    "r10": 10,
    "r11": 11,
    "r12": 12,
    "r13": 13,
    "r14": 14,
    "r15": 15,
    "r16": 16,
    "r17": 17,
    "r18": 18,
    "r19": 19,
    "r20": 20,
    "r21": 21,
    "r22": 22,
    "r23": 23,
    "r24": 24,
    "r25": 25,
    "r26": 26,
    "r27": 27,
    "r28": 28,
    "r29": 29,
    "r30": 30,
    "r31": 31,
}

lines = []
machine_code = []

def removeCommentsAndEmptyLines():
    cleaned_lines = []
    for line in lines:
        line = line.split(';')[0].strip()  # Remove comments
        if line:
            cleaned_lines.append(line)
    lines[:] = cleaned_lines

def handleLabels():
    cleaned_lines = []
    labels = {}
    pc = 0
    for line in lines:
        if line.endswith(':'):
            label = line[:-1]
            labels[label] = pc
        elif line.startswith('.'):
            label = line[1:]
            labels[label] = pc
        else:
            cleaned_lines.append(line)
            pc += 1
    for i, line in enumerate(cleaned_lines):
        for label, address in labels.items():
            # Use word boundary regex to replace only complete label matches
            pattern = r'\b' + re.escape(label) + r'\b'
            cleaned_lines[i] = re.sub(pattern, str(address), cleaned_lines[i])
    lines[:] = cleaned_lines

def normValue():
    for i, line in enumerate(lines):
        tokens = re.findall(r'\b0x[0-9a-fA-F]+\b|\b0b[01]+\b|\b\d+\b|\S+', line)
        new_tokens = []

        for t in tokens:
            if t.startswith("0x"):
                new_tokens.append(str(int(t, 16)))
            elif t.startswith("0b"):
                new_tokens.append(str(int(t, 2)))
            else:
                new_tokens.append(t)

        lines[i] = "".join(
            t if re.match(r'\W', t) else t + " "
            for t in new_tokens
        ).rstrip()


def assembleLine(line):
    clean = line.replace(",", " ")
    parts = clean.split()

    if not parts:
        return

    opcode_str = parts[0].upper()
    if opcode_str not in OPCODES:
        raise ValueError(f"Unbekannter Opcode: {opcode_str}")

    opcode = OPCODES[opcode_str]

    # Hilfsfunktion: Holt Register-Index oder 0, falls Operand fehlt
    def get_reg(val):
        if val is None: return 0
        v = val.strip()
        # Prüfe beide Register-Listen
        return REGISTERS.get(v.upper(), REGISTERS_2.get(v.lower(), 0))

    # Hilfsfunktion: Holt Integer-Wert (Immediate/Addr) oder 0
    def get_imm(val):
        if val is None: return 0
        try:
            return int(val.strip())
        except ValueError:
            return 0

    # --------- NO OPERANDS (NOP, HLT, RET) ----------
    if opcode_str in ("NOP", "HLT", "RET"):
        machine_code.append(f"{opcode:06b}_000000000000000000")
        return

    # --------- TRANSFER (LDI, LOD, STO, etc.) ----------
    elif opcode_str == "LDI":
        # Syntax: LDI Rc, IMM (parts[1]=C, parts[2]=Imm)
        C = get_reg(parts[1])
        imm = get_imm(parts[2])
        machine_code.append(f"{opcode:06b}_{C:05b}_{imm:010b}_000")
    
    elif opcode_str == "LOD":
        # Syntax: LOD Rc, ADDR
        C = get_reg(parts[1])
        addr = get_imm(parts[2])
        machine_code.append(f"{opcode:06b}_{C:05b}_{addr:010b}_000")

    elif opcode_str == "STO":
        # Syntax: STO Ra, ADDR
        A = get_reg(parts[1])
        addr = get_imm(parts[2])
        machine_code.append(f"{opcode:06b}_{A:05b}_{addr:010b}_000")

    elif opcode_str == "LDR":
        # Syntax: LDR Rc, [Ra]
        C = get_reg(parts[1])
        A = get_reg(parts[2].replace("[","").replace("]",""))
        machine_code.append(f"{opcode:06b}_{A:05b}_00000000_{C:05b}")

    elif opcode_str == "STR":
        # Syntax: STR Ra, [Rb]
        A = get_reg(parts[1])
        B = get_reg(parts[2].replace("[","").replace("]",""))
        machine_code.append(f"{opcode:06b}_{A:05b}_{B:05b}_00000000")
        
    elif opcode_str == "LBI":
        # Syntax: LBI Rc, IMM (parts[1]=C, parts[2]=Imm)
        imm = get_imm(parts[1])
        machine_code.append(f"{opcode:06b}_{imm:016b}_00")
        
    elif opcode_str == "LPC":
        # Syntax: LPC Rc, ADDR
        C = get_reg(parts[1])
        machine_code.append(f"{opcode:06b}_0000000000000_{C:05b}")
        
    elif opcode_str == "LSP":
        # Syntax: LPC Rc, ADDR
        C = get_reg(parts[1])
        machine_code.append(f"{opcode:06b}_0000000000000_{C:05b}")

    elif opcode_str == "MOV":
        # Syntax: MOV Rc, Ra
        C = get_reg(parts[1])
        A = get_reg(parts[2])
        machine_code.append(f"{opcode:06b}_{A:05b}_00000000_{C:05b}")

    # --------- ARITHMETIK (3 Register: ADD, SUB, etc.) ----------
    elif opcode_str in ("ADD", "ADC", "SUB", "AND", "IOR", "XOR", "NAN", "NOR", "XNO"):
        # Syntax: OP Rc, Ra, Rb
        C = get_reg(parts[1])
        A = get_reg(parts[2])
        B = get_reg(parts[3])
        machine_code.append(f"{opcode:06b}_{A:05b}_{B:05b}_000_{C:05b}")

    # --------- ARITHMETIK IMM (ADI, SBI) ----------
    elif opcode_str in ("ADI", "SBI"):
        # Syntax: OP Rc, Ra, IMM
        A = get_reg(parts[1])
        imm = get_imm(parts[2])
        # Wir nutzen hier dein Format: Op(6) + A(5) + Imm(10) + Rest(3)
        # Hinweis: Dein Decoder muss wissen, dass C hier gleich A ist oder aus Instr gelesen wird
        machine_code.append(f"{opcode:06b}_{A:05b}_{imm:010b}_000")

    # --------- PSEUDO-OPS (INC, DEC) ----------
    elif opcode_str == "INC":
        # Syntax: INC Rc, Ra -> Nutzt ADI mit Imm=1
        C = get_reg(parts[1])
        machine_code.append(f"{opcode:06b}_{C:05b}_{1:010b}_000")

    elif opcode_str == "DEC":
        # Syntax: DEC Rc, Ra -> Nutzt SBI mit Imm=1
        C = get_reg(parts[1])
        machine_code.append(f"{opcode:06b}_{C:05b}_{1:010b}_000")

    # --------- CONTROL FLOW (Jumps/Calls mit ADDR) ----------
    elif opcode_str in ("JMP", "JEZ", "JNZ", "JEC", "JNC", "JEH", "JNH", "CAL"):
        # Syntax: JMP ADDR
        addr = get_imm(parts[1])
        machine_code.append(f"{opcode:06b}_00000_{addr:010b}_000")

    elif opcode_str == "JMR":
        # Syntax: JMR [Ra]
        A = get_reg(parts[1].replace("[","").replace("]",""))
        machine_code.append(f"{opcode:06b}_{A:05b}_0000000000000")

    # --------- STACK (PSH, POP) ----------
    elif opcode_str == "PSH":
        # Syntax: PSH Ra
        A = get_reg(parts[1])
        machine_code.append(f"{opcode:06b}_{A:05b}_0000000000000")

    elif opcode_str == "POP":
        # Syntax: POP Rc
        C = get_reg(parts[1])
        machine_code.append(f"{opcode:06b}_0000000000000_{C:05b}")

    elif opcode_str == "NOT":
        # Syntax: NOT Rc, Ra
        C = get_reg(parts[1])
        A = get_reg(parts[2])
        machine_code.append(f"{opcode:06b}_{A:05b}_00000000_{C:05b}")

    elif opcode_str == "CMP":
        # Syntax: CMP Ra, Rb
        A = get_reg(parts[1])
        B = get_reg(parts[2])
        machine_code.append(f"{opcode:06b}_{A:05b}_{B:05b}_00000000")
    
    

if __name__ == "__main__":
    with open("main.asm", "r") as f:
        lines = f.readlines()

    removeCommentsAndEmptyLines()
    handleLabels()
    normValue()

    with open("main_norm.asm", "w") as f:
        for line in lines:
            f.write(f"{line}\n")

    for line in lines:
        assembleLine(line)

    with open("instruction_memory.bin", "w") as f:
        for line in machine_code:
            f.write(f"{line}\n")
    