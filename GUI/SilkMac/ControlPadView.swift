//
//  ControlPadView.swift
//  SilkMac
//
//  Created by Matt Stoker on 2/13/26.
//

import SwiftUI
import SilkSystem

struct ControlPadView: View {
    @EnvironmentObject var system: System
    var body: some View {
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
}
