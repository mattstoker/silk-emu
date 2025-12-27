//
//  CPU6502+ST.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

// STA
// Store Accumulator in Memory
//
// A -> M
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// zeropage      STA oper     85     2        3
// zeropage,X    STA oper,X   95     2        4
// absolute      STA oper     8D     3        4
// absolute,X    STA oper,X   9D     3        5
// absolute,Y    STA oper,Y   99     3        5
// (indirect,X)  STA (oper,X) 81     2        6
// (indirect),Y  STA (oper),Y 91     2        6
extension CPU6502 {
    mutating func executeSTA(zeropage oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper)
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(zeropageX oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper &+ xr)
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(absolute oper: UInt16) {
        let address = oper
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(absoluteX oper: UInt16) {
        let address = oper &+ UInt16(xr)
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(absoluteY oper: UInt16) {
        let address = oper &+ UInt16(yr)
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(indirectX oper: UInt16) {
        let pointer = oper &+ UInt16(xr)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(indirectY oper: UInt16) {
        let pointer = oper
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low) &+ UInt16(yr)
        CPU6502.store(address, ac)
    }
}

// STX
// Store Index X in Memory
//
// X -> M
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// zeropage      STX oper     86    2    3
// zeropage,Y    STX oper,Y   96    2    4
// absolute      STX oper     8E    3    4
extension CPU6502 {
    mutating func executeSTX(zeropage oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper)
        CPU6502.store(address, xr)
    }
    
    mutating func executeSTX(zeropageY oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper &+ yr)
        CPU6502.store(address, xr)
    }
    
    mutating func executeSTX(absolute oper: UInt16) {
        let address = oper
        CPU6502.store(address, xr)
    }
}

// STY
// Sore Index Y in Memory
//
// Y -> M
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// zeropage      STY oper     84    2    3
// zeropage,X    STY oper,X   94    2    4
// absolute      STY oper     8C    3    4
extension CPU6502 {
    mutating func executeSTY(zeropage oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper)
        CPU6502.store(address, yr)
    }
    
    mutating func executeSTY(zeropageX oper: UInt8) {
        let address = UInt16(high: 0x00, low: oper &+ xr)
        CPU6502.store(address, yr)
    }
    
    mutating func executeSTY(absolute oper: UInt16) {
        let address = oper
        CPU6502.store(address, yr)
    }
}
