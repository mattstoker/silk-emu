//
//  CPU6502_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//

import XCTest
@testable import SilkCPU

class CPU6502Tests: XCTestCase {
    func testInitializer() {
        let cpu = CPU6502()
        XCTAssertEqual(
            cpu,
            CPU6502(
                pc: 0x00,
                ac: 0x00,
                xr: 0x00,
                yr: 0x00,
                sr: 0x00,
                sp: 0x00,
                res: false,
                irq: false,
                nmi: false
            )
        )
    }
    
    func testExecuteLDAImmediate() {
        var cpu = CPU6502()
        cpu.executeLDA(immediate: 0xEA)
        XCTAssertEqual(cpu, CPU6502(ac: 0xEA))
    }
    
    func testExecuteLDAZeroPage() {
        var cpu = CPU6502()
        cpu.executeLDA(zeropage: 0xAB)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(0x00, 0xAB)))
    }
    
    func testExecuteLDAZeroPageX() {
        var cpu = CPU6502(xr: 0x23)
        cpu.executeLDA(zeropageX: 0xAB)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(0x00, 0xAB + 0x23), xr: 0x23))
    }
    
    func testExecuteLDAAbsolute() {
        var cpu = CPU6502()
        cpu.executeLDA(absolute: 0xABCD)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(0xAB, 0xCD)))
    }
    
    func testExecuteLDAAbsoluteX() {
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(absoluteX: 0xABCD)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(0xAB + 1, 0xCD &+ 0x63), xr: 0x63))
    }
    
    func testExecuteLDAAbsoluteY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(absoluteY: 0xABCD)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(0xAB + 1, 0xCD &+ 0x74), yr: 0x74))
    }
    
    func testExecuteLDAIndirectX() {
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(indirectX: 0xABCD)
        let address = UInt16(high: CPU6502.load(0xAB + 1, 0xCD &+ 0x63 + 1) + 1, low: CPU6502.load(0xAB + 1, 0xCD &+ 0x63))
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(address.high, address.low), xr: 0x63))
    }
    
    func testExecuteLDAIndirectY() {
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(indirectY: 0xABCD)
        let address = UInt16(high: CPU6502.load(0xAB, 0xCD + 1), low: CPU6502.load(0xAB, 0xCD)) &+ 0x74
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(address.high, address.low), yr: 0x74))
    }
}
