//
//  SilkMacApp.swift
//  SilkMac
//
//  Created by Matt Stoker on 1/4/26.
//

import SwiftUI
import SilkCPU

// MARK: - App

@main
struct SilkMacApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(System())
        }
    }
}

// MARK: - UI

struct ContentView: View {
    @State var programImporterShowing = false
    @State var programFile: URL?
    @State var programOffset: Int = 0xE000 // TODO: UI
    @State var showMemory: Bool = false
    @State var showVideo: Bool = true
    @State var videoStart: UInt16? = 0x2000
    @State var videoEnd: UInt16? = 0x4000
    @State var videoLine: UInt16? = 0x80
    @State var stepCount: Int? = nil
    @State var stepTimer: Timer? = nil
    @State var breakpoint: UInt16? = nil
    @State var log: String = ""
    @EnvironmentObject var system: System
    
    struct MemoryEntry: Identifiable {
        var address: UInt16
        var value: UInt8
        var id: Int { Int(address) }
    }
    
    var body: some View {
        HStack {
            VStack {
                TextEditor(text: $log)
                    .font(.system(size: 12.0, design: .monospaced))
                HStack {
                    Toggle("Video View", isOn: $showVideo)
                    TextField("Start", value: $videoStart, format: .hex).frame(width: 50)
                    TextField("End", value: $videoEnd, format: .hex).frame(width: 50)
                    TextField("Line", value: $videoLine, format: .hex).frame(width: 50)
                }
                if showVideo, let start = videoStart, let end = videoEnd, let line = videoLine {
                    let screenshot = system.screenshot(start: start, end: end, line: line)
                    Image(nsImage: screenshot)
                        .interpolation(.none)
                        .resizable(resizingMode: .stretch)
                        .frame(idealWidth: screenshot.size.width * 16, idealHeight: screenshot.size.height * 16)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .padding()
            VStack {
                // MARK: Program Execution
                switch system.cpu.state {
                case .boot, .stop:
                    Button(
                        action: { programImporterShowing = true },
                        label: { Text("Load Program") }
                    )
                    .fileImporter(isPresented: $programImporterShowing, allowedContentTypes: [.data]) { result in
                        switch result {
                        case .failure(let error):
                            print(error)
                        case .success(let url):
                            programFile = url
                            guard let programData = try? Data(contentsOf: url) else {
                                print("Couldn't open program \(url)")
                                return
                            }
                            var program: [UInt8] = Array(repeating: 0x00, count: programData.count)
                            programData.copyBytes(to: &program, count: min(program.count, programData.count))
                            
                            system.load(data: program, startingAt: UInt16(programOffset))
                            log += "\(system.cpu.debugDescription)\n"
                        }
                    }
                case .run:
                    if stepTimer == nil {
                        HStack {
                            Button(
                                action: {
                                    if let breakpoint = breakpoint {
                                        system.execute(until: breakpoint)
                                        log += "\(system.cpu.debugDescription)\n"
                                    } else {
                                        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                                            system.execute()
                                        }
                                        log = ""
                                    }
                                },
                                label: { if let breakpoint = breakpoint { Text("Run until \(breakpoint)") } else { Text("Run") } }
                            )
                            TextField("Break", value: $breakpoint, format: .hex)
                                .frame(width: 50)
                        }
                        HStack {
                            Button(
                                action: {
                                    system.execute(count: stepCount ?? 1)
                                    log += "\(system.cpu.debugDescription)\n"
                                },
                                label: { Text("Step\(stepCount.map { " 0x\($0)" } ?? "")") }
                            )
                            TextField("Steps", value: $stepCount, format: .hex)
                                .frame(width: 50)
                        }
                        HStack {
                            Button(
                                action: {
                                    system.execute(after: 0x60 /*RTS*/)
                                    log += "\(system.cpu.debugDescription)\n"
                                },
                                label: { Text("Step After Next RTS") }
                            )
                        }
                    } else {
                        Button(
                            action: {
                                stepTimer?.invalidate()
                                stepTimer = nil
                                log += "\(system.cpu.debugDescription)\n"
                            },
                            label: { Text("Pause") }
                        )
                    }
                case .wait:
                    Button(
                        action: { system.cpu.resume() },
                        label: { Text("Resume") }
                    )
                }
                
                // MARK: CPU State
                
                VStack {
                    HStack {
                        Text("PC")
                        Text(String(format: "%04X", system.cpu.pc))
                    }
                    HStack {
                        Text("AC")
                        Text(String(format: "%02X", system.cpu.ac))
                    }
                    HStack {
                        Text("XR")
                        Text(String(format: "%02X", system.cpu.xr))
                    }
                    HStack {
                        Text("YR")
                        Text(String(format: "%02X", system.cpu.yr))
                    }
                    HStack {
                        Text("SR")
                        Text(String(format: "%02X", system.cpu.sr))
                    }
                    HStack {
                        Text("SP")
                        Text(String(format: "%02X", system.cpu.sp))
                    }
                    HStack {
                        Text("State")
                        Text(String(describing: system.cpu.state))
                    }
                }
                switch system.cpu.state {
                case .boot, .stop:
                    HStack { }
                case .run, .wait:
                    Button(
                        action: {
                            system.reset()
                            log = ""
                        },
                        label: { Text("Reset") }
                    )
                }
                
                // MARK: Memory State
                
                Toggle("Memory View", isOn: $showMemory)
                if showMemory {
                    Table(system.memory.indices.map { MemoryEntry(address: UInt16($0), value: system.memory[$0]) }) {
                        TableColumn("Addr") {
                            Text(String(format: "%04X", $0.address))
                        }
                        .width(40.0)
                        TableColumn("D") {
                            Text(String(format: "%02X", $0.value))
                        }
                        .width(20.0)
                    }
                    .frame(width: 130.0)
                } else {
                    Spacer()
                }
            }
            .padding()
        }
    }
}

// MARK: - Hex Formatter

public struct HexFormatter<T>: ParseableFormatStyle where T: FixedWidthInteger {
    public func format(_ value: T) -> String {
        String(value, radix: 16).uppercased()
    }
    
    public struct Strategy: SwiftUI.ParseStrategy {
        public func parse(_ value: String) throws -> T {
            guard let result = T(value, radix: 16) else { throw Error.conversionError }
            return result
        }
        
        public enum Error: Swift.Error {
            case conversionError
        }
        
        public typealias ParseInput = String
        public typealias ParseOutput = T
    }
    
    public typealias FormatInput = Strategy.ParseOutput
    public typealias FormatOutput = Strategy.ParseInput
    
    public var parseStrategy: Strategy { Strategy() }
}

extension FormatStyle where Self == IntegerFormatStyle<UInt> {
    public static var hex: HexFormatter<UInt> { HexFormatter<UInt>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt8> {
    public static var hex: HexFormatter<UInt8> { HexFormatter<UInt8>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt16> {
    public static var hex: HexFormatter<UInt16> { HexFormatter<UInt16>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt32> {
    public static var hex: HexFormatter<UInt32> { HexFormatter<UInt32>() }
}
extension FormatStyle where Self == IntegerFormatStyle<UInt64> {
    public static var hex: HexFormatter<UInt64> { HexFormatter<UInt64>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int> {
    public static var hex: HexFormatter<Int> { HexFormatter<Int>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int8> {
    public static var hex: HexFormatter<Int8> { HexFormatter<Int8>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int16> {
    public static var hex: HexFormatter<Int16> { HexFormatter<Int16>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int32> {
    public static var hex: HexFormatter<Int32> { HexFormatter<Int32>() }
}
extension FormatStyle where Self == IntegerFormatStyle<Int64> {
    public static var hex: HexFormatter<Int64> { HexFormatter<Int64>() }
}

// MARK: - System

class System: ObservableObject {
    @Published var cpu: CPU6502 = CPU6502(load: { _ in 0 }, store: { _, _ in })
    @Published var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.min })
    
    init() {
        reset()
    }
    
    func reset() {
        self.memory = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
        self.cpu = CPU6502(
            load: { [weak self] address in return self?.memory[Int(address)] ?? 0xEA },
            store: { [weak self] address, value in self?.memory[Int(address)] = value }
        )
    }
    
    func load(data: [UInt8], startingAt offset: UInt16) {
        reset()
        // TODO: What if data is too large or offset causes overlap?
        for index in data.indices {
            memory[Int(offset + UInt16(index))] = data[index]
        }
        cpu.execute()
    }
    
    func execute(count: Int = 1) {
        for _ in 0..<count {
            cpu.execute()
        }
    }
    
    func execute(until breakpoint: UInt16) {
        repeat {
            cpu.execute()
        } while cpu.pc != breakpoint
    }
    
    func execute(after opcode: UInt8) {
        repeat {
            cpu.execute()
        } while memory[Int(cpu.pc)] != opcode
        cpu.execute()
    }
    
    func screenshot(start: UInt16, end: UInt16, line: UInt16) -> NSImage {
        let ppm = Self.memoryPPM(cpu: cpu, start: start, end: end, line: line)
        let image = NSImage(data: ppm.data(using: .utf8)!)!
        return image
    }
    
    static func memoryPPM(
        cpu: CPU6502,
        start: UInt16,
        end: UInt16,
        line: UInt16,
        channelMaxValue: UInt8 = 3,
        valueChannelConverter: (UInt8) -> (UInt8, UInt8, UInt8) = { (($0 & 0b00000011) >> 0, ($0 & 0b00001100) >> 2, ($0 & 0b00110000) >> 4) }
    ) -> String {
        let count = Int(min(end, UInt16.max)) + 1 - Int(min(start, min(end, UInt16.max)))
        let width = Int(line)
        let height = count / width
        var screenshot = ""
        screenshot.append("P3\n")
        screenshot.append("\(width) \(height)\n")
        screenshot.append("\(channelMaxValue)\n")
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let address = pixelIndex > count ? nil : start + UInt16(pixelIndex)
                let value: UInt8 = address.map { cpu.load($0) } ?? UInt8.min
                let (r, g, b) = valueChannelConverter(value)
                screenshot.append("\(r) \(g) \(b)\n")
            }
        }
        return screenshot
    }
}
