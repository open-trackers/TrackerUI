//
//  FormNumberPad.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

import NumberPad

public struct FormIntPad<Label, T>: View
    where Label: View,
    T: FixedWidthInteger
{
    // MARK: - Parameters

    @Binding private var selection: T
    private let label: (T) -> Label

    public init(selection: Binding<T>,
                upperBound: T,
                label: @escaping (T) -> Label)
    {
        _selection = selection
        self.label = label

        padSelection = .init(selection.wrappedValue, upperBound: upperBound)
    }

    // MARK: - Locals

    @State private var showSheet = false
    @ObservedObject var padSelection: NumPadInt<T>

    // MARK: - Views

    public var body: some View {
        HStack {
            label(selection)
            Spacer()
            Button(action: { showSheet = true }) {
                Image(systemName: "square.grid.2x2")
            }
            .foregroundStyle(.tint)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                IntPadSheet(selection: padSelection)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                if let nu = padSelection.value {
                                    selection = nu
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

public struct FormFloatPad<Label, T>: View
    where Label: View,
    T: BinaryFloatingPoint
{
    // MARK: - Parameters

    @Binding private var selection: T
    private let label: (T) -> Label

    public init(selection: Binding<T>,
                precision: Int,
                upperBound: T,
                label: @escaping (T) -> Label)
    {
        _selection = selection
        self.label = label

        padSelection = .init(selection.wrappedValue,
                             precision: precision,
                             upperBound: upperBound)
    }

    // MARK: - Locals

    @State private var showSheet = false
    @ObservedObject var padSelection: NumPadFloat<T>

    // MARK: - Views

    public var body: some View {
        HStack {
            label(selection)
            Spacer()
            Button(action: { showSheet = true }) {
                Image(systemName: "square.grid.2x2")
            }
            .foregroundStyle(.tint)
        }
        .sheet(isPresented: $showSheet) {
            NavigationStack {
                FloatPadSheet(selection: padSelection)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: {
                                if let nu = padSelection.value {
                                    selection = nu
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

// TODO: try to refactor this with FloatPadSheet, where selection is a NumPadBase and showDecimalPoint a parameter
private struct IntPadSheet<T>: View
    where T: FixedWidthInteger
{
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var selection: NumPadInt<T>

    let darkTitleColor: Color = .yellow

    var body: some View {
        platformView
            .symbolRenderingMode(.hierarchical)
    }

    #if os(watchOS)
        private var platformView: some View {
            GeometryReader { _ in
                VStack(spacing: 3) {
                    Text("\(selection.stringValue)")
                        .foregroundColor(darkTitleColor)
                    NumberPad(selection: selection, showDecimalPoint: false)
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
                    Text("\(selection.stringValue)")
                        .foregroundColor(selectionColor)
                    NumberPad(selection: selection, showDecimalPoint: false)
                        .buttonStyle(.bordered)
                        .foregroundStyle(Color.primary) // NOTE: colors the backspace too
                        .frame(maxWidth: 300, maxHeight: 400)
                }
                .font(.largeTitle)
                Spacer()
                Text("Enter a value up to \(Int(selection.upperBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }

        private var selectionColor: Color {
            colorScheme == .light ? .primary : darkTitleColor
        }
    #endif
}

// TODO: try to refactor this with IntPadSheet, where selection is a NumPadBase and showDecimalPoint a parameter
private struct FloatPadSheet<T>: View
    where T: BinaryFloatingPoint
{
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var selection: NumPadFloat<T>

    let darkTitleColor: Color = .yellow

    var body: some View {
        platformView
            .symbolRenderingMode(.hierarchical)
    }

    #if os(watchOS)
        private var platformView: some View {
            GeometryReader { _ in
                VStack(spacing: 3) {
                    Text("\(selection.stringValue)")
                        .foregroundColor(darkTitleColor)
                    NumberPad(selection: selection, showDecimalPoint: true)
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
                    Text("\(selection.stringValue)")
                        .foregroundColor(selectionColor)
                    NumberPad(selection: selection, showDecimalPoint: true)
                        .buttonStyle(.bordered)
                        .foregroundStyle(Color.primary) // NOTE: colors the backspace too
                        .frame(maxWidth: 300, maxHeight: 400)
                }
                .font(.largeTitle)
                Spacer()
                Text("Enter a value up to \(Int(selection.upperBound))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }

        private var selectionColor: Color {
            colorScheme == .light ? .primary : darkTitleColor
        }
    #endif
}

struct FormIntPad_Previews: PreviewProvider {
    struct TestHolder: View {
        @State var intValue: Int16 = 6222
        @State var floatValue: Float = 23.4
        var body: some View {
            Form {
                FormIntPad(selection: $intValue, upperBound: 30000) {
                    Text("\($0) cal")
                }
                FormFloatPad(selection: $floatValue, precision: 1, upperBound: 5000) {
                    Text("\($0, specifier: "%0.1f") mL")
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
