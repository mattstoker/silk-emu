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
    
    @Test func executeLDXImmediate() {
        var cpu = CPU6502()
        cpu.executeLDX(immediate: 0xEA)
        #expect(cpu == CPU6502(xr: 0xEA))
    }
    
    @Test func executeLDXZeroPage() {
        var cpu = CPU6502()
        cpu.executeLDX(zeropage: 0xAB)
        #expect(cpu == CPU6502(xr: CPU6502.load(UInt16(high: 0x00, low: 0xAB))))
    }
    
    @Test func executeLDXZeroPageY() {
        var cpu = CPU6502(yr: 0x23)
        cpu.executeLDX(zeropageY: 0xAB)
        #expect(cpu == CPU6502(xr: CPU6502.load(UInt16(high: 0x00, low: 0xAB + 0x23)), yr: 0x23))
    }
    
    @Test func executeLDXAbsolute() {
        var cpu = CPU6502()
        cpu.executeLDX(absolute: 0xABCD)
        #expect(cpu == CPU6502(xr: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))))
    }
    
    @Test func executeLDXAbsoluteY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDX(absoluteY: 0xABCD)
        #expect(cpu == CPU6502(xr: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x74)), yr: 0x74))
    }
    
    @Test func executeLDYImmediate() {
        var cpu = CPU6502()
        cpu.executeLDY(immediate: 0xEA)
        #expect(cpu == CPU6502(yr: 0xEA))
    }
    
    @Test func executeLDYZeroPage() {
        var cpu = CPU6502()
        cpu.executeLDY(zeropage: 0xAB)
        #expect(cpu == CPU6502(yr: CPU6502.load(UInt16(high: 0x00, low: 0xAB))))
    }
    
    @Test func executeLDYZeroPageX() {
        var cpu = CPU6502(xr: 0x23)
        cpu.executeLDY(zeropageX: 0xAB)
        #expect(cpu == CPU6502(xr: 0x23, yr: CPU6502.load(UInt16(high: 0x00, low: 0xAB + 0x23))))
    }
    
    @Test func executeLDYAbsolute() {
        var cpu = CPU6502()
        cpu.executeLDY(absolute: 0xABCD)
        #expect(cpu == CPU6502(yr: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))))
    }
    
    @Test func executeLDYAbsoluteX() {
        var cpu = CPU6502(xr: 0x74)
        cpu.executeLDY(absoluteX: 0xABCD)
        #expect(cpu == CPU6502(xr: 0x74, yr: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x74))))
    }
}
