//
//  BaseSettingsForm.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

public struct BaseSettingsForm<Content: View>: View {
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Parameters

    private let onRestoreToDefaults: () -> Void
    private let content: () -> Content

    public init(onRestoreToDefaults: @escaping () -> Void = {},
                @ViewBuilder content: @escaping () -> Content)
    {
        self.onRestoreToDefaults = onRestoreToDefaults
        self.content = content
    }

    // MARK: - Locals

    #if os(iOS)
        @AppStorage(colorSchemeModeKey) var colorSchemeMode: ColorSchemeMode = .automatic
    #endif

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: BaseSettingsForm<Content>.self))

    @State private var showRestoreDialog = false

    // MARK: - Views

    public var body: some View {
        Form {
            content()

            #if os(iOS)
                ColorSchemePicker()
            #endif

            #if os(watchOS)
                restoreButton
                    .foregroundStyle(.tint)
            #endif
        }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .destructiveAction) {
                restoreButton
            }
        }
        #endif
        .onDisappear(perform: disappearAction)
        .navigationTitle("Settings")
        .confirmationDialog("",
                            isPresented: $showRestoreDialog,
                            actions: {
                                Button("Restore", role: .destructive, action: restoreAction)
                            },
                            message: {
                                Text("Restore to default settings?")
                            })
    }

    private var restoreButton: some View {
        Button(action: {
            Haptics.play(.warning)
            showRestoreDialog = true

        }) {
            Text("Restore to defaults")
        }
    }

    // MARK: - Actions

    private func restoreAction() {
        #if os(iOS)
            colorSchemeMode = .automatic
        #endif

        onRestoreToDefaults() // continue up the chain
    }

    private func disappearAction() {
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }
}

struct SettingsForm_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            BaseSettingsForm(onRestoreToDefaults: {})
                { Text("other settings") }
                .accentColor(.orange)
        }
    }
}
