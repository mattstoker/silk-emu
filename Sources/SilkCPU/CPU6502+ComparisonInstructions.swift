//
//  CPU6502+ComparisonInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

// MARK: - Comparision Instructions

fileprivate let srCMP = CPU6502.srNMask | CPU6502.srZMask | CPU6502.srCMask

// CMP
// Compare Memory with Accumulator
//
// A - M
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     CMP #oper    C9     2        2
// zeropage      CMP oper     C5     2        3
// zeropage,X    CMP oper,X   D5     2        4
// absolute      CMP oper     CD     3        4
// absolute,X    CMP oper,X   DD     3        4*
// absolute,Y    CMP oper,Y   D9     3        4*
// (indirect,X)  CMP (oper,X) C1     2        6
// (indirect),Y  CMP (oper),Y D1     2        5*
extension CPU6502 {
    mutating func executeCMP(immediate oper: UInt8) {
        let (_, status) = CPU6502.subtract(ac, oper, status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(zeropage oper: UInt8) {
        let (_, status) = CPU6502.subtract(ac, load(zeropage: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(zeropageX oper: UInt8) {
        let (_, status) = CPU6502.subtract(ac, load(zeropageX: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(absolute oper: UInt16) {
        let (_, status) = CPU6502.subtract(ac, load(absolute: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(absoluteX oper: UInt16) {
        let (_, status) = CPU6502.subtract(ac, load(absoluteX: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(absoluteY oper: UInt16) {
        let (_, status) = CPU6502.subtract(ac, load(absoluteY: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(preIndirectX oper: UInt8) {
        let (_, status) = CPU6502.subtract(ac, load(preIndirectX: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCMP(postIndirectY oper: UInt8) {
        let (_, status) = CPU6502.subtract(ac, load(postIndirectY: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
}

// CMP
// Compare Memory with Accumulator
//
// A - (ZPG)
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    CMP (oper)   D2     2        5         *
extension CPU6502 {
    mutating func executeCMP(zeropageIndirect oper: UInt8) {
        let (_, status) = CPU6502.subtract(ac, load(zeropageIndirect: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
}

// CPX
// Compare Memory and Index X
//
// X - M
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     CPX #oper    E0     2        2
// zeropage      CPX oper     E4     2        3
// absolute      CPX oper     EC     3        4
extension CPU6502 {
    mutating func executeCPX(immediate oper: UInt8) {
        let (_, status) = CPU6502.subtract(xr, oper, status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCPX(zeropage oper: UInt8) {
        let (_, status) = CPU6502.subtract(xr, load(zeropage: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCPX(absolute oper: UInt16) {
        let (_, status) = CPU6502.subtract(xr, load(absolute: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
}

// CPY
// Compare Memory and Index Y
//
// Y - M
// N    Z    C    I    D    V
// +    +    +    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     CPY #oper    C0     2        2
// zeropage      CPY oper     C4     2        3
// absolute      CPY oper     CC     3        4
extension CPU6502 {
    mutating func executeCPY(immediate oper: UInt8) {
        let (_, status) = CPU6502.subtract(yr, oper, status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCPY(zeropage oper: UInt8) {
        let (_, status) = CPU6502.subtract(yr, load(zeropage: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
    
    mutating func executeCPY(absolute oper: UInt16) {
        let (_, status) = CPU6502.subtract(yr, load(absolute: oper), status: CPU6502.srCMask)
        sr = sr & ~srCMP | status & srCMP
    }
}
