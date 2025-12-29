//
//  CPU6502+FlagInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

// MARK: - Flag Instructions

// CLC
// Clear Carry Flag
//
// 0 -> C
// N    Z    C    I    D    V
// -    -    0    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       CLC          18     1        2
extension CPU6502 {
    mutating func executeCLC() {
        sr = sr & ~CPU6502.srCMask
    }
}

// CLD
// Clear Decimal Mode
//
// 0 -> D
// N    Z    C    I    D    V
// -    -    -    -    0    -
// addressing    assembler    opc    bytes    cycles
// implied       CLD          D8     1        2
extension CPU6502 {
    mutating func executeCLD() {
        sr = sr & ~CPU6502.srDMask
    }
}

// CLI
// Clear Interrupt Disable Bit
//
// 0 -> I
// N    Z    C    I    D    V
// -    -    -    0    -    -
// addressing    assembler    opc    bytes    cycles
// implied       CLI          58     1        2
extension CPU6502 {
    mutating func executeCLI() {
        sr = sr & ~CPU6502.srIMask
    }
}

// CLV
// Clear Overflow Flag
//
// 0 -> V
// N    Z    C    I    D    V
// -    -    -    -    -    0
// addressing    assembler    opc    bytes    cycles
// implied       CLV          B8     1        2
extension CPU6502 {
    mutating func executeCLV() {
        sr = sr & ~CPU6502.srVMask
    }
}

// SEC
// Set Carry Flag
//
// 1 -> C
// N    Z    C    I    D    V
// -    -    1    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       SEC          38     1        2
extension CPU6502 {
    mutating func executeSEC() {
        sr = sr | CPU6502.srCMask
    }
}

// SED
// Set Decimal Flag
//
// 1 -> D
// N    Z    C    I    D    V
// -    -    -    -    1    -
// addressing    assembler    opc    bytes    cycles
// implied       SED          F8     1        2
extension CPU6502 {
    mutating func executeSED() {
        sr = sr | CPU6502.srDMask
    }
}

// SEI
// Set Interrupt Disable Status
//
// 1 -> I
// N    Z    C    I    D    V
// -    -    -    1    -    -
// addressing    assembler    opc    bytes    cycles
// implied       SEI          78     1        2
extension CPU6502 {
    mutating func executeSEI() {
        sr = sr | CPU6502.srIMask
    }
}
