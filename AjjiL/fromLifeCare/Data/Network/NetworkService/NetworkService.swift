//  LifeCare
//
//  NetworkService.swift
//  Created by: M.Magdy on 5/5/25.
//

import Combine
import Foundation

class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    private let logging: Logging

    // MARK: - Initialization
    init(logging: Logging = APIDebugger()) {
        self.logging = logging
    }

    // MARK: - Public Methods
    func fetchData<T: Decodable>(target: TargetType, responseClass: T.Type) -> AnyPublisher<T, Error> {
        guard let urlRequest = buildURLRequest(for: target) else {
            return Fail(error: NetworkError.invalidURL).eraseToAnyPublisher()
        }
        
        logging.logRequest(request: urlRequest)
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .tryMap { [weak self] output in
                guard let self = self else {
                    throw NetworkError.unknown(URLError(.cancelled))
                }
                
                guard let response = output.response as? HTTPURLResponse else {
                    throw NetworkError.unknown(URLError(.badServerResponse))
                }
                
                self.logging.logResponse(request: urlRequest, response: response, data: output.data)
                self.saveHeaders(from: response)
                
                return try self.validateStatusCode(response: response, data: output.data, target: target)
            }
            .tryMap { [weak self] data -> T in
                guard let self = self else { throw NetworkError.decodingFailed }
                return try self.decodeSuccessData(data: data, type: T.self)
            }
            .mapError { error in
                (error as? NetworkError) ?? NetworkError.unknown(error)
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private Helper Methods
    
    private func buildURLRequest(for target: TargetType) -> URLRequest? {
        let urlString = target.baseURL + target.path
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = target.methods.rawValue
        
        if let headers = target.headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        switch target.task {
        case .requestPlain:
            break
        case .requestParameters(let parameters, let encoding):
            if encoding == .inBodyEncoding {
                request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
            } else if encoding == .inURLEncoding {
                var urlComponents = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
                urlComponents?.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                if let updatedURL = urlComponents?.url {
                    request.url = updatedURL
                }
            }
        }
        
        return request
    }
    
    private func saveHeaders(from response: HTTPURLResponse) {
        let defaults = UserDefaults.standard
        
        if let cartItemsCount = response.value(forHTTPHeaderField: "cartItems-count") {
            defaults.set(cartItemsCount, forKey: "cartCount")
        } else {
            defaults.set(0, forKey: "cartCount")
        }
        
        if let unReadNotificationCount = response.value(forHTTPHeaderField: "unReadNotification-count") {
            defaults.set(unReadNotificationCount, forKey: "unread")
        }
        
        if let activeNotification = response.value(forHTTPHeaderField: "active-Notification") {
            defaults.set(activeNotification, forKey: Constants.shared.isActiveNotification)
        }
    }
    
    private func validateStatusCode(response: HTTPURLResponse, data: Data, target: TargetType) throws -> Data {
        switch response.statusCode {
        case 200...299:
            return data
            
        case 401:
            if target.path == "login" || target.path == "change-password" {
                throw NetworkError.unauthorized
            } else {
                handleUnauthorizedAppReset()
                throw NetworkError.requestFailed(statusCode: response.statusCode)
            }
            
        case 403:
            if target.path == "login" {
                throw NetworkError.requestFailedWithMessage(
                    statusCode: response.statusCode,
                    message: "Phone or password is incorrect, please try again".localized()
                )
            } else {
                throw NetworkError.requestFailed(statusCode: response.statusCode)
            }
            
        case 400...499, 500...599:
            let errorMessage = extractErrorMessage(from: data)
            throw NetworkError.requestFailedWithMessage(
                statusCode: response.statusCode,
                message: errorMessage
            )
            
        default:
            throw NetworkError.unknown(URLError(.badServerResponse))
        }
    }
    
    private func handleUnauthorizedAppReset() {
        UserDefaults.standard.removeObject(forKey: "userDataKey")
        UserDefaults.standard.removeObject(forKey: "userTokenKey")
        UserDefaults.standard.removeObject(forKey: "isGuestMode")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            MOLH.reset()
        }
    }
    
    private func extractErrorMessage(from data: Data) -> String {
        do {
            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
            return errorResponse.message ?? "Unknown error."
        } catch {
            print("Error decoding error response: \(error.localizedDescription)")
            return "Unknown error."
        }
    }
    
    private func decodeSuccessData<T: Decodable>(data: Data, type: T.Type) throws -> T {
        do {
            // Optional: Keep raw JSON logging for debugging
            if let rawJSON = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Raw JSON: \(rawJSON)")
            }
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            logDecodingError(decodingError, data: data)
            throw NetworkError.decodingFailed
        }
    }
    
    private func logDecodingError(_ error: DecodingError, data: Data?) {
        switch error {
        case .typeMismatch(let type, let context):
            print("Decoding Error: Type mismatch for type \(type) - \(context.debugDescription)")
            if let codingPath = context.codingPath.last?.stringValue {
                print("Key causing error: \(codingPath)")
            }
        case .valueNotFound(let type, let context):
            print("Decoding Error: Value not found for type \(type) - \(context.debugDescription)")
        case .keyNotFound(let key, let context):
            print("Decoding Error: Key '\(key.stringValue)' not found - \(context.debugDescription)")
        case .dataCorrupted(let context):
            print("Decoding Error: Data corrupted - \(context.debugDescription)")
        @unknown default:
            print("Decoding Error: Unknown error occurred")
        }
    }
}
