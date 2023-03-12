//
//  NumberPad.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct NumberPad<T: FixedWidthInteger>: View {
    @Binding private var selection: T
    private let upperBound: T
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat

    // MARK: - Parameters

    public init(selection: Binding<T>, upperBound: T,
                horizontalSpacing: CGFloat = 3,
                verticalSpacing: CGFloat = 3)
    {
        _selection = selection
        self.upperBound = upperBound
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing

        let clamped = min(T(selection.wrappedValue), upperBound)
        let formatted = String(format: "%d", Int(clamped))
        _value = State(initialValue: formatted)

        let upperStr = String(format: "%d", Int(upperBound))
        maxDigits = upperStr.count
    }

    // MARK: - Locals

    @State private var value: String
    private let maxDigits: Int

    // MARK: - Views

    public var body: some View {
        VStack(spacing: verticalSpacing) {
            HStack(spacing: horizontalSpacing) {
                Group {
                    digit(1)
                    digit(2)
                    digit(3)
                }
            }
            HStack(spacing: horizontalSpacing) {
                Group {
                    digit(4)
                    digit(5)
                    digit(6)
                }
            }
            HStack(spacing: horizontalSpacing) {
                Group {
                    digit(7)
                    digit(8)
                    digit(9)
                }
            }
            HStack(spacing: horizontalSpacing) {
                Group {
                    digit(nil)
                    digit(0)
                    backspace
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear(perform: appearAction)
        // .border(.red)
    }

    private func digit(_ num: Int?) -> some View {
        Button(action: { digitAction(num) }) {
            let str: String = num != nil ? "\(num!)" : ""
            Text(str)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .modify {
            if num == nil {
                $0.hidden()
            } else {
                $0
            }
        }
        .disabled(value.count >= maxDigits)
    }

    private var backspace: some View {
        Button(action: {}) {
            Image(systemName: "delete.backward.fill")
                .imageScale(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(value == "0")
        .buttonStyle(.plain)
        .simultaneousGesture(
            LongPressGesture()
                .onEnded { _ in
                    clearAction()
                }
        )
        .highPriorityGesture(
            TapGesture()
                .onEnded { _ in
                    backspaceAction()
                }
        )
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

    private func clearAction() {
        forceZero()
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
        let maxValue = Int(T.max)
        selection = min(upperBound, T(min(maxValue, intValue)))
        value = "\(selection)"
    }

    private func forceZero() {
        value = "0"
    }
}

struct NumberPad_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var value: Int16 = 2333
        #if os(watchOS)
            let horz: CGFloat = 3
            let vert: CGFloat = 3
        #elseif os(iOS)
            let horz: CGFloat = 20
            let vert: CGFloat = 10
        #endif
        var body: some View {
            VStack {
                #if os(watchOS)
                    Text("\(value)")
                #elseif os(iOS)
                    GroupBox {
                        Text("\(value)")
                    } label: {
                        Text("Calories")
                    }
                #endif
                NumberPad(selection: $value, upperBound: 30000, horizontalSpacing: horz, verticalSpacing: vert)
                #if os(iOS)
                    .buttonStyle(.bordered)
                #endif
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
            .symbolRenderingMode(.hierarchical)
    }
}
