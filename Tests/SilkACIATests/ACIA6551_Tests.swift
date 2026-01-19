//
//  ACIA6551_Tests.swift
//  SilkEmu
//
//  Created by Matt Stoker on 1/12/26.
//

import Testing
@testable import SilkACIA

@Suite("6551 ACIA Base Tests")
struct ACIA6551Tests {
    @Test func initializer() {
        let acia = ACIA6551()
        #expect(
            acia == ACIA6551(
                sr: 0x00,
                ctl: 0x00,
                cmd: 0x00,
                tdr: 0x00,
                tsr: 0x00,
                rdr: 0x00,
                rsr: 0x00
            )
        )
    }
    
    @Test func read() {
        var acia = ACIA6551(
            sr: 0xFF,
            ctl: 0xEE,
            cmd: 0xDD,
            tdr: 0xCC,
            tsr: 0xBB,
            rdr: 0xAA,
            rsr: 0x99
        )
        
        let sr = acia.read(address: 0b00000001)
        #expect(sr == 0xFF | 0b00010000)
        #expect(acia == ACIA6551(
            sr: 0xFF & 0b00011111,
            ctl: 0xEE,
            cmd: 0xDD,
            tdr: 0xCC,
            tsr: 0xBB,
            rdr: 0xAA,
            rsr: 0x99
        ))
        
        let data = acia.read(address: 0b00000000)
        #expect(data == acia.rdr)
        #expect(acia == ACIA6551(
            sr: 0xFF & 0b00010010,
            ctl: 0xEE,
            cmd: 0xDD,
            tdr: 0xCC,
            tsr: 0xBB,
            rdr: 0xAA,
            rsr: 0x99
        ))
        
        let cmd = acia.read(address: 0b00000010)
        #expect(cmd == acia.cmd)
        
        let ctl = acia.read(address: 0b00000011)
        #expect(ctl == acia.ctl)
    }
    
    @Test func write() {
        var acia = ACIA6551()
        
        // Soft reset (value written is ignored)
        acia = ACIA6551(sr: 0b11111111, cmd: 0b11111111)
        acia.write(address: 0b00000001, data: 0b00000000)
        #expect(acia == ACIA6551(sr: 0b11111101, cmd: 0b11100000))
        
        // Configure serial control for 19200 baud N-8-1
        acia = ACIA6551()
        acia.write(address: 0b00000011, data: 0b00011111)
        #expect(acia == ACIA6551(ctl: 0b00011111))
        
        // Configure serial commands for no parity, no echo, enabled interrupts
        acia = ACIA6551()
        acia.write(address: 0b00000010, data: 0b00001001)
        #expect(acia == ACIA6551(cmd: 0b00001001))
        
        // Initiate send of data
        acia = ACIA6551()
        acia.write(address: 0b00000000, data: 0b10101010)
        #expect(acia == ACIA6551(ts: 0b00001000, tdr: 0b10101010, tsr: 0b10101010))
    }
    
    @Test func receive() {
        let message: [UInt8] = "This is a test".utf8.map { UInt8($0) }
        var messageBitIndex = 0
        let messageBitCount = message.count * UInt8.bitWidth
        var acia = ACIA6551(receive: {
            let messageByteIndex = messageBitIndex / UInt8.bitWidth
            let messageBitMask = UInt8(1 << (messageBitIndex % UInt8.bitWidth))
            let bit = (message[messageByteIndex] & messageBitMask) != 0
            messageBitIndex += 1
            return bit
        })
        
        var receivedMessage: [UInt8] = []
        while messageBitIndex < messageBitCount {
            acia.receiveBit()
            let rdrFull = (acia.read(address: ACIA6551.Register.SR.rawValue) & ACIA6551.srRDRFullMask) != 0
            if rdrFull {
                let byte = acia.read(address: ACIA6551.Register.DATA.rawValue)
                receivedMessage.append(byte)
            }
        }
        #expect(receivedMessage == message)
    }
    
    @Test func transmit() {
        var transmittedMessage: [UInt8] = []
        var transmittedMessageBitIndex = 0
        var acia = ACIA6551(transmit: { bit in
            let transmittedMessageByteIndex = transmittedMessageBitIndex / UInt8.bitWidth
            let transmittedMessageBitMask = UInt8(1 << (transmittedMessageBitIndex % UInt8.bitWidth))
            if transmittedMessage.count <= transmittedMessageByteIndex {
                transmittedMessage.append(0b00000000)
            }
            if bit {
                transmittedMessage[transmittedMessageByteIndex] = transmittedMessage[transmittedMessageByteIndex] | transmittedMessageBitMask
            }
            transmittedMessageBitIndex += 1
        })
        
        let message: [UInt8] = "This is a test".utf8.map { UInt8($0) }
        for byte in message {
            acia.write(address: ACIA6551.Register.DATA.rawValue, data: byte)
            for _ in 0..<UInt8.bitWidth {
                acia.transmitBit()
            }
        }
        
        #expect(transmittedMessage == message)
    }
}
