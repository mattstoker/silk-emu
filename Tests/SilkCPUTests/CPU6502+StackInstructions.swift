//
//  CPU6502+StackInstructions.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

// MARK: - Stack Instruction Tests

@Suite("6502 CPU Stack Instruction Tests")
class CPU6502StackInstructionTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executePHA() {
        var cpu = CPU6502(ac: 0xAA, sp: 0xEA)
        cpu.executePHA()
        #expect(cpu == CPU6502(ac: 0xAA, sp: 0xEA &- 1))
        #expect(memory(CPU6502.stackpage, 0xEA) == 0xAA)
    }
    
    @Test func executePHP() {
        var cpu = CPU6502(sr: 0xAA, sp: 0xEA)
        cpu.executePHP()
        #expect(cpu == CPU6502(sr: 0xAA, sp: 0xEA &- 1))
        #expect(memory(CPU6502.stackpage, 0xEA) == 0xAA | CPU6502.srBMask | CPU6502.srXMask)
    }
    
    @Test func executePHX() {
        var cpu = CPU6502(xr: 0xAA, sp: 0xEA)
        cpu.executePHX()
        #expect(cpu == CPU6502(xr: 0xAA, sp: 0xEA &- 1))
        #expect(memory(CPU6502.stackpage, 0xEA) == 0xAA)
    }
    
    @Test func executePHY() {
        var cpu = CPU6502(yr: 0xAA, sp: 0xEA)
        cpu.executePHY()
        #expect(cpu == CPU6502(yr: 0xAA, sp: 0xEA &- 1))
        #expect(memory(CPU6502.stackpage, 0xEA) == 0xAA)
    }
    
    @Test func executePLA() {
        var cpu = CPU6502(sp: 0xEA)
        cpu.executePLA()
        #expect(cpu == CPU6502(ac: memory(CPU6502.stackpage, 0xEA), sp: 0xEA &+ 1))
    }
    
    @Test func executePLP() {
        var cpu = CPU6502(sp: 0xEA)
        cpu.executePLP()
        #expect(cpu == CPU6502(sr: memory(CPU6502.stackpage, 0xEA), sp: 0xEA &+ 1))
    }
    
    @Test func executePLX() {
        var cpu = CPU6502(sp: 0xEA)
        cpu.executePLX()
        #expect(cpu == CPU6502(xr: memory(CPU6502.stackpage, 0xEA), sp: 0xEA &+ 1))
    }
    
    @Test func executePLY() {
        var cpu = CPU6502(sp: 0xEA)
        cpu.executePLY()
        #expect(cpu == CPU6502(yr: memory(CPU6502.stackpage, 0xEA), sp: 0xEA &+ 1))
    }
}
