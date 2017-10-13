//
//  DateExtensions.swift
//  VVV
//
//  Created by James Swiney on 15/2/17.
//  Copyright © 2017 Vroom Vroom Vroom. All rights reserved.
//

import Foundation

/** Various date helper methods */
extension Date {
    
    /**
     
     If the current time is before 10:00am use today at 10 otherwise use tomorrow at 10:0am
     
     -Return:
        - Date: Date object for 10:00am today or tomorrow depending on current time.
     
     */
    public static func tenAmTodayOrTomorrow() -> Date {
        
        guard let newDate = (Calendar.current as NSCalendar).date(bySettingHour: 10, minute: 0, second: 0, of: Date(), options: NSCalendar.Options.matchFirst) else { return Date() }
        
        let today = Date()
        
        //if 10am is in the past we move to tomorrow
        if newDate.compare(today) == .orderedAscending {
            return dateByAddingDays(date: newDate, days: 1)
        }
        return newDate
        
    }
    
    /**
     
     Adds days onto a Date object
     
     - Parameters:
     - date: The date to have the days added
     - days: The number of days to add.
     -Return:
     - Date: The initial date with the days added on.
     
     */
    public static func dateByAddingDays(date:Date,days:Int) -> Date {
        
        var dateComps = DateComponents()
        dateComps.day = days
        
        guard let newDate = (Calendar.current as NSCalendar).date(byAdding: dateComps, to: date, options: NSCalendar.Options.matchFirst) else { return Date() }
        
        return newDate
    }
    
    /**
     
     Ignores the time on the passed in dat param and only updates the days/months/year
     
     - Parameters:
     - newDate: The date to set the days/months/years for
     -Return:
     - Date: The new date object with the changed days/months/years
     
     */
    func setDateButKeepTime(newDate:Date) -> Date {
        
        let cal = Calendar.current
        
        let dayComps = (cal as NSCalendar).components([.day,.month,.year], from: newDate)
        let timeComps = (cal as NSCalendar).components([.hour,.minute,.second], from: self)
        
        var combinedComponants = DateComponents()
        combinedComponants.day = dayComps.day
        combinedComponants.month = dayComps.month
        combinedComponants.year = dayComps.year
        
        combinedComponants.hour = timeComps.hour
        combinedComponants.minute = timeComps.minute
        combinedComponants.second = timeComps.second
        
        guard let date = cal.date(from: combinedComponants) else { fatalError("unable to keep time on date") }
        
        return date
    }
    
    /**
     
     Ignores the days/months/year on the passed in date param and only updates the hours/minutes/seconds
     
     - Parameters:
     - newTime: The date to set the hours/minutes/seconds for
     -Return:
     - Date: The new date object with the changed hours/minutes/seconds
     
     */
    func setTimeButKeepDate(newTime:Date) -> Date {
        
        let cal = Calendar.current
        
        let dayComps = (cal as NSCalendar).components([.day,.month,.year], from: self)
        let timeComps = (cal as NSCalendar).components([.hour,.minute,.second], from: newTime)
        
        var combinedComponants = DateComponents()
        combinedComponants.day = dayComps.day
        combinedComponants.month = dayComps.month
        combinedComponants.year = dayComps.year
        
        combinedComponants.hour = timeComps.hour
        combinedComponants.minute = timeComps.minute
        combinedComponants.second = timeComps.second
        
        guard let date = cal.date(from: combinedComponants) else { fatalError("unable to keep time on date") }
        
        return date
        
    }
    
    /**
     
     Maps a Date object from the standard JSON API date format
     
     - Parameters:
     -  jsonData: the json date object
     -Return:
        - Date: The Date object if mapping was successful
     
     */
    static func dateFrom(jsonData:Any) -> Date? {
        
        guard let validDict = jsonData as? [String:Any],
            let timeString = validDict["time"] as? String,
            let dateString = validDict["date"] as? String else { return nil }
        
        return Date.dateFrom(timeString: timeString, dateString: dateString)
    }
    
    /**
     
     Creates a date from a seperate time and dateString of the standard API format
     
     - Parameters:
     - timeString: the time in HH:mm:ss format
     - dateString: the date in a YYYY-MM-dd format
     -Return:
     - Date: The Date object if mapping was successful
     
     */
    static func dateFrom(timeString:String,dateString:String) -> Date? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        var time : Date?
        time = timeFormatter.date(from: timeString)
        if time == nil {
            timeFormatter.dateFormat = "HH:mm"
            time = timeFormatter.date(from: timeString)
        }
        
        guard let timeDate = time,
            let date = dateFormatter.date(from: dateString) else {
                return nil
        }
        return date.setTimeButKeepDate(newTime: timeDate)
        
    }
    
    /**
     
     Creates a string from a date in the format to send in the vroom api requests
     
     -Return:
     - String: The date in string format of YYYY-MM-dd
     
     */
    func apiFormattedDateString() -> String {
        
        let formatter = DateFormatter()
        //We set to US so that english numerals are used.
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "YYYY-MM-dd"
        
        return formatter.string(from: self)
    }
    
    /**
     
     Creates a string from a date(time) in the format to send in the vroom api requests
     
     -Return:
     - String: The date in string format of HH:mm
     
     */
    func apiFormattedTimeString() -> String {
        let formatter = DateFormatter()
        //We set to US so that english numerals are used.
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm"
        
        return formatter.string(from: self)
    }
}
