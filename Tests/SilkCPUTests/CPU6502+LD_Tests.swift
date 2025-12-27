//
//  CPU6502+LD_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

@Suite("6502 CPU Load Instruction Tests")
class CPU6502LDTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeLDAImmediate() {
        var cpu = CPU6502()
        cpu.executeLDA(immediate: 0xEA)
        #expect(cpu == CPU6502(ac: 0xEA))
    }
    
    @Test func executeLDAZeroPage() {
        var cpu = CPU6502()
        cpu.executeLDA(zeropage: 0xAB)
        #expect(cpu == CPU6502(ac: CPU6502.load(UInt16(high: 0x00, low: 0xAB))))
    }
    
    @Test func executeLDAZeroPageX() {
        var cpu = CPU6502(xr: 0x23)
        cpu.executeLDA(zeropageX: 0xAB)
        #expect(cpu == CPU6502(ac: CPU6502.load(UInt16(high: 0x00, low: 0xAB + 0x23)), xr: 0x23))
    }
    
    @Test func executeLDAAbsolute() {
        var cpu = CPU6502()
        cpu.executeLDA(absolute: 0xABCD)
        #expect(cpu == CPU6502(ac: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))))
    }
    
    @Test func executeLDAAbsoluteX() {
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(absoluteX: 0xABCD)
        #expect(cpu == CPU6502(ac: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63)), xr: 0x63))
    }
    
    @Test func executeLDAAbsoluteY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(absoluteY: 0xABCD)
        #expect(cpu == CPU6502(ac: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x74)), yr: 0x74))
    }
    
    @Test func executeLDAIndirectX() {
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(indirectX: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63 + 1)),
            low: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63))
        )
        #expect(cpu == CPU6502(ac: CPU6502.load(address), xr: 0x63))
    }
    
    @Test func executeLDAIndirectY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(indirectY: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB, low: 0xCD + 1)),
            low: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))
        ) &+ 0x74
        #expect(cpu == CPU6502(ac: CPU6502.load(address), yr: 0x74))
    }
}
