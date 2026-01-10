//
//  LCDHD44780_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/10/26.
//

import Testing
@testable import SilkLCD

@Suite("HD44780 LCD Base Tests")
struct LCDHD44780Tests {
    @Test func initializer() {
        let lcd = LCDHD44780()
        #expect(lcd == LCDHD44780(
            ir: 0x00,
            dr: 0x00,
            ac: 0x00,
            id: true,
            s: false,
            d: false,
            c: false,
            b: false,
            sc: false,
            rl: false,
            dl: true,
            n: false,
            f: false,
            busy: false,
            cursor: 0x00,
            shift: 0x00,
            ddram: Array(repeating: 0x20, count: 80),
            cgram: Array(repeating: 0x00, count: 64)
        ))
    }
    
    @Test func execute() {
        var lcd = LCDHD44780()
        var data = UInt8(0)
        
        // Set 8-bit mode; 2-line display; 5x8 font
        data = UInt8(0b00111000)
        lcd = LCDHD44780()
        lcd.execute(rs: false, rw: false, data: &data)
        #expect(lcd == LCDHD44780(dl: true, n: true, f: false))
        
        // Display on; cursor on; blink off
        data = UInt8(0b00001110)
        lcd = LCDHD44780()
        lcd.execute(rs: false, rw: false, data: &data)
        #expect(lcd == LCDHD44780(d: true, c: true, b: false))
        
        // Increment and shift cursor; don't shift display
        data = UInt8(0b00000110)
        lcd = LCDHD44780()
        lcd.execute(rs: false, rw: false, data: &data)
        #expect(lcd == LCDHD44780(id: true, s: false))
        
        // Set DDRAM address then write
        // TODO: Test wrap-around of address
        let ddramAddress = UInt8(0b00101010)
        data = UInt8(0b10000000) | ddramAddress
        lcd = LCDHD44780()
        lcd.execute(rs: false, rw: false, data: &data)
        #expect(lcd == LCDHD44780(ac: UInt8(0b10000000) | ddramAddress))
        let character = UInt8(0b11010101)
        data = character
        let expectedAC = UInt8(0b10000000) | (ddramAddress &+ 1)
        let expectedDDRAM = { var ddram = lcd.ddram; ddram[Int(ddramAddress)] = character; return ddram }()
        lcd.execute(rs: true, rw: false, data: &data)
        #expect(lcd == LCDHD44780(ac: expectedAC, ddram: expectedDDRAM))
        
        // TODO: Test display shift, cursor off, 4-bit mode, decrement mode, other configurations
    }
}
