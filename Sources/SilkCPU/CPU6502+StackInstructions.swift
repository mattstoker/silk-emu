//
//  CPU6502+StackInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

// MARK: - Stack Instructions

// PHA
// Push Accumulator on Stack
//
// push A
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       PHA          48     1        3
extension CPU6502 {
    mutating func executePHA() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        store(absolute: address, ac)
        sp = sp &- 1
    }
}

// PHP
// Push Processor Status on Stack
//
// The status register will be pushed with the break
// flag and bit 5 set to 1.
//
// push SR
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       PHP          08     1        3
extension CPU6502 {
    mutating func executePHP() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        store(absolute: address, sr | CPU6502.srBMask | CPU6502.srXMask)
        sp = sp &- 1
    }
}

// PHX
// Push X Register on Stack
//
// push X
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// stack/implied PHX          DA     1        3         *
extension CPU6502 {
    mutating func executePHX() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        store(absolute: address, xr)
        sp = sp &- 1
    }
}

// PHY
// Push Y Register on Stack
//
// push Y
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// stack/implied PHY          5A     1        3         *
extension CPU6502 {
    mutating func executePHY() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        store(absolute: address, yr)
        sp = sp &- 1
    }
}

// PLA
// Pull Accumulator from Stack
//
// pull A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       PLA          68     1        4
extension CPU6502 {
    mutating func executePLA() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        ac = load(absolute: address)
        sp = sp &+ 1
    }
}

// PLP
// Pull Processor Status from Stack
//
// The status register will be pulled with the break
// flag and bit 5 ignored.
//
// pull SR
// N    Z    C    I    D    V
// from stack
// addressing    assembler    opc    bytes    cycles    
// implied       PLP          28     1        4
extension CPU6502 {
    mutating func executePLP() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        sr = load(absolute: address)
        sp = sp &+ 1
    }
}

// PLX
// Pull X Register from Stack
//
// pull X
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// implied       PLA          FA     1        4         *
extension CPU6502 {
    mutating func executePLX() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        xr = load(absolute: address)
        sp = sp &+ 1
    }
}

// PLY
// Pull Y Register from Stack
//
// pull Y
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// implied       PLA          7A     1        4         *
extension CPU6502 {
    mutating func executePLY() {
        let address = UInt16(high: CPU6502.stackpage, low: sp)
        yr = load(absolute: address)
        sp = sp &+ 1
    }
}
