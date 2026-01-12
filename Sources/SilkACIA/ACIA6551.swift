//
//  ACIA6551.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/11/26.
//

// MARK: ACIA State & Equality

public struct ACIA6551: Hashable {
    public internal(set) var sr: UInt8
    public internal(set) var ctl: UInt8
    public internal(set) var cmd: UInt8
    public internal(set) var tdr: UInt8
    public internal(set) var tsr: UInt8
    public internal(set) var rdr: UInt8
    public internal(set) var rsr: UInt8
    
    public init(
        sr: UInt8 = 0x00,
        ctl: UInt8 = 0x00,
        cmd: UInt8 = 0x00,
        tdr: UInt8 = 0x00,
        tsr: UInt8 = 0x00,
        rdr: UInt8 = 0x00,
        rsr: UInt8 = 0x00
    ) {
        self.sr = sr
        self.ctl = ctl
        self.cmd = cmd
        self.tdr = tdr
        self.tsr = tsr
        self.rdr = rdr
        self.rsr = rsr
    }
    
}

// MARK: - Register Addressing

extension ACIA6551 {
    public enum Register {
        case DATA
        case SR
        case CMD
        case CTL
    }
    
    static func destination(address: UInt8) -> Register {
        switch (address & 0x03) {
        case 0x1: return .SR
        case 0x2: return .CMD
        case 0x3: return .CTL
        default: return .DATA
        }
    }
}

// MARK: - Read & Write

extension ACIA6551 {
    public mutating func read(address: UInt8) -> UInt8 {
        let register = Self.destination(address: address)
        return read(register: register)
    }
    
    public mutating func write(address: UInt8, data: UInt8) {
        let register = Self.destination(address: address)
        write(register: register, data: data)
    }
    
    mutating func read(register: Register) -> UInt8 {
        switch register {
        case .DATA:
            sr = sr & 0b11110000
            return rdr
        case .SR:
            let sr = sr | 0b00010000
            self.sr = sr & 0b00011111
            return sr
        case .CMD:
            return cmd
        case .CTL:
            return ctl
        }
    }
    
    mutating func write(register: Register, data: UInt8) {
        switch register {
        case .DATA:
            tdr = data
            tsr = data
        case .SR:
            sr = sr & 0b11111101
            cmd = cmd & 0b11100000
        case .CMD:
            cmd = data
        case .CTL:
            ctl = data
        }
    }
}
