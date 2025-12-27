//
//  CPU6502+LDA.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

// LDA
// Load Accumulator with Memory
//
// M -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     LDA #oper    A9     2        2
// zeropage      LDA oper     A5     2        3
// zeropage,X    LDA oper,X   B5     2        4
// absolute      LDA oper     AD     3        4
// absolute,X    LDA oper,X   BD     3        4*
// absolute,Y    LDA oper,Y   B9     3        4*
// (indirect,X)  LDA (oper,X) A1     2        6
// (indirect),Y  LDA (oper),Y B1     2        5*
extension CPU6502 {
    mutating func executeLDA(immediate oper: UInt8) {
        ac = oper
    }
    
    mutating func executeLDA(zeropage oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper)
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(zeropageX oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper &+ xr)
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(absolute oper: UInt16) {
        let address = oper
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(absoluteX oper: UInt16) {
        let address = oper &+ UInt16(xr)
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(absoluteY oper: UInt16) {
        let address = oper &+ UInt16(yr)
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(indirectX oper: UInt16) {
        let pointer = oper &+ UInt16(xr)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(indirectY oper: UInt16) {
        let pointer = oper
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low) &+ UInt16(yr)
        ac = CPU6502.load(address)
    }
}

// LDX
// Load Index X with Memory
//
// M -> X
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     LDX #oper    A2     2        2
// zeropage      LDX oper     A6     2        3
// zeropage,Y    LDX oper,Y   B6     2        4
// absolute      LDX oper     AE     3        4
// absolute,Y    LDX oper,Y   BE     3        4*
extension CPU6502 {
    mutating func executeLDX(immediate oper: UInt8) {
        xr = oper
    }
    
    mutating func executeLDX(zeropage oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper)
        xr = CPU6502.load(address)
    }
    
    mutating func executeLDX(zeropageY oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper &+ xr)
        xr = CPU6502.load(address)
    }
    
    mutating func executeLDX(absolute oper: UInt16) {
        let address = oper
        xr = CPU6502.load(address)
    }
    
    mutating func executeLDX(absoluteY oper: UInt16) {
        let address = oper &+ UInt16(yr)
        xr = CPU6502.load(address)
    }
}

// LDY
// Load Index Y with Memory
//
// M -> Y
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// immediate     LDY #oper    A0     2        2
// zeropage      LDY oper     A4     2        3
// zeropage,X    LDY oper,X   B4     2        4
// absolute      LDY oper     AC     3        4
// absolute,X    LDY oper,X   BC     3        4*
extension CPU6502 {
    mutating func executeLDY(immediate oper: UInt8) {
        yr = oper
    }
    
    mutating func executeLDY(zeropage oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper)
        yr = CPU6502.load(address)
    }
    
    mutating func executeLDY(zeropageX oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper &+ xr)
        yr = CPU6502.load(address)
    }
    
    mutating func executeLDY(absolute oper: UInt16) {
        let address = oper
        yr = CPU6502.load(address)
    }
    
    mutating func executeLDY(absoluteX oper: UInt16) {
        let address = oper &+ UInt16(xr)
        yr = CPU6502.load(address)
    }
}
