//
//  FormColorPicker.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

// Using .clear as a local non-optional proxy for nil, because ColorPicker won't
// work with optional.
// When saved, the color .clear should be assigned is nil.

public struct FormColorPicker: View {
    // MARK: - Parameters

    @Binding private var color: Color

    public init(color: Binding<Color>) {
        _color = color
    }

    // MARK: - Locals

    // MARK: - Views

    public var body: some View {
        HStack {
            #if os(watchOS)
                WColorPicker(selection: $color) {
                    Text("Color")
                }
            #elseif os(iOS)
                ColorPicker(selection: $color, supportsOpacity: false) {
                    Text("Color")
                }
            #endif
            Divider()
            Button(action: { color = .clear }) {
                Image(systemName: "xmark.circle.fill")
                    .symbolRenderingMode(.hierarchical)
            }
        }
    }
}

struct CategoryColorPicker_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var color: Color = Color(cgColor: CGColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0))
        var body: some View {
            NavigationStack {
                Form {
                    FormColorPicker(color: $color)
                }
            }
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
