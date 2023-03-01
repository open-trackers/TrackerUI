//
//  PresetValues.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct PresetValues<T: Numeric & Hashable, Label: View>: View {
    private let values: [T]
    private let label: (T) -> Label
    private let onSelect: (T) -> Void

    public init(values: [T],
                label: @escaping (T) -> Label,
                onSelect: @escaping (T) -> Void)
    {
        self.values = values
        self.label = label
        self.onSelect = onSelect
    }

    // MARK: - Locals

    private let columnSpacing: CGFloat = 5
    private let rowSpacing: CGFloat = 5

    private var gridItems: [GridItem] { [
        GridItem(.adaptive(minimum: 100),
                 spacing: columnSpacing),
    ] }

    public var body: some View {
        LazyVGrid(columns: gridItems, spacing: rowSpacing) {
            ForEach(values, id: \.self) { amount in
                Button(action: {
                    withAnimation {
                        onSelect(amount)
                    }
                }) {
                    label(amount)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .buttonStyle(.bordered)
    }
}

struct PresetValues_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            PresetValues(values: [10, 20, 30], label: { Text("\($0)") }) { _ in }
        }
    }
}
