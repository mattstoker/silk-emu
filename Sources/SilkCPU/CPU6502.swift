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

// MARK: Memory Subsystem

extension CPU6502 {
    // TODO: Lock
    nonisolated(unsafe) static var load: (UInt16) -> UInt8 = { address in
        return 0xEA
    }
}

extension CPU6502 {
    // TODO: Lock
    nonisolated(unsafe) static var store: (UInt16, UInt8) -> () = { address, value in
        return
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
