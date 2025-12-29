//
//  CPU6502+ShiftInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/29/25.
//

import Testing
@testable import SilkCPU

// MARK: - Shift Instruction Tests

@Suite("6502 CPU Shift Instruction Tests")
class CPU6502ShiftInstructionTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeASL() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let expectedResult = registerOperand << 1
        let expectedStatus = registerOperand > 0x7F ? CPU6502.srCMask : 0x00
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeASL()
        #expect(cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeASLZeropage() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(zeropage: 0x13)
        let expectedResult = memoryOperand << 1
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeASL(zeropage: 0x13)
        #expect(cpu.load(zeropage: 0x13) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeASLZeropageX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(zeropageX: 0x13)
        let expectedResult = memoryOperand << 1
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeASL(zeropageX: 0x13)
        #expect(cpu.load(zeropageX: 0x13) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeASLAbsolute() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(absolute: 0xBEEF)
        let expectedResult = memoryOperand << 1
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeASL(absolute: 0xBEEF)
        #expect(cpu.load(absolute: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeASLAbsoluteX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(absoluteX: 0xBEEF)
        let expectedResult = memoryOperand << 1
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeASL(absoluteX: 0xBEEF)
        #expect(cpu.load(absoluteX: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeLSR() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let expectedResult = registerOperand >> 1
        let expectedStatus = registerOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeLSR()
        #expect(cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLSRZeropage() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(zeropage: 0x13)
        let expectedResult = memoryOperand >> 1
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeLSR(zeropage: 0x13)
        #expect(cpu.load(zeropage: 0x13) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeLSRZeropageX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(zeropageX: 0x13)
        let expectedResult = memoryOperand >> 1
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeLSR(zeropageX: 0x13)
        #expect(cpu.load(zeropageX: 0x13) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeLSRAbsolute() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(absolute: 0xBEEF)
        let expectedResult = memoryOperand >> 1
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeLSR(absolute: 0xBEEF)
        #expect(cpu.load(absolute: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeLSRAbsoluteX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(absoluteX: 0xBEEF)
        let expectedResult = memoryOperand >> 1
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeLSR(absoluteX: 0xBEEF)
        #expect(cpu.load(absoluteX: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeROL() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        let expectedResult = registerOperand << 1 & (carryOperand ? 0x01 : 0x00)
        let expectedStatus = registerOperand > 0x7F ? CPU6502.srCMask : 0x00
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeROL()
        #expect(cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeROLZeropage() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(zeropage: 0x13)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand << 1 & (carryOperand ? 0x01 : 0x00)
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeROL(zeropage: 0x13)
        #expect(cpu.load(zeropage: 0x13) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeROLZeropageX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(zeropageX: 0x13)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand << 1 & (carryOperand ? 0x01 : 0x00)
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeROL(zeropageX: 0x13)
        #expect(cpu.load(zeropageX: 0x13) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeROLAbsolute() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(absolute: 0xBEEF)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand << 1 & (carryOperand ? 0x01 : 0x00)
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeROL(absolute: 0xBEEF)
        #expect(cpu.load(absolute: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeROLAbsoluteX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(absoluteX: 0xBEEF)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand << 1 & (carryOperand ? 0x01 : 0x00)
        let expectedStatus = memoryOperand > 0x7F ? CPU6502.srCMask : 0x00
        cpu.executeROL(absoluteX: 0xBEEF)
        #expect(cpu.load(absoluteX: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeROR() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        let expectedResult = registerOperand >> 1 & (carryOperand ? 0x80 : 0x00)
        let expectedStatus = registerOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeROR()
        #expect(cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeRORZeropage() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(zeropage: 0x13)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand >> 1 & (carryOperand ? 0x80 : 0x00)
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeROR(zeropage: 0x13)
        #expect(cpu.load(zeropage: 0x13) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeRORZeropageX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(zeropageX: 0x13)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand >> 1 & (carryOperand ? 0x80 : 0x00)
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeROR(zeropageX: 0x13)
        #expect(cpu.load(zeropageX: 0x13) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
    
    @Test func executeRORAbsolute() {
        var cpu = CPU6502()
        let memoryOperand = cpu.load(absolute: 0xBEEF)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand >> 1 & (carryOperand ? 0x80 : 0x00)
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeROR(absolute: 0xBEEF)
        #expect(cpu.load(absolute: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(sr: expectedStatus))
    }
    
    @Test func executeRORAbsoluteX() {
        var cpu = CPU6502(xr: 0x3B)
        let memoryOperand = cpu.load(absoluteX: 0xBEEF)
        let carryOperand = Bool.random()
        let expectedResult = memoryOperand >> 1 & (carryOperand ? 0x80 : 0x00)
        let expectedStatus = memoryOperand & 0x01 != 0 ? CPU6502.srCMask : 0x00
        cpu.executeROR(absoluteX: 0xBEEF)
        #expect(cpu.load(absoluteX: 0xBEEF) == expectedResult)
        #expect(cpu == CPU6502(xr: 0x3B, sr: expectedStatus))
    }
}
