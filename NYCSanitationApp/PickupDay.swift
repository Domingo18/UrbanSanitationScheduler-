//
//  PickupDay.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/13/26.
//
import Foundation

struct PickupDay: Identifiable {
    let id = UUID()
    let day: WeekDay
    let type: PickupType
}

struct PickupEvent: Identifiable {
    let id = UUID()
    let oldPickupDay: PickupDay
    let newPickupDay: PickupDay
    let reasonForChange: String
}

enum WeekDay: Int, CaseIterable {
    
    case sunday = 1
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    
}

enum PickupType: String, CaseIterable {
    case trash = "t"
    case bulk = "b"
    case recycle =  "r"
}

func getPickupDays(address: GeoClientAddress) -> [PickupDay] {
    var pickupDays: [PickupDay] = []

    
    // parse for pickup types
    func parse(_ schedule: String?, type: PickupType) {
        guard let schedule = schedule?.lowercased() else { return }

        var index = schedule.startIndex

        while index < schedule.endIndex {
            let char = schedule[index]
            var weekday: WeekDay?

            // Handle "th" (Thursday)
            if char == "t" {
                let nextIndex = schedule.index(after: index)
                if nextIndex < schedule.endIndex,
                   schedule[nextIndex] == "h" {
                    weekday = .thursday
                    index = schedule.index(after: nextIndex) // consume "th"
                } else {
                    weekday = .tuesday
                    index = schedule.index(after: index)
                }
            } else {
                switch char {
                case "m": weekday = .monday
                case "w": weekday = .wednesday
                case "f": weekday = .friday
                case "s": weekday = .saturday
                case "u": weekday = .sunday
                default:  weekday = nil
                }
                index = schedule.index(after: index)
            }

            if let weekday {
                pickupDays.append(
                    PickupDay(day: weekday, type: type)
                )
            }
        }
    }

    parse(address.sanitationTrashSchedule, type: .trash)
    parse(address.sanitationRecyclingSchedule, type: .recycle)
    parse(address.sanitationLargeItemsSchedule, type: .bulk)

    return pickupDays
}

// Find the start of the week for a specific Date
func startOfWeek(for date: Date) -> Date {
    let calendar = Calendar.current
    let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
    return calendar.date(from: components)!
}


// Find a date for a WeekDay type.
func date(
    for weekday: WeekDay,
    inWeekContaining referenceDate: Date
) -> Date {
    let calendar = Calendar.current
    let weekStart = startOfWeek(for: referenceDate)

    let offset = weekday.rawValue - calendar.component(.weekday, from: weekStart)

    return calendar.date(byAdding: .day, value: offset, to: weekStart)!
}


//generate a array of pickup events to display on the calendar, taking into account holiday delays.
func generatePickupEvents(pickupDays: [PickupDay], holidays: [Date], referenceDate: Date) -> [PickupEvent] {
    
    var events: [PickupEvent] = []
    
    
    //Format holiday dates to avoid calendar errors
    let normalizedHolidays = holidays.map {
        Calendar.current.startOfDay(for: $0)
    }

        
    // iterate over pickupDays
    for pickup in pickupDays {
        let oldDate = date(for: pickup.day, inWeekContaining: referenceDate)


        var newDate = Calendar.current.startOfDay(for: oldDate)
        // start with the original pickup date
        // shift if needed
        
        while normalizedHolidays.contains(newDate) {
            newDate = Calendar.current.date(byAdding: .day, value: 1, to: newDate)!
        }
    
        
        let reason = (newDate == oldDate) ? "On schedule" : "Delayed due to holiday"

        let event = PickupEvent(
            oldPickupDay: PickupDay(day: pickup.day, type: pickup.type),
            newPickupDay: PickupDay(day: weekday(for: newDate), type: pickup.type),
            reasonForChange: reason
                )
        events.append(event)
    }

    
    return events
}



//function to find a WeekDay type from a Date type
func weekday(for date: Date) -> WeekDay {
    let calendar = Calendar.current
    let value = calendar.component(.weekday, from: date)
    return WeekDay(rawValue: value)!
}







