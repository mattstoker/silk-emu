//
//  CPU6502+TransferInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

// MARK: - Load Instruction Tests

@Suite("6502 CPU Load Instruction Tests")
class CPU6502LDTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
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
        #expect(cpu == CPU6502(ac: memory(CPU6502.zeropage, 0xAB)))
    }
    
    @Test func executeLDAZeroPageX() {
        var cpu = CPU6502(xr: 0x23)
        cpu.executeLDA(zeropageX: 0xAB)
        #expect(cpu == CPU6502(ac: memory(CPU6502.zeropage, 0xAB + 0x23), xr: 0x23))
    }
    
    @Test func executeLDAAbsolute() {
        var cpu = CPU6502()
        cpu.executeLDA(absolute: 0xABCD)
        #expect(cpu == CPU6502(ac: memory(0xABCD)))
    }
    
    @Test func executeLDAAbsoluteX() {
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(absoluteX: 0xABCD)
        #expect(cpu == CPU6502(ac: memory(0xABCD &+ 0x63), xr: 0x63))
    }
    
    @Test func executeLDAAbsoluteY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(absoluteY: 0xABCD)
        #expect(cpu == CPU6502(ac: memory(0xABCD &+ 0x74), yr: 0x74))
    }
    
    @Test func executeLDAIndirectX() {
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(indirectX: 0xABCD)
        let address = UInt16(
            high: memory(0xABCD &+ 0x63 + 1),
            low: memory(0xABCD &+ 0x63)
        )
        #expect(cpu == CPU6502(ac: memory(address), xr: 0x63))
    }
    
    @Test func executeLDAIndirectY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(indirectY: 0xABCD)
        let address = UInt16(
            high: memory(0xABCD + 1),
            low: memory(0xABCD)
        ) &+ 0x74
        #expect(cpu == CPU6502(ac: memory(address), yr: 0x74))
    }
    
    @Test func executeLDAZeropageIndirect() {
        var cpu = CPU6502()
        cpu.executeLDA(zeropageIndirect: 0xCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: CPU6502.zeropage, low: 0xCD + 1)),
            low: CPU6502.load(UInt16(high: CPU6502.zeropage, low: 0xCD))
        )
        #expect(cpu == CPU6502(ac: memory(address)))
    }
    
    @Test func executeLDXImmediate() {
        var cpu = CPU6502()
        cpu.executeLDX(immediate: 0xEA)
        #expect(cpu == CPU6502(xr: 0xEA))
    }
    
    @Test func executeLDXZeroPage() {
        var cpu = CPU6502()
        cpu.executeLDX(zeropage: 0xAB)
        #expect(cpu == CPU6502(xr: memory(CPU6502.zeropage, 0xAB)))
    }
    
    @Test func executeLDXZeroPageY() {
        var cpu = CPU6502(yr: 0x23)
        cpu.executeLDX(zeropageY: 0xAB)
        #expect(cpu == CPU6502(xr: memory(CPU6502.zeropage, 0xAB + 0x23), yr: 0x23))
    }
    
    @Test func executeLDXAbsolute() {
        var cpu = CPU6502()
        cpu.executeLDX(absolute: 0xABCD)
        #expect(cpu == CPU6502(xr: memory(0xABCD)))
    }
    
    @Test func executeLDXAbsoluteY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDX(absoluteY: 0xABCD)
        #expect(cpu == CPU6502(xr: memory(0xABCD &+ 0x74), yr: 0x74))
    }
    
    @Test func executeLDYImmediate() {
        var cpu = CPU6502()
        cpu.executeLDY(immediate: 0xEA)
        #expect(cpu == CPU6502(yr: 0xEA))
    }
    
    @Test func executeLDYZeroPage() {
        var cpu = CPU6502()
        cpu.executeLDY(zeropage: 0xAB)
        #expect(cpu == CPU6502(yr: memory(CPU6502.zeropage, 0xAB)))
    }
    
    @Test func executeLDYZeroPageX() {
        var cpu = CPU6502(xr: 0x23)
        cpu.executeLDY(zeropageX: 0xAB)
        #expect(cpu == CPU6502(xr: 0x23, yr: CPU6502.load(UInt16(high: CPU6502.zeropage, low: 0xAB + 0x23))))
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

// MARK: - Store Instruction Tests

@Suite("6502 CPU Store Instruction Tests")
class CPU6502STTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeSTAZeroPage() {
        var cpu = CPU6502(ac: 0xAA)
        cpu.executeSTA(zeropage: 0xAB)
        #expect(memory(CPU6502.zeropage, 0xAB) == 0xAA)
    }
    
    @Test func executeSTAZeroPageX() {
        var cpu = CPU6502(ac: 0xBB, xr: 0x23)
        cpu.executeSTA(zeropageX: 0xAB)
        #expect(memory(CPU6502.zeropage, 0xAB &+ 0x23) == 0xBB)
    }
    
    @Test func executeSTAAbsolute() {
        var cpu = CPU6502(ac: 0xCC)
        cpu.executeSTA(absolute: 0xABCD)
        #expect(memory(0xABCD) == 0xCC)
    }
    
    @Test func executeSTAAbsoluteX() {
        var cpu = CPU6502(ac: 0xDD, xr: 0x63)
        cpu.executeSTA(absoluteX: 0xABCD)
        #expect(memory(0xABCD &+ 0x63) == 0xDD)
    }
    
    @Test func executeSTAAbsoluteY() {
        var cpu = CPU6502(ac: 0xEE, yr: 0x74)
        cpu.executeSTA(absoluteY: 0xABCD)
        #expect(memory(0xABCD &+ 0x74) == 0xEE)
    }
    
    @Test func executeSTAIndirectX() {
        var cpu = CPU6502(ac: 0x55, xr: 0x63)
        cpu.executeSTA(indirectX: 0xABCD)
        let address = UInt16(
            high: memory(0xAB + 1, 0xCD &+ 0x63 + 1),
            low: memory(0xAB + 1, 0xCD &+ 0x63)
        )
        #expect(memory(address) == 0x55)
    }
    
    @Test func executeSTAIndirectY() {
        var cpu = CPU6502(ac: 0x66, yr: 0x74)
        cpu.executeSTA(indirectY: 0xABCD)
        let address = UInt16(
            high: memory(0xAB, 0xCD + 1),
            low: memory(0xAB, 0xCD)
        ) &+ 0x74
        #expect(memory(address) == 0x66)
    }
    
    @Test func executeSTAZeropageIndirect() {
        var cpu = CPU6502(ac: 0x55)
        cpu.executeSTA(indirectX: 0xCD)
        let address = UInt16(
            high: memory(CPU6502.zeropage, 0xCD + 1),
            low: memory(CPU6502.zeropage, 0xCD)
        )
        #expect(memory(address) == 0x55)
    }
    
    @Test func executeSTXZeroPage() {
        var cpu = CPU6502(xr: 0xAA)
        cpu.executeSTX(zeropage: 0xAB)
        #expect(memory(CPU6502.zeropage, 0xAB) == 0xAA)
    }
    
    @Test func executeSTXZeroPageY() {
        var cpu = CPU6502(xr: 0xBB, yr: 0x23)
        cpu.executeSTX(zeropageY: 0xAB)
        #expect(memory(CPU6502.zeropage, 0xAB &+ 0x23) == 0xBB)
    }
    
    @Test func executeSTXAbsolute() {
        var cpu = CPU6502(xr: 0xCC)
        cpu.executeSTX(absolute: 0xABCD)
        #expect(memory(0xABCD) == 0xCC)
    }
    
    @Test func executeSTYZeroPage() {
        var cpu = CPU6502(yr: 0xAA)
        cpu.executeSTY(zeropage: 0xAB)
        #expect(memory(CPU6502.zeropage, 0xAB) == 0xAA)
    }
    
    @Test func executeSTYZeroPageX() {
        var cpu = CPU6502(xr: 0x23, yr: 0xBB)
        cpu.executeSTY(zeropageX: 0xAB)
        #expect(memory(CPU6502.zeropage, 0xAB &+ 0x23) == 0xBB)
    }
    
    @Test func executeSTYAbsolute() {
        var cpu = CPU6502(yr: 0xCC)
        cpu.executeSTY(absolute: 0xABCD)
        #expect(memory(0xABCD) == 0xCC)
    }
}

// MARK: - Register Transfer Instruction Tests

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
