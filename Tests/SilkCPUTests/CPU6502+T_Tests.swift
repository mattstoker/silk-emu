//
//  CPU6502+T_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

@Suite("6502 CPU Register Transfer Tests")
class CPU6502TTests {
    @Test func executeTAX() {
        var cpu = CPU6502(ac: 0xAA, xr: 0xBB)
        cpu.executeTAX()
        #expect(cpu == CPU6502(ac: 0xAA, xr: 0xAA))
    }
    
    @Test func executeTXA() {
        var cpu = CPU6502(ac: 0xBB, xr: 0xAA)
        cpu.executeTXA()
        #expect(cpu == CPU6502(ac: 0xAA, xr: 0xAA))
    }
    
    @Test func executeTAY() {
        var cpu = CPU6502(ac: 0xAA, yr: 0xBB)
        cpu.executeTAY()
        #expect(cpu == CPU6502(ac: 0xAA, yr: 0xAA))
    }
    
    @Test func executeTYA() {
        var cpu = CPU6502(ac: 0xBB, yr: 0xAA)
        cpu.executeTYA()
        #expect(cpu == CPU6502(ac: 0xAA, yr: 0xAA))
    }
    
    @Test func executeTSX() {
        var cpu = CPU6502(xr: 0xBB, sp: 0xAA)
        cpu.executeTSX()
        #expect(cpu == CPU6502(xr: 0xAA, sp: 0xAA))
    }
    
    @Test func executeTXS() {
        var cpu = CPU6502(xr: 0xAA, sp: 0xBB)
        cpu.executeTXS()
        #expect(cpu == CPU6502(xr: 0xAA, sp: 0xAA))
    }
}
