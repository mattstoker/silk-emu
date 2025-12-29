//
//  CPU6502+ArithmeticInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

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
    mutating func accumulate(adding value: UInt8) {
        let sum = UInt16(ac) + UInt16(value) + (srC ? 1 : 0)
        let carry = sum > 0xFF
        ac = UInt8(sum & 0xFF)
        sr = carry ? (sr | CPU6502.srCMask) : (sr & ~CPU6502.srCMask)
    }
    
    mutating func executeADC(immediate oper: UInt8) {
        accumulate(adding: oper)
    }
    
    mutating func executeADC(zeropage oper: UInt8) {
        accumulate(adding: load(zeropage: oper))
    }
    
    mutating func executeADC(zeropageX oper: UInt8) {
        accumulate(adding: load(zeropageX: oper))
    }
    
    mutating func executeADC(absolute oper: UInt16) {
        accumulate(adding: load(absolute: oper))
    }
    
    mutating func executeADC(absoluteX oper: UInt16) {
        accumulate(adding: load(absoluteX: oper))
    }
    
    mutating func executeADC(absoluteY oper: UInt16) {
        accumulate(adding: load(absoluteY: oper))
    }
    
    mutating func executeADC(indirectX oper: UInt16) {
        accumulate(adding: load(indirectX: oper))
    }
    
    mutating func executeADC(indirectY oper: UInt16) {
        accumulate(adding: load(indirectY: oper))
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
        accumulate(adding: load(zeropageIndirect: oper))
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
    mutating func accumulate(subtracting value: UInt8) {
        accumulate(adding: ~value)
    }
    
    mutating func executeSBC(immediate oper: UInt8) {
        accumulate(subtracting: oper)
    }
    
    mutating func executeSBC(zeropage oper: UInt8) {
        accumulate(subtracting: load(zeropage: oper))
    }
    
    mutating func executeSBC(zeropageX oper: UInt8) {
        accumulate(subtracting: load(zeropageX: oper))
    }
    
    mutating func executeSBC(absolute oper: UInt16) {
        accumulate(subtracting: load(absolute: oper))
    }
    
    mutating func executeSBC(absoluteX oper: UInt16) {
        accumulate(subtracting: load(absoluteX: oper))
    }
    
    mutating func executeSBC(absoluteY oper: UInt16) {
        accumulate(subtracting: load(absoluteY: oper))
    }
    
    mutating func executeSBC(indirectX oper: UInt16) {
        accumulate(subtracting: load(indirectX: oper))
    }
    
    mutating func executeSBC(indirectY oper: UInt16) {
        accumulate(subtracting: load(indirectY: oper))
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
        accumulate(subtracting: load(zeropageIndirect: oper))
    }
}
