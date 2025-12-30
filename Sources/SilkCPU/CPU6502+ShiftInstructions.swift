//
//  CPU6502+ShiftInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

// MARK: - Shift Instructions

// ASL
// Shift Left One Bit (Memory or Accumulator)
//
// C <- [76543210] <- 0
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// accumulator   ASL A        0A     1        2
// zeropage      ASL oper     06     2        5
// zeropage,X    ASL oper,X   16     2        6
// absolute      ASL oper     0E     3        6
// absolute,X    ASL oper,X   1E     3        7
extension CPU6502 {
    mutating func executeASL() {
        (ac, sr) = CPU6502.left(ac, status: sr & ~CPU6502.srCMask)
    }
    
    mutating func executeASL(zeropage oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(zeropage: oper), status: sr & ~CPU6502.srCMask)
        store(zeropage: oper, value)
    }
    
    mutating func executeASL(zeropageX oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(zeropageX: oper), status: sr & ~CPU6502.srCMask)
        store(zeropageX: oper, value)
    }
    
    mutating func executeASL(absolute oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(absolute: oper), status: sr & ~CPU6502.srCMask)
        store(absolute: oper, value)
    }
    
    mutating func executeASL(absoluteX oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(absoluteX: oper), status: sr & ~CPU6502.srCMask)
        store(absoluteX: oper, value)
    }
}

// LSR
// Shift One Bit Right (Memory or Accumulator)
//
// 0 -> [76543210] -> C
// N    Z    C    I    D    V
// 0    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// accumulator   LSR A        4A     1        2
// zeropage      LSR oper     46     2        5
// zeropage,X    LSR oper,X   56     2        6
// absolute      LSR oper     4E     3        6
// absolute,X    LSR oper,X   5E     3        7
extension CPU6502 {
    mutating func executeLSR() {
        (ac, sr) = CPU6502.right(ac, status: sr & ~CPU6502.srCMask)
    }
    
    mutating func executeLSR(zeropage oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(zeropage: oper), status: sr & ~CPU6502.srCMask)
        store(zeropage: oper, value)
    }
    
    mutating func executeLSR(zeropageX oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(zeropageX: oper), status: sr & ~CPU6502.srCMask)
        store(zeropageX: oper, value)
    }
    
    mutating func executeLSR(absolute oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(absolute: oper), status: sr & ~CPU6502.srCMask)
        store(absolute: oper, value)
    }
    
    mutating func executeLSR(absoluteX oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(absoluteX: oper), status: sr & ~CPU6502.srCMask)
        store(absoluteX: oper, value)
    }
}

// ROL
// Rotate One Bit Left (Memory or Accumulator)
//
// C <- [76543210] <- C
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// accumulator   ROL A        2A     1        2
// zeropage      ROL oper     26     2        5
// zeropage,X    ROL oper,X   36     2        6
// absolute      ROL oper     2E     3        6
// absolute,X    ROL oper,X   3E     3        7
extension CPU6502 {
    mutating func executeROL() {
        (ac, sr) = CPU6502.left(ac, status: sr)
    }
    
    mutating func executeROL(zeropage oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(zeropage: oper), status: sr)
        store(zeropage: oper, value)
    }
    
    mutating func executeROL(zeropageX oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(zeropageX: oper), status: sr)
        store(zeropageX: oper, value)
    }
    
    mutating func executeROL(absolute oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(absolute: oper), status: sr)
        store(absolute: oper, value)
    }
    
    mutating func executeROL(absoluteX oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.left(load(absoluteX: oper), status: sr)
        store(absoluteX: oper, value)
    }
}

// ROR
// Rotate One Bit Right (Memory or Accumulator)
//
// C -> [76543210] -> C
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// accumulator   ROR A        6A     1        2
// zeropage      ROR oper     66     2        5
// zeropage,X    ROR oper,X   76     2        6
// absolute      ROR oper     6E     3        6
// absolute,X    ROR oper,X   7E     3        7
extension CPU6502 {
    mutating func executeROR() {
        (ac, sr) = CPU6502.right(ac, status: sr)
    }
    
    mutating func executeROR(zeropage oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(zeropage: oper), status: sr)
        store(zeropage: oper, value)
    }
    
    mutating func executeROR(zeropageX oper: UInt8) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(zeropageX: oper), status: sr)
        store(zeropageX: oper, value)
    }
    
    mutating func executeROR(absolute oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(absolute: oper), status: sr)
        store(absolute: oper, value)
    }
    
    mutating func executeROR(absoluteX oper: UInt16) {
        let value: UInt8
        (value, sr) = CPU6502.right(load(absoluteX: oper), status: sr)
        store(absoluteX: oper, value)
    }
}
