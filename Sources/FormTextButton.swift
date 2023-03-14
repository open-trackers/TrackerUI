//
//  FormTextButton.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

/// TapGesture-based button for use in Forms
public struct FormTextButton: View {
    private let title: String
    private let action: () -> Void

    public init(_ title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        Text(title)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
        // .border(.red)
    }
}

struct FormTextButton_Previews: PreviewProvider {
    static var previews: some View {
        FormTextButton("Blah") {}
    }
}
