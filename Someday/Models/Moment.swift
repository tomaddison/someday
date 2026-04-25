import Foundation
import SwiftData

@Model
final class Moment {
    var note: String
    var photoPath: String?
    var createdAt: Date
    var somedays: [SomedayItem] = []

    init(
        note: String,
        photoPath: String? = nil,
        createdAt: Date = Date(),
        somedays: [SomedayItem] = []
    ) {
        self.note = note
        self.photoPath = photoPath
        self.createdAt = createdAt
        self.somedays = somedays
    }
}
