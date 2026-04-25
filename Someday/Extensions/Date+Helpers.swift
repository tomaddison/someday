import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }

    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }

    var endOfWeek: Date {
        Calendar.current.date(byAdding: .day, value: 6, to: startOfWeek) ?? self
    }

    var weekDates: [Date] {
        let start = startOfWeek
        return (0..<7).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: start) }
    }

    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }

    var dayOfMonth: Int {
        Calendar.current.component(.day, from: self)
    }

    var shortDayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: self).prefix(1)).uppercased()
    }

    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: self)
    }

    var monthSectionTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = year == Date().year ? "MMMM" : "MMMM yyyy"
        return formatter.string(from: self)
    }

    var weekNumber: Int {
        Calendar.current.component(.weekOfYear, from: self)
    }

    var year: Int {
        Calendar.current.component(.year, from: self)
    }

    var timeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }

    var isAtMidnight: Bool {
        let c = Calendar.current.dateComponents([.hour, .minute, .second], from: self)
        return c.hour == 0 && c.minute == 0 && (c.second ?? 0) == 0
    }

    var momentTitleString: String {
        let day = dayOfMonth
        let suffix: String
        switch day {
        case 11, 12, 13: suffix = "th"
        case _ where day % 10 == 1: suffix = "st"
        case _ where day % 10 == 2: suffix = "nd"
        case _ where day % 10 == 3: suffix = "rd"
        default: suffix = "th"
        }

        let timeSuffix = isAtMidnight ? "" : " at \(timeString)"

        if Calendar.current.isDateInToday(self) {
            return "Today\(timeSuffix)"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday\(timeSuffix)"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return "\(formatter.string(from: self)) \(day)\(suffix)\(timeSuffix)"
        }
    }

    var relativeDayString: String {
        if Calendar.current.isDateInToday(self) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: self)
        }
    }

    func isSameDay(as other: Date) -> Bool {
        Calendar.current.isDate(self, inSameDayAs: other)
    }

    func isSameMonth(as other: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.component(.month, from: self) == calendar.component(.month, from: other)
            && calendar.component(.year, from: self) == calendar.component(.year, from: other)
    }
}
