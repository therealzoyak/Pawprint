import Foundation

struct FetchAICandidate: Codable {
    let id: String
    let title: String
    let description: String
    let category: String
    let durationMinutes: Int
    let materials: [String]
}

struct FetchAIRequest: Codable {
    let question: String
    let petName: String
    let species: String
    let age: String
    let energy: String
    let limitations: [String]
    let availableMaterials: [String]
    let candidates: [FetchAICandidate]
}

struct FetchAIResponse: Codable {
    let activityID: String
    let answer: String
}

enum FetchAIError: LocalizedError {
    case invalidServerURL
    case invalidResponse
    case server(String)

    var errorDescription: String? {
        switch self {
        case .invalidServerURL: "Ask Fetch isn’t connected to its AI service yet."
        case .invalidResponse: "Fetch received an incomplete answer. Please try again."
        case .server(let message): message
        }
    }
}

struct FetchAIService {
    private let session: URLSession
    private let baseURL: URL?

    init(session: URLSession = .shared, baseURL: URL? = nil) {
        self.session = session
        if let baseURL {
            self.baseURL = baseURL
        } else if let configured = Bundle.main.object(forInfoDictionaryKey: "FetchAIBaseURL") as? String,
                  !configured.isEmpty,
                  !configured.contains("$("),
                  let url = URL(string: configured) {
            self.baseURL = url
        } else {
            self.baseURL = URL(string: "http://127.0.0.1:8000")
        }
    }

    func ask(_ request: FetchAIRequest) async throws -> FetchAIResponse {
        guard let endpoint = baseURL?.appending(path: "fetch") else { throw FetchAIError.invalidServerURL }
        var urlRequest = URLRequest(url: endpoint)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = 30
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONEncoder().encode(request)

        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else { throw FetchAIError.invalidResponse }
        guard (200..<300).contains(http.statusCode) else {
            let detail = (try? JSONDecoder().decode(ServerError.self, from: data).detail)
            throw FetchAIError.server(detail ?? "Fetch couldn’t reach its AI helper. Please try again.")
        }
        return try JSONDecoder().decode(FetchAIResponse.self, from: data)
    }

    private struct ServerError: Codable { let detail: String }
}
