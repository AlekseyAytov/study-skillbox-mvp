//
//  String + extension.swift
//  18.6 Practice task
//
//  Created by Alex Aytov on 7/13/23.
//

import Foundation

extension String {
    public func trimHTMLTags() -> String? {
            guard let htmlStringData = self.data(using: .utf8) else { return nil }
        
            let options: [NSAttributedString.DocumentReadingOptionKey : Any] = [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ]
        
            let attributedString = try? NSAttributedString(data: htmlStringData, options: options, documentAttributes: nil)
            return attributedString?.string
    }
}
