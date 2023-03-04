//
//  WColorPicker.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

#if os(watchOS)
    /// A simple color picker for WatchOS.
    /// For iOS just use ColorPicker.
    /// Forces to RGB color space, for simplicity. Also forces alpha channel to 1.0 (no transparency).
    public struct WColorPicker<Content: View>: View {
        @Binding private var color: Color
        private let content: () -> Content

        public init(selection: Binding<Color>,
                    @ViewBuilder content: @escaping () -> Content)
        {
            _color = selection
            self.content = content

            if let cgc = selection.wrappedValue.cgColor,
               let rgb = cgc.converted(to: CGColorSpaceCreateDeviceRGB(),
                                       intent: .defaultIntent,
                                       options: nil),
               rgb.numberOfComponents == 4,
               let components = rgb.components
            {
                _r = State(initialValue: components[0])
                _g = State(initialValue: components[1])
                _b = State(initialValue: components[2])
            } else {
                _r = State(initialValue: 0.5)
                _g = State(initialValue: 0.5)
                _b = State(initialValue: 0.5)
            }

            _a = State(initialValue: 1.0) // not dealing with opacity here
        }

        @State private var r: CGFloat
        @State private var g: CGFloat
        @State private var b: CGFloat
        @State private var a: CGFloat

        @State private var showSliders = false

        public var body: some View {
            HStack {
                content()
                Spacer()
                Circle()
                    .fill(color)
                    .overlay {
                        Circle()
                            .stroke(lineWidth: 1)
                    }
                    .frame(width: 24, height: 24)
                    .onTapGesture {
                        showSliders = true
                    }
            }
            .sheet(isPresented: $showSliders) {
                VStack {
                    Slider(value: $r, in: 0.0 ... 1.0)
                        .tint(.red)
                    Slider(value: $g, in: 0.0 ... 1.0)
                        .tint(.green)
                    Slider(value: $b, in: 0.0 ... 1.0)
                        .tint(.blue)
                    HStack {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(color)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(userSelected)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showSliders = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            color = userSelected
                            showSliders = false
                        }
                    }
                }
                .ignoresSafeArea(.all, edges: [.bottom])
            }
        }

        private var userSelected: Color {
            Color(cgColor: CGColor(red: r, green: g, blue: b, alpha: a))
        }
    }

    struct WColorPicker_Previews: PreviewProvider {
        struct TestHolder: View {
            @State var color: Color = Color(cgColor: CGColor(genericCMYKCyan: 0.8, magenta: 0.2, yellow: 0.5, black: 0.1, alpha: 1.0))
            var body: some View {
                NavigationStack {
                    Form {
                        WColorPicker(selection: $color) {
                            Text("Color")
                            Spacer()
                        }
                    }
                }
            }
        }

        static var previews: some View {
            TestHolder()
                .accentColor(.orange)
        }
    }

#endif
