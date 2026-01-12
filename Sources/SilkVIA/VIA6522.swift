//
//  VIA6522.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/8/26.
//

// MARK: VIA State & Equality

public struct VIA6522: Hashable {
    public internal(set) var pa: UInt8
    public internal(set) var pb: UInt8
    public internal(set) var ddra: UInt8
    public internal(set) var ddrb: UInt8
    public internal(set) var sr: UInt8
    public internal(set) var acr: UInt8
    public internal(set) var pcr: UInt8
    public internal(set) var ifr: UInt8
    public internal(set) var ier: UInt8
    public internal(set) var t1c: UInt16
    public internal(set) var t1l: UInt16
    public internal(set) var t2c: UInt16
    public internal(set) var t2l: UInt16
    
    public init(
        pa: UInt8 = 0x00,
        pb: UInt8 = 0x00,
        ddra: UInt8 = 0x00,
        ddrb: UInt8 = 0x00,
        sr: UInt8 = 0x00,
        acr: UInt8 = 0x00,
        pcr: UInt8 = 0x00,
        ifr: UInt8 = 0x00,
        ier: UInt8 = 0x00,
        t1c: UInt16 = 0x0000,
        t1l: UInt16 = 0x0000,
        t2c: UInt16 = 0x0000,
        t2l: UInt16 = 0x0000
    ) {
        self.pa = pa
        self.pb = pb
        self.ddra = ddra
        self.ddrb = ddrb
        self.sr = sr
        self.acr = acr
        self.pcr = pcr
        self.ifr = ifr
        self.ier = ier
        self.t1c = t1c
        self.t1l = t1l
        self.t2c = t2c
        self.t2l = t2l
    }
}

// MARK: - Register Addressing

extension VIA6522 {
    public enum Register {
        case PA
        case PB
        case DDRA
        case DDRB
        case SR
        case ACR
        case PCR
        case IFR
        case IER
        case T1C
        case T1L
        case T2C
        case T2L
    }
    
    static func destination(address: UInt8) -> (register: Register, bits: UInt16) {
        switch (address & 0x0F) {
        case 0x0: return (register: .PB, bits: 0x00FF)
        case 0x1: return (register: .PA, bits: 0x00FF)
        case 0x2: return (register: .DDRB, bits: 0x00FF)
        case 0x3: return (register: .DDRA, bits: 0x00FF)
        case 0x4: return (register: .T1C, bits: 0x00FF)
        case 0x5: return (register: .T1C, bits: 0xFF00)
        case 0x6: return (register: .T1L, bits: 0x00FF)
        case 0x7: return (register: .T1L, bits: 0xFF00)
        case 0x8: return (register: .T2C, bits: 0x00FF)
        case 0x9: return (register: .T2C, bits: 0xFF00)
        case 0xA: return (register: .SR, bits: 0x00FF)
        case 0xB: return (register: .ACR, bits: 0x00FF)
        case 0xC: return (register: .PCR, bits: 0x00FF)
        case 0xD: return (register: .IFR, bits: 0x00FF)
        case 0xE: return (register: .IER, bits: 0x00FF)
        default: return (register: .PA, bits: 0x00FF)
        }
    }
}

// MARK: - Read & Write

extension VIA6522 {
    public func read(address: UInt8, paIn: UInt8, pbIn: UInt8) -> UInt8 {
        let destination = Self.destination(address: address)
        return read(from: destination.bits, of: destination.register, paIn: paIn, pbIn: pbIn)
    }
    
    public mutating func write(address: UInt8, data: UInt8) {
        let destination = Self.destination(address: address)
        write(into: destination.bits, of: destination.register, given: data)
    }
    
    func read(from bits: UInt16, of register: Register, paIn: UInt8, pbIn: UInt8) -> UInt8 {
        switch register {
        case .PA:
            let value = Self.uInt8Expansion.reduce(into: 0) { r, m in r |= (ddra & m) == 0 ? (paIn & m) : (pa & m) }
            return pack(bits: bits, of: UInt16(value))
        case .PB:
            let value = Self.uInt8Expansion.reduce(into: 0) { r, m in r |= (ddrb & m) == 0 ? (pbIn & m) : (pb & m) }
            return pack(bits: bits, of: UInt16(value))
        case .DDRA: return pack(bits: bits, of: UInt16(ddra))
        case .DDRB: return pack(bits: bits, of: UInt16(ddrb))
        case .SR: return pack(bits: bits, of: UInt16(sr))
        case .ACR: return pack(bits: bits, of: UInt16(acr))
        case .PCR: return pack(bits: bits, of: UInt16(pcr))
        case .IFR: return pack(bits: bits, of: UInt16(ifr))
        case .IER: return pack(bits: bits, of: UInt16(ier))
        case .T1C: return pack(bits: bits, of: t1c)
        case .T1L: return pack(bits: bits, of: t1l)
        case .T2C: return pack(bits: bits, of: t2c)
        case .T2L: return pack(bits: bits, of: t2l)
        }
    }
    
    mutating func write(into bits: UInt16, of register: Register, given data: UInt8) {
        switch register {
        case .PA:
            let value = UInt8(unpack(data, into: bits))
            pa = Self.uInt8Expansion.reduce(into: 0) { r, m in r |= (ddra & m) != 0 ? (value & m) : (pa & m) }
        case .PB:
            let value = UInt8(unpack(data, into: bits))
            pb = Self.uInt8Expansion.reduce(into: 0) { r, m in r |= (ddrb & m) != 0 ? (value & m) : (pb & m) }
        case .DDRA: ddra = UInt8(unpack(data, into: bits))
        case .DDRB: ddrb = UInt8(unpack(data, into: bits))
        case .SR: sr = UInt8(unpack(data, into: bits))
        case .ACR: acr = UInt8(unpack(data, into: bits))
        case .PCR: pcr = UInt8(unpack(data, into: bits))
        case .IFR: ifr = UInt8(unpack(data, into: bits))
        case .IER: ier = UInt8(unpack(data, into: bits))
        case .T1C: t1c = unpack(data, into: bits)
        case .T1L: t1l = unpack(data, into: bits)
        case .T2C: t2c = unpack(data, into: bits)
        case .T2L: t2l = unpack(data, into: bits)
        }
    }
}

// MARK: - Data Packing

extension VIA6522 {
    static let uInt8Expansion: [UInt8] = [
        0b00000001,
        0b00000010,
        0b00000100,
        0b00001000,
        0b00010000,
        0b00100000,
        0b01000000,
        0b10000000,
    ]
    
    func pack(bits: UInt16, of value: UInt16) -> UInt8 {
        var value = value
        var bits = bits
        var result = UInt8(0x00)
        var mask = UInt8(0x01)
        while bits != 0 {
            if bits & 0x1 == 1 {
                result = (value & 0x1 == 1) ? (result | mask) : (result & ~mask)
                mask = mask << 1
            }
            bits = bits >> 1
            value = value >> 1
        }
        return result
    }
    
    func unpack(_ value: UInt8, into bits: UInt16) -> UInt16 {
        var value = value
        var bits = bits
        var result = UInt16(0x0000)
        var mask = UInt16(0x01)
        while bits != 0 {
            if bits & 0x1 == 1 {
                result = (value & 0x1 == 1) ? (result | mask) : (result & ~mask)
                value = value >> 1
            }
            bits = bits >> 1
            mask = mask << 1
        }
        return result
    }
}

// MARK: - Conveniences

extension UInt16 {
    init(high: UInt8, low: UInt8) {
        self = (UInt16(high) << 8) | UInt16(low)
    }
}
