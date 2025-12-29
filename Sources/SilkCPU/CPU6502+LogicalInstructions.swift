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
    mutating func accumulate(anding value: UInt8) {
        let result = ac & value
        ac = result
    }
    
    mutating func executeAND(immediate oper: UInt8) {
        accumulate(anding: oper)
    }
    
    mutating func executeAND(zeropage oper: UInt8) {
        accumulate(anding: load(zeropage: oper))
    }
    
    mutating func executeAND(zeropageX oper: UInt8) {
        accumulate(anding: load(zeropageX: oper))
    }
    
    mutating func executeAND(absolute oper: UInt16) {
        accumulate(anding: load(absolute: oper))
    }
    
    mutating func executeAND(absoluteX oper: UInt16) {
        accumulate(anding: load(absoluteX: oper))
    }
    
    mutating func executeAND(absoluteY oper: UInt16) {
        accumulate(anding: load(absoluteY: oper))
    }
    
    mutating func executeAND(indirectX oper: UInt16) {
        accumulate(anding: load(indirectX: oper))
    }
    
    mutating func executeAND(indirectY oper: UInt16) {
        accumulate(anding: load(indirectY: oper))
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
        accumulate(anding: load(zeropageIndirect: oper))
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
    mutating func accumulate(xoring value: UInt8) {
        let result = ac ^ value
        ac = result
    }
    
    mutating func executeEOR(immediate oper: UInt8) {
        accumulate(xoring: oper)
    }
    
    mutating func executeEOR(zeropage oper: UInt8) {
        accumulate(xoring: load(zeropage: oper))
    }
    
    mutating func executeEOR(zeropageX oper: UInt8) {
        accumulate(xoring: load(zeropageX: oper))
    }
    
    mutating func executeEOR(absolute oper: UInt16) {
        accumulate(xoring: load(absolute: oper))
    }
    
    mutating func executeEOR(absoluteX oper: UInt16) {
        accumulate(xoring: load(absoluteX: oper))
    }
    
    mutating func executeEOR(absoluteY oper: UInt16) {
        accumulate(xoring: load(absoluteY: oper))
    }
    
    mutating func executeEOR(indirectX oper: UInt16) {
        accumulate(xoring: load(indirectX: oper))
    }
    
    mutating func executeEOR(indirectY oper: UInt16) {
        accumulate(xoring: load(indirectY: oper))
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
        accumulate(xoring: load(zeropageIndirect: oper))
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
    mutating func accumulate(oring value: UInt8) {
        let result = ac | value
        ac = result
    }
    
    mutating func executeORA(immediate oper: UInt8) {
        accumulate(oring: oper)
    }
    
    mutating func executeORA(zeropage oper: UInt8) {
        accumulate(oring: load(zeropage: oper))
    }
    
    mutating func executeORA(zeropageX oper: UInt8) {
        accumulate(oring: load(zeropageX: oper))
    }
    
    mutating func executeORA(absolute oper: UInt16) {
        accumulate(oring: load(absolute: oper))
    }
    
    mutating func executeORA(absoluteX oper: UInt16) {
        accumulate(oring: load(absoluteX: oper))
    }
    
    mutating func executeORA(absoluteY oper: UInt16) {
        accumulate(oring: load(absoluteY: oper))
    }
    
    mutating func executeORA(indirectX oper: UInt16) {
        accumulate(oring: load(indirectX: oper))
    }
    
    mutating func executeORA(indirectY oper: UInt16) {
        accumulate(oring: load(indirectY: oper))
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
        accumulate(oring: load(zeropageIndirect: oper))
    }
}
