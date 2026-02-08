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
import SilkSystem

// MARK: - App

@main
struct SilkMacApp: App {
    var body: some Scene {
        WindowGroup {
            SystemView().environmentObject(System())
        }
    }
}

extension System: @retroactive ObservableObject {
    public func executePublished(count: Int = 1) {
        execute(count: count)
        objectWillChange.send()
    }
    
    public func executePublished(until breakpoint: UInt16) {
        repeat {
            cpu.execute()
            objectWillChange.send()
        } while cpu.pc != breakpoint
    }
    
    public func executePublished(upTo opcode: UInt8) {
        repeat {
            cpu.execute()
            objectWillChange.send()
        } while cpu.load(cpu.pc) != opcode
    }
}

// MARK: - UI

struct SystemView: View {
    @EnvironmentObject var system: System
    @State var programImporterShowing = false
    @State var programFile: URL?
    @State var programOffset: Int = 0xE000
    @State var programDisassembly: [CPU6502.Operation] = []
    @State var videoStart: UInt16? = 0x2000
    @State var videoEnd: UInt16? = 0x4000
    @State var videoLine: UInt16? = 0x80
    @State var stepCount: Int? = nil
    @State var stepTimer: Timer? = nil
    @State var breakpoint: UInt16? = nil
    @State var log: String = ""
    @State var showACIAState: Bool = true
    @State var aciaReceiveTimer: Timer? = nil
    @State var aciaDataReceiveQueue: String = ""
    @State var aciaTransmitTimer: Timer? = nil
    @State var aciaDataTransmitQueue: String = ""
    @State var showVIAState: Bool = false
    @State var showLCDState: Bool = true
    @State var showControlPadState: Bool = true
    @State var showMemory: Bool = false
    @State var showVideo: Bool = true
    
    var body: some View {
        HStack {
            VStack {
                TextEditor(text: $log)
                    .font(.system(size: 12.0, design: .monospaced))
                ScrollViewReader { proxy in
                    Table(programDisassembly) {
                        TableColumn("Addr") {
                            Text(String(format: "%04X\($0.address == system.cpu.pc ? "*" : "")", $0.address))
                        }
                        .width(44.0)
                        TableColumn("Inst") {
                            Text($0.instruction.name)
                        }
                        .width(40.0)
                        TableColumn("OL") {
                            Text($0.oper.map { String(format: "%02X", $0) } ?? "--")
                        }
                        .width(22.0)
                        TableColumn("OH") {
                            Text($0.operWideHigh.map { String(format: "%02X", $0) } ?? "--")
                        }
                        .width(22.0)
                    }
                    .onChange(of: system.cpu.pc) { newValue, _ in
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
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
                            
                            programDisassembly = CPU6502.disassemble(program: program, offset: UInt16(programOffset))
                            
                            system.program(data: program, startingAt: UInt16(programOffset))
                            system.executePublished()
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
                                        system.executePublished(until: breakpoint)
                                        log += "\(system.cpu.debugDescription)\n"
                                    } else {
                                        stepTimer = Timer.scheduledTimer(withTimeInterval: 0.0001, repeats: true) { _ in
                                            system.executePublished()
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
                                    system.executePublished(count: stepCount ?? 1)
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
                                    system.executePublished(upTo: CPU6502.Instruction.JSR_abs.opcode)
                                    log += "\(system.cpu.debugDescription)\n"
                                },
                                label: { Text("Step Until Next JSR") }
                            )
                        }
                        HStack {
                            Button(
                                action: {
                                    system.executePublished(upTo: CPU6502.Instruction.RTS_impl.opcode)
                                    system.executePublished()
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
                            system.objectWillChange.send()
                            aciaDataReceiveQueue = ""
                            aciaDataTransmitQueue = ""
                            programDisassembly = []
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
                        Toggle(
                            isOn: .init(
                                get: { aciaReceiveTimer != nil },
                                set: { on in
                                    if on {
                                        aciaReceiveTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                            guard let character = aciaDataReceiveQueue.first else { return }
                                            aciaDataReceiveQueue.removeFirst()
                                            var receiveQueue = System.bits(of: String(character))
                                            while !receiveQueue.isEmpty {
                                                let bit = receiveQueue[0]
                                                receiveQueue.removeFirst()
                                                system.acia.receiveBit() { bit }
                                            }
                                        }
                                    } else {
                                        aciaReceiveTimer?.invalidate()
                                        aciaReceiveTimer = nil
                                    }
                                }
                            ),
                            label: { Text("Remote Transmitting") }
                        )
                        TextField("Empty", text: $aciaDataReceiveQueue)
                            .frame(width: 200)
                        Toggle(
                            isOn: .init(
                                get: { aciaTransmitTimer != nil },
                                set: { on in
                                    if on {
                                        aciaTransmitTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                                            var transmitQueue: [Bool] = []
                                            for _ in 0..<UInt8.bitWidth {
                                                var bit = false
                                                system.acia.transmitBit() { bit = $0 }
                                                transmitQueue.append(bit)
                                            }
                                            let bits = Array(transmitQueue[..<UInt8.bitWidth])
                                            transmitQueue.removeFirst(UInt8.bitWidth)
                                            let byte = System.string(of: bits)
                                            aciaDataTransmitQueue.append(byte)
                                        }
                                    } else {
                                        aciaTransmitTimer?.invalidate()
                                        aciaTransmitTimer = nil
                                    }
                                }
                            ),
                            label: { Text("Remote Receiving") }
                        )
                        TextField("Empty", text: $aciaDataTransmitQueue)
                            .frame(width: 200)
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
                    Table((0x0000...0xFFFF).map { MemoryEntry(address: UInt16($0), value: system.cpu.load(UInt16($0))) }) {
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

// MARK: - Memory Entry

struct MemoryEntry: Identifiable {
    var address: UInt16
    var value: UInt8
    var id: Int { Int(address) }
}

extension CPU6502.Operation: @retroactive Identifiable {
    public var id: Int { Int(address) }
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

// MARK: - Screenshot

extension System {
    func screenshot(start: UInt16, end: UInt16, line: UInt16) -> NSImage {
        let ppm = memoryPPM(start: start, end: end, line: line)
        let image = NSImage(data: ppm.data(using: .utf8)!)!
        return image
    }
}
