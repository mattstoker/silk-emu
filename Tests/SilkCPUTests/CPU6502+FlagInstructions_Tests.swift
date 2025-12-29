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
class CPU6502FlagInstructionTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeCLC() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srCMask
        var cpu = CPU6502(sr: status)
        cpu.executeCLC()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeCLD() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srDMask
        var cpu = CPU6502(sr: status)
        cpu.executeCLD()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
 
    @Test func executeCLI() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srIMask
        var cpu = CPU6502(sr: status)
        cpu.executeCLI()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeCLV() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status & ~CPU6502.srVMask
        var cpu = CPU6502(sr: status)
        cpu.executeCLV()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeSEC() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status | CPU6502.srCMask
        var cpu = CPU6502(sr: status)
        cpu.executeSEC()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeSED() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status | CPU6502.srDMask
        var cpu = CPU6502(sr: status)
        cpu.executeSED()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }

    @Test func executeSEI() {
        let status = UInt8.random(in: 0x00...0xFF)
        let expectedStatus = status | CPU6502.srIMask
        var cpu = CPU6502(sr: status)
        cpu.executeSEI()
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
}
