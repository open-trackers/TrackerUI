//
//  AddElementButton.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import os
import SwiftUI

import TrackerLib

public struct AddElementButton<Element>: View
    where Element: NSManagedObject & UserOrdered
{
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Parameters

    private let elementName: String
    private let onCreate: () -> Element
    private let onAfterSave: (Element) -> Void

    public init(elementName: String,
                onCreate: @escaping () -> Element,
                onAfterSave: @escaping (Element) -> Void)
    {
        self.elementName = elementName
        self.onCreate = onCreate
        self.onAfterSave = onAfterSave
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: AddElementButton.self))

    // MARK: - Views

    public var body: some View {
        Button(action: addAction) {
            #if os(watchOS)
                Label("Add \(elementName)", systemImage: "plus.circle")
            #elseif os(iOS)
                Text("Add \(elementName)")
            #endif
        }
    }

    // MARK: - Properties

    // MARK: - Actions

    private func addAction() {
        logger.notice("\(#function)")
        Haptics.play()

        withAnimation {
            let nu = onCreate()
            do {
                try viewContext.save()

                // used for routing
                onAfterSave(nu)
            } catch {
                logger.error("\(#function): \(error.localizedDescription)")
            }
        }
    }
}
