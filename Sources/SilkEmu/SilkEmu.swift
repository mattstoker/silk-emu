// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SilkCPU

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
    
    @Flag
    var printState: Bool = false
    
    static let queue = DispatchQueue(label: "CPU Execution Loop")
    
    mutating func run() throws {
        let programData = try Data(contentsOf: URL(fileURLWithPath: programFile))
        var program: [UInt8] = Array(repeating: 0x00, count: programData.count)
        programData.copyBytes(to: &program, count: min(program.count, programData.count))
        
        var memory = Array(repeating: UInt8(0x00), count: 0x10000)
        for index in program.indices {
            memory[programOffset + index] = program[index]
        }
        
        var cpu = CPU6502(
            load: { address in memory[Int(address)] },
            store: { address, value in memory[Int(address)] = value }
        )
        
        let printState = printState
        let screenshotFrequency = screenshotFrequency
        var instructionsExecuted = 0
//        if #available(macOS 10.15, *) {
//            signal(SIGINT, SIG_IGN)
//            let sigintSource = DispatchSource.makeSignalSource(signal: SIGINT, queue: .main)
//            sigintSource.setEventHandler {
//                print("Got SIGINT")
//                SilkEmu.exit()
//            }
//            sigintSource.resume()
//            let sighupSource = DispatchSource.makeSignalSource(signal: SIGHUP, queue: .main)
//            sighupSource.setEventHandler {
//                print("Got SIGHUP")
//                cpu.resume()
//                SilkEmu.exit()
//            }
//            sighupSource.resume()
//
//            _ = DispatchQueue.main.schedule(
//                after: .init(.now().advanced(by: .seconds(1))),
//                interval: .milliseconds(1)
//            ) {
//                Self.loop(cpu: &cpu, printState: printState)
//            }
//            dispatchMain()
//        } else {
            while true {
                Self.loop(cpu: &cpu, printState: printState)
                instructionsExecuted += 1
                if screenshotFrequency > 0 && instructionsExecuted % screenshotFrequency == 0 {
                    let screenshot = Self.screenshot(cpu: cpu, start: UInt16(screenshotStartAddress), end: UInt16(screenshotEndAddress), width: screenshotWidth)
                    try screenshot.write(toFile: "\(programFile)_\(instructionsExecuted).ppm", atomically: true, encoding: .utf8)
                }
            }
//        }
    }
    
    static func loop(cpu: inout CPU6502, printState: Bool = false) {
        if printState {
            print("\(cpu.debugDescription)")
        }
        switch cpu.state {
        case .boot, .run:
            cpu.execute()
        case .wait:
            ()
        case .stop:
            ()
        }
    }
    
    static func screenshot(cpu: CPU6502, start: UInt16, end: UInt16, width: Int) -> String {
        let count = Int(end) - Int(start) + 1
        let height = count / width
        var screenshot = ""
        screenshot.append("P3\n")
        screenshot.append("\(width) \(height)\n")
        screenshot.append("3\n")
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let address = pixelIndex > count ? nil : start + UInt16(pixelIndex)
                let value: UInt8 = address.map { cpu.load($0) } ?? UInt8.min
                let r = ((value & 0b00000011) >> 0)
                let g = ((value & 0b00001100) >> 2)
                let b = ((value & 0b00110000) >> 4)
                screenshot.append("\(r) \(g) \(b)\n")
            }
        }
        return screenshot
    }
}
