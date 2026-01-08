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
struct CPU6502LDTests {
    func expectedStatus(_ result: UInt8) -> UInt8 {
        let negative = result & 0x80 != 0
        let zero = result == 0
        var status = UInt8.min
        status = negative ? (status | CPU6502.srNMask) : (status & ~CPU6502.srNMask)
        status = zero ? (status | CPU6502.srZMask) : (status & ~CPU6502.srZMask)
        return status
    }
    
    @Test func executeLDAImmediate() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDA(immediate: 0xEA)
        #expect(s.cpu == CPU6502(ac: 0xEA, sr: CPU6502.srNMask))
    }
    
    @Test func executeLDAZeroPage() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(zeropage: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(zeropage: 0xAB)
        #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDAZeroPageX() {
        let s = System(cpu: CPU6502(xr: 0x23))
        let expectedResult = s.cpu.load(zeropageX: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(zeropageX: 0xAB)
        #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x23, sr: expectedStatus))
    }
    
    @Test func executeLDAAbsolute() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(absolute: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(absolute: 0xABCD)
        #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDAAbsoluteX() {
        let s = System(cpu: CPU6502(xr: 0x63))
        let expectedResult = s.cpu.load(absoluteX: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(absoluteX: 0xABCD)
        #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x63, sr: expectedStatus))
    }
    
    @Test func executeLDAAbsoluteY() {
        let s = System(cpu: CPU6502(yr: 0x74))
        let expectedResult = s.cpu.load(absoluteY: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(absoluteY: 0xABCD)
        #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeLDAIndirectX() {
        let s = System(cpu: CPU6502(xr: 0x63))
        let expectedResult = s.cpu.load(preIndirectX: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(preIndirectX: 0xAB)
        #expect(s.cpu == CPU6502(ac: expectedResult, xr: 0x63, sr: expectedStatus))
    }
    
    @Test func executeLDAIndirectY() {
        let s = System(cpu: CPU6502(yr: 0x74))
        let expectedResult = s.cpu.load(postIndirectY: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(postIndirectY: 0xAB)
        #expect(s.cpu == CPU6502(ac: expectedResult, yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeLDAZeropageIndirect() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(zeropageIndirect: 0xCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDA(zeropageIndirect: 0xCD)
        #expect(s.cpu == CPU6502(ac: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDXImmediate() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDX(immediate: 0xEA)
        #expect(s.cpu == CPU6502(xr: 0xEA, sr: CPU6502.srNMask))
    }
    
    @Test func executeLDXZeroPage() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(zeropage: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDX(zeropage: 0xAB)
        #expect(s.cpu == CPU6502(xr: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDXZeroPageY() {
        let s = System(cpu: CPU6502(yr: 0x23))
        let expectedResult = s.cpu.load(zeropageY: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDX(zeropageY: 0xAB)
        #expect(s.cpu == CPU6502(xr: expectedResult, yr: 0x23, sr: expectedStatus))
    }
    
    @Test func executeLDXAbsolute() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(absolute: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDX(absolute: 0xABCD)
        #expect(s.cpu == CPU6502(xr: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDXAbsoluteY() {
        let s = System(cpu: CPU6502(yr: 0x74))
        let expectedResult = s.cpu.load(absoluteY: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDX(absoluteY: 0xABCD)
        #expect(s.cpu == CPU6502(xr: expectedResult, yr: 0x74, sr: expectedStatus))
    }
    
    @Test func executeLDYImmediate() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDY(immediate: 0xEA)
        #expect(s.cpu == CPU6502(yr: 0xEA, sr: CPU6502.srNMask))
    }
    
    @Test func executeLDYZeroPage() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(zeropage: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDY(zeropage: 0xAB)
        #expect(s.cpu == CPU6502(yr: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDYZeroPageX() {
        let s = System(cpu: CPU6502(xr: 0x23))
        let expectedResult = s.cpu.load(zeropageX: 0xAB)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDY(zeropageX: 0xAB)
        #expect(s.cpu == CPU6502(xr: 0x23, yr: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDYAbsolute() {
        let s = System(cpu: CPU6502())
        let expectedResult = s.cpu.load(absolute: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDY(absolute: 0xABCD)
        #expect(s.cpu == CPU6502(yr: expectedResult, sr: expectedStatus))
    }
    
    @Test func executeLDYAbsoluteX() {
        let s = System(cpu: CPU6502(xr: 0x74))
        let expectedResult = s.cpu.load(absoluteX: 0xABCD)
        let expectedStatus = expectedStatus(expectedResult)
        s.cpu.executeLDY(absoluteX: 0xABCD)
        #expect(s.cpu == CPU6502(xr: 0x74, yr: expectedResult, sr: expectedStatus))
    }
}

// MARK: - Store Instruction Tests

@Suite("6502 CPU Store Instruction Tests")
class CPU6502STTests {
    @Test func executeSTAZeroPage() {
        let s = System(cpu: CPU6502(ac: 0xAA))
        s.cpu.executeSTA(zeropage: 0xAB)
        #expect(s.cpu.load(zeropage: 0xAB) == 0xAA)
    }
    
    @Test func executeSTAZeroPageX() {
        let s = System(cpu: CPU6502(ac: 0xBB, xr: 0x23))
        s.cpu.executeSTA(zeropageX: 0xAB)
        #expect(s.cpu.load(zeropageX: 0xAB) == 0xBB)
    }
    
    @Test func executeSTAAbsolute() {
        let s = System(cpu: CPU6502(ac: 0xCC))
        s.cpu.executeSTA(absolute: 0xABCD)
        #expect(s.cpu.load(absolute: 0xABCD) == 0xCC)
    }
    
    @Test func executeSTAAbsoluteX() {
        let s = System(cpu: CPU6502(ac: 0xDD, xr: 0x63))
        s.cpu.executeSTA(absoluteX: 0xABCD)
        #expect(s.cpu.load(absoluteX: 0xABCD) == 0xDD)
    }
    
    @Test func executeSTAAbsoluteY() {
        let s = System(cpu: CPU6502(ac: 0xEE, yr: 0x74))
        s.cpu.executeSTA(absoluteY: 0xABCD)
        #expect(s.cpu.load(absoluteY: 0xABCD) == 0xEE)
    }
    
    @Test func executeSTAIndirectX() {
        let s = System(cpu: CPU6502(ac: 0x55, xr: 0x63))
        s.cpu.executeSTA(preIndirectX: 0xAB)
        #expect(s.cpu.load(preIndirectX: 0xAB) == 0x55)
    }
    
    @Test func executeSTAIndirectY() {
        let s = System(cpu: CPU6502(ac: 0x66, yr: 0x74))
        s.cpu.executeSTA(postIndirectY: 0xAB)
        #expect(s.cpu.load(postIndirectY: 0xAB) == 0x66)
    }
    
    @Test func executeSTAZeropageIndirect() {
        let s = System(cpu: CPU6502(ac: 0x55))
        s.cpu.executeSTA(zeropageIndirect: 0xCD)
        #expect(s.cpu.load(zeropageIndirect: 0xCD) == 0x55)
    }
    
    @Test func executeSTXZeroPage() {
        let s = System(cpu: CPU6502(xr: 0xAA))
        s.cpu.executeSTX(zeropage: 0xAB)
        #expect(s.cpu.load(zeropage: 0xAB) == 0xAA)
    }
    
    @Test func executeSTXZeroPageY() {
        let s = System(cpu: CPU6502(xr: 0xBB, yr: 0x23))
        s.cpu.executeSTX(zeropageY: 0xAB)
        #expect(s.cpu.load(zeropageY: 0xAB) == 0xBB)
    }
    
    @Test func executeSTXAbsolute() {
        let s = System(cpu: CPU6502(xr: 0xCC))
        s.cpu.executeSTX(absolute: 0xABCD)
        #expect(s.cpu.load(absolute: 0xABCD) == 0xCC)
    }
    
    @Test func executeSTYZeroPage() {
        let s = System(cpu: CPU6502(yr: 0xAA))
        s.cpu.executeSTY(zeropage: 0xAB)
        #expect(s.cpu.load(zeropage: 0xAB) == 0xAA)
    }
    
    @Test func executeSTYZeroPageX() {
        let s = System(cpu: CPU6502(xr: 0x23, yr: 0xBB))
        s.cpu.executeSTY(zeropageX: 0xAB)
        #expect(s.cpu.load(zeropageX: 0xAB) == 0xBB)
    }
    
    @Test func executeSTYAbsolute() {
        let s = System(cpu: CPU6502(yr: 0xCC))
        s.cpu.executeSTY(absolute: 0xABCD)
        #expect(s.cpu.load(absolute: 0xABCD) == 0xCC)
    }
    
    @Test func executeSTZZeroPage() {
        let s = System(cpu: CPU6502())
        s.cpu.executeSTZ(zeropage: 0xAB)
        #expect(s.cpu.load(zeropage: 0xAB) == 0x00)
    }
    
    @Test func executeSTZZeroPageX() {
        let s = System(cpu: CPU6502(xr: 0x23))
        s.cpu.executeSTZ(zeropageX: 0xAB)
        #expect(s.cpu.load(zeropageX: 0xAB) == 0x00)
    }
    
    @Test func executeSTZAbsolute() {
        let s = System(cpu: CPU6502())
        s.cpu.executeSTZ(absolute: 0xABCD)
        #expect(s.cpu.load(absolute: 0xABCD) == 0x00)
    }
    
    @Test func executeSTZAbsoluteX() {
        let s = System(cpu: CPU6502(xr: 0xCC))
        s.cpu.executeSTZ(absoluteX: 0xABCD)
        #expect(s.cpu.load(absoluteX: 0xABCD) == 0x00)
    }
}

// MARK: - Register Transfer Instruction Tests

@Suite("6502 CPU Register Transfer Tests")
class CPU6502TTests {
    @Test func executeTAX() {
        let s = System(cpu: CPU6502(ac: 0xAA, xr: 0xBB))
        s.cpu.executeTAX()
        #expect(s.cpu == CPU6502(ac: 0xAA, xr: 0xAA, sr: CPU6502.srNMask))
    }
    
    @Test func executeTXA() {
        let s = System(cpu: CPU6502(ac: 0xBB, xr: 0xAA))
        s.cpu.executeTXA()
        #expect(s.cpu == CPU6502(ac: 0xAA, xr: 0xAA, sr: CPU6502.srNMask))
    }
    
    @Test func executeTAY() {
        let s = System(cpu: CPU6502(ac: 0xAA, yr: 0xBB))
        s.cpu.executeTAY()
        #expect(s.cpu == CPU6502(ac: 0xAA, yr: 0xAA, sr: CPU6502.srNMask))
    }
    
    @Test func executeTYA() {
        let s = System(cpu: CPU6502(ac: 0xBB, yr: 0xAA))
        s.cpu.executeTYA()
        #expect(s.cpu == CPU6502(ac: 0xAA, yr: 0xAA, sr: CPU6502.srNMask))
    }
    
    @Test func executeTSX() {
        let s = System(cpu: CPU6502(xr: 0xBB, sp: 0xAA))
        s.cpu.executeTSX()
        #expect(s.cpu == CPU6502(xr: 0xAA, sr: CPU6502.srNMask, sp: 0xAA))
    }
    
    @Test func executeTXS() {
        let s = System(cpu: CPU6502(xr: 0xAA, sp: 0xBB))
        s.cpu.executeTXS()
        #expect(s.cpu == CPU6502(xr: 0xAA, sp: 0xAA))
    }
}
