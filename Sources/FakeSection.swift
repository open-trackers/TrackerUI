//
//  FakeSection.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

#if os(watchOS)

    public struct FakeSection<Content: View>: View {
        var title: String
        var content: () -> Content

        public init(title: String,
                    @ViewBuilder content: @escaping () -> Content)
        {
            self.title = title
            self.content = content
        }

        public var body: some View {
            VStack(alignment: .leading) {
                Text(title.uppercased())
                    .font(.footnote)
                    .foregroundColor(.primary.opacity(0.6))
                    .padding(.leading, 10)
                content()
            }
        }
    }

    struct FakeSection_Previews: PreviewProvider {
        static var previews: some View {
            FakeSection(title: "Foobar Baz Blah") {
                Text("The Content")
            }
        }
    }

#endif
