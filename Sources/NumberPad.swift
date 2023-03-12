//
//  NumberImage.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct NumberPad<T: BinaryInteger>: View {
    @Binding private var selection: T
    private let range: ClosedRange<T>

    // MARK: - Parameters

    public init(selection: Binding<T>, range: ClosedRange<T>) {
        _selection = selection
        self.range = range

        let clamped = T(selection.wrappedValue).clamped(to: range)
        let formatted = String(format: "%d", Int(clamped))
        _value = State(initialValue: formatted)

        let upperStr = String(format: "%d", Int(range.upperBound))
        maxDigits = upperStr.count
    }

    // MARK: - Locals

    @State private var value: String
    private let maxDigits: Int

    private let horzSpace: CGFloat = 3
    private let vertSpace: CGFloat = 3

    // MARK: - Views

    public var body: some View {
        GeometryReader { geo in
            let buttonWidth = (geo.size.width / 3) - (horzSpace * 2)
            // let buttonHeight = (geo.size.height / 4) - (vertSpace * 3)
            VStack(spacing: vertSpace) {
                HStack(spacing: horzSpace) {
                    Group {
                        digit(1)
                        digit(2)
                        digit(3)
                    }
                    .frame(width: buttonWidth)
                }
                HStack(spacing: horzSpace) {
                    Group {
                        digit(4)
                        digit(5)
                        digit(6)
                    }
                    .frame(width: buttonWidth)
                }
                HStack(spacing: horzSpace) {
                    Group {
                        digit(7)
                        digit(8)
                        digit(9)
                    }
                    .frame(width: buttonWidth)
                }
                HStack(spacing: horzSpace) {
                    Group {
                        digit(nil)
                        digit(0)
                        backspace
                    }
                    .frame(width: buttonWidth)
                }
            }
        }
        .ignoresSafeArea(.all, edges: [.bottom])
        .onAppear(perform: appearAction)
    }

    private func digit(_ num: Int?) -> some View {
        Button(action: { digitAction(num) }) {
            let str: String = num != nil ? "\(num!)" : ""
            Text(str)
        }
        .buttonStyle(.plain)
        .disabled(value.count >= maxDigits)
    }

    private var backspace: some View {
        Button(action: backspaceAction) {
            Image(systemName: "delete.backward")
        }
        .buttonStyle(.plain)
        .disabled(value == "0")
    }

    // MARK: - Actions

    private func appearAction() {
        if value.count == 0 {
            forceZero()
        }
    }

    private func digitAction(_ num: Int?) {
        guard let num else { return }
        let strNum = "\(num)"
        if value == "0" {
            value = strNum
        } else {
            value.append(strNum)
        }
        refreshSelection()
        Haptics.play()
    }

    private func backspaceAction() {
        if value.count <= 1 {
            forceZero()
        } else {
            value.removeLast()
        }
        refreshSelection()
        Haptics.play()
    }

    // MARK: - Helpers

    private func refreshSelection() {
        let intValue = Int(value) ?? 0
        //TODO need to cap to range of T
        //T.init(value, format: "%d", lenient: true)
        selection = T(intValue).clamped(to: range)
    }

    private func forceZero() {
        value = "0"
    }
}

struct NumberPad_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var value: Int16 = 23423
        var body: some View {
            VStack {
                Text("\(value)")
                NumberPad(selection: $value, range: 0 ... 30000)
                    .font(.title2)
            }
            .modify {
                if #available(iOS 16.1, watchOS 9.1, *) {
                    $0.fontDesign(.monospaced)
                } else {
                    $0.monospaced()
                }
            }
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
