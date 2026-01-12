//
//  VIA6522_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/9/26.
//

import Testing
@testable import SilkVIA

@Suite("6522 VIA Base Tests")
struct VIA6522Tests {
    @Test func initializer() {
        let via = VIA6522()
        #expect(
            via == VIA6522(
                pa: 0x00,
                pb: 0x00,
                ddra: 0x00,
                ddrb: 0x00,
                sr: 0x00,
                acr: 0x00,
                pcr: 0x00,
                ifr: 0x00,
                ier: 0x00,
                t1c: 0x0000,
                t1l: 0x0000,
                t2c: 0x0000,
                t2l: 0x0000
            )
        )
    }
    
    @Test func read() {
        let via = VIA6522(
            pa: 0xAA,
            pb: 0x55,
            ddra: 0xF1,
            ddrb: 0xE2,
            sr: 0xD3,
            acr: 0xC4,
            pcr: 0xB5,
            ifr: 0xA6,
            ier: 0x97,
            t1c: 0x1234,
            t1l: 0xFEDC,
            t2c: 0x4321,
            t2l: 0xCDEF
        )
        
        let paIn = UInt8(0xA5)
        let pbIn = UInt8(0x5A)
        #expect(via.read(address: 0x0, paIn: paIn, pbIn: pbIn) == (via.pb & via.ddrb) | (pbIn & ~via.ddrb))
        #expect(via.read(address: 0x1, paIn: paIn, pbIn: pbIn) == (via.pa & via.ddra) | (paIn & ~via.ddra))
        #expect(via.read(address: 0x2, paIn: paIn, pbIn: pbIn) == via.ddrb)
        #expect(via.read(address: 0x3, paIn: paIn, pbIn: pbIn) == via.ddra)
        #expect(via.read(address: 0x4, paIn: paIn, pbIn: pbIn) == via.t1c & 0x00FF)
        #expect(via.read(address: 0x5, paIn: paIn, pbIn: pbIn) == (via.t1c & 0xFF00) >> 8)
        #expect(via.read(address: 0x6, paIn: paIn, pbIn: pbIn) == via.t1l & 0x00FF)
        #expect(via.read(address: 0x7, paIn: paIn, pbIn: pbIn) == (via.t1l & 0xFF00) >> 8)
        #expect(via.read(address: 0x8, paIn: paIn, pbIn: pbIn) == via.t2c & 0x00FF)
        #expect(via.read(address: 0x9, paIn: paIn, pbIn: pbIn) == (via.t2c & 0xFF00) >> 8)
        #expect(via.read(address: 0xA, paIn: paIn, pbIn: pbIn) == via.sr)
        #expect(via.read(address: 0xB, paIn: paIn, pbIn: pbIn) == via.acr)
        #expect(via.read(address: 0xC, paIn: paIn, pbIn: pbIn) == via.pcr)
        #expect(via.read(address: 0xD, paIn: paIn, pbIn: pbIn) == via.ifr)
        #expect(via.read(address: 0xE, paIn: paIn, pbIn: pbIn) == via.ier)
        #expect(via.read(address: 0xF, paIn: paIn, pbIn: pbIn) == (via.pa & via.ddra) | (paIn & ~via.ddra))
    }
    
    @Test func write() {
        let test = VIA6522(
            pa: 0xAA,
            pb: 0x55,
            ddra: 0xF1,
            ddrb: 0xE2,
            sr: 0xD3,
            acr: 0xC4,
            pcr: 0xB5,
            ifr: 0xA6,
            ier: 0x97,
            t1c: 0x1234,
            t1l: 0xFEDC,
            t2c: 0x4321,
            t2l: 0xCDEF
        )
        var via = test
        
        let dataBus = UInt8(0xA5)
        via.write(address: 0x0, data: dataBus)
        #expect(via.pb == (test.pb & ~test.ddrb) | (dataBus & test.ddrb))
        via.write(address: 0x1, data: dataBus)
        #expect(via.pa == (test.pa & ~test.ddra) | (dataBus & test.ddra))
        via.write(address: 0x2, data: dataBus)
        #expect(via.ddrb == dataBus)
        via.write(address: 0x3, data: dataBus)
        #expect(via.ddra == dataBus)
        via.write(address: 0x4, data: dataBus)
        #expect(via.t1c & 0x00FF == dataBus)
        via.write(address: 0x5, data: dataBus)
        #expect((via.t1c & 0xFF00) >> 8 == dataBus)
        via.write(address: 0x6, data: dataBus)
        #expect(via.t1l & 0x00FF == dataBus)
        via.write(address: 0x7, data: dataBus)
        #expect((via.t1l & 0xFF00) >> 8 == dataBus)
        via.write(address: 0x8, data: dataBus)
        #expect(via.t2c & 0x00FF == dataBus)
        via.write(address: 0x9, data: dataBus)
        #expect((via.t2c & 0xFF00) >> 8 == dataBus)
        via.write(address: 0xA, data: dataBus)
        #expect(via.sr == dataBus)
        via.write(address: 0xB, data: dataBus)
        #expect(via.acr == dataBus)
        via.write(address: 0xC, data: dataBus)
        #expect(via.pcr == dataBus)
        via.write(address: 0xD, data: dataBus)
        #expect(via.ifr == dataBus)
        via.write(address: 0xE, data: dataBus)
        #expect(via.ier == dataBus)
        via.write(address: 0xF, data: dataBus)
        #expect(via.pa == (test.pa & ~via.ddra) | (dataBus & via.ddra))
    }
}
