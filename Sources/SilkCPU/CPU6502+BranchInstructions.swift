//
//  CPU6502+BranchInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

// BNE
// Branch on Result not Zero
//
// branch on Z = 0
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BNE oper     D0     2        2**
extension CPU6502 {
    mutating func executeBNE(relative oper: UInt8) {
        if sr & CPU6502.srZMask == 0 {
            pc = address(relative: oper)
        }
    }
}

// BEQ
// Branch on Result Zero
//
// branch on Z = 1
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BEQ oper     F0     2        2**
extension CPU6502 {
    mutating func executeBEQ(relative oper: UInt8) {
        if sr & CPU6502.srZMask != 0 {
            pc = address(relative: oper)
        }
    }
}

// BCC
// Branch on Carry Clear
//
// branch on C = 0
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BCC oper     90     2        2**
extension CPU6502 {
    mutating func executeBCC(relative oper: UInt8) {
        if sr & CPU6502.srCMask == 0 {
            pc = address(relative: oper)
        }
    }
}

// BCS
// Branch on Carry Set
//
// branch on C = 1
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BCS oper     B0     2        2**
extension CPU6502 {
    mutating func executeBCS(relative oper: UInt8) {
        if sr & CPU6502.srCMask != 0 {
            pc = address(relative: oper)
        }
    }
}

// BPL
// Branch on Result Plus
//
// branch on N = 0
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BPL oper     10     2        2**
extension CPU6502 {
    mutating func executeBPL(relative oper: UInt8) {
        if sr & CPU6502.srNMask == 0 {
            pc = address(relative: oper)
        }
    }
}

// BMI
// Branch on Result Minus
//
// branch on N = 1
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BMI oper     30     2        2**
extension CPU6502 {
    mutating func executeBMI(relative oper: UInt8) {
        if sr & CPU6502.srNMask != 0 {
            pc = address(relative: oper)
        }
    }
}

// BVC
// Branch on Overflow Clear
//
// branch on V = 0
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BVC oper     50     2        2**
extension CPU6502 {
    mutating func executeBVC(relative oper: UInt8) {
        if sr & CPU6502.srVMask == 0 {
            pc = address(relative: oper)
        }
    }
}

// BVS
// Branch on Overflow Set
//
// branch on V = 1
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// relative      BVS oper     70     2        2**
extension CPU6502 {
    mutating func executeBVS(relative oper: UInt8) {
        if sr & CPU6502.srVMask != 0 {
            pc = address(relative: oper)
        }
    }
}

// BBR
// Branch on Bit Reset***
//
// This branch instruction tests a given bit of
// the accumulator and branches, if this bit is
// not set. This is an entire family of eight
// instructions in total, testing one of bits #0
// to #7, each. Individual mnemonics designate the
// tested bit, as in BBRn, where n = 0..7.
// As with all branch instructions, the address
// mode is relative, taking a signed single-byte
// offset as operand.
//
// branch on An = 0
// N    Z    C    I    D    V
// -    -    -    -    -    -
// bit tested    assembler    opc    bytes    cycles    W65C02-only
// 0 [-------0]  BBR0 oper    0F     2        5**       *
// 1 [------0-]  BBR1 oper    1F     2        5**       *
// 2 [-----0--]  BBR2 oper    2F     2        5**       *
// 3 [----0---]  BBR3 oper    3F     2        5**       *
// 4 [---0----]  BBR4 oper    4F     2        5**       *
// 5 [--0-----]  BBR5 oper    5F     2        5**       *
// 6 [-0------]  BBR6 oper    6F     2        5**       *
// 7 [0-------]  BBR7 oper    7F     2        5**       *
extension CPU6502 {
    mutating func executeBBR0(relative oper: UInt8) {
        if ac & 0b00000001 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR1(relative oper: UInt8) {
        if ac & 0b00000010 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR2(relative oper: UInt8) {
        if ac & 0b00000100 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR3(relative oper: UInt8) {
        if ac & 0b00001000 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR4(relative oper: UInt8) {
        if ac & 0b00010000 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR5(relative oper: UInt8) {
        if ac & 0b00100000 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR6(relative oper: UInt8) {
        if ac & 0b01000000 == 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBR7(relative oper: UInt8) {
        if ac & 0b10000000 == 0 {
            pc = address(relative: oper)
        }
    }
}

// BBS
// Branch on Bit Set***
//
// Similar to BBR, but branches on bit n set.
// Individual mnemonics designate the tested bit,
// as in BBSn, where n = 0..7.
// As with all branch instructions, the address
// mode is relative, taking a signed single-byte
// offset as operand.
//
// branch on An = 1
// N    Z    C    I    D    V
// -    -    -    -    -    -
// bit tested    assembler    opc    bytes    cycles    W65C02-only
// 0 [-------1]  BBS0 oper    8F     2        5**       *
// 1 [------1-]  BBS1 oper    9F     2        5**       *
// 2 [-----1--]  BBS2 oper    AF     2        5**       *
// 3 [----1---]  BBS3 oper    BF     2        5**       *
// 4 [---1----]  BBS4 oper    CF     2        5**       *
// 5 [--1-----]  BBS5 oper    DF     2        5**       *
// 6 [-1------]  BBS6 oper    EF     2        5**       *
// 7 [1-------]  BBS7 oper    FF     2        5**       *
extension CPU6502 {
    mutating func executeBBS0(relative oper: UInt8) {
        if ac & 0b00000001 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS1(relative oper: UInt8) {
        if ac & 0b00000010 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS2(relative oper: UInt8) {
        if ac & 0b00000100 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS3(relative oper: UInt8) {
        if ac & 0b00001000 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS4(relative oper: UInt8) {
        if ac & 0b00010000 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS5(relative oper: UInt8) {
        if ac & 0b00100000 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS6(relative oper: UInt8) {
        if ac & 0b01000000 != 0 {
            pc = address(relative: oper)
        }
    }
    
    mutating func executeBBS7(relative oper: UInt8) {
        if ac & 0b10000000 != 0 {
            pc = address(relative: oper)
        }
    }
}

// BRA
// Branch Always
//
// Similar to other branch instructions, but
// branches unconditionally.
// Equivalent to a relative jump.
//
// PC+2 + operand -> PC
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// relative      BRA oper     80     2        3*        *
extension CPU6502 {
    mutating func executeBRA(relative oper: UInt8) {
        pc = address(relative: oper)
    }
}
