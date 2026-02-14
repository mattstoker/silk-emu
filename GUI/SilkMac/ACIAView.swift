//
//  ACIAView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkACIA
import SilkSystem

struct ACIAView: View {
    @EnvironmentObject var system: System
    @State var aciaReceiveTimer: Timer? = nil
    @State var aciaDataReceiveQueue: String = ""
    @State var aciaTransmitTimer: Timer? = nil
    @State var aciaDataTransmitQueue: String = ""
    var body: some View {
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
}
