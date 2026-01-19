//
//  ROMAT28C64B_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/18/26.
//

import Testing
@testable import SilkROM

@Suite("AT28C64B ROM Tests")
struct ROMAT28C64BTests {
    @Test func initializer() {
        let rom = ROMAT28C64B()
        #expect(rom == ROMAT28C64B())
    }
    
    @Test func program() {
        var rom = ROMAT28C64B()
        rom.program(data: [1,2,3,4,5], startingAt: 0x300)
        #expect(rom.memory.count == ROMAT28C64B.size)
        #expect(rom.memory[0x0000...0x02FF].allSatisfy { $0 == 0 })
        #expect(rom.memory[0x0300...0x0304] == [1,2,3,4,5])
        #expect(rom.memory[0x0305...].allSatisfy { $0 == 0 })
    }
    
    @Test func load() {
        var rom = ROMAT28C64B()
        rom.program(data: [1,2,3,4,5], startingAt: 0x300)
        #expect(rom.load(0x0000) == 0)
        #expect(rom.load(0x0300) == 1)
        #expect(rom.load(0x0304) == 5)
        #expect(rom.load(0x0305) == 0)
        #expect(rom.load(0x1FFF) == 0)
        
        #expect(rom.load(0x2000) == rom.load(0x0000))
        #expect(rom.load(0x2300) == rom.load(0x0300))
        #expect(rom.load(0x2304) == rom.load(0x0304))
        #expect(rom.load(0x4304) == rom.load(0x0304))
    }
}
