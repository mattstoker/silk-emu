//
//  CPU6502_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 12/24/25.
//

import Testing
@testable import SilkCPU

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
                sp: 0x00,
                res: false,
                irq: false,
                nmi: false
            )
        )
    }
}
