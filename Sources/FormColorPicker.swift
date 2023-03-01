//
//  ServingColorPicker.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

// Using .clear as a local non-optional proxy for nil, because picker won't
// work with optional.
// When saved, the color .clear should be assigned is nil.

public struct FormColorPicker: View {
    // MARK: - Parameters

    @Binding private var color: Color

    public init(color: Binding<Color>) {
        _color = color
    }

    // MARK: - Locals

    #if os(watchOS)
        private let colors: [Color] = [
            .red, .orange, .yellow, .green, .mint, .teal, .cyan, .blue, .indigo, .purple, .pink, .brown, .gray, .clear,
        ]
    #endif

    // MARK: - Views

    public var body: some View {
        #if os(watchOS)
            Picker(selection: $color) {
                ForEach(colors, id: \.self) {
                    let str = String(describing: $0)
                    Text(str != "clear" ? str : "(none)")
                        .foregroundColor($0 != .clear ? $0 : .white)
                        .tag($0)
                }
            } label: {
                Text("Color")
            }
        #elseif os(iOS)
            HStack {
                ColorPicker(selection: $color, supportsOpacity: false) {
                    Text("Color")
                }
                Divider()
                Button(action: { color = .clear }) {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                }
            }
        #endif
    }
}

struct CategoryColorPicker_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var color: Color = .green
        var body: some View {
            Form {
                FormColorPicker(color: $color)
            }
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
