//
//  AboutView.swift
//
// Copyright 2022, 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import SwiftUI

public struct AboutView<IconImage>: View
    where IconImage: View
{
    private let shortAppName: String
    private let websiteURL: URL
    private let privacyURL: URL?
    private let termsURL: URL?
    private let tutorialURL: URL?
    private let copyright: String?
    private let iconImage: () -> IconImage

    public init(shortAppName: String,
                websiteURL: URL,
                privacyURL: URL?,
                termsURL: URL?,
                tutorialURL: URL?,
                copyright: String?,
                iconImage: @escaping () -> IconImage)
    {
        self.shortAppName = shortAppName
        self.websiteURL = websiteURL
        self.privacyURL = privacyURL
        self.termsURL = termsURL
        self.tutorialURL = tutorialURL
        self.copyright = copyright
        self.iconImage = iconImage
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                iconImage()
                    .frame(width: 40, height: 40)

                VStack(spacing: 5) {
                    Section {
                        Text(appName)
                            .bold()
                        Text("Version: \(releaseVersionNumber) (build \(buildNumber))")
                            .foregroundColor(.secondary)
                    }
                }

                Text(plea)
                    .foregroundColor(.accentColor)

                VStack(spacing: 5) {
                    Section("Website") {
                        Link(websiteDomain, destination: websiteURL)

                        if let privacyURL {
                            Link("Privacy Policy", destination: privacyURL)
                        }
                        if let termsURL {
                            Link("Terms & Conditions", destination: termsURL)
                        }
                        if let tutorialURL {
                            Link("Tutorial", destination: tutorialURL)
                        }
                    }
                }

                if let copyright {
                    Text(copyright)
                        .foregroundStyle(.secondary)
                }
            }
            .multilineTextAlignment(.center) // NOTE to center the copyright on watch
        }
        .navigationTitle("About")
    }

    private var plea: String {
        "As an open source project, \(shortAppName) depends on its community of users. If you use this app, please help by rating and reviewing in the App Store!"
    }

    private var appName: String {
        Bundle.main.appName ?? ""
    }

    private var releaseVersionNumber: String {
        Bundle.main.releaseVersionNumber ?? ""
    }

    private var buildNumber: String {
        Bundle.main.buildNumber ?? ""
    }

    private var websiteDomain: String {
        websiteURL.host ?? "unknown"
    }
}

struct AboutView_Previews: PreviewProvider {
    static let url = URL(string: "https://tracker.github.io/daily-calorie")!

    static var previews: some View {
        NavigationStack {
            AboutView( //                appName: "Gym Routine Tracker Plus",
                //                      displayName: "Gym RT+",
//                      releaseVersionNumber: "1.0",
//                      buildNumber: "100",
                shortAppName: "DCT+",
                websiteURL: url,
                privacyURL: url.appending(path: "privacy"),
                termsURL: url.appending(path: "terms"),
                tutorialURL: url.appending(path: "tutorial"),
                copyright: "Copyright 2022, 2023 OpenAlloc LLC"
            ) {
                Image(systemName: "g.circle.fill")
                    .imageScale(.large)
            }
            .accentColor(.orange)
        }
    }
}
