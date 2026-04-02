//  LifeCare
//
//NetworkServiceProtocol.swift

//Created by: M.Magdy on 5/5/25.
//

import Combine
import Foundation
import UIKit

protocol NetworkServiceProtocol {
    func fetchData<T: Decodable>(target: TargetType, responseClass: T.Type) -> AnyPublisher<T, Error>
    
//    func uploadMultipart(
//        path: String,
//        parameters: [String: Any],
//        photos: [String: UIImage?],
//        photosArray: [String: [UIImage]?]?,
//        medicalDocuments: [String: [MedicalDocument]?]?,
//        useFullPath: Bool, 
//        completion: @escaping (Result<[String: Any], NetworkError>) -> Void
//    )
//    func uploadAudioFile(
//        path: String,
//        parameters: [String: Any],
//        audioURL: URL,
//        useFullPath: Bool ,
//        completion: @escaping (Result<[String: Any], NetworkError>) -> Void
//    )
    
    
}



protocol Logging {
    func logRequest(request: URLRequest)
    func logResponse(request: URLRequest, response: URLResponse?, data: Data?)
}
