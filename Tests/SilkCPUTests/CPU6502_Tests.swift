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
    
    @Test func execute() {
        let s = System(
            cpu: CPU6502(sp: 0xFF),
            memory: [
                CPU6502.Instruction.LDA_imm.rawValue, 0xAA,
                CPU6502.Instruction.ADC_imm.rawValue, 0x21,
                CPU6502.Instruction.STA_abs.rawValue, 0xEF, 0xBE,
            ]
        )
        s.memory += Array(repeating: UInt8.min, count: 0xFFF9 - s.memory.count)
        s.memory += [0x00, 0x00]
        s.memory += [0x00, 0x00]
        s.memory += [0x00, 0x00]
        #expect(s.memory.count == 0xFFFF)
        #expect(s.cpu == CPU6502(pc: 0x0000, ac: 0x00, xr: 0x00, yr: 0x00, sr: 0x00, sp: 0xFF))
        s.cpu.execute()
        #expect(s.cpu == CPU6502(pc: 0x0000, ac: 0x00, xr: 0x00, yr: 0x00, sr: 0x00, sp: 0xFF))
        s.cpu.execute()
        #expect(s.cpu == CPU6502(pc: 0x0002, ac: 0xAA, xr: 0x00, yr: 0x00, sr: 0x00, sp: 0xFF))
        s.cpu.execute()
        #expect(s.cpu == CPU6502(pc: 0x0004, ac: 0xCB, xr: 0x00, yr: 0x00, sr: 0x80, sp: 0xFF))
        s.cpu.execute()
        #expect(s.cpu == CPU6502(pc: 0x0007, ac: 0xCB, xr: 0x00, yr: 0x00, sr: 0x80, sp: 0xFF))
        #expect(s.memory[0xBEEF] == 0xCB)
    }
}
