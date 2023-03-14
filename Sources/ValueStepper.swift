//
//  ValueStepper.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import TrackerLib

public struct ValueStepper<T>: View
    where T: Numeric & Comparable & _FormatSpecifiable & Strideable
{
    // MARK: - Parameters

    @Binding private var value: T
    private let range: ClosedRange<T>
    private let step: T.Stride
    private let specifier: String
    private let ifZero: String?
    private let multiplier: T
    private let maxFontSize: CGFloat
    private let forceFocus: Bool

    public init(value: Binding<T>,
                in range: ClosedRange<T>,
                step: T.Stride,
                specifier: String,
                ifZero: String? = nil,
                multiplier: T = 1,
                maxFontSize: CGFloat = 24,
                forceFocus: Bool = false)
    {
        _value = value
        self.range = range
        self.step = step
        self.specifier = specifier
        self.ifZero = ifZero
        self.multiplier = multiplier
        self.maxFontSize = maxFontSize
        self.forceFocus = forceFocus
    }

    // MARK: - Locals

    // used to force focus for digital crown, assuming it's the only stepper in (detail) view
    @FocusState private var focusedField: Bool

    // MARK: - Views

    public var body: some View {
        Stepper(value: $value, in: range, step: step) {
            textValue(value)
                .font(.system(size: maxFontSize))
                .minimumScaleFactor(0.1)
                .lineLimit(1)
            #if os(watchOS)
                .modify {
                    if #available(iOS 16.1, watchOS 9.1, *) {
                        $0.fontDesign(.rounded)
                    } else {
                        $0
                    }
                }
            #endif
        }
        .focused($focusedField)
        .onAppear {
            guard forceFocus else { return }
            focusedField = true
        }
    }

    @ViewBuilder
    private func textValue(_ value: T) -> some View {
        if let ifZero, value == 0 {
            Text(ifZero)
                .padding(.horizontal)
        } else {
            Text("\(value * multiplier, specifier: specifier)")
        }
    }
}

struct ValueStepper_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var value: Double = 0.3
        var body: some View {
            VStack {
                ValueStepper(value: $value, in: 0 ... 100, step: 0.1, specifier: "%0.1f cal", ifZero: "-")
                Form {
                    ValueStepper(value: $value, in: 0 ... 100, step: 0.1, specifier: "%0.1f g", ifZero: "none")
                    ValueStepper(value: $value, in: 0 ... 1, step: 0.001, specifier: "%0.1f%%", multiplier: 100)
                }
            }
        }
    }

    static var previews: some View {
        TestHolder()
    }
}
