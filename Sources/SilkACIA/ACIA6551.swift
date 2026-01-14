//
//  ACIA6551.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/11/26.
//

// MARK: ACIA State & Equality

public struct ACIA6551 {
    public internal(set) var sr: UInt8
    public internal(set) var ctl: UInt8
    public internal(set) var cmd: UInt8
    public internal(set) var ts: UInt8
    public internal(set) var tdr: UInt8
    public internal(set) var tsr: UInt8
    public internal(set) var rs: UInt8
    public internal(set) var rdr: UInt8
    public internal(set) var rsr: UInt8
    public internal(set) var transmit: (Bool) -> ()
    public internal(set) var receive: () -> Bool
    
    public init(
        sr: UInt8 = 0x00,
        ctl: UInt8 = 0x00,
        cmd: UInt8 = 0x00,
        ts: UInt8 = 0x00,
        tdr: UInt8 = 0x00,
        tsr: UInt8 = 0x00,
        rs: UInt8 = 0x00,
        rdr: UInt8 = 0x00,
        rsr: UInt8 = 0x00,
        transmit: @escaping (Bool) -> () = { _ in },
        receive: @escaping () -> Bool = { true }
    ) {
        self.sr = sr
        self.ctl = ctl
        self.cmd = cmd
        self.ts = ts
        self.tdr = tdr
        self.tsr = tsr
        self.rs = rs
        self.rdr = rdr
        self.rsr = rsr
        self.transmit = transmit
        self.receive = receive
    }
}

extension ACIA6551: Equatable {
    public static func == (lhs: ACIA6551, rhs: ACIA6551) -> Bool {
        return
            lhs.sr == rhs.sr &&
            lhs.ctl == rhs.ctl &&
            lhs.cmd == rhs.cmd &&
            lhs.ts == rhs.ts &&
            lhs.tdr == rhs.tdr &&
            lhs.tsr == rhs.tsr &&
            lhs.rs == rhs.rs &&
            lhs.rdr == rhs.rdr &&
            lhs.rsr == rhs.rsr
    }
}

extension ACIA6551: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(sr)
        hasher.combine(ctl)
        hasher.combine(cmd)
        hasher.combine(ts)
        hasher.combine(tdr)
        hasher.combine(tsr)
        hasher.combine(rs)
        hasher.combine(rdr)
        hasher.combine(rsr)
    }
}

// MARK: - Status Register Bits

extension ACIA6551 {
    static let srParityEMask: UInt8 = 0b00000001
    static let srFramingEMask: UInt8 = 0b00000100
    static let srOverrunMask: UInt8 = 0b00000100
    static let srRDRFullMask: UInt8 = 0b00001000
    static let srTDREmptyMask: UInt8 = 0b00010000
    static let srDCDBMask: UInt8 = 0b00100000
    static let srDSRBMask: UInt8 = 0b01000000
    static let srInterruptMask: UInt8 = 0b10000000
    static let tsCountMask: UInt8 = 0b00001111
    static let rsCountMask: UInt8 = 0b00001111
}

// MARK: - Register Addressing

extension ACIA6551 {
    public enum Register: UInt8 {
        case DATA = 0x0
        case SR = 0x1
        case CMD = 0x2
        case CTL = 0x3
    }
    
    static func destination(address: UInt8) -> Register {
        return Register(rawValue: address) ?? .DATA
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
            // Clear auto-clearing bits of the Status Register on read of the RDR
            sr = sr & ~ACIA6551.srRDRFullMask & ~ACIA6551.srOverrunMask & ~ACIA6551.srFramingEMask & ~ACIA6551.srParityEMask
            return rdr
        case .SR:
            // Query the current Status Register value and ensure the TDR Empty flag is always set when read (W65C51-specific behavior)
            let sr = sr | ACIA6551.srTDREmptyMask
            
            // Clear the data status bits from the Status Register, but return the previously queried state
            self.sr = sr & ~ACIA6551.srDCDBMask & ~ACIA6551.srDSRBMask & ~ACIA6551.srInterruptMask
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
            // Write both the Transmit Data Register and Transmit Shift Register (W65C51-specific behavior)
            tdr = data
            tsr = data
            let tsCount = UInt8(8)
            ts = ts | (tsCount & ACIA6551.tsCountMask)
        case .SR:
            // Set the flags required by a Program Reset
            sr = sr & 0b11111101
            cmd = cmd & 0b11100000
        case .CMD:
            cmd = data
        case .CTL:
            ctl = data
        }
    }
}

// MARK: - Transmit & Receive

extension ACIA6551 {
    public mutating func receiveBit() {
        // Receive the bit and shift it into the Receive Shift Register
        let bit = receive()
        rsr = (rsr >> 1) | (bit ? 0b10000000 : 0b00000000)
        
        // Read the status of the receive registers
        var rsCount = UInt8(rs & ACIA6551.rsCountMask)
        
        // Increment the count of received bits in the RSR
        // When the RSR is full, transfer it to the RDR
        // On transfer, if the data in the RDR had not been read yet, set the overrun flag
        rsCount += 1
        if rsCount == 8 {
            rdr = rsr
            rsr = 0b00000000
            if (sr & ACIA6551.srRDRFullMask) != 0 {
                sr = sr | ACIA6551.srOverrunMask
            }
            sr = sr | ACIA6551.srRDRFullMask
            rsCount = 0
        }
        rs = (rs & ~ACIA6551.rsCountMask) | (rsCount & ACIA6551.rsCountMask)
    }
    
    public mutating func transmitBit() {
        // Read the status of the transmit registers
        var tsCount = UInt8(ts & ACIA6551.tsCountMask)
        
        // Decrement the count of bits-to-transmit in the TSR
        // When the TSR is empty, it is logical to transfer the TDR to it, but that is not how the W65C51 works
        // Instead, the TSR and TDR are written at the same time, and SR bit 5 is never 0
        tsCount -= 1
        ts = (ts & ~ACIA6551.tsCountMask) | (tsCount & ACIA6551.tsCountMask)
        if (tsCount == 0) {
            tsCount = 8
        }
        
        // Shift the bit to transmit out of the Transmit Shift Register and transmit it
        let bit = (tsr & 0b1) != 0
        tsr = tsr >> 1
        transmit(bit)
    }
}
