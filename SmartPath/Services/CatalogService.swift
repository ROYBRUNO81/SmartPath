//
//  CatalogService.swift
//  SmartPath
//
//  Created by Bruno Ndiba Mbwaye Roy on 7/6/25.
//

import Foundation
import SwiftSoup

enum ScrapeError: Error {
    case invalidURL, tableNotFound, detailNotFound, encodingFailed
}

struct CourseDetail {
    let description: String
    let prerequisites: [String]
    let semestersOffered: [String]
    let weeklyHours: [String: [Int]]
    let difficulty: Double
}

class CatalogService {
    static let shared = CatalogService()
    private let searchBase = "https://catalog.upenn.edu/search/?search="

    private init() {}

    func fetchMajorRequirements(from url: URL) async throws -> [CourseDetail] {
        let html = try await fetchHTML(from: url)
        let doc = try SwiftSoup.parse(html)
        guard let table = try doc.select("table.sc_courselist").first() else {
            throw ScrapeError.tableNotFound
        }
        var courses: [CourseDetail] = []
        let rows = try table.select("tr").array()
        for row in rows {
            guard
                let codeTd = try row.select("td.codecol").first(),
                let titleTd = try row.select("td:nth-of-type(2)").first(),
                let creditTd = try row.select("td:nth-of-type(3)").first()
            else { continue }
            let rawCode = try codeTd.text().replacingOccurrences(of: "\u{00a0}", with: " ")
            let primary = rawCode.split(separator: "/")[0].trimmingCharacters(in: .whitespaces)
            let parts = primary.split(separator: " ")
            guard parts.count == 2, Int(parts[1]) != nil else { continue }
            let detail = try await fetchCourseDetail(code: String(primary))
            courses.append(detail)
        }
        return courses
    }

    func fetchCourseDetail(code: String) async throws -> CourseDetail {
        let query = code.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: searchBase + query) else {
            throw ScrapeError.invalidURL
        }
        let html = try await fetchHTML(from: url)
        let doc = try SwiftSoup.parse(html)
        guard let block = try doc.select("div.search-summary div.courseblock").first() else {
            throw ScrapeError.detailNotFound
        }
        let paras = try block.select("p.courseblockextra.noindent").array()
        let description = try paras.first?.text() ?? ""

        // Semesters
        var semesters: [String] = []
        for p in paras {
            let txt = try p.text()
            if txt.contains("Fall") || txt.contains("Spring") || txt.contains("Summer") {
                if txt.contains("Fall") { semesters.append("Fall") }
                if txt.contains("Spring") { semesters.append("Spring") }
                if txt.contains("Summer") { semesters.append("Summer") }
                break
            }
        }

        // Prerequisites
        var prereqs: [String] = []
        for p in paras {
            let txt = try p.text()
            if txt.starts(with: "Prerequisite") {
                let links = try p.select("a.bubblelink.code").array()
                if !links.isEmpty {
                    prereqs = links.compactMap { try? $0.text().replacingOccurrences(of: "\u{00a0}", with: " ") }
                } else {
                    let regex = try NSRegularExpression(pattern: "[A-Z]{2,4}\\s*\\d{4}")
                    let matches = regex.matches(in: txt, range: NSRange(txt.startIndex..., in: txt))
                    prereqs = matches.compactMap { match in
                        let range = Range(match.range, in: txt)!; return String(txt[range])
                    }
                }
                break
            }
        }

        // Weekly hours (not scraped, default empty)
        let weekly: [String: [Int]] = [:]
        // Difficulty default
        let difficulty = 1.0

        return CourseDetail(
            description: description,
            prerequisites: prereqs,
            semestersOffered: semesters,
            weeklyHours: weekly,
            difficulty: difficulty
        )
    }

    private func fetchHTML(from url: URL) async throws -> String {
        let (data, _) = try await URLSession.shared.data(from: url)
        guard let html = String(data: data, encoding: .utf8) else {
            throw ScrapeError.encodingFailed
        }
        return html
    }
}
