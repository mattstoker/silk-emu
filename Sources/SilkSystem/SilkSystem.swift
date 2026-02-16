//
//  SilkSystem.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/18/26.
//

// MARK: - System

import SilkCPU
import SilkRAM
import SilkROM
import SilkVIA
import SilkACIA
import SilkLCD

public class System {
    public static let ramAddressSpace = (UInt16(0x0000)...UInt16(0x3FFF))
    public static let aciaAddressSpace = (UInt16(0x4000)...UInt16(0x5FFF))
    public static let viaAddressSpace = (UInt16(0x6000)...UInt16(0x7FFF))
    public static let romAddressSpace = (UInt16(0xE000)...UInt16(0xFFFF))
    
    public var cpu: CPU6502
    public var ram: RAMHM62256
    public var rom: ROMAT28C64B
    public var via: VIA6522
    public var acia: ACIA6551
    public var lcd: LCDHD44780
    public var controlPad: ControlPad
    public var breakpoints: Set<UInt16>
    
    public init() {
        cpu = CPU6502()
        ram = RAMHM62256()
        rom = ROMAT28C64B()
        via = VIA6522()
        acia = ACIA6551()
        lcd = LCDHD44780()
        controlPad = ControlPad()
        breakpoints = []
        
        cpu = CPU6502(
            load: { address in
                switch address {
                case System.ramAddressSpace:
                    return self.ram.load(address - System.ramAddressSpace.lowerBound)
                case System.aciaAddressSpace:
                    return self.acia.read(address: UInt8(address & 0x0003))
                case System.viaAddressSpace:
                    let lcdrs = (self.via.pa & 0b00100000) != 0
                    let lcdrw = (self.via.pa & 0b01000000) != 0
                    let lcde = (self.via.pa & 0b10000000) != 0
                    var lcddata = self.via.pb
                    if lcde {
                        self.lcd.execute(rs: lcdrs, rw: lcdrw, data: &lcddata)
                    }
                    let paIn = UInt8(0) |
                    (self.controlPad.upPressed ? 0b00000001 : 0) |
                    (self.controlPad.leftPressed ? 0b00000010 : 0) |
                    (self.controlPad.rightPressed ? 0b00000100 : 0) |
                    (self.controlPad.downPressed ? 0b00001000 : 0) |
                    (self.controlPad.actionPressed ? 0b00010000 : 0)
                    
                    return self.via.read(address: UInt8(address & 0x000F), paIn: paIn, pbIn: 0x00)
                case System.romAddressSpace:
                    return self.rom.load(address - System.romAddressSpace.lowerBound)
                default:
                    return 0xEA
                }
            },
            store: { address, value in
                switch address {
                case System.ramAddressSpace:
                    self.ram.store(address - System.ramAddressSpace.lowerBound, value)
                case System.aciaAddressSpace:
                    self.acia.write(address: UInt8(address & 0x0003), data: value)
                case System.viaAddressSpace:
                    self.via.write(address: UInt8(address & 0x000F), data: value)
                    let lcdrs = (self.via.pa & 0b00100000) != 0
                    let lcdrw = (self.via.pa & 0b01000000) != 0
                    let lcde = (self.via.pa & 0b10000000) != 0
                    var lcddata = self.via.pb
                    if lcde {
                        self.lcd.execute(rs: lcdrs, rw: lcdrw, data: &lcddata)
                    }
                default:
                    ()
                }
            }
        )
    }
    
    public func reset(
        cpu: Bool = true,
        ram: Bool = true,
        rom: Bool = false,
        via: Bool = true,
        acia: Bool = true,
        lcd: Bool = true,
        controlPad: Bool = true,
        breakpoints: Bool = true
    ) {
        if cpu {
            self.cpu = CPU6502(load: self.cpu.load, store: self.cpu.store)
        }
        if ram {
            self.ram = RAMHM62256()
        }
        if rom {
            self.rom = ROMAT28C64B()
        }
        if via {
            self.via = VIA6522()
        }
        if acia {
            self.acia = ACIA6551()
        }
        if lcd {
            self.lcd = LCDHD44780()
        }
        if controlPad {
            self.controlPad = ControlPad()
        }
        if breakpoints {
            self.breakpoints = []
        }
    }
    
    public func program(data: [UInt8], startingAt offset: UInt16) {
        let addresses = Int(offset)..<(Int(offset) + data.count)
        for address in addresses where System.ramAddressSpace.contains(UInt16(address)) {
            ram.store(UInt16(address) - System.ramAddressSpace.lowerBound, data[address - Int(offset)])
        }
        var romData: [UInt8] = Array(repeating: 0, count: ROMAT28C64B.size)
        for address in addresses where System.romAddressSpace.contains(UInt16(address)) {
            romData[address - Int(offset)] = data[address - Int(offset)]
        }
        rom.program(data: romData)
    }
    
    public func execute() -> (instruction: CPU6502.Instruction, oper: UInt8?, operWideHigh: UInt8?) {
        return cpu.execute()
    }
    
    public func execute(count: Int) {
        for _ in 0..<count {
            cpu.execute()
            if breakpoints.contains(cpu.pc) {
                break
            }
        }
    }
    
    public func run() {
        repeat {
            cpu.execute()
        } while !breakpoints.contains(cpu.pc)
    }
}

// MARK: - ControlPad

extension System {
    public struct ControlPad {
        public var leftPressed: Bool = false
        public var rightPressed: Bool = false
        public var upPressed: Bool = false
        public var downPressed: Bool = false
        public var actionPressed: Bool = false
    }
}

// MARK: - Memory Screenshot

extension System {
    public func memoryPPM(
        start: UInt16 = .min,
        end: UInt16 = .max,
        line: UInt16 = 0x80,
        channelMaxValue: UInt8 = 3,
        valueChannelConverter: (UInt8) -> (UInt8, UInt8, UInt8) = { (($0 & 0b00000011) >> 0, ($0 & 0b00001100) >> 2, ($0 & 0b00110000) >> 4) }
    ) -> String {
        let count = Int(min(end, UInt16.max)) - Int(min(start, min(end, UInt16.max)))
        let width = Int(line)
        let height = Int((Double(count) / Double(width)).rounded(.up))
        var screenshot = ""
        screenshot.append("P3\n")
        screenshot.append("\(width) \(height)\n")
        screenshot.append("\(channelMaxValue)\n")
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let address = pixelIndex >= count ? nil : start + UInt16(pixelIndex)
                let value: UInt8 = address.map { cpu.load($0) } ?? UInt8.min
                let (r, g, b) = valueChannelConverter(value)
                screenshot.append("\(r) \(g) \(b)\n")
            }
        }
        return screenshot
    }
}

// MARK: - Memory Convenience

extension System {
    public static func bits(of string: String) -> [Bool] {
        return Array(string.utf8.map { bits(of: $0) }.joined())
    }
    
    public static func bits(of byte: UInt8) -> [Bool] {
        return [
            (byte & 0b00000001) != 0,
            (byte & 0b00000010) != 0,
            (byte & 0b00000100) != 0,
            (byte & 0b00001000) != 0,
            (byte & 0b00010000) != 0,
            (byte & 0b00100000) != 0,
            (byte & 0b01000000) != 0,
            (byte & 0b10000000) != 0,
        ]
    }
    
    public static func bytes(of bits: [Bool]) -> [UInt8] {
        var bytes: [UInt8] = []
        for byteIndex in 0..<(bits.count / UInt8.bitWidth) {
            let bit0Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 0] ? 0b00000001 : 0
            let bit1Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 1] ? 0b00000010 : 0
            let bit2Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 2] ? 0b00000100 : 0
            let bit3Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 3] ? 0b00001000 : 0
            let bit4Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 4] ? 0b00010000 : 0
            let bit5Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 5] ? 0b00100000 : 0
            let bit6Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 6] ? 0b01000000 : 0
            let bit7Mask: UInt8 = bits[byteIndex * UInt8.bitWidth + 7] ? 0b10000000 : 0
            let byte: UInt8 = bit0Mask | bit1Mask | bit2Mask | bit3Mask | bit4Mask | bit5Mask | bit6Mask | bit7Mask
            bytes.append(byte)
        }
        return bytes
    }
    
    public static func string(of bits: [Bool]) -> String {
        return String(decoding: bytes(of: bits), as: UTF8.self)
    }
}
