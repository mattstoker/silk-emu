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
    
    func expectedStatus(_ result: UInt8) -> UInt8 {
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return status
    }
    
    @Test func executePLA() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        let expectedResult = s.cpu.load(stackpage: 0xEA &+ 1)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executePLA()
        #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus, sp: 0xEA &+ 1))
    }
    
    @Test func executePLP() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        let expectedResult = s.cpu.load(stackpage: 0xEA &+ 1)
        s.cpu.executePLP()
        #expect(s.cpu == CPU6502(sr: expectedResult, sp: 0xEA &+ 1))
    }
    
    @Test func executePLX() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        let expectedResult = s.cpu.load(stackpage: 0xEA &+ 1)
        let expectedStatus = expectedStatus(expectedResult)
         s.cpu.executePLX()
        #expect(s.cpu == CPU6502(xr: expectedResult, sr: expectedStatus, sp: 0xEA &+ 1))
    }
    
    @Test func executePLY() {
        let s = System(cpu: CPU6502(sp: 0xEA))
        let expectedResult = s.cpu.load(stackpage: 0xEA &+ 1)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executePLY()
        #expect(s.cpu == CPU6502(yr: expectedResult, sr: expectedStatus, sp: 0xEA &+ 1))
    }
}
