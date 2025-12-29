//
//  CPU6502+ArithmeticInstructions_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/28/25.
//

import Testing
@testable import SilkCPU

// MARK: - Arithmetic Instruction Tests

@Suite("6502 CPU Arithmetic Instruction Tests")
class CPU6502ArithmeticInstructionTests {
    var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
    func memory(_ high: UInt8, _ low: UInt8) -> UInt8 { memory[Int(UInt16(high: high, low: low))] }
    func memory(_ address: UInt16) -> UInt8 { memory[Int(address)] }
    init() {
        CPU6502.load = { address in return self.memory[Int(address)] }
        CPU6502.store = { address, value in self.memory[Int(address)] = value }
    }
    
    @Test func executeADCImmediate() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let immediateOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        let expectedSum = UInt16(registerOperand) + UInt16(immediateOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        var cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
        cpu.executeADC(immediate: immediateOperand)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeADCZeroPage() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(zeropage: 0xAB)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(zeropage: 0xAB)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeADCZeroPageX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, xr: 0x23, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(zeropageX: 0xAB)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(zeropageX: 0xAB)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), xr: 0x23, sr: expectedStatus))
    }
    
    @Test func executeADCAbsolute() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(absolute: 0xABCD)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(absolute: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeADCAbsoluteX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, xr: 0x63, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(absoluteX: 0xABCD)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(absoluteX: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), xr: 0x63, sr: expectedStatus))
    }
    
    @Test func executeADCAbsoluteY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, yr: 0x74, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(absoluteY: 0xABCD)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(absoluteY: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeADCIndirectX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, xr: 0x63, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(indirectX: 0xABCD)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(indirectX: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), xr: 0x63, sr: expectedStatus))
    }
    
    @Test func executeADCIndirectY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, yr: 0x74, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(indirectY: 0xABCD)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(indirectY: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeADCZeropageIndirect() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let carryOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, sr: carryOperand ? CPU6502.srCMask : 0x00)
        let memoryOperand = cpu.load(zeropageIndirect: 0xCD)
        let expectedSum = UInt16(registerOperand) + UInt16(memoryOperand) + UInt16(carryOperand ? 1 : 0)
        let expectedStatus = expectedSum > 0xFF ? CPU6502.srCMask : 0x00
        cpu.executeADC(zeropageIndirect: 0xCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedSum & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeSBCImmediate() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let immediateOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        let expectedDifference = Int16(registerOperand) - Int16(immediateOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        var cpu = CPU6502(ac: registerOperand, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        cpu.executeSBC(immediate: immediateOperand)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeSBCZeroPage() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(zeropage: 0xAB)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(zeropage: 0xAB)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeSBCZeroPageX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, xr: 0x23, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(zeropageX: 0xAB)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(zeropageX: 0xAB)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), xr: 0x23, sr: expectedStatus))
    }
    
    @Test func executeSBCAbsolute() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(absolute: 0xABCD)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(absolute: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), sr: expectedStatus))
    }
    
    @Test func executeSBCAbsoluteX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, xr: 0x63, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(absoluteX: 0xABCD)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(absoluteX: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), xr: 0x63, sr: expectedStatus))
    }
    
    @Test func executeSBCAbsoluteY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, yr: 0x74, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(absoluteY: 0xABCD)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(absoluteY: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeSBCIndirectX() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, xr: 0x63, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(indirectX: 0xABCD)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(indirectX: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), xr: 0x63, sr: expectedStatus))
    }
    
    @Test func executeSBCIndirectY() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, yr: 0x74, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(indirectY: 0xABCD)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(indirectY: 0xABCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeSBCZeropageIndirect() {
        let registerOperand = UInt8.random(in: 0x00...0xFF)
        let borrowOperand = Bool.random()
        var cpu = CPU6502(ac: registerOperand, sr: borrowOperand ? 0x00 : CPU6502.srCMask)
        let memoryOperand = cpu.load(zeropageIndirect: 0xCD)
        let expectedDifference = Int16(registerOperand) - Int16(memoryOperand) - Int16(borrowOperand ? 1 : 0)
        let expectedStatus = expectedDifference < 0 ? 0x00 : CPU6502.srCMask
        cpu.executeSBC(zeropageIndirect: 0xCD)
        #expect(cpu == CPU6502(ac: UInt8(expectedDifference & 0xFF), sr: expectedStatus))
    }
}
