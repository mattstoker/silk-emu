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
    static let srNMask: UInt8 = 0b10000000
    static let srVMask: UInt8 = 0b01000000
    static let srXMask: UInt8 = 0b00100000
    static let srBMask: UInt8 = 0b00010000
    static let srDMask: UInt8 = 0b00001000
    static let srIMask: UInt8 = 0b00000100
    static let srZMask: UInt8 = 0b00000010
    static let srCMask: UInt8 = 0b00000001
    
    var srN: Bool { sr & CPU6502.srNMask != 0 }
    var srV: Bool { sr & CPU6502.srVMask != 0 }
    var srX: Bool { sr & CPU6502.srZMask != 0 }
    var srB: Bool { sr & CPU6502.srBMask != 0 }
    var srD: Bool { sr & CPU6502.srDMask != 0 }
    var srI: Bool { sr & CPU6502.srIMask != 0 }
    var srZ: Bool { sr & CPU6502.srZMask != 0 }
    var srC: Bool { sr & CPU6502.srCMask != 0 }
}

// MARK: Memory Subsystem

extension CPU6502 {
    // TODO: Lock
    nonisolated(unsafe) static var load: (UInt16) -> UInt8 = { address in
        return 0xEA
    }
    
    // TODO: Lock
    nonisolated(unsafe) static var store: (UInt16, UInt8) -> () = { address, value in
        return
    }
}

// MARK: Addressing Modes

extension CPU6502 {
    static let zeropage: UInt8 = 0x00
    static let stackpage: UInt8 = 0x01
    
    func load(zeropage oper: UInt8) -> UInt8 {
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(zeropageX oper: UInt8) -> UInt8 {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(zeropageY oper: UInt8) -> UInt8 {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ yr)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(absolute oper: UInt16) -> UInt8 {
        let address = oper
        let value = CPU6502.load(address)
        return value
    }
    
    func load(absoluteX oper: UInt16) -> UInt8 {
        let address = oper &+ UInt16(xr)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(absoluteY oper: UInt16) -> UInt8 {
        let address = oper &+ UInt16(yr)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(indirectX oper: UInt16) -> UInt8 {
        let pointer = oper &+ UInt16(xr)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(indirectY oper: UInt16) -> UInt8 {
        let pointer = oper
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low) &+ UInt16(yr)
        let value = CPU6502.load(address)
        return value
    }
    
    func load(zeropageIndirect oper: UInt8) -> UInt8 {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
        let value = CPU6502.load(address)
        return value
    }
    
    func store(zeropage oper: UInt8, value: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper)
        CPU6502.store(address, value)
    }
    
    func store(zeropageX oper: UInt8, value: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ xr)
        CPU6502.store(address, value)
    }
    
    func store(zeropageY oper: UInt8, value: UInt8) {
        let address = UInt16(high: CPU6502.zeropage, low: oper &+ yr)
        CPU6502.store(address, value)
    }
    
    func store(absolute oper: UInt16, value: UInt8) {
        let address = oper
        CPU6502.store(address, value)
    }
    
    func store(absoluteX oper: UInt16, value: UInt8) {
        let address = oper &+ UInt16(xr)
        CPU6502.store(address, value)
    }
    
    func store(absoluteY oper: UInt16, value: UInt8) {
        let address = oper &+ UInt16(yr)
        CPU6502.store(address, value)
    }
    
    func store(indirectX oper: UInt16, value: UInt8) {
        let pointer = oper &+ UInt16(xr)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
        CPU6502.store(address, value)
    }
    
    func store(indirectY oper: UInt16, value: UInt8) {
        let pointer = oper
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low) &+ UInt16(yr)
        CPU6502.store(address, value)
    }

    func store(zeropageIndirect oper: UInt8, value: UInt8) {
        let pointer = UInt16(high: CPU6502.zeropage, low: oper)
        let low = CPU6502.load(pointer)
        let high = CPU6502.load(pointer.next)
        let address = UInt16(high: high, low: low)
        CPU6502.store(address, value)
    }
}

// MARK: Conveniences

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
    
    var next: Self {
        self &+ 1
    }
}
