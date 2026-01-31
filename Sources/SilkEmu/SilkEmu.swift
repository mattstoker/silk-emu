// The Swift Programming Language
// https://docs.swift.org/swift-book
//
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import Foundation
import SilkSystem
import SilkCPU

@main
struct SilkEmu: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "6502-based computer system emulator."
    )
    
    @Argument(help: "Program to load into memory. Ensure the program has the desired initial program counter address stored at 0xFFFE.")
    var programFile: String
    
    @Option(help: "Memory offset to use to load the input program into memory.")
    var programOffset: Int = 0
    
    @Option(help: "Frequency at which clock cycles should be fed to the system (in cycles / sec).")
    var clockFrequency: Double = 1_000_000.0
    
    @Option(help: "Ratio of wall-clock time to clock cycle time to use in simulation.")
    var realtimeRatio: Double = 1.0 / 1.0
    
    @Option(help: "File to use as input to the ACIA hardware. Use /dev/stdin (or OS equivalent) to interactively provide data.")
    var aciaTransmitFile: String? = nil
    
    @Option(help: "File to use as output from the ACIA hardware. Use /dev/stdout (or OS equivalent) to print output to the console.")
    var aciaReceiveFile: String? = nil
    
    @Option(help: "Frequency to take screenshots of memory, simulating a VGA attached to the system.")
    var screenshotFrequency: Int = 0
    
    @Option(help: "Start address for memory screenshots. Many programs start VGA at 8192 (0x2000).")
    var screenshotStartAddress: Int = 0x0000
    
    @Option(help: "End address for memory screenshots. Many programs end VGA at 16383 (0x3FFF).")
    var screenshotEndAddress: Int = 0xFFFF
    
    @Option(help: "Width of memory screenshot, in bytes.")
    var screenshotWidth: Int = 0x80
    
    @Flag(help: "Print the CPU registers and current program opcode & operand.")
    var printState: Bool = false
    
    @Flag(help: "Print changes to the LCD DDRAM.")
    var printLCD: Bool = false

    mutating func run() throws {
        // Load the provided program
        let programData = try Data(contentsOf: URL(fileURLWithPath: programFile))
        var program: [UInt8] = Array(repeating: 0x00, count: programData.count)
        programData.copyBytes(to: &program, count: min(program.count, programData.count))
        
        // Create a system and load the program into it
        let system = System()
        system.program(data: program, startingAt: 0x0000)
        
        // Open files being used for ACIA transmit / receive
        let aciaTransmitStream = aciaTransmitFile.map { fopen($0, "r") } ?? nil
        let aciaReceiveStream = aciaReceiveFile.map { fopen($0, "a") } ?? nil
        
        // Execution loop
        var instructionsExecuted = 0
        var cyclesExecuted = 0
        let executionBegin = Date()
        var transmitTime = 0.0
        var transmitQueue = [Bool]()
        var receiveTime = 0.0
        var receiveQueue = [Bool]()
        var displayedLCD = ""
        while true {
            // Execute an instruction
            switch system.cpu.state {
            case .boot, .run:
                let execution = system.execute()
                instructionsExecuted += 1
                cyclesExecuted += Int(execution.instruction.cycles)
            case .wait, .stop:
                cyclesExecuted += Int(CPU6502.Instruction.NOP_impl.cycles)
            }
            
            // Keep track of the simulated time and real-time that have elapsed
            let time = Double(cyclesExecuted) / clockFrequency
            //let realtime = abs(executionBegin.timeIntervalSinceNow)
            
            // Transmit data via the ACIA
            if let aciaTransmitStream = aciaTransmitStream, transmitQueue.isEmpty {
                let c = fgetc(aciaTransmitStream)
                if c != EOF {
                    let byte = UInt8(c)
                    transmitQueue.append(contentsOf: System.bits(of: byte))
                }
            }
            if abs(transmitTime - time) > 100.0 / system.acia.baudRate.rawValue, let bit = transmitQueue.first {
                transmitQueue.removeFirst()
                system.acia.receiveBit() { bit }
                transmitTime = time
            }
            
            // Receive data via the ACIA
            if abs(receiveTime - time) > 100.0 / system.acia.baudRate.rawValue, system.acia.ts > 0 {
                var bit = false
                system.acia.transmitBit() { bit = $0 }
                receiveQueue.append(bit)
                receiveTime = time
            }
            if let aciaReceiveStream = aciaReceiveStream, receiveQueue.count >= UInt8.bitWidth {
                let bits = Array(receiveQueue[..<UInt8.bitWidth])
                receiveQueue.removeFirst(UInt8.bitWidth)
                let byte = System.bytes(of: bits)[0]
                if byte != 0 {
                    let c = Int32(byte)
                    fputc(c, aciaReceiveStream)
                    fflush(aciaReceiveStream)
                }
            }
            
            // Emit system state, if requested
            if printState {
                print("\(system.cpu.debugDescription)")
            }
            
            // Print LCD changes, if requested
            if printLCD {
                let lcd = String(decoding: system.lcd.ddram, as: UTF8.self)
                if displayedLCD != lcd {
                    displayedLCD = lcd
                    print(lcd)
                }
            }
            
            // Print instruction execution frequency
//            if instructionsExecuted % 100_000 == 0 {
//                let frequency = Double(cyclesExecuted) / abs(executionBegin.timeIntervalSinceNow)
//                print("Executed: \(instructionsExecuted) / \(cyclesExecuted)  Frequency: \(frequency / 1_000_000) MHz")
//            }
            
            // Take memory screenshots, if requested
            if screenshotFrequency > 0 && instructionsExecuted % screenshotFrequency == 0 {
                let screenshot = system.memoryPPM(start: UInt16(screenshotStartAddress), end: UInt16(screenshotEndAddress), line: UInt16(screenshotWidth))
                try screenshot.write(toFile: "\(programFile)_\(instructionsExecuted).ppm", atomically: true, encoding: .utf8)
            }
            
            // Match real-time to simulated execution time
            let simulatedTime = time * realtimeRatio
            let targetTime = executionBegin + simulatedTime
            let timeDifference = targetTime.timeIntervalSinceNow
            if timeDifference > 0.0001 {
                Thread.sleep(until: targetTime)
            }
        }
    }
}
