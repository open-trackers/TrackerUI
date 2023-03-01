//
//  TextFieldWithPresets.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Collections
import SwiftUI

import TrackerLib

public struct TextFieldWithPresets<PresetGroupKey, NamedValue, Label>: View
    where PresetGroupKey: Hashable & CustomStringConvertible,
    NamedValue: Hashable & NameablePreset,
    Label: View
{
    public typealias PresetsType = PresetsPicker<PresetGroupKey, NamedValue, Label>.PresetsDictionary

    public typealias PresetsOnSelect = (PresetGroupKey, NamedValue) -> Void

    public typealias PresetsLabel = (NamedValue) -> Label

    // MARK: - Parameters

    @Binding private var namedValue: NamedValue
    private let prompt: String
    private let presets: PresetsType
    private let onSelect: PresetsOnSelect
    private let label: PresetsLabel

    public init(_ namedValue: Binding<NamedValue>,
                prompt: String,
                presets: PresetsType,
                onSelect: @escaping PresetsOnSelect,
                label: @escaping PresetsLabel)
    {
        _namedValue = namedValue
        self.prompt = prompt
        self.presets = presets
        self.onSelect = onSelect
        self.label = label
    }

    // MARK: - Locals

    @State private var showPresetNames = false

    // MARK: - Views

    public var body: some View {
        HStack {
            TextField(text: $namedValue.title,
                      prompt: Text(prompt),
                      axis: .vertical) { EmptyView() }
            Button(action: {
                showPresetNames = true
            }) {
                Image(systemName: "line.3.horizontal.decrease")
                    .imageScale(.large)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.tint)
            }
            .buttonStyle(.borderless)
        }
        .font(.title3)
        .sheet(isPresented: $showPresetNames) {
            NavigationStack {
                PresetsPicker(presets: presets,
                              showPresets: $showPresetNames,
                              onSelect: { groupKey, presetValue in
                                  // set the hard-coded name from the preset
                                  namedValue.title = presetValue.title
                                  onSelect(groupKey, presetValue)
                              },
                              label: label)
            }
            .interactiveDismissDisabled() // NOTE: needed to prevent home button from dismissing sheet
        }
    }
}

struct TextFieldWithPresets_Previews: PreviewProvider {
    struct TestHolder: View {
        let presets: OrderedDictionary = [
            "Machine/Free Weights": [
                "Abdominal",
                "Arm Curl",
            ],
            "Bodyweight": [
                "Crunch",
                "Jumping-jack",
            ],
        ]
        @State var name: String = "Back & Bicep and many other things"
        var body: some View {
            Form {
                TextFieldWithPresets($name, prompt: "Enter name", presets: presets) { _, _ in

                } label: {
                    Text($0)
                }
            }
            .padding()
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
