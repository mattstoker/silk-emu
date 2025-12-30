//
//  CPU6502+StackInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

// MARK: - Stack Instruction Tests

@Suite("6502 CPU Stack Instruction Tests")
struct CPU6502StackInstructionTests {
    @Test func executePHA() {
        let s = System(cpu: CPU6502(ac: 0xAA, sp: 0xEA))
        s.cpu.executePHA()
        #expect(s.cpu == CPU6502(ac: 0xAA, sp: 0xEA &- 1))
        #expect(s.cpu.load(stackpage: 0xEA) == 0xAA)
    }
    
    @Test func executePHP() {
        let s = System(cpu: CPU6502(sr: 0xAA, sp: 0xEA))
        s.cpu.executePHP()
        #expect(s.cpu == CPU6502(sr: 0xAA, sp: 0xEA &- 1))
        #expect(s.cpu.load(stackpage: 0xEA) == 0xAA | CPU6502.srBMask | CPU6502.srXMask)
    }
    
    @Test func executePHX() {
        let s = System(cpu: CPU6502(xr: 0xAA, sp: 0xEA))
        s.cpu.executePHX()
        #expect(s.cpu == CPU6502(xr: 0xAA, sp: 0xEA &- 1))
        #expect(s.cpu.load(stackpage: 0xEA) == 0xAA)
    }
    
    @Test func executePHY() {
        let s = System(cpu: CPU6502(yr: 0xAA, sp: 0xEA))
        s.cpu.executePHY()
        #expect(s.cpu == CPU6502(yr: 0xAA, sp: 0xEA &- 1))
        #expect(s.cpu.load(stackpage: 0xEA) == 0xAA)
    }
    
    @Test func executePLA() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        s.cpu.executePLA()
        #expect(s.cpu == CPU6502(ac: s.cpu.load(stackpage: 0xEA), sp: 0xEA &+ 1))
    }
    
    @Test func executePLP() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        s.cpu.executePLP()
        #expect(s.cpu == CPU6502(sr: s.cpu.load(stackpage: 0xEA), sp: 0xEA &+ 1))
    }
    
    @Test func executePLX() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        s.cpu.executePLX()
        #expect(s.cpu == CPU6502(xr: s.cpu.load(stackpage: 0xEA), sp: 0xEA &+ 1))
    }
    
    @Test func executePLY() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        s.cpu.executePLY()
        #expect(s.cpu == CPU6502(yr: s.cpu.load(stackpage: 0xEA), sp: 0xEA &+ 1))
    }
}
