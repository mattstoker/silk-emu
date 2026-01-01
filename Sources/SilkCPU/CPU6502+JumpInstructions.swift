//
//  CPU6502+JumpInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/31/25.
//

// JMP
// Jump to New Location
//
// operand 1st byte -> PCL
// operand 2nd byte -> PCH
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// absolute      JMP oper     4C     3        3
// indirect      JMP (oper)   6C     3        5
extension CPU6502 {
    mutating func executeJMP(absolute oper: UInt16) {
        pc = address(absolute: oper)
    }
    
    mutating func executeJMP(indirect oper: UInt16) {
        pc = address(indirect: oper)
    }
}

// JMP
// Jump to New Location
//
// (operand + X) 1st byte -> PCL
// (operand + X) 2nd byte -> PCH
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (absolute,X)  JMP (oper,X) 7C     3        6         *
extension CPU6502 {
    mutating func executeJMP(absoluteX oper: UInt16) {
        pc = address(absoluteX: oper)
    }
}

// JSR
// Jump to New Location Saving Return Address
//
// push (PC+2),
// operand 1st byte -> PCL
// operand 2nd byte -> PCH
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// absolute      JSR oper     20     3        6
extension CPU6502 {
    mutating func executeJSR(absolute oper: UInt16) {
        let pcNext = pc &+ 2 // TODO: Should be 3?
        let pcNextHigh = UInt8((pcNext & 0xFF00) >> 8)
        let pcNextLow = UInt8(pcNext & 0x00FF) >> 8
        store(stackpage: sp, pcNextHigh)
        sp = sp &- 1
        store(stackpage: sp, pcNextLow)
        sp = sp &- 1
        pc = address(absolute: oper)
    }
}

// RTS
// Return from Subroutine
//
// pull PC, PC+1 -> PC
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       RTS          60     1        6
extension CPU6502 {
    mutating func executeRTS() {
        let pcNextHigh = load(stackpage: sp)
        sp = sp &+ 1
        let pcNextLow = load(stackpage: sp)
        sp = sp &+ 1
        let pcNext = UInt16(high: pcNextHigh, low: pcNextLow)
        pc = address(absolute: pcNext)
    }
}
