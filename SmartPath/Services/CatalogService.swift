//
//  CatalogService.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation
import SwiftSoup

enum ScrapeError: Error {
    case invalidURL, detailNotFound, encodingFailed
}

class CatalogService {
    static let shared = CatalogService()
    private let searchBase = "https://catalog.upenn.edu/search/?search="

    private init() {}

    /// Fetches all details for a single course code and returns a Course model.
    func fetchCourseDetail(code: String) async throws -> Course {
        // Build the search URL
        let query = code.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: searchBase + query) else {
            throw ScrapeError.invalidURL
        }

        // Download and parse HTML
        let html = try await fetchHTML(from: url)
        let doc  = try SwiftSoup.parse(html)

        // Locate the courseblock
        guard let block = try doc.select("div.search-summary div.courseblock").first() else {
            throw ScrapeError.detailNotFound
        }
        let paras = try block.select("p.courseblockextra.noindent").array()

        // Extract title from the <h3> tag
        let title: String = try {
            if let heading = try doc.select("h3").first() {
                return try! heading.text().replacingOccurrences(of: "\u{00a0}", with: " ")
            }
            return code
        }()

        // 1) Description
        let description = try paras.first?.text() ?? ""

        // 2) Semesters offered
        var semestersOffered: [String] = []
        for p in paras {
            let txt = try p.text()
            if txt.contains("Fall") || txt.contains("Spring") || txt.contains("Summer") {
                if txt.contains("Fall")   { semestersOffered.append("Fall") }
                if txt.contains("Spring") { semestersOffered.append("Spring") }
                if txt.contains("Summer") { semestersOffered.append("Summer") }
                break
            }
        }

        // 3) Prerequisites
        var prerequisites: [String] = []
        for p in paras {
            let txt = try p.text()
            if txt.starts(with: "Prerequisite") {
                let links = try p.select("a.bubblelink.code").array()
                if !links.isEmpty {
                    prerequisites = links.map {
                        try! $0.text().replacingOccurrences(of: "\u{00a0}", with: " ")
                    }
                } else {
                    let regex = try NSRegularExpression(pattern: "[A-Z]{2,4}\\s*\\d{4}")
                    let matches = regex.matches(in: txt, range: NSRange(txt.startIndex..., in: txt))
                    prerequisites = matches.compactMap { match in
                        let range = Range(match.range, in: txt)!
                        return String(txt[range])
                    }
                }
                break
            }
        }

        // 4) Credit
        var credit: Double? = nil
        if let creditPara = paras.last(where: { (try? $0.text().contains("Course Unit")) ?? false }) {
            let text = try creditPara.text()
            let unitRegex = try NSRegularExpression(pattern: #"(\d+(\.\d+)?)\s+Course Unit"#)
            if let match = unitRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                credit = Double(text[range])
            }
        }

        // 5) Weekly hours (not scraped yet, default empty)
        let weeklyHours: [String: [Int]] = [:]

        // 6) Difficulty default
        let difficulty = 1.0

        // Construct and return your Course model
        return Course(
            code:               code.capitalized,
            title:              title,
            description:        description,
            credit:             credit,
            difficulty:         difficulty,
            prerequisites:      prerequisites,
            semestersOffered:   semestersOffered,
            weeklyHours:        weeklyHours
        )
    }

    /// Helper to fetch raw HTML from a URL
    private func fetchHTML(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScrapeError.encodingFailed
        }
        return html
    }
}


