//
//  CPU6502+ArithmeticInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

// MARK: - Arithmetic Instructions

// ADC
// Add Memory to Accumulator with Carry
//
// A + M + C -> A, C
// N    Z    C    I    D    V
// +    +    +    -    -    +
// addressing    assembler    opc    bytes    cycles
// immediate     ADC #oper    69     2        2
// zeropage      ADC oper     65     2        3
// zeropage,X    ADC oper,X   75     2        4
// absolute      ADC oper     6D     3        4
// absolute,X    ADC oper,X   7D     3        4*
// absolute,Y    ADC oper,Y   79     3        4*
// (indirect,X)  ADC (oper,X) 61     2        6
// (indirect),Y  ADC (oper),Y 71     2        5*
extension CPU6502 {
    mutating func executeADC(immediate oper: UInt8) {
        (ac, sr) = CPU6502.add(ac, oper, status: sr)
    }
    
    mutating func executeADC(zeropage oper: UInt8) {
        (ac, sr) = CPU6502.add(ac, load(zeropage: oper), status: sr)
    }
    
    mutating func executeADC(zeropageX oper: UInt8) {
        (ac, sr) = CPU6502.add(ac, load(zeropageX: oper), status: sr)
    }
    
    mutating func executeADC(absolute oper: UInt16) {
        (ac, sr) = CPU6502.add(ac, load(absolute: oper), status: sr)
    }
    
    mutating func executeADC(absoluteX oper: UInt16) {
        (ac, sr) = CPU6502.add(ac, load(absoluteX: oper), status: sr)
    }
    
    mutating func executeADC(absoluteY oper: UInt16) {
        (ac, sr) = CPU6502.add(ac, load(absoluteY: oper), status: sr)
    }
    
    mutating func executeADC(preIndirectX oper: UInt16) {
        (ac, sr) = CPU6502.add(ac, load(preIndirectX: oper), status: sr)
    }
    
    mutating func executeADC(postIndirectY oper: UInt16) {
        (ac, sr) = CPU6502.add(ac, load(postIndirectY: oper), status: sr)
    }
}

// ADC
// Add Memory to Accumulator with Carry
//
// A + (ZPG) + C -> A, C
// N    Z    C    I    D    V
// +    +    +    -    -    +
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    ADC (oper)   72     2        5         *
extension CPU6502 {
    mutating func executeADC(zeropageIndirect oper: UInt8) {
        (ac, sr) = CPU6502.add(ac, load(zeropageIndirect: oper), status: sr)
    }
}

// SBC
// Subtract Memory from Accumulator with Borrow
//
// A - M - C̅ -> A
// N    Z    C    I    D    V
// +    +    +    -    -    +
// addressing    assembler    opc    bytes    cycles
// immediate     SBC #oper    E9     2        2
// zeropage      SBC oper     E5     2        3
// zeropage,X    SBC oper,X   F5     2        4
// absolute      SBC oper     ED     3        4
// absolute,X    SBC oper,X   FD     3        4*
// absolute,Y    SBC oper,Y   F9     3        4*
// (indirect,X)  SBC (oper,X) E1     2        6
// (indirect),Y  SBC (oper),Y F1     2        5*
extension CPU6502 {
    mutating func executeSBC(immediate oper: UInt8) {
        (ac, sr) = CPU6502.subtract(ac, oper, status: sr)
    }
    
    mutating func executeSBC(zeropage oper: UInt8) {
        (ac, sr) = CPU6502.subtract(ac, load(zeropage: oper), status: sr)
    }
    
    mutating func executeSBC(zeropageX oper: UInt8) {
        (ac, sr) = CPU6502.subtract(ac, load(zeropageX: oper), status: sr)
    }
    
    mutating func executeSBC(absolute oper: UInt16) {
        (ac, sr) = CPU6502.subtract(ac, load(absolute: oper), status: sr)
    }
    
    mutating func executeSBC(absoluteX oper: UInt16) {
        (ac, sr) = CPU6502.subtract(ac, load(absoluteX: oper), status: sr)
    }
    
    mutating func executeSBC(absoluteY oper: UInt16) {
        (ac, sr) = CPU6502.subtract(ac, load(absoluteY: oper), status: sr)
    }
    
    mutating func executeSBC(preIndirectX oper: UInt16) {
        (ac, sr) = CPU6502.subtract(ac, load(preIndirectX: oper), status: sr)
    }
    
    mutating func executeSBC(postIndirectY oper: UInt16) {
        (ac, sr) = CPU6502.subtract(ac, load(postIndirectY: oper), status: sr)
    }
}

// SBC
// Subtract Memory from Accumulator with Borrow
//
// A - (ZPG) - C̅ -> A
// N    Z    C    I    D    V
// +    +    +    -    -    +
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    SBC (oper)   F2     2        5         *
extension CPU6502 {
    mutating func executeSBC(zeropageIndirect oper: UInt8) {
        (ac, sr) = CPU6502.subtract(ac, load(zeropageIndirect: oper), status: sr)
    }
}
