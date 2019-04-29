//
//  DateService.swift
//  AirBoard
//
//  Created by Кирилл Клименков on 4/8/19.
//  Copyright © 2019 Кирилл Клименков. All rights reserved.
//

import Foundation

class DateService {
    
    func convert(unix timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: Double(timestamp))
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "EEEE, MMMM d"
        
        return formatter.string(from: date)
    }
    
    func getCurrentDate() -> Date {
        var calendar = Calendar(identifier: .gregorian)
        let currentDay = Date()
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        
        return calendar.startOfDay(for: currentDay)
    }
    
    func subract(from date: Date, days: Int) -> Date {
        return date.addingTimeInterval(TimeInterval(-days * 24 * 60 * 60))
    }
}

extension Double {
    func getDateFromUTC() -> String {
        let date = Date(timeIntervalSince1970: self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
}
