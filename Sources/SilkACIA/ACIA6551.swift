//
//  ACIA6551.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/11/26.
//
//  Official documentation for the W65C51 can be found at:
//  https://www.westerndesigncenter.com/wdc/documentation/w65c51n.pdf
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
    
    public init(
        sr: UInt8 = 0x00,
        ctl: UInt8 = 0x00,
        cmd: UInt8 = 0x00,
        ts: UInt8 = 0x00,
        tdr: UInt8 = 0x00,
        tsr: UInt8 = 0x00,
        rs: UInt8 = 0x00,
        rdr: UInt8 = 0x00,
        rsr: UInt8 = 0x00
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

// MARK: - Control Register Bits & Interpretation

extension ACIA6551 {
    static let ctlBaudRateMask: UInt8 = 0b00001111
    static let ctlBaudRateShift: UInt8 = 0
    static let ctlClockSourceMask: UInt8 = 0b00010000
    static let ctlWordLengthMask: UInt8 = 0b01100000
    static let ctlWordLengthShift: UInt8 = 5
    static let ctlStopBitNumberMask: UInt8 = 0b10000000
}

extension ACIA6551 {
    public enum BaudRate: Double {
        case r50 = 50
        case r75 = 75
        case r109p92 = 109.92
        case r134p58 = 134.58
        case r150 = 150
        case r300 = 300
        case r600 = 600
        case r1200 = 1200
        case r1800 = 1800
        case r2400 = 2400
        case r3600 = 3600
        case r4800 = 4800
        case r7200 = 7200
        case r9600 = 9600
        case r19200 = 19200
        case r115200 = 115200
    }
    
    public var baudRate: BaudRate {
        let setting = (ctl & ACIA6551.ctlBaudRateMask) >> ACIA6551.ctlBaudRateShift
        switch setting & 0b1111 {
        case 0: return .r115200
        case 1: return .r50
        case 2: return .r75
        case 3: return .r109p92
        case 4: return .r134p58
        case 5: return .r150
        case 6: return .r300
        case 7: return .r600
        case 8: return .r1200
        case 9: return .r1800
        case 10: return .r2400
        case 11: return .r3600
        case 12: return .r4800
        case 13: return .r7200
        case 14: return .r9600
        default: return .r19200
        }
    }
}

extension ACIA6551 {
    public var receiverClockSourceMatchTransmitter: Bool {
        let setting = (ctl & ACIA6551.ctlClockSourceMask)
        return setting == 0 ? false : true
    }
}

extension ACIA6551 {
    public enum WordLength: Int {
        case l5 = 5
        case l6 = 6
        case l7 = 7
        case l8 = 8
    }
    
    public var wordLength: WordLength {
        let setting = (ctl & ACIA6551.ctlWordLengthMask) >> ACIA6551.ctlWordLengthShift
        switch setting & 0b11 {
        case 0: return .l5
        case 1: return .l6
        case 2: return .l7
        default: return .l8
        }
    }
}

extension ACIA6551 {
    public enum StopBits: Double {
        case s1 = 1
        case s1p5 = 1.5
        case s2 = 2
    }
    
    public var stopBits: StopBits {
        let setting = (ctl & ACIA6551.ctlStopBitNumberMask)
        switch (setting == 0, wordLength) {
        case (true, _): return .s1
        case (false, .l5): return .s1p5
        case (false, _): return .s2
        }
    }
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
    public mutating func receiveBit(receive: () -> Bool) {
        // Read the status of the receive registers
        var rsCount = UInt8(rs & ACIA6551.rsCountMask)
        
        // Receive the bit and shift it into the Receive Shift Register
        let bit = receive()
        rsr = (rsr >> 1) | (bit ? 0b10000000 : 0b00000000)
        rsCount = min(8, rsCount + 1)
        
        // Increment the count of received bits in the RSR
        // When the RSR is full, transfer it to the RDR
        // On transfer, if the data in the RDR had not been read yet, set the overrun flag
        if rsCount == 8 {
            rdr = rsr
            rsr = 0b00000000
            if (sr & ACIA6551.srRDRFullMask) != 0 {
                sr = sr | ACIA6551.srOverrunMask
            }
            sr = sr | ACIA6551.srRDRFullMask
            rsCount = 0
        }
        
        // Update the status of the receive registers
        rs = (rs & ~ACIA6551.rsCountMask) | (rsCount & ACIA6551.rsCountMask)
    }
    
    public mutating func transmitBit(transmit: (Bool) -> ()) {
        // Read the status of the transmit registers
        var tsCount = UInt8(ts & ACIA6551.tsCountMask)
        
        // Decrement the count of bits-to-transmit in the TSR
        // When the TSR is empty, it is logical to transfer the TDR to it, but that is not how the W65C51 works
        // Instead, the TSR and TDR are written at the same time, and SR bit 5 is never 0
        if tsCount == 0 {
            //sr = sr | ACIA6551.srTDREmptyMask
            //tsr = tdr
            //tdr = 0b00000000
        }
        
        // Shift the bit to transmit out of the Transmit Shift Register and transmit it
        let bit = (tsr & 0b1) != 0
        tsr = tsr >> 1
        transmit(bit)
        tsCount = max(0, tsCount - 1)
        
        // Update the status of the receive registers
        ts = (ts & ~ACIA6551.tsCountMask) | (tsCount & ACIA6551.tsCountMask)
    }
}
