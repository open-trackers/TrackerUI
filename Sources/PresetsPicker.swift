//
//  PresetsPicker.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Collections
import os
import SwiftUI

import TrackerLib

public struct PresetsPicker<Key, NamedValue, Label>: View
    where Key: Hashable & CustomStringConvertible, NamedValue: Hashable & NameablePreset, Label: View
{
    public typealias PresetsDictionary = OrderedDictionary<Key, [NamedValue]>
    // [String: [NamedValue]]

    public typealias OnSelect = (Key, NamedValue) -> Void

    // MARK: - Parameters

    private let presets: PresetsDictionary
    @Binding private var showPresets: Bool
    private let onSelect: OnSelect
    private let label: (NamedValue) -> Label

    public init(presets: PresetsPicker.PresetsDictionary,
                showPresets: Binding<Bool>,
                onSelect: @escaping OnSelect,
                label: @escaping (NamedValue) -> Label)
    {
        self.presets = presets
        _showPresets = showPresets
        self.onSelect = onSelect
        self.label = label
    }

    // MARK: - Views

    public var body: some View {
        List {
            ForEach(presets.keys, id: \.self) { key in // .sorted(by: <)
                Section(header: Text(key.description)) {
                    ForEach(presets[key]!, id: \.self) { value in // .sorted(by: <)
                        Button {
                            onSelect(key, value)
                            showPresets = false
                        } label: {
                            label(value)
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { self.showPresets = false }
            }
        }
    }
}

struct PresetsPicker_Previews: PreviewProvider {
    struct TestHolder: View {
        let presets: OrderedDictionary = [
            "Machine/Free Weights": [
                "Abdominal",
                "Arm Curl",
                "Arm Ext",
            ],
            "Bodyweight": [
                "Crunch",
                "Jumping-jack",
                "Jump",
            ],
        ]

        @State var showPresets = false
        var body: some View {
            NavigationStack {
                PresetsPicker(presets: presets, showPresets: $showPresets) {
                    print("\(#function): Selected \($0) \($1)")
                } label: {
                    Text($0.title)
                }
            }
        }
    }

    static var previews: some View {
        TestHolder()
    }
}
