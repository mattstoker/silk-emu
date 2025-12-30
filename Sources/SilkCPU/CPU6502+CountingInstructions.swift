//
//  CPU6502+CountingInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

// MARK: - Counting Instructions

let srDEC = CPU6502.srNMask | CPU6502.srZMask

// INC
// Increment Memory by One
//
// M + 1 -> M
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// zeropage      INC oper     E6     2        5
// zeropage,X    INC oper,X   F6     2        6
// absolute      INC oper     EE     3        6
// absolute,X    INC oper,X   FE     3        7
extension CPU6502 {
    mutating func executeINC(zeropage oper: UInt8) {
        let (result, status) = CPU6502.increment(load(zeropage: oper), status: sr)
        store(zeropage: oper, result)
        sr = sr & ~srDEC | status & srDEC
    }
    
    mutating func executeINC(zeropageX oper: UInt8) {
        let (result, status) = CPU6502.increment(load(zeropageX: oper), status: sr)
        store(zeropageX: oper, result)
        sr = sr & ~srDEC | status & srDEC
    }
    
    mutating func executeINC(absolute oper: UInt16) {
        let (result, status) = CPU6502.increment(load(absolute: oper), status: sr)
        store(absolute: oper, result)
        sr = sr & ~srDEC | status & srDEC
    }
    
    mutating func executeINC(absoluteX oper: UInt16) {
        let (result, status) = CPU6502.increment(load(absoluteX: oper), status: sr)
        store(absoluteX: oper, result)
        sr = sr & ~srDEC | status & srDEC
    }
}

// INC
// Increment by One (Accumulator)
//
// A + 1 -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// accumulator   INC A        1A     1        2         *
extension CPU6502 {
    mutating func executeINC() {
        let (result, status) = CPU6502.increment(ac, status: sr)
        ac = result
        sr = sr & ~srDEC | status & srDEC
    }
}

// INX
// Increment Index X by One
//
// X + 1 -> X
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       INX          E8     1        2
extension CPU6502 {
    mutating func executeINX() {
        let (result, status) = CPU6502.increment(xr, status: sr)
        xr = result
        sr = sr & ~srDEC | status & srDEC
    }
}

// INY
// Increment Index Y by One
//
// Y + 1 -> Y
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       INY          C8     1        2
extension CPU6502 {
    mutating func executeINY() {
        let (result, status) = CPU6502.increment(yr, status: sr)
        yr = result
        sr = sr & ~srDEC | status & srDEC
    }
}

// DEC
// Decrement Memory by One
//
// M - 1 -> M
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// zeropage      DEC oper     C6     2        5
// zeropage,X    DEC oper,X   D6     2        6
// absolute      DEC oper     CE     3        6
// absolute,X    DEC oper,X   DE     3        7
extension CPU6502 {
    mutating func executeDEC(zeropage oper: UInt8) {
        let (result, status) = CPU6502.decrement(load(zeropage: oper), status: sr)
        sr = sr & ~srDEC | status & srDEC
        store(zeropage: oper, result)
    }
    
    mutating func executeDEC(zeropageX oper: UInt8) {
        let (result, status) = CPU6502.decrement(load(zeropageX: oper), status: sr)
        sr = sr & ~srDEC | status & srDEC
        store(zeropageX: oper, result)
    }
    
    mutating func executeDEC(absolute oper: UInt16) {
        let (result, status) = CPU6502.decrement(load(absolute: oper), status: sr)
        sr = sr & ~srDEC | status & srDEC
        store(absolute: oper, result)
    }
    
    mutating func executeDEC(absoluteX oper: UInt16) {
        let (result, status) = CPU6502.decrement(load(absoluteX: oper), status: sr)
        sr = sr & ~srDEC | status & srDEC
        store(absoluteX: oper, result)
    }
}

// DEC
// Decrement by One (Accumulator)
//
// A - 1 -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// accumulator   DEC A        3A     1        2         *
extension CPU6502 {
    mutating func executeDEC() {
        let (result, status) = CPU6502.decrement(ac, status: sr)
        ac = result
        sr = sr & ~srDEC | status & srDEC
    }
}

// DEX
// Decrement Index X by One
//
// X - 1 -> X
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       DEX          CA     1        2
extension CPU6502 {
    mutating func executeDEX() {
        let (result, status) = CPU6502.decrement(xr, status: sr)
        xr = result
        sr = sr & ~srDEC | status & srDEC
    }
}

// DEY
// Decrement Index Y by One
//
// Y - 1 -> Y
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       DEY          88     1        2
extension CPU6502 {
    mutating func executeDEY() {
        let (result, status) = CPU6502.decrement(yr, status: sr)
        yr = result
        sr = sr & ~srDEC | status & srDEC
    }
}
