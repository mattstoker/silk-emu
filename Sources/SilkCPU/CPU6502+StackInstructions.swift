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
        push(ac)
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
        push(sr | CPU6502.srBMask | CPU6502.srXMask)
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
        push(xr)
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
        push(yr)
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
        ac = pull()
        sr = CPU6502.flags(sr, value: ac)
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
        sr = pull()
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
        xr = pull()
        sr = CPU6502.flags(sr, value: xr)
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
        yr = pull()
        sr = CPU6502.flags(sr, value: yr)
    }
}
