//
//  ScheduleView.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/13/26.
//
import SwiftUI
import Foundation

struct ScheduleView: View {
    
    @State var geo: GeoClientAddress
    @State var selectedDate: Date = Date()

    let calendar = Calendar.current

    // MARK: - Days in selected week
    var daysInWeek: [Date] {
        guard let interval = calendar.dateInterval(of: .weekOfYear, for: selectedDate) else {
            return []
        }

        return (0..<7).compactMap { day in
            calendar.date(byAdding: .day, value: day, to: interval.start)
        }
    }
    // MARK: - Holiday array
    let holidays: [Date] = [
        // Example holidays
        Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 19))!,
        Calendar.current.date(from: DateComponents(year: 2026, month: 2, day: 17))!
    ]


    // MARK: - Pickup days for address
    var pickupDays: [PickupDay] {
        return getPickupDays(address: geo)
    }
    var pickupEvents: [PickupEvent] {
        return   generatePickupEvents(pickupDays: pickupDays, holidays: holidays, referenceDate: selectedDate)
    }

    // MARK: - Pickups for a specific date
    func pickups(on date: Date) -> [PickupDay] {
        let dayWeekday = weekday(for: date)
        return pickupDays.filter { $0.day == dayWeekday }
    }
    func events(on date: Date) -> [PickupEvent] {
        pickupEvents.filter { weekday(for: date)  == $0.newPickupDay.day}
    }

    var body: some View {
        VStack(alignment: .leading) {
            // Header
            VStack(alignment: .leading) {
                Text("Schedule for")
                    .font(.caption)
                    .foregroundColor(.secondary)

                    Text(geo.streetName)
                        .font(.headline)
            }
            .padding(.horizontal)

            // MARK: Weekly selector
            HStack(spacing: 10) {
                ForEach(daysInWeek, id: \.self) { day in
                 
                    VStack {
                        Text(day.format("EEE"))
                            .font(.system(size: 12, weight: .semibold))
                        
                        Text(day.format("d"))
                            .font(.system(size: 18, weight: .bold))
                        
                        let dayEvents = events(on: day)
                        
                        ForEach(dayEvents) { event in
                            let isDelayed = event.reasonForChange != "On schedule"

                            
                          
                            VStack(alignment: .leading, spacing: 2) {

                                HStack(spacing: 4) {
                                    if isDelayed {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .foregroundColor(.orange)
                                            .font(.caption2)
                                            .opacity(0.9)
                                            .scaleEffect(0.9)
                                    }
                                }
                                Text(label(for: event.newPickupDay.type))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)

                                if isDelayed {
                                    Text("Holiday delay")
                                        .font(.caption2)
                                        .foregroundColor(.orange.opacity(0.8))
                                        .italic()
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        calendar.isDate(day, inSameDayAs: selectedDate)
                        ? Color.blue
                        : Color.clear
                    )
                    .foregroundColor(
                        calendar.isDate(day, inSameDayAs: selectedDate)
                        ? .white
                        : .primary
                    )
                    .cornerRadius(10)
                    .onTapGesture {
                        selectedDate = day
                    }
                }
            }
            .padding()

            Spacer()

            Text("Selected Date: \(selectedDate.format("MMMM dd, yyyy"))")
                .padding()
        }
    }

    func label(for type: PickupType) -> String {
        switch type {
        case .trash: return "Trash"
        case .recycle: return "Recycling"
        case .bulk: return "Bulk"
        }
    }
}


extension Date {
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}






