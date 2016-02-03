//
//  CSV.swift
//  SwiftCSV
//
//  Created by naoty on 2014/06/09.
//  Copyright (c) 2014年 Naoto Kaneko. All rights reserved.
//

import Foundation

public class CSV {
	public var headers: [String] = []
	public var rows: [Dictionary<String, String>] = []
	public var columns = Dictionary<String, [String]>()
	var delimiter: Character = ","
	
	public init(string: String, delimiter: Character = ",") {
		self.delimiter = delimiter
		
		let newline = NSCharacterSet.newlineCharacterSet()
		var lines: [String] = []
		string.stringByTrimmingCharactersInSet(newline).enumerateLines { line, stop in lines.append(line) }
		
		self.headers = self.parseHeaders(fromLines: lines)
		self.rows = self.parseRows(fromLines: lines)
		self.columns = self.parseColumns(fromLines: lines)
	}
	
	public convenience init?(contentsOfURL url: NSURL, delimiter: Character = ",", encoding: UInt = NSUTF8StringEncoding) throws {
		let csvString = try String(contentsOfURL: url, encoding: encoding)
		self.init(string: csvString, delimiter: delimiter)
	}
	
	public class func parseLine(line: String, delimiter: Character = ",") -> [String] {
		
		var columns: [String] = [""]
		
		var inQuotes = false
		for char in line.characters {
			switch char {
			case delimiter:
				inQuotes ? columns[columns.indices.last!].append(char) : columns.append("")
			case "\"":
				inQuotes = !inQuotes
			default:
				columns[columns.indices.last!].append(char)
			}
		}
		
		return columns
	}
	
	func parseHeaders(fromLines lines: [String]) -> [String] {
		return CSV.parseLine(lines[0], delimiter: delimiter)
	}
	
	func parseRows(fromLines lines: [String]) -> [Dictionary<String, String>] {
		var rows: [Dictionary<String, String>] = []
		
		for (lineNumber, line) in lines.enumerate() {
			if lineNumber == 0 {
				continue
			}
			
			var row = Dictionary<String, String>()
//			let values = line.componentsSeparatedByCharactersInSet(self.delimiter)
			let values = CSV.parseLine(line, delimiter: delimiter)
			for (index, header) in self.headers.enumerate() {
				if index < values.count {
					row[header] = values[index]
				} else {
					row[header] = ""
				}
			}
			rows.append(row)
		}
		
		return rows
	}
	
	func parseColumns(fromLines lines: [String]) -> Dictionary<String, [String]> {
		var columns = Dictionary<String, [String]>()
		
		for header in self.headers {
			let column = self.rows.map { row in row[header] != nil ? row[header]! : "" }
			columns[header] = column
		}
		
		return columns
	}
}
