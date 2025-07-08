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

struct CourseDetail {
    let code: String
    let title: String
    let description: String
    let credit: Double?
    let difficulty: Double
    let semestersOffered: [String]
    let weeklyHours: [String: [Int]]
    let prerequisites: [String]
}

class CatalogService {
    static let shared = CatalogService()
    private let searchBase = "https://catalog.upenn.edu/search/?search="

    private init() {}

    /// Fetches a CourseDetail for the given code
    func fetchCourseDetail(code: String) async throws -> CourseDetail {
        // Build and validate URL
        let query = code.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: searchBase + query) else {
            throw ScrapeError.invalidURL
        }

        // Download HTML
        let html = try await fetchHTML(from: url)
        let doc  = try SwiftSoup.parse(html)

        // Locate the courseblock
        guard let block = try doc.select("div.search-summary div.courseblock").first() else {
            throw ScrapeError.detailNotFound
        }
        let paras = try block.select("p.courseblockextra.noindent").array()

        // Extract title from the <h3> heading
        let title: String = try {
            if let h3 = try doc.select("h3").first() {
                return try! h3.text().replacingOccurrences(of: "\u{00a0}", with: " ")
            }
            return code
        }()

        // 1) Description
        let description = try paras.first?.text() ?? ""

        // 2) Semesters offered
        var semesters: [String] = []
        for p in paras {
            let txt = try p.text()
            if txt.contains("Fall") || txt.contains("Spring") || txt.contains("Summer") {
                if txt.contains("Fall")   { semesters.append("Fall") }
                if txt.contains("Spring") { semesters.append("Spring") }
                if txt.contains("Summer") { semesters.append("Summer") }
                break
            }
        }

        // 3) Prerequisites
        var prereqs: [String] = []
        for p in paras {
            let txt = try p.text()
            if txt.starts(with: "Prerequisite") {
                let links = try p.select("a.bubblelink.code").array()
                if !links.isEmpty {
                    prereqs = links.map {
                        try! $0.text().replacingOccurrences(of: "\u{00a0}", with: " ")
                    }
                } else {
                    let regex = try NSRegularExpression(pattern: "[A-Z]{2,4}\\s*\\d{4}")
                    let matches = regex.matches(in: txt, range: NSRange(txt.startIndex..., in: txt))
                    prereqs = matches.compactMap { m in
                        Range(m.range, in: txt).map { String(txt[$0]) }
                    }
                }
                break
            }
        }

        // 4) Credit
        var creditValue: Double? = nil
        if let creditPara = paras.last(where: { (try? $0.text().contains("Course Unit")) ?? false }) {
            let text = try creditPara.text()
            let unitRegex = try NSRegularExpression(pattern: #"(\d+(\.\d+)?)\s+Course Unit"#)
            if let match = unitRegex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let r = Range(match.range(at: 1), in: text) {
                creditValue = Double(text[r])
            }
        }

        // 5) Weekly hours (default empty; can be expanded later)
        let weekly: [String: [Int]] = [:]

        // 6) Difficulty (default to 1.0; can be computed later)
        let difficulty = 1.0

        return CourseDetail(
            code: code,
            title: title,
            description: description,
            credit: creditValue,
            difficulty: difficulty,
            semestersOffered: semesters,
            weeklyHours: weekly,
            prerequisites: prereqs
        )
    }

    // Helper to download HTML
    private func fetchHTML(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScrapeError.encodingFailed
        }
        return html
    }
}



