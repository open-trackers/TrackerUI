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

/// This is intended to be implemented by an Int-based enum
public protocol ControlBarred: RawRepresentable, Equatable where RawValue == Int {
    static var first: Self { get }
    static var last: Self { get }
    var next: Self? { get }
    var previous: Self? { get }
}

/// A navigation control for detail pages (on the watch)
/// It allows detail items to be broken up onto their own pages, so that the crown's focus will be a bit more predictable.
public struct ControlBar<T: ControlBarred>: View {
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
                Haptics.play()
            }) {
                Image(systemName: "arrow.left.circle.fill")
            }
            .foregroundStyle(tint)
            .disabled(selection == T.first)

            Spacer()

            // Capsule(style: .circular)
            //     .fill(tint)

            Text("\(selection.rawValue) of \(T.last.rawValue)")
                .modify {
                    if #available(iOS 16.1, watchOS 9.1, *) {
                        $0.fontDesign(.monospaced)
                    } else {
                        $0.monospaced()
                    }
                }
                .onTapGesture(perform: tapAction)

            Spacer()

            Button(action: {
                guard let next = selection.next else { return }
                selection = next
                Haptics.play()
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
        // .frame(maxHeight: 20)
    }

    // MARK: - Actions

    private func tapAction() {
        if selection == T.first {
            selection = T.last
        } else {
            selection = T.first
        }
        Haptics.play()
    }
}

struct ControlBar_Previews: PreviewProvider {
    enum Tab: Int, ControlBarred {
        case one = 1
        case two = 2
        case three = 3
        static var first: Tab = .one
        static var last: Tab = .three
        var previous: Tab? {
            Tab(rawValue: rawValue - 1)
        }

        var next: Tab? {
            Tab(rawValue: rawValue + 1)
        }
    }

    struct TestHolder: View {
        @State var selection: Tab = .one
        var body: some View {
            ControlBar(selection: $selection, tint: .green)
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
            .symbolRenderingMode(.hierarchical)
    }
}
