//
//  CPU6502+Disassembly_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 2/7/26.
//

import Testing
@testable import SilkCPU

// MARK: - Comparision Instruction Tests

@Suite("6502 CPU Disassembly Tests")
struct CPU6502DisassemblyTests {
    @Test func disassemble() {
        let program: [UInt8] = [0xA2, 0xFF, 0x9A, 0x20, 0x8B, 0xE4, 0x58, 0x20, 0x11, 0xE5, 0x20, 0x2D, 0xE5, 0xA2, 0xFD]
        let operations = CPU6502.disassemble(program: program)
        #expect(operations == [
            .init(address: 0, instruction: .LDX_imm, oper: 0xFF),
            .init(address: 2, instruction: .TXS_impl),
            .init(address: 3, instruction: .JSR_abs, oper: 0x8B, operWideHigh: 0xE4),
            .init(address: 6, instruction: .CLI_impl),
            .init(address: 7, instruction: .JSR_abs, oper: 0x11, operWideHigh: 0xE5),
            .init(address: 10, instruction: .JSR_abs, oper: 0x2D, operWideHigh: 0xE5),
            .init(address: 13, instruction: .LDX_imm, oper: 0xFD),
        ])
    }
}
