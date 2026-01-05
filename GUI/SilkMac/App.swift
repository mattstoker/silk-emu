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
    @State var stepCount: Int = 1
    @State var stepTimer: Timer? = nil
    @State var log: String = ""
    @EnvironmentObject var system: System
    
    struct MemoryEntry: Identifiable {
        var address: UInt16
        var value: UInt8
        var id: Int { Int(address) }
    }
    
    var body: some View {
        HStack {
            TextEditor(text: $log)
                .disabled(true)
            VStack {
                // MARK: Program
                
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
                    }
                }
                
                // MARK: Execution
                
                if system.cpu.state == .run {
                    if stepTimer == nil {
                        Button(
                            action: {
                                system.execute(count: stepCount)
                                log += "\(system.cpu.debugDescription)\n"
                            },
                            label: { Text("Step \(stepCount)") }
                        )
                        TextField("Count", value: $stepCount, formatter: NumberFormatter())
                            .frame(width: 50)
                        Button(
                            action: {
                                log = ""
                                stepTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                                    system.execute()
                                }
                            },
                            label: { Text("Run") }
                        )
                    } else {
                        Button(
                            action: {
                                stepTimer?.invalidate()
                                stepTimer = nil
                            },
                            label: { Text("Pause") }
                        )
                    }
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
                }
                Toggle("Video View", isOn: $showVideo)
                if showVideo {
                    Image(nsImage: system.screenshot())
                }
            }
            .padding()
        }
    }
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
            pc: cpu.pc,
            ac: cpu.ac,
            xr: cpu.xr,
            yr: cpu.yr,
            sr: cpu.sr,
            sp: cpu.sp,
            state: cpu.state,
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
    
    func screenshot() -> NSImage {
        let ppm = Self.screenshot(cpu: cpu, start: 0x2000, end: 0x4000, width: 0x80)
        let image = NSImage(data: ppm.data(using: .utf8)!)!
        return image
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
