//
//  CPU6502+LogicalInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/27/25.
//

import Testing
@testable import SilkCPU

// MARK: - Logical Instruction Tests

@Suite("6502 CPU Logical Instruction Tests")
class CPU6502LogicalInstructionTests {
    @Test func executeANDImmediate() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let immediateOperand = UInt8.random(in: 0x00...0xFF)
        let expectedResult = registerOperand & immediateOperand
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeAND(immediate: immediateOperand)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeANDZeropage() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(zeropage: 0x3D)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(zeropage: 0x3D)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeANDZeropageX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x8E)
        let memoryOperand = cpu.load(zeropageX: 0x3D)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(zeropageX: 0x3D)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x8E))
    }
    
    @Test func executeANDAbsolute() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(absolute: 0x3D47)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(absolute: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeANDAbsoluteX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x2A)
        let memoryOperand = cpu.load(absoluteX: 0x3D47)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(absoluteX: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x2A))
    }
    
    @Test func executeANDAbsoluteY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, yr: 0x2A)
        let memoryOperand = cpu.load(absoluteY: 0x3D47)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(absoluteY: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, yr: 0x2A))
    }
    
    @Test func executeANDIndirectX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x2A)
        let memoryOperand = cpu.load(indirectX: 0x3D47)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(indirectX: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x2A))
    }
    
    @Test func executeANDIndirectY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, yr: 0x2A)
        let memoryOperand = cpu.load(indirectY: 0x3D47)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(indirectY: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, yr: 0x2A))
    }
    
    @Test func executeANDZeropageIndirect() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(zeropageIndirect: 0x47)
        let expectedResult = registerOperand & memoryOperand
        cpu.executeAND(zeropageIndirect: 0x47)
        #expect(cpu == CPU6502(ac: expectedResult))
    }

    @Test func executeEORImmediate() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let immediateOperand = UInt8.random(in: 0x00...0xFF)
        let expectedResult = registerOperand ^ immediateOperand
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeEOR(immediate: immediateOperand)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeEORZeropage() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(zeropage: 0x3D)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(zeropage: 0x3D)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeEORZeropageX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x8E)
        let memoryOperand = cpu.load(zeropageX: 0x3D)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(zeropageX: 0x3D)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x8E))
    }
    
    @Test func executeEORAbsolute() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(absolute: 0x3D47)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(absolute: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeEORAbsoluteX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x2A)
        let memoryOperand = cpu.load(absoluteX: 0x3D47)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(absoluteX: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x2A))
    }
    
    @Test func executeEORAbsoluteY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, yr: 0x2A)
        let memoryOperand = cpu.load(absoluteY: 0x3D47)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(absoluteY: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, yr: 0x2A))
    }
    
    @Test func executeEORIndirectX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x2A)
        let memoryOperand = cpu.load(indirectX: 0x3D47)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(indirectX: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x2A))
    }
    
    @Test func executeEORIndirectY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, yr: 0x2A)
        let memoryOperand = cpu.load(indirectY: 0x3D47)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(indirectY: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, yr: 0x2A))
    }
    
    @Test func executeEORZeropageIndirect() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(zeropageIndirect: 0x47)
        let expectedResult = registerOperand ^ memoryOperand
        cpu.executeEOR(zeropageIndirect: 0x47)
        #expect(cpu == CPU6502(ac: expectedResult))
    }

    @Test func executeORAImmediate() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let immediateOperand = UInt8.random(in: 0x00...0xFF)
        let expectedResult = registerOperand | immediateOperand
        var cpu = CPU6502(ac: registerOperand)
        cpu.executeORA(immediate: immediateOperand)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeORAZeropage() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(zeropage: 0x3D)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(zeropage: 0x3D)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeORAZeropageX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x8E)
        let memoryOperand = cpu.load(zeropageX: 0x3D)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(zeropageX: 0x3D)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x8E))
    }
    
    @Test func executeORAAbsolute() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(absolute: 0x3D47)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(absolute: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
    
    @Test func executeORAAbsoluteX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x2A)
        let memoryOperand = cpu.load(absoluteX: 0x3D47)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(absoluteX: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x2A))
    }
    
    @Test func executeORAAbsoluteY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, yr: 0x2A)
        let memoryOperand = cpu.load(absoluteY: 0x3D47)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(absoluteY: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, yr: 0x2A))
    }
    
    @Test func executeORAIndirectX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, xr: 0x2A)
        let memoryOperand = cpu.load(indirectX: 0x3D47)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(indirectX: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, xr: 0x2A))
    }
    
    @Test func executeORAIndirectY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand, yr: 0x2A)
        let memoryOperand = cpu.load(indirectY: 0x3D47)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(indirectY: 0x3D47)
        #expect(cpu == CPU6502(ac: expectedResult, yr: 0x2A))
    }
    
    @Test func executeORAZeropageIndirect() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        var cpu = CPU6502(ac: registerOperand)
        let memoryOperand = cpu.load(zeropageIndirect: 0x47)
        let expectedResult = registerOperand | memoryOperand
        cpu.executeORA(zeropageIndirect: 0x47)
        #expect(cpu == CPU6502(ac: expectedResult))
    }
}
