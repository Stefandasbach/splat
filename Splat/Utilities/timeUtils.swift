//
//  timeUtils.swift
//  Splat
//
//  Created by Aaron Tainter on 3/18/15.
//  Copyright (c) 2015 Team Splat. All rights reserved.
//

import Foundation

func calculateDateDifference(start: NSDate, end: NSDate) -> NSDateComponents? {
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    var components = calendar?.components(.CalendarUnitDay, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
    
    return components
}

//should probably clean these methods up
func getStringTimeDiff(start: NSDate, end: NSDate)->(number: Int, unit: String) {
    
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    var difference = calendar?.components(.CalendarUnitDay, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
    if let days = difference?.day {
        if (days == 0) {
            var difference = calendar?.components(.CalendarUnitHour, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
            if let hours = difference?.hour {
                if (hours == 0) {
                    var difference = calendar?.components(.CalendarUnitMinute, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
                    if let minutes = difference?.minute {
                        if (minutes == 0) {
                            var difference = calendar?.components(.CalendarUnitSecond, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
                            if let seconds = difference?.second {
                                return (seconds, "s")
                            }
                        } else {
                            return (minutes, "m")
                        }
                    }
                } else {
                    return (hours, "h")
                }
            }
        }
        else {
            return(days, "d")
        }
    }
    return (0, "")
}

func getStringTimeTo(start: NSDate, end: NSDate)->(number: Int, unit: String) {
    
    if (end.timeIntervalSinceNow < 0) {
        return (0, "Ended")
    }
    
    var calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
    
    var difference = calendar?.components(.CalendarUnitMonth, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
    if let months = difference?.month {
        if (months == 0) {
            
            var difference = calendar?.components(.CalendarUnitDay, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
            if let days = difference?.day {
                if (days == 0) {
                    var difference = calendar?.components(.CalendarUnitHour, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
                    if let hours = difference?.hour {
                        if (hours == 0) {
                            var difference = calendar?.components(.CalendarUnitMinute, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
                            if let minutes = difference?.minute {
                                if (minutes == 0) {
                                    var difference = calendar?.components(.CalendarUnitSecond, fromDate: start, toDate: end, options: NSCalendarOptions.allZeros)
                                    if let seconds = difference?.second {
                                        if (seconds == 1) {
                                            return (seconds, "second")
                                        }
                                        return (seconds, "seconds")
                                    }
                                } else {
                                    if (minutes == 1) {
                                        return (minutes, "minute")
                                    }
                                    return (minutes, "minutes")
                                }
                            }
                        } else {
                            if (hours == 1) {
                                return (hours, "hour")
                            }
                            return (hours, "hours")
                        }
                    }
                }
                else {
                    if (days == 1) {
                        return (days, "day")
                    }
                    return(days, "days")
                }
            }
        }
        else {
            if (months == 1) {
                return (months, "month")
            }
            return (months, "months")
        }
    }
    return (0, "")
}

