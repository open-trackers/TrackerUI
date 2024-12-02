//
//  BaseNavStack.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import os
import SwiftUI

import TrackerLib

public extension Notification.Name {
    static let trackerPopNavStack = Notification.Name("tracker-pop-nav-stack") // payload of stackIdentifier String
}

//extension BaseCoreDataStack: ObservableObject {}

public struct BaseNavStack<Destination, Content, MyRoute>: View
    where Destination: View, Content: View, MyRoute: Hashable & Codable
{
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.scenePhase) private var scenePhase

    public typealias MyRouter = Router<MyRoute>
    public typealias DestinationFn = (MyRouter, MyRoute) -> Destination

    // MARK: - Parameters

    @Binding private var navData: Data?
    private var stackIdentifier: String?
    private var coreDataStack: BaseCoreDataStack
    private var destination: DestinationFn
    private var content: () -> Content

    public init(navData: Binding<Data?>,
                stackIdentifier: String?,
                coreDataStack: BaseCoreDataStack,
                @ViewBuilder destination: @escaping DestinationFn,
                @ViewBuilder content: @escaping () -> Content)
    {
        _navData = navData
        self.stackIdentifier = stackIdentifier
        self.coreDataStack = coreDataStack
        self.destination = destination
        self.content = content
    }

    // MARK: - Locals

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                category: String(describing: BaseNavStack<Destination, Content, MyRoute>.self))

    @StateObject private var router: MyRouter = .init()

    private let popStackPublisher = NotificationCenter.default.publisher(for: .trackerPopNavStack)

    // MARK: - Views

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
                .environmentObject(router)
                .environmentObject(coreDataStack)
                .environment(\.managedObjectContext, viewContext)
                .navigationDestination(for: MyRoute.self, destination: destinationAction)
                .onChange(of: scenePhase, perform: scenePhaseChangeAction)
        }
        .interactiveDismissDisabled() // NOTE: needed to prevent home button from dismissing sheet
        .onReceive(popStackPublisher) { payload in
            logger.debug("onReceive: \(popStackPublisher.name.rawValue)")
            guard let stackIdentifier,
                  let strID = payload.object as? String,
                  strID == stackIdentifier
            else { return }
            router.path = [] // pop!
        }
    }

    // obtain the view for the given route
    // NOTE: may be a view that exists exclusively in an iOS or watchOS project
    private func destinationAction(_ route: MyRoute) -> some View {
        destination(router, route)
    }

    private func scenePhaseChangeAction(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .background, .inactive:
            logger.notice("\(#function): scenePhase going background/inactive; saving navigation state")
            do {
                navData = try router.saveNavigationState()
                logger.debug("\(#function): saved path \(router.path)")
            } catch {
                logger.error("\(#function): unable to save navigation state, \(error)")
            }
        case .active:
            if let navData {
                logger.notice("\(#function): scenePhase going active; restoring navigation state")
                router.restoreNavigationState(from: navData)
                logger.debug("\(#function): restored path \(router.path)")
            } else {
                logger.notice("\(#function): scenePhase going active; but no data to restore navigation state")
            }
        @unknown default:
            logger.notice("\(#function): scenePhase not recognized")
        }
    }
}
