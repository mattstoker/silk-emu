//
//  LCDHD44780.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/10/26.
//

public struct LCDHD44780: Hashable {
    public static let ddramSize = 80
    public static let cgramSize = 64
//    public static let cgromSize = 1240
    
    public internal(set) var ir: UInt8
    public internal(set) var dr: UInt8
    public internal(set) var ac: UInt8
    
    public internal(set) var id: Bool
    public internal(set) var s: Bool
    public internal(set) var d: Bool
    public internal(set) var c: Bool
    public internal(set) var b: Bool
    public internal(set) var sc: Bool
    public internal(set) var rl: Bool
    public internal(set) var dl: Bool
    public internal(set) var n: Bool
    public internal(set) var f: Bool
    public internal(set) var busy: Bool
    
    public internal(set) var cursor: UInt8
    public internal(set) var shift: UInt8
    
    public internal(set) var ddram: [UInt8]
    public internal(set) var cgram: [UInt8]
//    public let cgrom: [UInt8]
    
    public init() {
        ir = 0x00
        dr = 0x00
        ac = 0x00
        id = true
        s = false
        d = false
        c = false
        b = false
        sc = false
        rl = false
        dl = true
        n = false
        f = false
        busy = false
        cursor = 0x00
        shift = 0x00
        ddram = Array(repeating: 0x20, count: Self.ddramSize)
        cgram = Array(repeating: 0x00, count: Self.cgramSize)
    }
}

extension LCDHD44780 {
    mutating func executeClearDisplay() {
        ddram = Array(repeating: 0x20, count: Self.ddramSize)
        ac = 0b10000000
        cursor = 0x00
        shift = 0x00
        id = true
    }
    
    mutating func executeCursorHome() {
        ac = 0b10000000
        cursor = 0x00
        shift = 0x00
    }
    
    mutating func executeEntryModeSet(directionIncrement: Bool, shift: Bool) {
        id = directionIncrement
        s = shift
    }
    
    mutating func executeDisplaySet(displayOn: Bool, cursorOn: Bool, blinkOn: Bool) {
        d = displayOn
        c = cursorOn
        b = blinkOn
    }
    
    mutating func executeCursorMove(displayShift: Bool, directionRight: Bool) {
        if displayShift {
            shift = directionRight ? shift &- 1 : shift &+ 1
        } else {
            cursor = directionRight ? cursor &- 1 : cursor &+ 1
        }
    }
    
    mutating func executeFunctionSet(dataLength8: Bool, lineCountTwo: Bool, font5x10: Bool) {
        dl = dataLength8
        n = lineCountTwo
        f = font5x10
    }
    
    mutating func executeCGRAMAddressSet(address: UInt8) {
        ac = (0b01111111 & address) | (0b01000000 | address)
    }
    
    mutating func executeDDRAMAddressSet(address: UInt8) {
        ac = 0b1000000 | address
    }
    
    func executeReadBusyFlagAndCounter() -> UInt8 {
        return (busy ? 0b10000000 : 0b00000000) | (ac & 0b01111111)
    }
    
    mutating func executeWriteRAM(data: UInt8) {
        if ac & 0b10000000 == 0 {
            cgram[Int(ac & 0b00111111)] = data
        } else {
            ddram[Int(ac & 0b01111111)] = data
        }
    }
    
    func executeReadRAM() -> UInt8 {
        if ac & 0b10000000 == 0 {
            return cgram[Int(ac & 0b00111111)]
        } else {
            return ddram[Int(ac & 0b01111111)]
        }
    }
    
    mutating func execute(rs: Bool, rw: Bool, data: inout UInt8) {
        switch (rs, rw) {
        case (false, false):
            if data & 0b00000001 != 0 {
                executeClearDisplay()
            }
            else if data & 0b00000010 != 0 {
                executeCursorHome()
            }
            else if data & 0b00000100 != 0 {
                let directionIncrement = data & 0b00000010 != 0
                let shift = data & 0b00000001 != 0
                executeEntryModeSet(directionIncrement: directionIncrement, shift: shift)
            }
            else if data & 0b00001000 != 0 {
                let displayOn = data & 0b00000100 != 0
                let cursorOn = data & 0b00000010 != 0
                let blinkOn = data & 0b00000001 != 0
                executeDisplaySet(displayOn: displayOn, cursorOn: cursorOn, blinkOn: blinkOn)
            }
            else if data & 0b00010000 != 0 {
                let displayShift = 0b00001000 != 0
                let directionRight = 0b00000100 != 0
                executeCursorMove(displayShift: displayShift, directionRight: directionRight)
            }
            else if data & 0b00100000 != 0 {
                let dataLength8 = 0b00010000 != 0
                let lineCountTwo = 0b00001000 != 0
                let font5x10 = 0b00000100 != 0
                executeFunctionSet(dataLength8: dataLength8, lineCountTwo: lineCountTwo, font5x10: font5x10)
            }
            else if data & 0b01000000 != 0 {
                executeCGRAMAddressSet(address: data)
            }
            else {
                executeDDRAMAddressSet(address: data)
            }
        case (false, true):
            data = executeReadBusyFlagAndCounter()
        case (true, false):
            executeWriteRAM(data: data)
        case (true, true):
            data = executeReadRAM()
        }
    }
}
