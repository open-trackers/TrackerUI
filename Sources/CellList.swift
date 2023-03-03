//
//  CellList.swift
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

public protocol Named {
    var name: String? { get set }
}

public struct CellList<Element, Cell, Add, ExtraListItems>: View
    where Element: NSManagedObject & UserOrdered & Named,
    Cell: View,
    Add: View,
    ExtraListItems: View
{
    @Environment(\.managedObjectContext) private var viewContext

    // MARK: - Parameters

    private let cell: (Element, Binding<Date>) -> Cell
    private let addButton: () -> Add
    private let extraListItems: () -> ExtraListItems

    public init(cell: @escaping (Element, Binding<Date>) -> Cell,
                addButton: @escaping () -> Add,
                @ViewBuilder extraListItems: @escaping () -> ExtraListItems = { EmptyView() })
    {
        self.cell = cell
        self.addButton = addButton
        self.extraListItems = extraListItems
    }

    // MARK: - Locals

    @FetchRequest( // entity: Element.entity(),
        sortDescriptors: [
            NSSortDescriptor(key: "userOrder", ascending: true),
            // SortDescriptor(\Element.userOrder, order: .forward)
            // NSSortDescriptor(keyPath: \Element.userOrder, ascending: true),
        ],
        animation: .default
    )

    private var elements: FetchedResults<Element>

    // timer used to refresh "2d ago, for 16.5m" on each Element Cell
    @State private var now = Date()
    private let timer = Timer.publish(every: 60,
                                      on: .main,
                                      in: .common).autoconnect()

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: CellList<Element, Cell, Add, ExtraListItems>.self))

    // support for delete confirmation dialog
    @State private var toBeDeleted: Element? = nil
    @State private var confirmDelete = false

    // MARK: - Views

    public var body: some View {
        List {
            ForEach(elements, id: \.self) { element in
                cell(element, $now)
                    .swipeActions(edge: .trailing) {
                        swipeToDelete(element: element)
                    }
            }
            .onMove(perform: moveAction)
            // .onDelete(perform: deleteAction)
            #if os(watchOS)
            .listItemTint(.orange)
            #elseif os(iOS)
            .listRowBackground(rowBackground)
            #endif

            extraListItems()
        }

        #if os(watchOS)
        .listStyle(.carousel)
        #endif

        #if os(iOS)
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem {
                addButton()
            }
        }
        #endif
        .confirmationDialog("Are you sure?",
                            isPresented: $confirmDelete,
                            actions: confirmedDelete)
        .onReceive(timer) { _ in
            self.now = Date.now
        }
        .onAppear {
            // refresh immediately when tab/screen is shown (timer only updates 'now' on the minute)
            now = Date.now
        }
    }

    // MARK: - Properties

    #if os(iOS)
        private var rowBackground: some View {
            EntityBackground(.accentColor)
        }
    #endif

    // MARK: - Actions

    private func moveAction(from source: IndexSet, to destination: Int) {
        logger.notice("\(#function)")
        Haptics.play()
        Element.move(elements, from: source, to: destination)
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    private func deleteAction(element: Element?) {
        logger.notice("\(#function)")
        Haptics.play()
        guard let element else { return }
        viewContext.delete(element)
        do {
            try viewContext.save()
        } catch {
            logger.error("\(#function): \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers

    // swipe button to be shown when user has swiped left
    private func swipeToDelete(element: Element) -> some View {
        // NOTE that button role is NOT destructive, to prevent item from disappearing before confirmation
        Button(role: .none) {
            toBeDeleted = element
            Haptics.play(.warning)
            confirmDelete = true
        } label: {
            Label("Delete", systemImage: "trash")
        }
        .tint(.red)
    }

    // confirmation dialog to be shown after user has swiped to delete
    private func confirmedDelete() -> some View {
        withAnimation {
            Button("Delete ‘\(toBeDeleted?.name ?? "")’",
                   role: .destructive) {
                deleteAction(element: toBeDeleted)
                confirmDelete = false
                toBeDeleted = nil
            }
        }
    }
}
