import Foundation

enum ISO8601DateCoder {
    private static let formatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    private static let formatterWithoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    static var formatter: ISO8601DateFormatter {
        formatterWithFractionalSeconds
    }

    static func decoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)

            if let date = formatterWithFractionalSeconds.date(from: dateString) {
                return date
            }

            if let fallbackDate = formatterWithoutFractionalSeconds.date(from: dateString) {
                return fallbackDate
            }

            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Expected date string to be ISO8601-formatted."
                )
            )
        }
        return decoder
    }

    static func encoder() -> JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .custom { date, encoder in
            let dateString = formatterWithFractionalSeconds.string(from: date)
            var container = encoder.singleValueContainer()
            try container.encode(dateString)
        }
        return encoder
    }
}
