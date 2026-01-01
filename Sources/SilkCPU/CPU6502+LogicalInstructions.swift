//
//  CPU6502+LogicalInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

// MARK: - Logical Instructions

// AND
// AND Memory with Accumulator
//
// A AND M -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     AND #oper    29     2        2
// zeropage      AND oper     25     2        3
// zeropage,X    AND oper,X   35     2        4
// absolute      AND oper     2D     3        4
// absolute,X    AND oper,X   3D     3        4*
// absolute,Y    AND oper,Y   39     3        4*
// (indirect,X)  AND (oper,X) 21     2        6
// (indirect),Y  AND (oper),Y 31     2        5*
extension CPU6502 {
    mutating func executeAND(immediate oper: UInt8) {
        (ac, sr) = CPU6502.and(ac, oper, status: sr)
    }
    
    mutating func executeAND(zeropage oper: UInt8) {
        (ac, sr) = CPU6502.and(ac, load(zeropage: oper), status: sr)
    }
    
    mutating func executeAND(zeropageX oper: UInt8) {
        (ac, sr) = CPU6502.and(ac, load(zeropageX: oper), status: sr)
    }
    
    mutating func executeAND(absolute oper: UInt16) {
        (ac, sr) = CPU6502.and(ac, load(absolute: oper), status: sr)
    }
    
    mutating func executeAND(absoluteX oper: UInt16) {
        (ac, sr) = CPU6502.and(ac, load(absoluteX: oper), status: sr)
    }
    
    mutating func executeAND(absoluteY oper: UInt16) {
        (ac, sr) = CPU6502.and(ac, load(absoluteY: oper), status: sr)
    }
    
    mutating func executeAND(preIndirectX oper: UInt16) {
        (ac, sr) = CPU6502.and(ac, load(preIndirectX: oper), status: sr)
    }
    
    mutating func executeAND(postIndirectY oper: UInt16) {
        (ac, sr) = CPU6502.and(ac, load(postIndirectY: oper), status: sr)
    }
}

// AND
// AND Memory with Accumulator
// 
// A AND (ZPG) -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    AND (oper)   32     2        5         *
extension CPU6502 {
    mutating func executeAND(zeropageIndirect oper: UInt8) {
        (ac, sr) = CPU6502.and(ac, load(zeropageIndirect: oper), status: sr)
    }
}

// ORA
// OR Memory with Accumulator
//
// A OR M -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     ORA #oper    09     2        2
// zeropage      ORA oper     05     2        3
// zeropage,X    ORA oper,X   15     2        4
// absolute      ORA oper     0D     3        4
// absolute,X    ORA oper,X   1D     3        4*
// absolute,Y    ORA oper,Y   19     3        4*
// (indirect,X)  ORA (oper,X) 01     2        6
// (indirect),Y  ORA (oper),Y 11     2        5*
extension CPU6502 {
    mutating func executeORA(immediate oper: UInt8) {
        (ac, sr) = CPU6502.or(ac, oper, status: sr)
    }
    
    mutating func executeORA(zeropage oper: UInt8) {
        (ac, sr) = CPU6502.or(ac, load(zeropage: oper), status: sr)
    }
    
    mutating func executeORA(zeropageX oper: UInt8) {
        (ac, sr) = CPU6502.or(ac, load(zeropageX: oper), status: sr)
    }
    
    mutating func executeORA(absolute oper: UInt16) {
        (ac, sr) = CPU6502.or(ac, load(absolute: oper), status: sr)
    }
    
    mutating func executeORA(absoluteX oper: UInt16) {
        (ac, sr) = CPU6502.or(ac, load(absoluteX: oper), status: sr)
    }
    
    mutating func executeORA(absoluteY oper: UInt16) {
        (ac, sr) = CPU6502.or(ac, load(absoluteY: oper), status: sr)
    }
    
    mutating func executeORA(preIndirectX oper: UInt16) {
        (ac, sr) = CPU6502.or(ac, load(preIndirectX: oper), status: sr)
    }
    
    mutating func executeORA(postIndirectY oper: UInt16) {
        (ac, sr) = CPU6502.or(ac, load(postIndirectY: oper), status: sr)
    }
}

// ORA
// OR Memory with Accumulator
//
// A OR (ZPG) -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    ORA (oper)   12     2        5         *
extension CPU6502 {
    mutating func executeORA(zeropageIndirect oper: UInt8) {
        (ac, sr) = CPU6502.or(ac, load(zeropageIndirect: oper), status: sr)
    }
}

// EOR
// Exclusive-OR Memory with Accumulator
//
// A EOR M -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate    EOR #oper    49    2    2
// zeropage    EOR oper    45    2    3
// zeropage,X    EOR oper,X    55    2    4
// absolute    EOR oper    4D    3    4
// absolute,X    EOR oper,X    5D    3    4*
// absolute,Y    EOR oper,Y    59    3    4*
// (indirect,X)    EOR (oper,X)    41    2    6
// (indirect),Y    EOR (oper),Y    51    2    5*
extension CPU6502 {
    mutating func executeEOR(immediate oper: UInt8) {
        (ac, sr) = CPU6502.xor(ac, oper, status: sr)
    }
    
    mutating func executeEOR(zeropage oper: UInt8) {
        (ac, sr) = CPU6502.xor(ac, load(zeropage: oper), status: sr)
    }
    
    mutating func executeEOR(zeropageX oper: UInt8) {
        (ac, sr) = CPU6502.xor(ac, load(zeropageX: oper), status: sr)
    }
    
    mutating func executeEOR(absolute oper: UInt16) {
        (ac, sr) = CPU6502.xor(ac, load(absolute: oper), status: sr)
    }
    
    mutating func executeEOR(absoluteX oper: UInt16) {
        (ac, sr) = CPU6502.xor(ac, load(absoluteX: oper), status: sr)
    }
    
    mutating func executeEOR(absoluteY oper: UInt16) {
        (ac, sr) = CPU6502.xor(ac, load(absoluteY: oper), status: sr)
    }
    
    mutating func executeEOR(preIndirectX oper: UInt16) {
        (ac, sr) = CPU6502.xor(ac, load(preIndirectX: oper), status: sr)
    }
    
    mutating func executeEOR(postIndirectY oper: UInt16) {
        (ac, sr) = CPU6502.xor(ac, load(postIndirectY: oper), status: sr)
    }
}

// EOR
// Exclusive-OR Memory with Accumulator
//
// A EOR (ZPG) -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    EOR (oper)   52     2        5         *
extension CPU6502 {
    mutating func executeEOR(zeropageIndirect oper: UInt8) {
        (ac, sr) = CPU6502.xor(ac, load(zeropageIndirect: oper), status: sr)
    }
}
