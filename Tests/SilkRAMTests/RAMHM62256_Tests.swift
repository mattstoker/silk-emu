//
//  RAMHM62256_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/18/26.
//

import Testing
@testable import SilkRAM

@Suite("HM62256 RAM Tests")
struct RAMHM62256Tests {
    @Test func initializer() {
        let ram = RAMHM62256()
        #expect(ram == RAMHM62256())
    }
    
    @Test func loadStore() {
        var ram = RAMHM62256()
        
        #expect(ram.load(0x0000) == 0)
        #expect(ram.load(0x0300) == 0)
        #expect(ram.load(0x0301) == 0)
        #expect(ram.load(0x0302) == 0)
        #expect(ram.load(0x0303) == 0)
        #expect(ram.load(0x0304) == 0)
        #expect(ram.load(0x0305) == 0)
        #expect(ram.load(0x3FFF) == 0)
        
        ram.store(0x0300, 1)
        ram.store(0x0301, 2)
        ram.store(0x0302, 3)
        ram.store(0x0303, 4)
        ram.store(0x0304, 5)
        
        #expect(ram.load(0x0000) == 0)
        #expect(ram.load(0x0300) == 1)
        #expect(ram.load(0x0301) == 2)
        #expect(ram.load(0x0302) == 3)
        #expect(ram.load(0x0303) == 4)
        #expect(ram.load(0x0304) == 5)
        #expect(ram.load(0x0305) == 0)
        #expect(ram.load(0x3FFF) == 0)
        
        #expect(ram.load(0x2000) == ram.load(0x0000))
        #expect(ram.load(0x4300) == ram.load(0x0300))
        #expect(ram.load(0x4304) == ram.load(0x0304))
        #expect(ram.load(0x8304) == ram.load(0x0304))
    }
}
