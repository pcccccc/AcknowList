//
// AcknowListSwiftUI.swift
//
// Copyright (c) 2015-2024 Vincent Tourraine (https://www.vtourraine.net)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import SwiftUI

extension Acknow: Identifiable {
    public var id: String {
        get {
            title
        }
    }
}

/// View that displays a list of acknowledgements.
@available(iOS 13.0.0, macOS 10.15.0, watchOS 7.0.0, tvOS 13.0.0, *)
public struct AcknowListSwiftUIView: View {

    /// The represented array of `Acknow`.
    public var acknowledgements: [Acknow] = []

    /// Header text to be displayed above the list of the acknowledgements.
    public var headerText: String?

    /// Footer text to be displayed below the list of the acknowledgements.
    public var footerText: String?

    public init(acknowList: AcknowList) {
        acknowledgements = acknowList.acknowledgements
        headerText = acknowList.headerText
        footerText = acknowList.footerText
    }

    public init(acknowledgements: [Acknow], headerText: String? = nil, footerText: String? = nil) {
        self.acknowledgements = acknowledgements
        self.headerText = headerText
        self.footerText = footerText
    }

    public init(plistFileURL: URL) {
        guard let data = try? Data(contentsOf: plistFileURL),
              let acknowList = try? AcknowPodDecoder().decode(from: data) else {
            self.init(acknowledgements: [], headerText: nil, footerText: nil)
            return
        }

        let header: String?
        if acknowList.headerText != AcknowPodDecoder.K.DefaultHeaderText {
            header = acknowList.headerText
        }
        else {
            header = nil
        }

        self.init(acknowledgements: acknowList.acknowledgements, headerText: header, footerText: acknowList.footerText)
    }

    struct HeaderFooter: View {
        let text: String?

        var body: some View {
            if let text = text {
                Text(text)
            }
            else {
                EmptyView()
            }
        }
    }

    public var body: some View {
        #if os(iOS) || os(tvOS)
        List {
            Section(header: HeaderFooter(text: headerText), footer: HeaderFooter(text: footerText)) {
                ForEach (acknowledgements) { acknowledgement in
                    AcknowListRowSwiftUIView(acknowledgement: acknowledgement)
                }
            }
        }
        .listStyle(GroupedListStyle())
        .navigationBarTitle(Text(AcknowLocalization.localizedTitle()))
        #else
        List {
            Section(header: HeaderFooter(text: headerText), footer: HeaderFooter(text: footerText)) {
                ForEach (acknowledgements) { acknowledgement in
                    AcknowListRowSwiftUIView(acknowledgement: acknowledgement)
                }
            }
        }
        #endif
    }
}

/// View that displays a row in a list of acknowledgements.
@available(iOS 13.0.0, macOS 10.15.0, watchOS 7.0.0, tvOS 13.0.0, *)
public struct AcknowListRowSwiftUIView: View {

    /// The represented `Acknow`.
    public var acknowledgement: Acknow

    /// Indicates if the view controller should try to fetch missing licenses from the GitHub API.
    public var canFetchLicenseFromGitHub = true
    
    @State var show: Bool = false

    public var body: some View {
        if let repository = acknowledgement.repository,
                canOpenRepository(for: repository) {
            if #available(tvOS 15.0, *) {
                Button(action: {
                    show = true
                }) {
                    Text(acknowledgement.title)
                        .foregroundColor(.primary)
                }
                .fullScreenCover(isPresented: $show, content: {
                    AcknowSwiftUIView(acknowledgement: acknowledgement)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThickMaterial)
                })
            } else {
                // Fallback on earlier versions
            }
        }
        else {
            Text(acknowledgement.title)
        }
    }

    private func canOpenRepository(for url: URL) -> Bool {
        guard let scheme = url.scheme else {
            return false
        }

        return scheme == "http" || scheme == "https"
    }

    private func canFetchLicenseFromGitHubAndIsGitHubRepository(_ acknowledgement: Acknow) -> Bool {
        if canFetchLicenseFromGitHub,
           let repository = acknowledgement.repository {
            return GitHubAPI.isGitHubRepository(repository)
        }
        else {
            return false
        }
    }
}

@available(iOS 13.0.0, macOS 10.15.0, watchOS 7.0.0, tvOS 13.0.0, *)
struct AcknowListSwiftUI_Previews: PreviewProvider {
    static let license = """
        Copyright (c) 2015-2024 Vincent Tourraine (https://www.vtourraine.net)

        Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

        The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

        THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    """
    static let acks = [Acknow(title: "Title 1", text: license),
                       Acknow(title: "Title 2", text: license),
                       Acknow(title: "Title 3", text: license)]

    static var previews: some View {
        NavigationView {
            AcknowListSwiftUIView(acknowledgements: acks)
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 12"))

        NavigationView {
            AcknowListSwiftUIView(acknowledgements: acks, headerText: "Test Header", footerText: "Test Footer")
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
        
        NavigationView {
            AcknowListSwiftUIView(acknowledgements: acks, headerText: "Test Header", footerText: "Test Footer")
        }
        .previewDevice(PreviewDevice(rawValue: "Apple TV 4K"))

        NavigationView {
            AcknowListSwiftUIView(acknowledgements: acks, headerText: "Test Header", footerText: "Test Footer")
        }
        .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 6 - 44mm"))

        NavigationView {
            AcknowListSwiftUIView(acknowledgements: acks, headerText: "Test Header", footerText: "Test Footer")
        }
        .previewDevice(PreviewDevice(rawValue: "Mac"))
    }
}
