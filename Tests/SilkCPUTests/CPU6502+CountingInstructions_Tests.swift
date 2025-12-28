//
//  CPU6502+CountingInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

import Testing
@testable import SilkCPU

// MARK: - Counting Instruction Tests

@Suite("6502 CPU Counting Instruction Tests")
class CPU6502CountingInstructionTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeDECZeropage() {
        var cpu = CPU6502()
        let value = memory(CPU6502.zeropage, 0x13)
        cpu.executeDEC(zeropage: 0x13)
        #expect(memory(CPU6502.zeropage, 0x13) == value &- 1)
    }
    
    @Test func executeDECZeropageX() {
        var cpu = CPU6502(xr: 0x3B)
        let value = memory(CPU6502.zeropage, 0x13 &+ 0x3B)
        cpu.executeDEC(zeropageX: 0x13)
        #expect(memory(CPU6502.zeropage, 0x13 &+ 0x3B) == value &- 1)
    }
    
    @Test func executeDECAbsolute() {
        var cpu = CPU6502()
        let value = memory(0xBEEF)
        cpu.executeDEC(absolute: 0xBEEF)
        #expect(memory(0xBEEF) == value &- 1)
    }
    
    @Test func executeDECAbsoluteX() {
        var cpu = CPU6502(xr: 0x3B)
        let value = memory(0xBEEF &+ 0x3B)
        cpu.executeDEC(absoluteX: 0xBEEF)
        #expect(memory(0xBEEF &+ 0x3B) == value &- 1)
    }

    @Test func executeDEC() {
        var cpu = CPU6502(ac: 0x15)
        cpu.executeDEC()
        #expect(cpu == CPU6502(ac: 0x15 &- 1))
    }

    @Test func executeDEX() {
        var cpu = CPU6502(xr: 0x25)
        cpu.executeDEX()
        #expect(cpu == CPU6502(xr: 0x25 &- 1))
    }

    @Test func executeDEY() {
        var cpu = CPU6502(yr: 0x35)
        cpu.executeDEY()
        #expect(cpu == CPU6502(yr: 0x35 &- 1))
    }

    @Test func executeINCZeropage() {
        var cpu = CPU6502()
        let value = memory(CPU6502.zeropage, 0x13)
        cpu.executeINC(zeropage: 0x13)
        #expect(memory(CPU6502.zeropage, 0x13) == value &+ 1)
    }
    
    @Test func executeINCZeropageX() {
        var cpu = CPU6502(xr: 0x3B)
        let value = memory(CPU6502.zeropage, 0x13 &+ 0x3B)
        cpu.executeINC(zeropageX: 0x13)
        #expect(memory(CPU6502.zeropage, 0x13 &+ 0x3B) == value &+ 1)
    }
    
    @Test func executeINCAbsolute() {
        var cpu = CPU6502()
        let value = memory(0xBEEF)
        cpu.executeINC(absolute: 0xBEEF)
        #expect(memory(0xBEEF) == value &+ 1)
    }
    
    @Test func executeINCAbsoluteX() {
        var cpu = CPU6502(xr: 0x3B)
        let value = memory(0xBEEF &+ 0x3B)
        cpu.executeINC(absoluteX: 0xBEEF)
        #expect(memory(0xBEEF &+ 0x3B) == value &+ 1)
    }

    @Test func executeINC() {
        var cpu = CPU6502(ac: 0x15)
        cpu.executeINC()
        #expect(cpu == CPU6502(ac: 0x15 &+ 1))
    }

    @Test func executeINX() {
        var cpu = CPU6502(xr: 0x25)
        cpu.executeINX()
        #expect(cpu == CPU6502(xr: 0x25 &+ 1))
    }

    @Test func executeINY() {
        var cpu = CPU6502(yr: 0x35)
        cpu.executeINY()
        #expect(cpu == CPU6502(yr: 0x35 &+ 1))
    }
}
