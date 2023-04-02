//
//  Cell.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

import TrackerLib

public protocol Celled {
    func getColor() -> Color?
    func setColor(_: Color?)
    var name: String? { get set }
    var imageName: String? { get set }
}

public struct Cell<Element, Subtitle>: View
    where Element: NSManagedObject & Celled,
    Subtitle: View
{
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.colorScheme) private var colorScheme

    // MARK: - Parameters

    // NOTE: needs to be an @ObservedObject for color to be reflected
    @ObservedObject private var element: Element
    private let statusImageName: String?
    @Binding private var now: Date
    private let defaultImageName: String
    private let subtitle: () -> Subtitle
    private let onDetail: () -> Void
    private let onShortPress: () -> Void

    public init(element: Element,
                statusImageName: String? = nil,
                now: Binding<Date>,
                defaultImageName: String,
                subtitle: @escaping () -> Subtitle,
                onDetail: @escaping () -> Void,
                onShortPress: @escaping () -> Void)
    {
        self.element = element
        self.statusImageName = statusImageName
        _now = now
        self.defaultImageName = defaultImageName
        self.subtitle = subtitle
        self.onDetail = onDetail
        self.onShortPress = onShortPress

        color = element.getColor() ?? .accentColor
    }

    // MARK: - Locals

    private let color: Color

    private let minHeight = 100.0

    // MARK: - Views

    public var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                topRow(width: geo.size.width)
                    .frame(height: geo.size.height * 0.4)

                bottomRows
                    .frame(height: geo.size.height * 0.6)
            }
//            .padding(.horizontal, 5)
            .foregroundColor(cellForeground)
        }
        #if os(watchOS)
        .listItemTint(backgroundTint)
        #elseif os(iOS)
        .listRowBackground(cellBackground)
        #endif
        .frame(minHeight: minHeight, maxHeight: .infinity)

        .onAppear(perform: onAppearAction)
    }

    private func topRow(width: CGFloat) -> some View {
        HStack(spacing: 0) {
            ImageButton(systemName: element.imageName ?? defaultImageName, alignment: .leading, onShortPress: onShortPress)
                .frame(width: width * (statusImageName == nil ? 2 : 1) / 3)
            // .border(.white)

            if let statusImageName {
                ImageButton(systemName: statusImageName, alignment: .center, onShortPress: onShortPress)
                    // .imageScale(.large)
                    .frame(width: width * 1 / 3)
                // .border(.gray)
            }

            ImageButton(systemName: "ellipsis", alignment: .trailing, onShortPress: onDetail)
                .padding(.trailing, 5)
                .frame(width: width * 1 / 3)
                .fontWeight(.bold)
            // .border(.white)
        }
        .font(.title2)
        .symbolRenderingMode(.hierarchical)
    }

    private var bottomRows: some View {
        Button(action: { onShortPress() }) {
            HStack {
                VStack(alignment: .leading) {
                    titleText
                    elementSinceText
                }
                Spacer()
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        // .border(.white)
    }

    private var titleText: some View {
        TitleText(element.name ?? "unknown")
    }

    private var elementSinceText: some View {
        subtitle()
            .font(.body)
            .italic()
            .opacity(0.8)
            .lineLimit(1)
            .truncationMode(.middle)
    }

    private var cellForeground: Color {
        .primary.opacity(colorScheme == .light ? 0.6 : 0.8)
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

    #if os(watchOS)
        private var backgroundTint: Color {
            netColor.opacity(opacities.0)
        }
    #endif

    #if os(iOS)
        private var cellBackground: some View {
            LinearGradient(gradient: .init(colors: [
                netColor.opacity(opacities.0),
                netColor.opacity(opacities.1),
            ]),
            startPoint: .topLeading,
            endPoint: .bottom)
        }
    #endif

    // MARK: - Actions

    // refresh immediately on element completion (timer only updates 'now' on the minute)
    private func onAppearAction() {
        now = Date.now
    }
}
