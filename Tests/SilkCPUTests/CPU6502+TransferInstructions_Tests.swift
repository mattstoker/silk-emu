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
    @Test func executeLDAImmediate() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDA(immediate: 0xEA)
        #expect(s.cpu == CPU6502(ac: 0xEA))
    }
    
    @Test func executeLDAZeroPage() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDA(zeropage: 0xAB)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(zeropage: 0xAB)))
    }
    
    @Test func executeLDAZeroPageX() {
        let s = System(cpu: CPU6502(xr: 0x23))
        s.cpu.executeLDA(zeropageX: 0xAB)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(zeropageX: 0xAB), xr: 0x23))
    }
    
    @Test func executeLDAAbsolute() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDA(absolute: 0xABCD)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(absolute: 0xABCD)))
    }
    
    @Test func executeLDAAbsoluteX() {
        let s = System(cpu: CPU6502(xr: 0x63))
        s.cpu.executeLDA(absoluteX: 0xABCD)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(absoluteX: 0xABCD), xr: 0x63))
    }
    
    @Test func executeLDAAbsoluteY() {
        let s = System(cpu: CPU6502(yr: 0x74))
        s.cpu.executeLDA(absoluteY: 0xABCD)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(absoluteY: 0xABCD), yr: 0x74))
    }
    
    @Test func executeLDAIndirectX() {
        let s = System(cpu: CPU6502(xr: 0x63))
        s.cpu.executeLDA(preIndirectX: 0xABCD)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(preIndirectX: 0xABCD), xr: 0x63))
    }
    
    @Test func executeLDAIndirectY() {
        let s = System(cpu: CPU6502(yr: 0x74))
        s.cpu.executeLDA(postIndirectY: 0xABCD)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(postIndirectY: 0xABCD), yr: 0x74))
    }
    
    @Test func executeLDAZeropageIndirect() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDA(zeropageIndirect: 0xCD)
        #expect(s.cpu == CPU6502(ac: s.cpu.load(zeropageIndirect: 0xCD)))
    }
    
    @Test func executeLDXImmediate() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDX(immediate: 0xEA)
        #expect(s.cpu == CPU6502(xr: 0xEA))
    }
    
    @Test func executeLDXZeroPage() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDX(zeropage: 0xAB)
        #expect(s.cpu == CPU6502(xr: s.cpu.load(zeropage: 0xAB)))
    }
    
    @Test func executeLDXZeroPageY() {
        let s = System(cpu: CPU6502(yr: 0x23))
        s.cpu.executeLDX(zeropageY: 0xAB)
        #expect(s.cpu == CPU6502(xr: s.cpu.load(zeropageY: 0xAB), yr: 0x23))
    }
    
    @Test func executeLDXAbsolute() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDX(absolute: 0xABCD)
        #expect(s.cpu == CPU6502(xr: s.cpu.load(absolute: 0xABCD)))
    }
    
    @Test func executeLDXAbsoluteY() {
        let s = System(cpu: CPU6502(yr: 0x74))
        s.cpu.executeLDX(absoluteY: 0xABCD)
        #expect(s.cpu == CPU6502(xr: s.cpu.load(absoluteY: 0xABCD), yr: 0x74))
    }
    
    @Test func executeLDYImmediate() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDY(immediate: 0xEA)
        #expect(s.cpu == CPU6502(yr: 0xEA))
    }
    
    @Test func executeLDYZeroPage() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDY(zeropage: 0xAB)
        #expect(s.cpu == CPU6502(yr: s.cpu.load(zeropage: 0xAB)))
    }
    
    @Test func executeLDYZeroPageX() {
        let s = System(cpu: CPU6502(xr: 0x23))
        s.cpu.executeLDY(zeropageX: 0xAB)
        #expect(s.cpu == CPU6502(xr: 0x23, yr: s.cpu.load(zeropageX: 0xAB)))
    }
    
    @Test func executeLDYAbsolute() {
        let s = System(cpu: CPU6502())
        s.cpu.executeLDY(absolute: 0xABCD)
        #expect(s.cpu == CPU6502(yr: s.cpu.load(absolute: 0xABCD)))
    }
    
    @Test func executeLDYAbsoluteX() {
        let s = System(cpu: CPU6502(xr: 0x74))
        s.cpu.executeLDY(absoluteX: 0xABCD)
        #expect(s.cpu == CPU6502(xr: 0x74, yr: s.cpu.load(absoluteX: 0xABCD)))
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
        s.cpu.executeSTA(preIndirectX: 0xABCD)
        #expect(s.cpu.load(preIndirectX: 0xABCD) == 0x55)
    }
    
    @Test func executeSTAIndirectY() {
        let s = System(cpu: CPU6502(ac: 0x66, yr: 0x74))
        s.cpu.executeSTA(postIndirectY: 0xABCD)
        #expect(s.cpu.load(postIndirectY: 0xABCD) == 0x66)
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
        #expect(s.cpu == CPU6502(ac: 0xAA, xr: 0xAA))
    }
    
    @Test func executeTXA() {
        let s = System(cpu: CPU6502(ac: 0xBB, xr: 0xAA))
        s.cpu.executeTXA()
        #expect(s.cpu == CPU6502(ac: 0xAA, xr: 0xAA))
    }
    
    @Test func executeTAY() {
        let s = System(cpu: CPU6502(ac: 0xAA, yr: 0xBB))
        s.cpu.executeTAY()
        #expect(s.cpu == CPU6502(ac: 0xAA, yr: 0xAA))
    }
    
    @Test func executeTYA() {
        let s = System(cpu: CPU6502(ac: 0xBB, yr: 0xAA))
        s.cpu.executeTYA()
        #expect(s.cpu == CPU6502(ac: 0xAA, yr: 0xAA))
    }
    
    @Test func executeTSX() {
        let s = System(cpu: CPU6502(xr: 0xBB, sp: 0xAA))
        s.cpu.executeTSX()
        #expect(s.cpu == CPU6502(xr: 0xAA, sp: 0xAA))
    }
    
    @Test func executeTXS() {
        let s = System(cpu: CPU6502(xr: 0xAA, sp: 0xBB))
        s.cpu.executeTXS()
        #expect(s.cpu == CPU6502(xr: 0xAA, sp: 0xAA))
    }
}
