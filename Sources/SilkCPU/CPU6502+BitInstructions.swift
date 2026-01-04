//
//  CPU6502+BitInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

// MARK: - Bit Instructions

// BIT
// Test Bits in Memory with Accumulator
//
// bits 7 and 6 of operand are transfered to bit 7 and 6 of SR (N,V);
// the zero-flag is set according to the result of the operand AND
// the accumulator (set, if the result is zero, unset otherwise).
// This allows a quick check of a few bits at once without affecting
// any of the registers, other than the status register (SR).
//
// A AND M -> Z, M7 -> N, M6 -> V
// N    Z    C    I    D    V
// M7   +    -    -    -    M6
// addressing    assembler    opc    bytes    cycles
// absolute      BIT oper     2C     3        4
extension CPU6502 {
    mutating func executeBIT(absolute oper: UInt16) {
        (_, sr) = CPU6502.bit(ac, load(absolute: oper), status: sr)
    }
}

// BIT
// Test Bits in Memory with Accumulator
//
// A AND M -> Z, M7 -> N, M6 -> V
// N    Z    C    I    D    V
// M7   +    -    -    -    M6
// addressing    assembler    opc    bytes    cycles    W65C02-only
// immediate     BIT #oper    89     3        2         *
// absolute,X    BIT oper,X   3C     3        4*        *
// zeropage      BIT oper     24     2        3         *
// zeropage,X    BIT oper,X   34     2        4         *
extension CPU6502 {
    mutating func executeBIT(immediate oper: UInt8) {
        (_, sr) = CPU6502.bit(ac, oper, status: sr)
    }
    
    mutating func executeBIT(absoluteX oper: UInt16) {
        (_, sr) = CPU6502.bit(ac, load(absoluteX: oper), status: sr)
    }
    
    mutating func executeBIT(zeropage oper: UInt8) {
        (_, sr) = CPU6502.bit(ac, load(zeropage: oper), status: sr)
    }
    
    mutating func executeBIT(zeropageX oper: UInt8) {
        (_, sr) = CPU6502.bit(ac, load(zeropageX: oper), status: sr)
    }
}

// TRB
//
// Test and Reset Memory Bit***
//
// This instruction first ANDs the contents of the given
// memory location with the contents of the accumulator (A)
// and sets the Z flag accordingly to the result, much
// like the BIT instruction. Then, the contents of the
// memory location is ANDed with the compliment of the
// mask in A, and then written back, thus clearing the
// bit(s) set in A.
// In other words, TRB clears the bits set in A in the
// specified location and sets Z, if any of these bits
// were set, otherwise resetting Z.
//
// A AND M -> Z, ¬A AND M -> M
// N    Z    C    I    D    V
// -    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// absolute      TRB oper     1C     3        6         *
// zeropage      TRB oper     14     2        5         *
extension CPU6502 {
    mutating func executeTRB(absolute oper: UInt16) {
        let value = load(absolute: oper)
        let result = ~ac & value
        let (_, status) = CPU6502.bit(ac, value, status: sr)
        sr = (sr & ~CPU6502.srZMask) | (status &  CPU6502.srZMask)
        store(absolute: oper, result)
    }
    
    mutating func executeTRB(zeropage oper: UInt8) {
        let value = load(zeropage: oper)
        let result = ~ac & value
        let (_, status) = CPU6502.bit(ac, value, status: sr)
        sr = (sr & ~CPU6502.srZMask) | (status &  CPU6502.srZMask)
        store(zeropage: oper, result)
    }
}

// TSB
// Test and Set Memory Bit***
//
// Similar to TRB, but sets the bits according to the bit
// mask in A.
// TSB sets the bits set in A in the specified location
// and sets Z, if any of these bits were previously set,
// otherwise resetting Z.
//
// A AND M -> Z, A OR M -> M
// N    Z    C    I    D    V
// -    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// absolute      TRB oper     0C     3        6         *
// zeropage      TRB oper     04     2        5         *
extension CPU6502 {
    mutating func executeTSB(absolute oper: UInt16) {
        let value = load(absolute: oper)
        let result = ac | value
        let (_, status) = CPU6502.bit(ac, value, status: sr)
        sr = (sr & ~CPU6502.srZMask) | (status &  CPU6502.srZMask)
        store(absolute: oper, result)
    }
    
    mutating func executeTSB(zeropage oper: UInt8) {
        let value = load(zeropage: oper)
        let result = ac | value
        let (_, status) = CPU6502.bit(ac, value, status: sr)
        sr = (sr & ~CPU6502.srZMask) | (status &  CPU6502.srZMask)
        store(zeropage: oper, result)
    }
}

// RMB
// Reset Memory Bit***
//
// Resets a bit in memory at the given zeropage
// location. This is an entire family of eight
// instructions in total, resetting one of bits #0
// to #7, each. Individual mnemonics designate the
// bit to be reset, as in RMBn, where n = 0..7.
// The operand is always a zeropage address.
//
// 0 -> Mn
// N    Z    C    I    D    V
// -    -    -    -    -    -
// bit reset     assembler    opc    bytes    cycles    W65C02-only
// 0 [-------0]  RMB0 zpg     07     2        5         *
// 1 [------0-]  RMB1 zpg     17     2        5         *
// 2 [-----0--]  RMB2 zpg     27     2        5         *
// 3 [----0---]  RMB3 zpg     37     2        5         *
// 4 [---0----]  RMB4 zpg     47     2        5         *
// 5 [--0-----]  RMB5 zpg     57     2        5         *
// 6 [-0------]  RMB6 zpg     67     2        5         *
// 7 [0-------]  RMB7 zpg     77     2        5         *
extension CPU6502 {
    mutating func executeRMB0(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b11111110)
    }
    
    mutating func executeRMB1(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b11111101)
    }
    
    mutating func executeRMB2(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b11111011)
    }
    
    mutating func executeRMB3(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b11110111)
    }
    
    mutating func executeRMB4(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b11101111)
    }
    
    mutating func executeRMB5(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b11011111)
    }
    
    mutating func executeRMB6(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b10111111)
    }
    
    mutating func executeRMB7(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) & 0b01111111)
    }
}

// SMB
// Set Memory Bit***
//
// Similar to RMB, but sets the respective bit.
// This is an entire family of eight instructions
// in total, setting one of bits #0to #7, each.
// Individual mnemonics designate the bit to be
// set, as in SMBn, where n = 0..7.
// The operand is always a zeropage address.
//
// 1 -> Mn
// N    Z    C    I    D    V
// -    -    -    -    -    -
// bit set       assembler    opc    bytes    cycles    W65C02-only
// 0 [-------1]  SMB0 zpg     87     2        5         *
// 1 [------1-]  SMB1 zpg     97     2        5         *
// 2 [-----1--]  SMB2 zpg     A7     2        5         *
// 3 [----1---]  SMB3 zpg     B7     2        5         *
// 4 [---1----]  SMB4 zpg     C7     2        5         *
// 5 [--1-----]  SMB5 zpg     D7     2        5         *
// 6 [-1------]  SMB6 zpg     E7     2        5         *
// 7 [1-------]  SMB7 zpg     F7     2        5         *
extension CPU6502 {
    mutating func executeSMB0(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b00000001)
    }
    
    mutating func executeSMB1(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b00000010)
    }
    
    mutating func executeSMB2(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b00000100)
    }
    
    mutating func executeSMB3(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b00001000)
    }
    
    mutating func executeSMB4(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b00010000)
    }
    
    mutating func executeSMB5(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b00100000)
    }
    
    mutating func executeSMB6(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b01000000)
    }
    
    mutating func executeSMB7(zeropage oper: UInt8) {
        store(zeropage: oper, load(zeropage: oper) | 0b10000000)
    }
}
