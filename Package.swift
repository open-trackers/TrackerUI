// swift-tools-version: 5.7

import PackageDescription

let package = Package(name: "TrackerUI",
                      platforms: [.macOS(.v13), .iOS(.v16), .watchOS(.v9)],
                      products: [
                          .library(name: "TrackerUI",
                                   targets: ["TrackerUI"]),
                      ],
                      dependencies: [
                          .package(url: "https://github.com/openalloc/SwiftCompactor", from: "1.3.0"),
                          .package(url: "https://github.com/apple/swift-collections.git", from: "1.0.4"),
                          .package(url: "https://github.com/open-trackers/TrackerLib.git", from: "1.0.0"),
                      ],
                      targets: [
                          .target(name: "TrackerUI",
                                  dependencies: [
                                      .product(name: "Compactor", package: "SwiftCompactor"),
                                      .product(name: "Collections", package: "swift-collections"),
                                      .product(name: "TrackerLib", package: "TrackerLib"),
                                  ],
                                  path: "Sources"),
                          .testTarget(name: "TrackerUITests",
                                      dependencies: ["TrackerUI"],
                                      path: "Tests"),
                      ])
