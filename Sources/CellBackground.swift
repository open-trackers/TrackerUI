//
//  CellBackground.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import TrackerLib

public struct CellBackground: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Parameters

    private let color: Color

    public init(color: Color?) {
        self.color = color ?? .accentColor
    }

    // MARK: - Views

    public var body: some View {
        LinearGradient(gradient: .init(colors: [
            netColor.opacity(opacities.0),
            netColor.opacity(opacities.1),
        ]),
        startPoint: .topLeading,
        endPoint: .bottom)
    }

    private var isThemed: Bool {
        ![Color.black, Color.clear].contains(color)
    }

    private var opacities: (Double, Double) {
        if isThemed {
            if colorScheme == .light {
                return (0.5, 0.7)
            }
            return (0.4, 0.6)
        }
        return (0.1, 0.2)
    }

    private var netColor: Color {
        isThemed ? color : Color.accentColor
    }
}

struct CellBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Text("Hello")
        }
        .frame(width: 200, height: 200)
        .background(CellBackground(color: .orange))
    }
}
