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
        let value = ac
        ac = value << 1
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeASL(zeropage oper: UInt8) {
        let value = load(zeropage: oper)
        store(zeropage: oper, value: value << 1)
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeASL(zeropageX oper: UInt8) {
        let value = load(zeropageX: oper)
        store(zeropageX: oper, value: value << 1)
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeASL(absolute oper: UInt16) {
        let value = load(absolute: oper)
        store(absolute: oper, value: value << 1)
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeASL(absoluteX oper: UInt16) {
        let value = load(absoluteX: oper)
        store(absoluteX: oper, value: value << 1)
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
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
        let value = ac
        ac = value >> 1
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeLSR(zeropage oper: UInt8) {
        let value = load(zeropage: oper)
        store(zeropage: oper, value: value >> 1)
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeLSR(zeropageX oper: UInt8) {
        let value = load(zeropageX: oper)
        store(zeropageX: oper, value: value >> 1)
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeLSR(absolute oper: UInt16) {
        let value = load(absolute: oper)
        store(absolute: oper, value: value >> 1)
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeLSR(absoluteX oper: UInt16) {
        let value = load(absoluteX: oper)
        store(absoluteX: oper, value: value >> 1)
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
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
        let value = ac
        ac = value << 1 & (srC ? 0x01 : 0x00)
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROL(zeropage oper: UInt8) {
        let value = load(zeropage: oper)
        store(zeropage: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROL(zeropageX oper: UInt8) {
        let value = load(zeropageX: oper)
        store(zeropageX: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROL(absolute oper: UInt16) {
        let value = load(absolute: oper)
        store(absolute: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROL(absoluteX oper: UInt16) {
        let value = load(absoluteX: oper)
        store(absoluteX: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x80 == 0 ? sr : sr | CPU6502.srCMask
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
        let value = ac
        ac = value << 1 & (srC ? 0x01 : 0x00)
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROR(zeropage oper: UInt8) {
        let value = load(zeropage: oper)
        store(zeropage: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROR(zeropageX oper: UInt8) {
        let value = load(zeropageX: oper)
        store(zeropageX: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROR(absolute oper: UInt16) {
        let value = load(absolute: oper)
        store(absolute: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
    
    mutating func executeROR(absoluteX oper: UInt16) {
        let value = load(absoluteX: oper)
        store(absoluteX: oper, value: (value << 1) & (srC ? 0x01 : 0x00))
        sr = value & 0x01 == 0 ? sr : sr | CPU6502.srCMask
    }
}
