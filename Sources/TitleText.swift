//
//  TitleText.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct TitleText: View {
    @Environment(\.colorScheme) private var colorScheme

    private let text: Text
    private let fontWeight: Font.Weight
    private let maxFontSize: CGFloat
    private let minScaleFactor: CGFloat

    public init(_ strText: String,
                fontWeight: Font.Weight = .medium,
                maxFontSize: CGFloat = 40,
                minScaleFactor: CGFloat = 0.3) // no smaller than 30% of maxFontSize
    {
        self.init(Text(strText),
                  fontWeight: fontWeight,
                  maxFontSize: maxFontSize,
                  minScaleFactor: minScaleFactor)
    }

    public init(_ text: Text,
                fontWeight: Font.Weight = .medium,
                maxFontSize: CGFloat = 40,
                minScaleFactor: CGFloat = 0.3) // no smaller than 30% of maxFontSize
    {
        self.text = text
        self.fontWeight = fontWeight
        self.maxFontSize = maxFontSize
        self.minScaleFactor = minScaleFactor
    }

    public var body: some View {
        text
            .font(.system(size: maxFontSize))
            .minimumScaleFactor(minScaleFactor)
            .fontWeight(fontWeight)
            .lineLimit(1)
    }

//    private var shadowColor: Color {
//        colorScheme == .light ? .black.opacity(0.33) : .clear
//    }
}

struct TitleView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Circle().strokeBorder(Color.red, lineWidth: 10)
            TitleText("This is a test")
                .foregroundStyle(.orange)
        }
    }
}
