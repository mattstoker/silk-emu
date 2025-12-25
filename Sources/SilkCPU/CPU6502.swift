//
//  CPU6502.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//

struct CPU6502: Hashable {
    var pc: UInt16
    var ac: UInt8
    var xr: UInt8
    var yr: UInt8
    var sr: UInt8
    var sp: UInt8
    var res: Bool
    var irq: Bool
    var nmi: Bool
}

extension CPU6502 {
    init(
        pc: UInt16 = 0x00,
        ac: UInt8 = 0x00,
        xr: UInt8 = 0x00,
        yr: UInt8 = 0x00,
        sr: UInt8 = 0x00,
        sp: UInt8 = 0x00,
        res: Bool = false,
        irq: Bool = false
        // nmi: Bool = false
    ) {
        self.pc = pc
        self.ac = ac
        self.xr = xr
        self.yr = yr
        self.sr = sr
        self.sp = sp
        self.res = res
        self.irq = irq
        self.nmi = false //nmi
    }
}

extension CPU6502 {
    var srN: Bool { sr & 0b10000000 != 0 }
    var srV: Bool { sr & 0b01000000 != 0 }
    var srX: Bool { sr & 0b00100000 != 0 }
    var srB: Bool { sr & 0b00010000 != 0 }
    var srD: Bool { sr & 0b00001000 != 0 }
    var srI: Bool { sr & 0b00000100 != 0 }
    var srZ: Bool { sr & 0b00000010 != 0 }
    var srC: Bool { sr & 0b00000001 != 0 }
}

// MARK: Transfer Instructions

extension CPU6502 {
    // Load Accumulator with Memory
    //
    // M -> A
    // N    Z    C    I    D    V
    // +    +    -    -    -    -
    // addressing   assembler    opc    bytes    cycles
    // immediate    LDA #oper    A9     2        2
    // zeropage     LDA oper     A5     2        3
    // zeropage,X   LDA oper,X   B5     2        4
    // absolute     LDA oper     AD     3        4
    // absolute,X   LDA oper,X   BD     3        4*
    // absolute,Y   LDA oper,Y   B9     3        4*
    // (indirect,X) LDA (oper,X) A1     2        6
    // (indirect),Y LDA (oper),Y B1     2        5*
    mutating func executeLDA(immediate oper: UInt8) {
        ac = oper
    }
    
    mutating func executeLDA(zeropage oper: UInt8) {
        ac = fetchZeroPage(oper)
    }
    
    mutating func executeLDA(zeropageX oper: UInt8) {
        ac = fetchZeroPage(oper &+ xr)
    }
    
    mutating func executeLDA(absolute oper: UInt16) {
        let address = oper
        ac = fetch(address)
    }
    
    mutating func executeLDA(absoluteX oper: UInt16) {
        let address = oper &+ UInt16(xr)
        ac = fetch(address)
    }
    
    mutating func executeLDA(absoluteY oper: UInt16) {
        let address = oper &+ UInt16(yr)
        ac = fetch(address)
    }
    
    mutating func executeLDA(indirectX oper: UInt16) {
        let ptr = oper &+ UInt16(xr)
        let low = fetch(ptr)
        let high = fetchNext(ptr)
        ac = fetch(high, low)
    }
    
    mutating func executeLDA(indirectY oper: UInt16) {
        let ptr = oper
        let low = fetch(ptr)
        let high = fetchNext(ptr)
        let address = UInt16(high: high, low: low) &+ UInt16(yr)
        ac = fetch(address)
    }
}

extension CPU6502 {
    nonisolated(unsafe) static var fetch: (UInt8, UInt8) -> UInt8 = { addressHigh, addressLow in
        return (addressHigh & 0xF0) | (addressLow & 0x0F)
    }
    
    func fetchNext(_ address: UInt16) -> UInt8 {
        return fetch(address &+ 1)
    }
    
    func fetchNext(_ addressHigh: UInt8, _ addressLow: UInt8) -> UInt8 {
        return fetchNext((UInt16(addressHigh) << 8) &+ UInt16(addressLow))
    }
    
    func fetchZeroPage(_ address: UInt8) -> UInt8 {
        return fetch(0x00, address)
    }
    
    func fetch(_ address: UInt16) -> UInt8 {
        let addressLow = UInt8(address & 0x00FF)
        let addressHigh = UInt8((address & 0xFF00) >> 8)
        return fetch(addressHigh, addressLow)
    }
    
    func fetch(_ addressHigh: UInt8, _ addressLow: UInt8) -> UInt8 {
        return CPU6502.fetch(addressHigh, addressLow)
    }
}

extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self = (UInt16(high) << 8) &+ UInt16(low)
    }
    
    var high: UInt8 {
        return UInt8((self & 0xFF00) >> 8)
    }
    
    var low: UInt8 {
        return UInt8(self & 0x00FF)
    }
}
