//
//  FormNumberPad.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import NumberPad

public struct FormIntegerPad<T, Label>: View
    where T: FixedWidthInteger & Comparable,
    Label: View
{
    @Binding private var value: T
    private let upperBound: T
    private let label: (T?) -> Label

    public init(value: Binding<T>,
                upperBound: T,
                label: @escaping (T?) -> Label)
    {
        _value = value
        self.upperBound = upperBound
        self.label = label

        config = NPIntegerConfig(value.wrappedValue, upperBound: upperBound)
    }

    @ObservedObject private var config: NPIntegerConfig<T>

    public var body: some View {
        FormNumberPad(value: $value, config: config, showDecimalPoint: false, label: label)
    }
}

public struct FormFloatPad<T, Label>: View
    where T: BinaryFloatingPoint & Comparable,
    Label: View
{
    @Binding private var value: T
    private let precision: Int
    private let upperBound: T
    private let label: (T?) -> Label

    public init(value: Binding<T>,
                precision: Int,
                upperBound: T,
                label: @escaping (T?) -> Label)
    {
        _value = value
        self.precision = precision
        self.upperBound = upperBound
        self.label = label

        config = NPFloatConfig(value.wrappedValue, precision: precision, upperBound: upperBound)
    }

    @ObservedObject private var config: NPFloatConfig<T>

    public var body: some View {
        FormNumberPad(value: $value, config: config, showDecimalPoint: true, label: label)
    }
}

private struct FormNumberPad<Label, N, T, Footer>: View
    where Label: View,
    N: NPBaseConfig<T>,
    Footer: View
{
    // MARK: - Parameters

    @Binding private var value: T
    private let config: NPBaseConfig<T>
    private let showDecimalPoint: Bool
    private let label: (T?) -> Label
    private let footer: () -> Footer

    init(value: Binding<T>,
         config: NPBaseConfig<T>,
         showDecimalPoint: Bool,
         label: @escaping (T?) -> Label,
         footer: @escaping () -> Footer = { EmptyView() })
    {
        _value = value
        self.config = config
        self.showDecimalPoint = showDecimalPoint
        self.label = label
        self.footer = footer
    }

    // MARK: - Locals

    @State private var showSheet = false

    // MARK: - Views

    var body: some View {
        HStack {
            label(config.value)
            Spacer()
            Button(action: { showSheet = true }) {
                Image(systemName: "square.grid.2x2")
            }
            .foregroundStyle(.tint)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                PadSheet(config: config, showDecimalPoint: showDecimalPoint, footer: footer)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                if let nu = config.value {
                                    value = nu
                                }
                                showSheet = false
                            }) {
                                Text("Save")
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button(action: {
                                showSheet = false
                            }) {
                                Text("Cancel")
                            }
                        }
                    }
            }
        }
    }
}

private struct PadSheet<T, Footer: View>: View where T: Comparable {
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var config: NPBaseConfig<T>
    let showDecimalPoint: Bool
    let footer: () -> Footer

    let darkTitleColor: Color = .yellow

    var body: some View {
        platformView
            .symbolRenderingMode(.hierarchical)
    }

    #if os(watchOS)
        private var platformView: some View {
            GeometryReader { _ in
                VStack(spacing: 3) {
                    Text("\(config.stringValue)")
                        .foregroundColor(darkTitleColor)
                    NumberPad(config: config, showDecimalPoint: showDecimalPoint)
                        .buttonStyle(.plain)
                        .modify {
                            if #available(iOS 16.1, watchOS 9.1, *) {
                                $0.fontDesign(.monospaced)
                            } else {
                                $0.monospaced()
                            }
                        }
                }
                .font(.title2)
            }
            .ignoresSafeArea(.all, edges: [.bottom])
        }
    #endif

    #if os(iOS)
        private var platformView: some View {
            VStack {
                Group {
                    Text("\(config.stringValue)")
                        .foregroundColor(selectionColor)
                    NumberPad(config: config, showDecimalPoint: showDecimalPoint)
                        .buttonStyle(.bordered)
                        .foregroundStyle(Color.primary) // NOTE: colors the backspace too
                        .frame(maxWidth: 300, maxHeight: 400)
                }
                .font(.largeTitle)
                Spacer()
                footer()
            }
        }

        private var selectionColor: Color {
            colorScheme == .light ? .primary : darkTitleColor
        }
    #endif
}

struct FormNumberPad_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var intValue: Int16 = 6222
        @State var floatValue: Float = 23.4
        var intConfig: NPIntegerConfig<Int16> { NPIntegerConfig(intValue, upperBound: 30000) }
        var floatConfig: NPFloatConfig<Float> { NPFloatConfig(floatValue, precision: 1, upperBound: 5000) }
        var body: some View {
            Form {
                FormNumberPad(value: $intValue,
                              config: intConfig,
                              showDecimalPoint: false)
                {
                    Text("\($0 ?? 0) cal")
                } footer: {
                    Text("Enter a value up to \(intConfig.upperBound)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                FormNumberPad(value: $floatValue,
                              config: floatConfig,
                              showDecimalPoint: true)
                {
                    Text("\($0 ?? 0, specifier: "%0.1f") mL")
                } footer: {
                    Text("Enter a value up to \(floatConfig.upperBound)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
    }

    static var previews: some View {
        TestHolder()
            .accentColor(.orange)
    }
}
