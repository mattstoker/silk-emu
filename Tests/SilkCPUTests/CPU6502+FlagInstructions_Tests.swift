//
//  CPU6502+FlagInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

import Testing
@testable import SilkCPU

// MARK: - Flag Instruction Tests

@Suite("6502 CPU Flag Instruction Tests")
struct CPU6502FlagInstructionTests {
    @Test func executeCLC() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srCMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeCLC()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeCLD() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srDMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeCLD()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }
 
    @Test func executeCLI() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srIMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeCLI()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeCLV() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srVMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeCLV()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeSEC() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status | CPU6502.srCMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeSEC()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeSED() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status | CPU6502.srDMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeSED()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeSEI() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status | CPU6502.srIMask
        let s = System(cpu: CPU6502(sr: status))
        s.cpu.executeSEI()
        #expect(s.cpu == CPU6502(sr: expectedStatus))
    }
}
