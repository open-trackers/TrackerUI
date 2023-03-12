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
    private let minButtonWidth: CGFloat
    private let label: (T) -> Label
    private let onLongPress: ((T) -> Void)?
    private let onShortPress: (T) -> Void

    public init(values: [T],
                minButtonWidth: CGFloat,
                label: @escaping (T) -> Label,
                onLongPress: ((T) -> Void)? = { _ in },
                onShortPress: @escaping (T) -> Void)
    {
        self.values = values
        self.minButtonWidth = minButtonWidth
        self.label = label
        self.onLongPress = onLongPress
        self.onShortPress = onShortPress
    }

    // MARK: - Locals

    private let columnSpacing: CGFloat = 5
    private let rowSpacing: CGFloat = 5

    private var gridItems: [GridItem] { [
        GridItem(.adaptive(minimum: minButtonWidth),
                 spacing: columnSpacing),
    ] }

    public var body: some View {
        LazyVGrid(columns: gridItems, spacing: rowSpacing) {
            if let onLongPress {
                ForEach(values, id: \.self) { amount in
                    Button(action: {}, label: { myLabel(amount) })
                        .simultaneousGesture(
                            LongPressGesture()
                                .onEnded { _ in
                                    onLongPress(amount)
                                }
                        )
                        .highPriorityGesture(
                            TapGesture()
                                .onEnded { _ in
                                    onShortPress(amount)
                                }
                        )
                }
            } else {
                ForEach(values, id: \.self) { amount in
                    Button(action: {
                        withAnimation {
                            onShortPress(amount)
                        }
                    }) {
                        myLabel(amount)
                    }
                }
            }
        }
        .buttonStyle(.bordered)
    }

    private func myLabel(_ amount: T) -> some View {
        label(amount)
            .lineLimit(1)
            .frame(maxWidth: .infinity)
    }
}

struct PresetValues_Previews: PreviewProvider {
    static var previews: some View {
        Form {
            PresetValues(values: [10, 20, 30],
                         minButtonWidth: 100,
                         label: { Text("\($0)") }) { _ in }
        }
    }
}
