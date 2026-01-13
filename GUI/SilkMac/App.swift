//
//  SilkMacApp.swift
//  SilkMac
//
//  Created by Matt Stoker on 1/4/26.
//

import SwiftUI
import SilkCPU
import SilkVIA
import SilkACIA
import SilkLCD

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
    @State var programOffset: Int = 0xE000
    @State var showACIAState: Bool = true
    @State var showVIAState: Bool = true
    @State var showLCDState: Bool = true
    @State var showControlPadState: Bool = true
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
                        label: { Text("Load Program to 0x\(String(programOffset, radix: 16))") }
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
                    TextField("Program", value: $programOffset, format: .hex)
                        .frame(width: 50)
                    
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
                                label: { if let breakpoint = breakpoint { Text("Run until 0x\(String(breakpoint, radix: 16))") } else { Text("Run") } }
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
                                label: { Text("Step\(stepCount.map { " 0x\(String($0, radix: 16))" } ?? "")") }
                            )
                            TextField("Steps", value: $stepCount, format: .hex)
                                .frame(width: 50)
                        }
                        HStack {
                            Button(
                                action: {
                                    system.execute(upTo: 0x20 /*JSR*/)
                                    log += "\(system.cpu.debugDescription)\n"
                                },
                                label: { Text("Step Until Next JSR") }
                            )
                        }
                        HStack {
                            Button(
                                action: {
                                    system.execute(upTo: 0x60 /*RTS*/)
                                    system.execute()
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
                    Text("CPU 6502 State")
                        .bold()
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
                Spacer()
                
                // MARK: ACIA State
                
                Toggle("ACIA 6551 State", isOn: $showACIAState)
                if showACIAState {
                    VStack {
                        HStack {
                            Text("SR")
                            Text(String(format: "%02X", system.acia.sr))
                        }
                        HStack {
                            Text("CTL")
                            Text(String(format: "%02X", system.acia.ctl))
                        }
                        HStack {
                            Text("CMD")
                            Text(String(format: "%02X", system.acia.cmd))
                        }
                        HStack {
                            Text("TS")
                            Text(String(format: "%02X", system.acia.ts))
                        }
                        HStack {
                            Text("TDR")
                            Text(String(format: "%02X", system.acia.tdr))
                        }
                        HStack {
                            Text("TSR")
                            Text(String(format: "%02X", system.acia.tsr))
                        }
                        HStack {
                            Text("RS")
                            Text(String(format: "%02X", system.acia.rs))
                        }
                        HStack {
                            Text("RDR")
                            Text(String(format: "%02X", system.acia.rdr))
                        }
                        HStack {
                            Text("RSR")
                            Text(String(format: "%02X", system.acia.rsr))
                        }
                    }
                }
                Spacer()
                
                // MARK: VIA State
                
                Toggle("VIA 6522 State", isOn: $showVIAState)
                if showVIAState {
                    VStack {
                        HStack {
                            Text("PA")
                            Text(String(format: "%02X", system.via.pa))
                        }
                        HStack {
                            Text("PB")
                            Text(String(format: "%02X", system.via.pb))
                        }
                        HStack {
                            Text("DDRA")
                            Text(String(format: "%02X", system.via.ddra))
                        }
                        HStack {
                            Text("DDRB")
                            Text(String(format: "%02X", system.via.ddrb))
                        }
                        HStack {
                            Text("SR")
                            Text(String(format: "%02X", system.via.sr))
                        }
                        HStack {
                            Text("ACR")
                            Text(String(format: "%02X", system.via.acr))
                        }
                        HStack {
                            Text("PCR")
                            Text(String(format: "%02X", system.via.pcr))
                        }
                        HStack {
                            Text("IFR")
                            Text(String(format: "%02X", system.via.ifr))
                        }
                        HStack {
                            Text("IER")
                            Text(String(format: "%02X", system.via.ier))
                        }
                        HStack {
                            Text("T1C")
                            Text(String(format: "%04X", system.via.t1c))
                        }
                        HStack {
                            Text("T1L")
                            Text(String(format: "%04X", system.via.t1l))
                        }
                        HStack {
                            Text("T2C")
                            Text(String(format: "%04X", system.via.t2c))
                        }
                        HStack {
                            Text("T2L")
                            Text(String(format: "%04X", system.via.t2l))
                        }
                    }
                }
                Spacer()
                
                // MARK: LCD State
                
                Toggle("LCD HD44780 State", isOn: $showLCDState)
                if showLCDState {
                    VStack {
                        HStack {
                            Text("IR")
                            Text(String(format: "%02X", system.lcd.ir))
                        }
                        HStack {
                            Text("DR")
                            Text(String(format: "%02X", system.lcd.dr))
                        }
                        HStack {
                            Text("AC")
                            Text(String(format: "%02X", system.lcd.ac))
                        }
                        HStack {
                            Text("ID")
                            Text("S")
                            Text("D")
                            Text("C")
                            Text("B")
                            Text("SC")
                            }
                        HStack {
                            Text(String(format: "%@", system.lcd.id ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.s ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.d ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.c ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.b ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.sc ? "1" : "0"))
                        }
                        HStack {
                            Text("RL")
                            Text("DL")
                            Text("N")
                            Text("F")
                            Text("BUSY")
                        }
                        HStack {
                            Text(String(format: "%@", system.lcd.rl ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.dl ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.n ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.f ? "1" : "0"))
                            Text(String(format: "%@", system.lcd.busy ? "1" : "0"))
                        }
                        VStack {
                            let lineLength = 40
                            let attributes = AttributeContainer()
                                .foregroundColor(.white)
                                .backgroundColor(system.lcd.d ? .blue : .clear)
                                .font(.system(size: 8.0, design: .monospaced))
                            let line0 = String(system.lcd.ddram[0..<lineLength].map { Character(Unicode.Scalar($0)) })
                            Text(AttributedString(line0, attributes: attributes))
                            if system.lcd.n {
                                let line1 = String(system.lcd.ddram[lineLength..<(lineLength*2)].map { Character(Unicode.Scalar($0)) })
                                Text(AttributedString(line1, attributes: attributes))
                            }
                        }
                    }
                }
                Spacer()
                
                // MARK: Control Pad State
                
                Toggle("Control Pad State", isOn: $showControlPadState)
                if showControlPadState {
                    HStack {
                        Toggle(
                            isOn: .init(get: { system.controlPad.leftPressed }, set: { system.controlPad.leftPressed = $0 }),
                            label: { Text("⬅️") }
                        ).toggleStyle(.button)
                        Toggle(
                            isOn: .init(get: { system.controlPad.rightPressed }, set: { system.controlPad.rightPressed = $0 }),
                            label: { Text("➡️") }
                        ).toggleStyle(.button)
                        Toggle(
                            isOn: .init(get: { system.controlPad.upPressed }, set: { system.controlPad.upPressed = $0 }),
                            label: { Text("⬆️") }
                        ).toggleStyle(.button)
                        Toggle(
                            isOn: .init(get: { system.controlPad.downPressed }, set: { system.controlPad.downPressed = $0 }),
                            label: { Text("⬇️") }
                        ).toggleStyle(.button)
                        Toggle(
                            isOn: .init(get: { system.controlPad.actionPressed }, set: { system.controlPad.actionPressed = $0 }),
                            label: { Text("⏺️") }
                        ).toggleStyle(.button)
                    }
                }
                Spacer()
                
                // MARK: Memory State
                
                Toggle("Memory View", isOn: $showMemory)
                if showMemory {
                    Table(system.memory.indices.map { MemoryEntry(address: UInt16($0), value: system.cpu.load(UInt16($0))) }) {
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
                }
                Spacer()
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

// MARK: - ControlPad

struct ControlPad {
    var leftPressed: Bool = false
    var rightPressed: Bool = false
    var upPressed: Bool = false
    var downPressed: Bool = false
    var actionPressed: Bool = false
}

// MARK: - System

class System: ObservableObject {
    @Published var cpu: CPU6502 = CPU6502(load: { _ in 0 }, store: { _, _ in })
    @Published var via: VIA6522 = VIA6522()
    @Published var acia: ACIA6551 = ACIA6551()
    @Published var lcd: LCDHD44780 = LCDHD44780()
    @Published var controlPad: ControlPad = ControlPad()
    @Published var memory: [UInt8] = Array((0x0000...0xFFFF).map { _ in UInt8.min })
    
    init() {
        reset()
    }
    
    func reset() {
        self.memory = Array((0x0000...0xFFFF).map { _ in UInt8.random(in: 0x00...0xFF) })
        self.via = VIA6522()
        self.acia = ACIA6551()
        self.lcd = LCDHD44780()
        self.controlPad = ControlPad()
        self.cpu = CPU6502(
            load: { [weak self] address in
                switch address {
                case (0x4000...0x5FFF):
                    return self?.acia.read(address: UInt8(address & 0x0003)) ?? 0xEA
                case (0x6000...0x7FFF):
                    let viapa = self?.via.pa ?? 0b00000000
                    let viapb = self?.via.pb ?? 0b00000000
                    let lcdrs = (viapa & 0b00100000) != 0
                    let lcdrw = (viapa & 0b01000000) != 0
                    let lcde = (viapa & 0b10000000) != 0
                    var lcddata = viapb
                    if lcde {
                        self?.lcd.execute(rs: lcdrs, rw: lcdrw, data: &lcddata)
                    }
                    let paIn = UInt8(0) |
                        ((self?.controlPad.upPressed ?? false) ? 0b00000001 : 0) |
                        ((self?.controlPad.leftPressed ?? false) ? 0b00000010 : 0) |
                        ((self?.controlPad.rightPressed ?? false) ? 0b00000100 : 0) |
                        ((self?.controlPad.downPressed ?? false) ? 0b00001000 : 0) |
                        ((self?.controlPad.actionPressed ?? false) ? 0b00010000 : 0)
                    
                    return self?.via.read(address: UInt8(address & 0x000F), paIn: paIn, pbIn: 0x00) ?? 0xEA
                default:
                    return self?.memory[Int(address)] ?? 0xEA
                }
            },
            store: { [weak self] address, value in
                switch address {
                case (0x4000...0x5FFF):
                    self?.acia.write(address: UInt8(address & 0x0003), data: value)
                case (0x6000...0x7FFF):
                    self?.via.write(address: UInt8(address & 0x000F), data: value)
                    let viapa = self?.via.pa ?? 0b00000000
                    let viapb = self?.via.pb ?? 0b00000000
                    let lcdrs = (viapa & 0b00100000) != 0
                    let lcdrw = (viapa & 0b01000000) != 0
                    let lcde = (viapa & 0b10000000) != 0
                    var lcddata = viapb
                    if lcde {
                        self?.lcd.execute(rs: lcdrs, rw: lcdrw, data: &lcddata)
                    }
                default:
                    self?.memory[Int(address)] = value
                }
            }
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
    
    func execute(upTo opcode: UInt8) {
        repeat {
            cpu.execute()
        } while memory[Int(cpu.pc)] != opcode
    }
    
    func screenshot(start: UInt16, end: UInt16, line: UInt16) -> NSImage {
        let ppm = Self.memoryPPM(memory: memory, start: start, end: end, line: line)
        let image = NSImage(data: ppm.data(using: .utf8)!)!
        return image
    }
    
    static func memoryPPM(
        memory: [UInt8],
        start: UInt16,
        end: UInt16,
        line: UInt16,
        channelMaxValue: UInt8 = 3,
        valueChannelConverter: (UInt8) -> (UInt8, UInt8, UInt8) = { (($0 & 0b00000011) >> 0, ($0 & 0b00001100) >> 2, ($0 & 0b00110000) >> 4) }
    ) -> String {
        let count = Int(min(end, UInt16.max)) - Int(min(start, min(end, UInt16.max)))
        let width = Int(line)
        let height = Int((Double(count) / Double(width)).rounded(.up))
        var screenshot = ""
        screenshot.append("P3\n")
        screenshot.append("\(width) \(height)\n")
        screenshot.append("\(channelMaxValue)\n")
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = y * width + x
                let address = pixelIndex >= count ? nil : start + UInt16(pixelIndex)
                let value: UInt8 = address.map { memory[Int($0)] } ?? UInt8.min
                let (r, g, b) = valueChannelConverter(value)
                screenshot.append("\(r) \(g) \(b)\n")
            }
        }
        return screenshot
    }
}
