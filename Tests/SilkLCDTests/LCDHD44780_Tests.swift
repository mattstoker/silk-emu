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
        #expect(lcd.ir == 0x00)
        #expect(lcd.dr == 0x00)
        #expect(lcd.ac == 0x00)
        
        #expect(lcd.id == true)
        #expect(lcd.s == false)
        #expect(lcd.d == false)
        #expect(lcd.c == false)
        #expect(lcd.b == false)
        #expect(lcd.sc == false)
        #expect(lcd.rl == false)
        #expect(lcd.dl == true)
        #expect(lcd.n == false)
        #expect(lcd.f == false)
        #expect(lcd.busy == false)
        
        #expect(lcd.cursor == 0x00)
        #expect(lcd.shift == 0x00)
        
        #expect(lcd.ddram == Array(repeating: 0x20, count: 80))
        #expect(lcd.cgram == Array(repeating: 0x00, count: 64))
    }
}
