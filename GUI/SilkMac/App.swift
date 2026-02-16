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
    
    public func runPublished() {
        run()
        objectWillChange.send()
    }
}

// MARK: - UI

struct SystemView: View {
    @EnvironmentObject var system: System
    @State var programDisassembly: [CPU6502.Operation] = []
    @State var showCPUState: Bool = true
    @State var showVIAState: Bool = false
    @State var showLCDState: Bool = true
    @State var showControlPadState: Bool = true
    @State var showACIAState: Bool = false
    @State var showMemory: Bool = false
    @State var showVGA: Bool = true
    
    var body: some View {
        HStack {
            VStack {
                // MARK: Program Execution
                ExecutionView(programDisassembly: $programDisassembly)
                Spacer()
                
                // MARK: CPU
                Toggle("CPU 6502", isOn: $showCPUState)
                if showCPUState {
                    CPUView()
                }
                Spacer()
                
                // MARK: VIA
                Toggle("VIA 6522", isOn: $showVIAState)
                if showVIAState {
                    VIAView()
                }
                Spacer()
                
                // MARK: LCD
                Toggle("LCD HD44780", isOn: $showLCDState)
                if showLCDState {
                    LCDView()
                }
                Spacer()
                
                // MARK: Control Pad
                Toggle("Control Pad", isOn: $showControlPadState)
                if showControlPadState {
                    ControlPadView()
                }
                Spacer()
                
                // MARK: ACIA
                Toggle("ACIA 6551", isOn: $showACIAState)
                if showACIAState {
                    ACIAView()
                }
                Spacer()
                
                // MARK: Memory
                Toggle("Memory", isOn: $showMemory)
                if showMemory {
                    MemoryView()
                }
                Spacer()
            }
            .padding()
            
            // MARK: Program Disassembly
            VStack {
                ProgramView(programDisassembly: $programDisassembly)
                Toggle("VGA View", isOn: $showVGA)
                if showVGA {
                    VGAView()
                }
            }
            .padding()
        }
    }
}
