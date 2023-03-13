//
//  ImageStepper.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct ImageStepper: View {
    // MARK: - Parameters

    private var initialName: String?
    private var imageNames: [String]
    private let forceFocus: Bool
    private var onSelect: (String) -> Void

    public init(initialName: String? = nil,
                imageNames: [String],
                forceFocus: Bool = false,
                onSelect: @escaping (String) -> Void)
    {
        self.initialName = initialName
        self.imageNames = imageNames
        self.forceFocus = forceFocus
        self.onSelect = onSelect

        let index = imageNames.firstIndex(where: { $0 == initialName }) ?? 0
        _index = State(initialValue: index)
    }

    // MARK: - Locals

    @State private var index: Int = 0

    // used to force focus for digital crown, assuming it's the only stepper in (detail) view
    @FocusState private var focusedField: Bool

    // MARK: - Views

    public var body: some View {
        Stepper(value: $index, in: 0 ... imageNames.count - 1) {
            Image(systemName: imageNames[index])
        }.onChange(of: index) { newValue in
            onSelect(imageNames[newValue])
        }
        .symbolRenderingMode(.hierarchical)
        .frame(height: 65)
        .focused($focusedField)
        .onAppear {
            guard forceFocus else { return }
            focusedField = true
        }
    }
}

struct SystemImageStepper_Previews: PreviewProvider {
    static var previews: some View {
        let systemImageNames = [
            "dumbbell",
            "dumbbell.fill",
            "figure.strengthtraining.functional",
            "figure.strengthtraining.traditional",
            "figure.arms.open",
        ]
        return ImageStepper(initialName: "flame", imageNames: systemImageNames, onSelect: { _ in })
            .imageScale(.medium)
    }
}
