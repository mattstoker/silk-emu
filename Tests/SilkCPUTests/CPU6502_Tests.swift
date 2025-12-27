//
//  CPU6502_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//

import XCTest
@testable import SilkCPU

class CPU6502Tests: XCTestCase {
    nonisolated(unsafe) static var memory: [UInt8] = Array((0x0000...0xFFFF).map { UInt8($0 & 0xFF) })
    static override func setUp() {
        CPU6502.load = { address in return memory[Int(address)] }
        CPU6502.store = { address, value in memory[Int(address)] = value }
    }
    
    static func memoryRandomize() {
        memory = memory.indices.map { _ in UInt8.random(in: 0x00...0xFF) }
    }
    
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
        Self.memoryRandomize()
        var cpu = CPU6502()
        cpu.executeLDA(immediate: 0xEA)
        XCTAssertEqual(cpu, CPU6502(ac: 0xEA))
    }
    
    func testExecuteLDAZeroPage() {
        Self.memoryRandomize()
        var cpu = CPU6502()
        cpu.executeLDA(zeropage: 0xAB)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(UInt16(high: 0x00, low: 0xAB))))
    }
    
    func testExecuteLDAZeroPageX() {
        Self.memoryRandomize()
        var cpu = CPU6502(xr: 0x23)
        cpu.executeLDA(zeropageX: 0xAB)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(UInt16(high: 0x00, low: 0xAB + 0x23)), xr: 0x23))
    }
    
    func testExecuteLDAAbsolute() {
        Self.memoryRandomize()
        var cpu = CPU6502()
        cpu.executeLDA(absolute: 0xABCD)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))))
    }
    
    func testExecuteLDAAbsoluteX() {
        Self.memoryRandomize()
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(absoluteX: 0xABCD)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63)), xr: 0x63))
    }
    
    func testExecuteLDAAbsoluteY() {
        Self.memoryRandomize()
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(absoluteY: 0xABCD)
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x74)), yr: 0x74))
    }
    
    func testExecuteLDAIndirectX() {
        Self.memoryRandomize()
        var cpu = CPU6502(xr: 0x63)
        cpu.executeLDA(indirectX: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63 + 1)),
            low: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63))
        )
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(address), xr: 0x63))
    }
    
    func testExecuteLDAIndirectY() {
        Self.memoryRandomize()
        var cpu = CPU6502(yr: 0x74)
        cpu.executeLDA(indirectY: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB, low: 0xCD + 1)),
            low: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))
        ) &+ 0x74
        XCTAssertEqual(cpu, CPU6502(ac: CPU6502.load(address), yr: 0x74))
    }
    
    func testExecuteSTAZeroPage() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0xAA)
        cpu.executeSTA(zeropage: 0xAB)
        XCTAssertEqual(Self.memory[0x00AB], 0xAA)
    }
    
    func testExecuteSTAZeroPageX() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0xBB, xr: 0x23)
        cpu.executeSTA(zeropageX: 0xAB)
        XCTAssertEqual(Self.memory[0x00AB &+ 0x23], 0xBB)
    }
    
    func testExecuteSTAAbsolute() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0xCC)
        cpu.executeSTA(absolute: 0xABCD)
        XCTAssertEqual(Self.memory[0xABCD], 0xCC)
    }
    
    func testExecuteSTAAbsoluteX() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0xDD, xr: 0x63)
        cpu.executeSTA(absoluteX: 0xABCD)
        XCTAssertEqual(Self.memory[0xABCD &+ 0x63], 0xDD)
    }
    
    func testExecuteSTAAbsoluteY() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0xEE, yr: 0x74)
        cpu.executeSTA(absoluteY: 0xABCD)
        XCTAssertEqual(Self.memory[0xABCD &+ 0x74], 0xEE)
    }
    
    func testExecuteSTAIndirectX() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0x55, xr: 0x63)
        cpu.executeSTA(indirectX: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63 + 1)),
            low: CPU6502.load(UInt16(high: 0xAB + 1, low: 0xCD &+ 0x63))
        )
        XCTAssertEqual(Self.memory[Int(address)], 0x55)
    }
    
    func testExecuteSTAIndirectY() {
        Self.memoryRandomize()
        var cpu = CPU6502(ac: 0x66, yr: 0x74)
        cpu.executeSTA(indirectY: 0xABCD)
        let address = UInt16(
            high: CPU6502.load(UInt16(high: 0xAB, low: 0xCD + 1)),
            low: CPU6502.load(UInt16(high: 0xAB, low: 0xCD))
        ) &+ 0x74
        XCTAssertEqual(Self.memory[Int(address)], 0x66)
    }
}
