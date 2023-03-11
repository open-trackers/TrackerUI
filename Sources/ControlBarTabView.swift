//
//  BarTabView.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct ControlBarTabView<Content, Selection>: View
    where
    Content: View,
    Selection: Hashable & ControlBarProtocol
{
    @Binding var selection: Selection
    private let tint: Color
    private let title: String
    private let content: () -> Content

    public init(selection: Binding<Selection>,
                tint: Color,
                title: String,
                @ViewBuilder content: @escaping () -> Content)
    {
        _selection = selection
        self.tint = tint
        self.title = title
        self.content = content
    }

    public var body: some View {
        VStack {
            TabView(selection: $selection) {
                content()
            }
            .animation(.easeInOut(duration: 0.25), value: selection)
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            ControlBar(selection: $selection, tint: tint)
                .padding(.horizontal, 20)
                .padding(.bottom)
        }
        .ignoresSafeArea(.all, edges: [.bottom]) // NOTE: allows control bar to be at bottom
        #if os(watchOS)
            .navigationTitle {
                NavTitle(title, color: tint)
            }
        #elseif os(iOS)
            .navigationTitle(title)
        #endif
    }
}

struct BarTabView_Previews: PreviewProvider {
    enum Tab: Int, ControlBarProtocol {
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
            ControlBarTabView(selection: $selection, tint: .green, title: "Blah") {
                Text("One").tag(Tab.one)
                Text("Two").tag(Tab.two)
                Text("Three").tag(Tab.three)
            }
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
