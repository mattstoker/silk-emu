//
//  CPU6502_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//

import Testing
@testable import SilkCPU

class System {
    var cpu: CPU6502 {
        didSet {
            self.cpu.load = { [weak self] address in return self?.memory[Int(address)] ?? 0xEA }
            self.cpu.store = { [weak self] address, value in self?.memory[Int(address)] = value }
        }
    }
    var memory: [UInt8]
    init(cpu: CPU6502, memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })) {
        self.cpu = cpu
        self.memory = memory
        self.cpu.load = { [weak self] address in return self?.memory[Int(address)] ?? 0xEA }
        self.cpu.store = { [weak self] address, value in self?.memory[Int(address)] = value }
    }
}

let MemoryTestAddresses = stride(from: UInt16.min, to: UInt16.max, by: 123)

@Suite("6502 CPU Base Tests")
struct CPU6502Tests {
    @Test func initializer() {
        let cpu = CPU6502()
        #expect(
            cpu == CPU6502(
                pc: 0x00,
                ac: 0x00,
                xr: 0x00,
                yr: 0x00,
                sr: 0x00,
                sp: 0x00
            )
        )
    }
}
