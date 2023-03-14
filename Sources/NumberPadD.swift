//
//  NumberPadD.swift
//
// Copyright 2023  OpenAlloc LLC
//
// Decimalhis Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import TrackerLib

public struct NumberPadD: View {
    @Binding private var selection: DecimalNumPad
    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat

    // MARK: - Parameters

    public init(selection: Binding<DecimalNumPad>,
                horizontalSpacing: CGFloat = 3,
                verticalSpacing: CGFloat = 3)
    {
        _selection = selection
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
    }

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
                    decimalPoint
                    digit(0)
                    backspace
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
    }

    private var decimalPoint: some View {
        Button(action: decimalPointAction) {
            Text(".")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var backspace: some View {
        Button(action: {}) {
            Image(systemName: "delete.backward.fill")
                .imageScale(.large)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .disabled(selection.stringValue == "0")
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

    private func digitAction(_ num: Int?) {
        guard let num else { return }
        selection.digitAction(num)
        Haptics.play()
    }

    private func clearAction() {
        selection.clearAction()
        Haptics.play()
    }

    private func decimalPointAction() {
        selection.decimalPointAction()
        Haptics.play()
    }

    private func backspaceAction() {
        selection.backspaceAction()
        Haptics.play()
    }
}

struct NumberPadD_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var dValue: DecimalNumPad = DecimalNumPad(2333.23, precision: 2, range: 0 ... 30000)
        // @State var dValue: Decimal = 2333.23
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
                    Text("\(dValue.stringValue)")
                #elseif os(iOS)
                    GroupBox {
                        Text("\(dValue.stringValue)")
                    } label: {
                        Text("Calories")
                    }
                #endif
                NumberPadD(selection: $dValue, horizontalSpacing: horz, verticalSpacing: vert)
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

public extension Decimal {
    var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }

    mutating func round(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) {
        var localCopy = self
        NSDecimalRound(&self, &localCopy, scale, roundingMode)
    }

    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
