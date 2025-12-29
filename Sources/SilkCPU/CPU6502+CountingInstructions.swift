//
//  CPU6502+CountingInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

// MARK: - Counting Instructions

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
        let value = load(zeropage: oper)
        store(zeropage: oper, value: value &- 1)
    }
    
    mutating func executeDEC(zeropageX oper: UInt8) {
        let value = load(zeropageX: oper)
        store(zeropageX: oper, value: value &- 1)
    }
    
    mutating func executeDEC(absolute oper: UInt16) {
        let value = load(absolute: oper)
        store(absolute: oper, value: value &- 1)
    }
    
    mutating func executeDEC(absoluteX oper: UInt16) {
        let value = load(absoluteX: oper)
        store(absoluteX: oper, value: value &- 1)
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
        ac = ac &- 1
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
        xr = xr &- 1
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
        yr = yr &- 1
    }
}

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
        let value = load(zeropage: oper)
        store(zeropage: oper, value: value &+ 1)
    }
    
    mutating func executeINC(zeropageX oper: UInt8) {
        let value = load(zeropageX: oper)
        store(zeropageX: oper, value: value &+ 1)
    }
    
    mutating func executeINC(absolute oper: UInt16) {
        let value = load(absolute: oper)
        store(absolute: oper, value: value &+ 1)
    }
    
    mutating func executeINC(absoluteX oper: UInt16) {
        let value = load(absoluteX: oper)
        store(absoluteX: oper, value: value &+ 1)
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
        ac = ac &+ 1
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
        xr = xr &+ 1
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
        yr = yr &+ 1
    }
}
