//
//  GettingStarted.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public extension View {
    func gettingStarted(show: Binding<Bool>,
                        @ViewBuilder content: @escaping () -> some View) -> some View
    {
        sheet(isPresented: show) {
            NavigationStack {
                GettingStarted(show: show) {
                    content()
                }
            }
        }
    }
}

private struct GettingStarted<Content: View>: View {
    // MARK: - Parameters

    @Binding var show: Bool
    @ViewBuilder let content: () -> Content

    // MARK: - Locals

    private let title = "Getting Started"

    // MARK: - Views

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                #if os(watchOS)
                    Text(title)
                        .font(.title3)
                        .foregroundColor(.accentColor)
                #endif
//                VStack(alignment: .leading, spacing: 20) {
                content()

//                    Text("Look for the handy (\(Image(systemName: "line.3.horizontal.decrease"))) button to select a preset to reduce typing!")
//                        .font(.footnote)
//                        .foregroundColor(.secondary)
//                }
                #if os(iOS)
.padding()
                #endif
            }
        }
        #if os(iOS)
        .navigationTitle(title)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Close", action: { show = false })
            }
        }
        #endif
    }
}

struct GettingStarted_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var show = false
        var body: some View {
            Button("Show Getting Started", action: { show = true })
                .gettingStarted(show: $show) {
                    Text("foobar")
                }
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
