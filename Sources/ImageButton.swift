//
//  ImageButton.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct ImageButton: View {
    private let systemName: String
    private let alignment: Alignment
    private let onShortPress: () -> Void
    // private let onLongPress: () -> Void

    public init(systemName: String,
                alignment: Alignment = .center,
                onShortPress: @escaping () -> Void)
    // onLongPress: @escaping () -> Void)
    {
        self.systemName = systemName
        self.alignment = alignment
        self.onShortPress = onShortPress
        // self.onLongPress = onLongPress
    }

    public var body: some View {
        Button(action: onShortPress) {
            Image(systemName: systemName)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
//        .contentShape(Rectangle())
//        .simultaneousGesture(
//            LongPressGesture()
//                .onEnded { _ in
//                    // onLongPress?()
//                    onLongPress()
//                }
//        )
//        .highPriorityGesture(
//            TapGesture()
//                .onEnded { _ in
//                    onShortPress()
//                }
//        )

        // .border(.green)
    }

    // NOTE this implementation was picking up spurious button clicks
//        ZStack {
//            Image(systemName: systemName)
//
//            Button(action: action) {
//                EmptyView()
//            }
//
//            .frame(width: 0, height: 0)
//            .foregroundColor(.clear)
//        }
//        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
}

struct ImageButton_Previews: PreviewProvider {
    static var previews: some View {
        HStack {
            ImageButton(systemName: "square.fill", alignment: .trailing, onShortPress: { print("square") })
            ImageButton(systemName: "circle.fill", alignment: .trailing, onShortPress: { print("circle") })
            ImageButton(systemName: "triangle.fill", alignment: .trailing, onShortPress: { print("triangle") })
        }
        .font(.largeTitle)
    }
}
