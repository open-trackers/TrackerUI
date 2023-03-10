//
//  ControlBar.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// This is intended to be inherited by an Int-based enum
public protocol ControlBarProtocol: RawRepresentable where RawValue == Int {
    static var first: Self { get }
    static var last: Self { get }
    var next: Self? { get }
    var previous: Self? { get }
}

public struct ControlBar<T: ControlBarProtocol>: View {
    @Binding private var selection: T
    private let tint: Color

    public init(selection: Binding<T>, tint: Color) {
        _selection = selection
        self.tint = tint
    }

    public var body: some View {
        HStack {
            Button(action: {
                guard let previous = selection.previous else { return }
                selection = previous
            }) {
                Image(systemName: "arrow.left.circle.fill")
            }
            .foregroundStyle(tint)
            .disabled(selection == T.first)

            Spacer()

            Text("\(selection.rawValue) of \(T.last.rawValue)")

            Spacer()

            Button(action: {
                guard let next = selection.next else { return }
                selection = next
            }) {
                Image(systemName: "arrow.right.circle.fill")
            }
            .foregroundStyle(tint)
            .disabled(selection == T.last)
        }
        .imageScale(.large)
        // .padding(.horizontal, 20)
        .buttonStyle(.plain)
        // .padding(.bottom)
    }
}

// struct ControlBar_Previews: PreviewProvider {
//    static var previews: some View {
//        ControlBar()
//    }
// }
