//
//  File.swift
//  MovieBrowser
//
//  Created by Yefga on 14/09/25.
//

import Foundation

extension Int {
    static var zero: Self { 0 }
    static var one: Self { 1 }
}

extension String {
    static var zero: Self { "0" }
    static var empty: Self { "" }
}

extension String {
    enum DateFormat: String {
        case short = "dd/MM/yyyy"
        case long = "MMMM dd, yyyy"
        case time = "HH:mm"
        case yyyyMMdd = "yyyy-MM-dd"
    }
    
    func convertDate(from source: DateFormat, to target: DateFormat) -> String? {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = source.rawValue
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = target.rawValue
        
        guard let date = inputFormatter.date(from: self) else { return nil }
        return outputFormatter.string(from: date)
    }
}
