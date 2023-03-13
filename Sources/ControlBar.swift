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

/// A navigation control for detail pages (on the watch)
/// It allows detail items to be broken up onto their own pages, so that the crown's focus will be a bit more predictable.
public struct ControlBar<T>: View
    where T: RawRepresentable & Equatable & CaseIterable,
    T.RawValue == Int
{
    @Binding private var selection: T
    private let tint: Color

    public init(selection: Binding<T>, tint: Color) {
        _selection = selection
        self.tint = tint
    }

    public var body: some View {
        HStack {
            Button(action: {
                guard let previous = previous(selection) else { return }
                selection = previous
                Haptics.play()
            }) {
                Image(systemName: "arrow.left.circle.fill")
            }
            .padding(.trailing, 5)
            .foregroundStyle(tint)
            .disabled(selection == first)
            // .border(.red)

            Spacer()

            // Capsule(style: .circular)
            //     .fill(tint)

            Text("\(selection.rawValue) of \(last.rawValue)")
                .lineLimit(1)
                .modify {
                    if #available(iOS 16.1, watchOS 9.1, *) {
                        $0.fontDesign(.monospaced)
                    } else {
                        $0.monospaced()
                    }
                }
//                .padding(.horizontal)
                .onTapGesture(perform: tapAction)
            // .border(.red)

            Spacer()

            Button(action: {
                guard let next = next(selection) else { return }
                selection = next
                Haptics.play()
            }) {
                Image(systemName: "arrow.right.circle.fill")
            }
            .padding(.leading, 5)
            .foregroundStyle(tint)
            .disabled(selection == last)
            // .border(.red)
        }
        .imageScale(.large)
        .buttonStyle(.plain)
    }

    // MARK: - Properties

    private var first: T {
        T.allCases[T.allCases.startIndex]
    }

    private var last: T {
        let endIndex = T.allCases.endIndex // one past end
        let lastIndex = T.allCases.index(endIndex, offsetBy: -1)
        return T.allCases[lastIndex]
    }

    private func previous(_ element: T) -> T? {
        guard let index = T.allCases.firstIndex(of: element),
              index != T.allCases.startIndex
        else { return nil }
        let previousIndex = T.allCases.index(index, offsetBy: -1)
        return T.allCases[previousIndex]
    }

    private func next(_ element: T) -> T? {
        guard let index = T.allCases.firstIndex(of: element),
              index != T.allCases.endIndex
        else { return nil }
        let nextIndex = T.allCases.index(index, offsetBy: 1)
        return T.allCases[nextIndex]
    }

    // MARK: - Actions

    private func tapAction() {
        if selection == first {
            selection = last
        } else {
            selection = first
        }
        Haptics.play()
    }
}

struct ControlBar_Previews: PreviewProvider {
    enum Tab: Int, CaseIterable {
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
