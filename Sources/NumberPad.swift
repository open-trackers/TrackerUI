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

public struct NumberPad: View {
    @Binding private var selection: Int
    private let maxDigits: Int

    // MARK: - Parameters

    public init(selection: Binding<Int>, maxDigits: Int = 9, locale _: Locale = .current) {
        _selection = selection
        self.maxDigits = maxDigits

        _value = State(initialValue: String(format: "%d", selection.wrappedValue))
    }

    // MARK: - Locals

    @State private var value: String

    private var horzSpace: CGFloat = 3
    private var vertSpace: CGFloat = 3

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
    }

    private func backspaceAction() {
        if value.count <= 1 {
            forceZero()
        } else {
            value.removeLast()
        }
        refreshSelection()
    }

    // MARK: - Helpers

    private func refreshSelection() {
        selection = Int(value) ?? 0
    }

    private func forceZero() {
        value = "0"
    }
}

struct NumberPad_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var value: Int = 23423
        var body: some View {
            VStack {
                Text("\(value)")
                NumberPad(selection: $value, maxDigits: 6)
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
