// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SilkSystem

@main
struct SilkEmu: ParsableCommand {
    @Argument()
    var programFile: String
    
    @Option
    var programOffset: Int = 0
    
    @Option
    var screenshotFrequency: Int = 0
    
    @Option
    var screenshotStartAddress: Int = 0x0000
    
    @Option
    var screenshotEndAddress: Int = 0xFFFF
    
    @Option
    var screenshotWidth: Int = 0x80
    
    @Option
    var stepSleep: Double = 0.01
    
    @Flag
    var printState: Bool = false
    
    @Flag
    var stepWait: Bool = false
    
    static let queue = DispatchQueue(label: "CPU Execution Loop")
    
    mutating func run() throws {
        let programData = try Data(contentsOf: URL(fileURLWithPath: programFile))
        var program: [UInt8] = Array(repeating: 0x00, count: programData.count)
        programData.copyBytes(to: &program, count: min(program.count, programData.count))
        
        let system = System()
        system.program(data: program, startingAt: 0x0000)
        
        var aciaDataReceiveQueue = "This is a test"
        var aciaDataTransmitQueue = ""
        
        var instructionsExecuted = 0
        while true {
            if printState {
                print("\(system.cpu.debugDescription)    LCD: \(String(decoding: system.lcd.ddram, as: UTF8.self))")
            }
            switch system.cpu.state {
            case .boot, .run:
                system.execute()
            case .wait:
                ()
            case .stop:
                ()
            }
            
            // TODO: When should acia be checked?
            if instructionsExecuted % 100 == 0 {
                if let character = aciaDataReceiveQueue.first {
                    aciaDataReceiveQueue.removeFirst()
                    var receiveQueue = System.bits(of: String(character))
                    while !receiveQueue.isEmpty {
                        let bit = receiveQueue[0]
                        receiveQueue.removeFirst()
                        system.acia.receiveBit() { bit }
                    }
                }
                
                if system.acia.ts >= UInt8.bitWidth {
                    var transmitQueue: [Bool] = []
                    for _ in 0..<UInt8.bitWidth {
                        var bit = false
                        system.acia.transmitBit() { bit = $0 }
                        transmitQueue.append(bit)
                    }
                    let bits = Array(transmitQueue[..<UInt8.bitWidth])
                    transmitQueue.removeFirst(UInt8.bitWidth)
                    let byte = System.string(of: bits)
                    //                aciaDataTransmitQueue.append(byte)
                    print(byte, terminator: "")
                }
            }
                            
            instructionsExecuted += 1
            if screenshotFrequency > 0 && instructionsExecuted % screenshotFrequency == 0 {
                let screenshot = system.memoryPPM(start: UInt16(screenshotStartAddress), end: UInt16(screenshotEndAddress), line: UInt16(screenshotWidth))
                try screenshot.write(toFile: "\(programFile)_\(instructionsExecuted).ppm", atomically: true, encoding: .utf8)
            }
                                    
            if stepSleep != 0 {
                Thread.sleep(forTimeInterval: stepSleep)
            }
            if stepWait {
                _ = getchar()
            }
        }
    }
}
