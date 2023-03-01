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
    private let plea: String
    private let iconImage: () -> IconImage

    public init(shortAppName: String,
                websiteURL: URL,
                privacyURL: URL?,
                termsURL: URL?,
                tutorialURL: URL?,
                copyright: String?,
                plea: String,
                iconImage: @escaping () -> IconImage)
    {
        self.shortAppName = shortAppName
        self.websiteURL = websiteURL
        self.privacyURL = privacyURL
        self.termsURL = termsURL
        self.tutorialURL = tutorialURL
        self.copyright = copyright
        self.plea = plea
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
                #if os(iOS)
                    .padding(.horizontal)
                #endif

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
            AboutView(
                shortAppName: "DCT+",
                websiteURL: url,
                privacyURL: url.appending(path: "privacy"),
                termsURL: url.appending(path: "terms"),
                tutorialURL: url.appending(path: "tutorial"),
                copyright: "Copyright 2022, 2023 OpenAlloc LLC", plea: "Blah!"
            ) {
                Image(systemName: "g.circle.fill")
                    .imageScale(.large)
            }
            .accentColor(.orange)
        }
    }
}
