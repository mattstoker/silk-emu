//
//  CPU6502+TransferInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

// MARK: - Load Instructions

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
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        ac = CPU6502.load(address)
    }
    
    mutating func executeLDA(zeropageX oper: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
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

// LDA
// Load Accumulator with Memory
//
// (ZPG) -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    LDA (oper)   B2     2        5         *
extension CPU6502 {
    mutating func executeLDA(zeropageIndirect oper: UInt8) {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
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
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        xr = CPU6502.load(address)
    }
    
    mutating func executeLDX(zeropageY oper: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ yr)
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
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        yr = CPU6502.load(address)
    }
    
    mutating func executeLDY(zeropageX oper: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
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

// MARK: - Store Instructions

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
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        CPU6502.store(address, ac)
    }
    
    mutating func executeSTA(zeropageX oper: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
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

// STA
// Store Accumulator in Memory
//
// A -> (ZPG)
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles    W65C02-only
// (zeropage)    SBC (oper)   92     2        5         *
extension CPU6502 {
    mutating func executeSTA(zeropageIndirect oper: UInt8) {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
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
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        CPU6502.store(address, xr)
    }
    
    mutating func executeSTX(zeropageY oper: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ yr)
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
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        CPU6502.store(address, yr)
    }
    
    mutating func executeSTY(zeropageX oper: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
        CPU6502.store(address, yr)
    }
    
    mutating func executeSTY(absolute oper: UInt16) {
        let address = oper
        CPU6502.store(address, yr)
    }
}

// MARK: - Register Transfer Instructions

// TAX
// Transfer Accumulator to Index X
//
// A -> X
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       TAX          AA     1        2
extension CPU6502 {
    mutating func executeTAX() {
        xr = ac
    }
}

// TXA
// Transfer Index X to Accumulator
//
// X -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       TXA          8A     1        2
extension CPU6502 {
    mutating func executeTXA() {
        ac = xr
    }
}

// TAY
// Transfer Accumulator to Index Y
//
// A -> Y
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       TAY          A8     1        2
extension CPU6502 {
    mutating func executeTAY() {
        yr = ac
    }
}

// TYA
// Transfer Index Y to Accumulator
//
// Y -> A
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       TYA          98     1        2
extension CPU6502 {
    mutating func executeTYA() {
        ac = yr
    }
}

// TSX
// Transfer Stack Pointer to Index X
//
// SP -> X
// N    Z    C    I    D    V
// +    +    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       TSX          BA     1        2
extension CPU6502 {
    mutating func executeTSX() {
        xr = sp
    }
}

// TXS
// Transfer Index X to Stack Register
//
// X -> SP
// N    Z    C    I    D    V
// -    -    -    -    -    -
// addressing    assembler    opc    bytes    cycles
// implied       TXS          9A     1        2
extension CPU6502 {
    mutating func executeTXS() {
        sp = xr
    }
}
