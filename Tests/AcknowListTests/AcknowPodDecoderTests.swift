//
//  AcknowPodDecoderTests.swift
//  AcknowExampleTests
//
//  Created by Vincent Tourraine on 15/08/15.
//  Copyright © 2015-2022 Vincent Tourraine. All rights reserved.
//

import XCTest

@testable import AcknowList

class AcknowPodDecoderTests: XCTestCase {

    func testHeaderFooter() throws {
        let bundle = resourcesBundle()
        let url = try XCTUnwrap(bundle.url(forResource: "Pods-acknowledgements", withExtension: "plist"))
        let data = try Data(contentsOf: url)
        let acknowList = try AcknowPodDecoder().decode(from: data)
        XCTAssertEqual(acknowList.headerText, "This application makes use of the following third party libraries:")
        XCTAssertEqual(acknowList.footerText, "Generated by CocoaPods - https://cocoapods.org")
    }

    func testAcknowledgements() throws {
        let bundle = resourcesBundle()
        let url = try XCTUnwrap(bundle.url(forResource: "Pods-acknowledgements", withExtension: "plist"))
        let data = try Data(contentsOf: url)
        let acknowList = try AcknowPodDecoder().decode(from: data)

        XCTAssertEqual(acknowList.acknowledgements.count, 3)

        let acknow = try XCTUnwrap(acknowList.acknowledgements.first)
        XCTAssertEqual(acknow.title, "AcknowList (1)")
        let text = try XCTUnwrap(acknow.text)
        XCTAssertTrue(text.hasPrefix("Copyright (c) 2015-2019 Vincent Tourraine (http://www.vtourraine.net)"))
    }

    // To test the somewhat complicated extraneous-newline-removing regex, I have:
    //
    //  (1) Made a temporary project and installed the 5 most popular pods that
    //      had no dependencies (loosely based on https://trendingcocoapods.github.io -
    //      scroll down to the "Top CocoaPods" section). I skipped pods with duplicate
    //      licenses.
    //
    //      Ultimately, I installed: TYPFontAwesome (SIL OFL 1.1), pop (BSD),
    //      Alamofire (MIT), Charts (Apache 2), and TPKeyboardAvoiding (zLib)
    //
    //  (2) Copied the acknowledgements file over to Pods-acknowledgements-RegexTesting.plist
    //
    //  (3) Created this test, which parses the plist and applies the regex, then
    //      verifies that the generated strings are correct verus a manually edited
    //      "ground truth" text file.
    func testFilterOutPrematureLineBreaks() throws {
        let bundle = resourcesBundle()
        let url = try XCTUnwrap(bundle.url(forResource: "Pods-acknowledgements-RegexTesting", withExtension: "plist"))
        let data = try Data(contentsOf: url)
        let acknowList = try AcknowPodDecoder().decode(from: data)
        
        XCTAssertEqual(acknowList.acknowledgements.count, 5)

        // For each acknowledgement, load the ground truth and compare...
        for acknowledgement in acknowList.acknowledgements {
            let groundTruthPath = try XCTUnwrap(bundle.url(forResource: "RegexTesting-GroundTruth-\(acknowledgement.title)", withExtension: "txt"))
            let groundTruth = try String(contentsOf: groundTruthPath, encoding: .utf8)
            XCTAssertEqual(acknowledgement.text, groundTruth)
        }
    }
    
    func testGeneralPerformance() throws {
        let bundle = resourcesBundle()
        let url = try XCTUnwrap(bundle.url(forResource: "Pods-acknowledgements", withExtension: "plist"))
        let data = try Data(contentsOf: url)

        self.measure() {
            _ = try? AcknowPodDecoder().decode(from: data)
        }
    }

    func testParseNonExistentFile() {
        let data = Data()
        XCTAssertThrowsError(try AcknowPodDecoder().decode(from: data))
    }
}
