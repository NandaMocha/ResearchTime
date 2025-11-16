import Foundation

extension DateFormatter {
    static let appDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    static let appDateOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

    static let appTimeOnlyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Date {
    var formattedDateAndTime: String {
        DateFormatter.appDateFormatter.string(from: self)
    }

    var formattedDate: String {
        DateFormatter.appDateOnlyFormatter.string(from: self)
    }

    var formattedTime: String {
        DateFormatter.appTimeOnlyFormatter.string(from: self)
    }
}
