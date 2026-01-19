//
//  LCDHD44780.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/10/26.
//
//  Official documentation for the HD44780 can be found at:
//  https://cdn-shop.adafruit.com/datasheets/HD44780.pdf
//


// MARK: LCD State & Equality

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
    
    public init(
        ir: UInt8 = 0x00,
        dr: UInt8 = 0x00,
        ac: UInt8 = 0x00,
        id: Bool = true,
        s: Bool = false,
        d: Bool = false,
        c: Bool = false,
        b: Bool = false,
        sc: Bool = false,
        rl: Bool = false,
        dl: Bool = true,
        n: Bool = false,
        f: Bool = false,
        busy: Bool = false,
        cursor: UInt8 = 0x00,
        shift: UInt8 = 0x00,
        ddram: [UInt8] = Array(repeating: 0x20, count: Self.ddramSize),
        cgram: [UInt8] = Array(repeating: 0x00, count: Self.cgramSize)
    ) {
        self.ir = ir
        self.dr = dr
        self.ac = ac
        self.id = id
        self.s = s
        self.d = d
        self.c = c
        self.b = b
        self.sc = sc
        self.rl = rl
        self.dl = dl
        self.n = n
        self.f = f
        self.busy = busy
        self.cursor = cursor
        self.shift = shift
        self.ddram = Array(repeating: 0x20, count: Self.ddramSize)
        for i in 0..<min(self.ddram.count, ddram.count) {
            self.ddram[i] = ddram[i]
        }
        self.cgram = Array(repeating: 0x00, count: Self.cgramSize)
        for i in 0..<min(self.cgram.count, ddram.count) {
            self.cgram[i] = cgram[i]
        }
    }
}

// MARK: - Instruction Execution

extension LCDHD44780 {
    public mutating func execute(rs: Bool, rw: Bool, data: inout UInt8) {
        switch (rs, rw) {
        case (false, false):
            if data & 0b11111111 == 0b00000001 {
                executeClearDisplay()
            }
            else if data & 0b11111110 == 0b00000010 {
                executeCursorHome()
            }
            else if data & 0b11111100 == 0b00000100 {
                let directionIncrement = data & 0b00000010 != 0
                let shift = data & 0b00000001 != 0
                executeEntryModeSet(directionIncrement: directionIncrement, shift: shift)
            }
            else if data & 0b11111000 == 0b00001000 {
                let displayOn = data & 0b00000100 != 0
                let cursorOn = data & 0b00000010 != 0
                let blinkOn = data & 0b00000001 != 0
                executeDisplaySet(displayOn: displayOn, cursorOn: cursorOn, blinkOn: blinkOn)
            }
            else if data & 0b11110000 == 0b00010000 {
                let displayShift = data & 0b00001000 != 0
                let directionRight = data & 0b00000100 != 0
                executeCursorMove(displayShift: displayShift, directionRight: directionRight)
            }
            else if data & 0b11100000 == 0b00100000 {
                let dataLength8 = data & 0b00010000 != 0
                let lineCountTwo = data & 0b00001000 != 0
                let font5x10 = data & 0b00000100 != 0
                executeFunctionSet(dataLength8: dataLength8, lineCountTwo: lineCountTwo, font5x10: font5x10)
            }
            else if data & 0b11000000 == 0b01000000 {
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
        ac = 0b10000000 | address
    }
    
    func executeReadBusyFlagAndCounter() -> UInt8 {
        return (busy ? 0b10000000 : 0b00000000) | (ac & 0b01111111)
    }
    
    mutating func executeWriteRAM(data: UInt8) {
        if ac & 0b10000000 == 0 {
            let cgramAddress = Int(ac & 0b00111111) % LCDHD44780.cgramSize
            cgram[cgramAddress] = data
            ac = (id ? (ac &+ 1) : (ac &- 1)) & 0b01111111 | 0b01000000
        } else {
            let ddramAddress = Int(ac & 0b01111111) % LCDHD44780.ddramSize
            ddram[ddramAddress] = data
            ac = (id ? (ac &+ 1) : (ac &- 1)) | 0b10000000
        }
    }
    
    func executeReadRAM() -> UInt8 {
        if ac & 0b10000000 == 0 {
            let cgramAddress = Int(ac & 0b00111111) % LCDHD44780.cgramSize
            return cgram[cgramAddress]
        } else {
            let ddramAddress = Int(ac & 0b01111111) % LCDHD44780.ddramSize
            return ddram[ddramAddress]
        }
    }
}
