//
//  CPU6502+ST_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

@Suite("6502 CPU Store Instruction Tests")
class CPU6502STTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeSTAZeroPage() {
        var cpu = CPU6502(ac: 0xAA)
        cpu.executeSTA(zeropage: 0xAB)
        #expect(memory[0x00AB] == 0xAA)
    }
    
    @Test func executeSTAZeroPageX() {
        var cpu = CPU6502(ac: 0xBB, xr: 0x23)
        cpu.executeSTA(zeropageX: 0xAB)
        #expect(memory[0x00AB &+ 0x23] == 0xBB)
    }
    
    @Test func executeSTAAbsolute() {
        var cpu = CPU6502(ac: 0xCC)
        cpu.executeSTA(absolute: 0xABCD)
        #expect(memory[0xABCD] == 0xCC)
    }
    
    @Test func executeSTAAbsoluteX() {
        var cpu = CPU6502(ac: 0xDD, xr: 0x63)
        cpu.executeSTA(absoluteX: 0xABCD)
        #expect(memory[0xABCD &+ 0x63] == 0xDD)
    }
    
    @Test func executeSTAAbsoluteY() {
        var cpu = CPU6502(ac: 0xEE, yr: 0x74)
        cpu.executeSTA(absoluteY: 0xABCD)
        #expect(memory[0xABCD &+ 0x74] == 0xEE)
    }
    
    @Test func executeSTAIndirectX() {
        var cpu = CPU6502(ac: 0x55, xr: 0x63)
        cpu.executeSTA(indirectX: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63 + 1)),
            low: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63))
        )
        #expect(memory[Int(address)] == 0x55)
    }
    
    @Test func executeSTAIndirectY() {
        var cpu = CPU6502(ac: 0x66, yr: 0x74)
        cpu.executeSTA(indirectY: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB, low: 0xCD + 1)),
            low: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))
        ) &+ 0x74
        #expect(memory[Int(address)] == 0x66)
    }
}
