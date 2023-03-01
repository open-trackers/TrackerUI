//
//  ColorSchemeSettings.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

// not needed for watch
#if os(iOS)

    import SwiftUI

    // import GroutLib
    // import GroutUI

    public struct ColorSchemeSettings: View {
        public init() {}

        // MARK: - Locals

        @AppStorage(colorSchemeModeKey) var colorSchemeMode: ColorSchemeMode = .automatic

        // MARK: - Views

        public var body: some View {
            Section {
                Picker("Color", selection: $colorSchemeMode) {
                    ForEach(ColorSchemeMode.allCases, id: \.self) { mode in
                        Text(mode.description).tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            } header: {
                Text("Color Scheme")
                    .foregroundStyle(.tint)
            }
        }
    }

    struct ColorSchemeSettings_Previews: PreviewProvider {
        static var previews: some View {
            Form {
                ColorSchemeSettings()
            }
        }
    }

#endif
