//
//  ExportSettings.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

// not needed for watch
#if os(iOS)

    import CoreData
    import os
    import SwiftUI

    // import GroutLib
    // import GroutUI
    import TrackerLib

    public struct ExportSettings: View {
        @Environment(\.managedObjectContext) private var viewContext

        public typealias createZipFn = (NSManagedObjectContext, NSPersistentStore, NSPersistentStore, ExportFormat) throws -> Data?

        // MARK: - Parameters

        private let mainStore: NSPersistentStore
        private let archiveStore: NSPersistentStore
        private let filePrefix: String
        private let createZipArchive: createZipFn

        public init(mainStore: NSPersistentStore,
                    archiveStore: NSPersistentStore,
                    filePrefix: String,
                    createZipArchive: @escaping createZipFn)
        {
            self.mainStore = mainStore
            self.archiveStore = archiveStore
            self.filePrefix = filePrefix
            self.createZipArchive = createZipArchive
        }

        // MARK: - Locals

        @AppStorage(exportFormatKey) var exportFormat: ExportFormat = .CSV

        @State private var showFileExport = false
        @State private var zipDocument: ZipDocument?
        @State private var zipFileName: String?

        private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!,
                                    category: String(describing: ExportSettings.self))

        // MARK: - Views

        public var body: some View {
            Section {
                Button(action: exportAction) {
                    Text("Export Data")
                }
                Picker("", selection: $exportFormat) {
                    ForEach(ExportFormat.allCases, id: \.self) { mode in
                        Text(mode.defaultFileExtension.uppercased())
                            .tag(mode)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            } footer: {
                Text("Will export data to ZIP archive containing \(exportFormat.description) (\(exportFormat.rawValue)) files.")
            }
            .fileExporter(isPresented: $showFileExport,
                          document: zipDocument,
                          contentType: .zip,
                          defaultFilename: zipFileName)
            { result in
                switch result {
                case let .success(url):
                    logger.notice("\(#function): saved to \(url)")
                case let .failure(error):
                    logger.error("\(#function): \(error.localizedDescription)")
                }
                zipDocument = nil
                zipFileName = nil
            }
        }

        // MARK: - Actions

        private func exportAction() {
            if let document = createZipDocument() {
                zipDocument = document
                zipFileName = generateTimestampFileName(prefix: filePrefix, suffix: ".zip")
                showFileExport = true
            } else {
                logger.error("Unable to generate zip document, so not exporting.")
            }
        }

        // MARK: - Helpers

        private func createZipDocument() -> ZipDocument? {
            logger.notice("\(#function) ENTER")
            do {
                if let data = try createZipArchive(viewContext,
                                                   mainStore,
                                                   archiveStore,
                                                   exportFormat)
                {
                    logger.notice("\(#function) EXIT (success)")
                    return ZipDocument(data: data)
                } else {
                    logger.notice("\(#function) unable to create data")
                }
            } catch {
                logger.error("\(#function): ERROR \(error.localizedDescription)")
            }

            logger.notice("\(#function) EXIT (failure)")
            return nil
        }
    }

    // struct ExportSettings_Previews: PreviewProvider {
//    static var previews: some View {
//        Form {
//            ExportSettings()
//        }
//    }
    // }

#endif
