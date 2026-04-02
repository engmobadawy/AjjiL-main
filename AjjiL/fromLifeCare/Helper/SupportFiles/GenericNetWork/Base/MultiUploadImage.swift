
////
////  UploadImage.swift

////

import UIKit
//import Alamofire
//import MOLH

//class MultipartUploadImage {
//    
//    static var shared = MultipartUploadImage()
//    
//    
//    
//    func uploadDoc(
//        path: String,
//        docsData: [Data],
//        docsUrl: [URL],
//        parameters: [String:Any],
//        paramName: String? = nil,
//        completion: @escaping (String?, NSError?,Int?) -> Void) {
//            
//            let toLanguage = MOLHLanguage.currentAppleLanguage()
//            let token:String = "\(GenericUserDefault.shared.getValue(Constants.shared.token) ?? "no token")"
//            
//            AF.upload(multipartFormData: { (form: MultipartFormData) in
//                
//                for (key, value) in parameters {
//                    if let temp = value as? String {
//                        form.append(temp.data(using: .utf8)!, withName: key)
//                    }
//                    if let temp = value as? Int {
//                        form.append("\(temp)".data(using: .utf8)!, withName: key)
//                    }
//                    if let temp = value as? Double {
//                        form.append("\(temp)".data(using: .utf8)!, withName: key)
//                    }
//                    if let temp = value as? Float {
//                        form.append("\(temp)".data(using: .utf8)!, withName: key)
//                    }
//                    if let temp = value as? NSArray {
//                        temp.forEach({ element in
//                            let keyObj = key + "[]"
//                            if let string = element as? String {
//                                form.append(string.data(using: .utf8)!, withName: keyObj)
//                            } else
//                            if let num = element as? Int {
//                                let value = "\(num)"
//                                form.append(value.data(using: .utf8)!, withName: keyObj)
//                            }
//                        })
//                    }
//                }
//                
//                for i in 0 ..< docsData.count {
//                    form.append(docsData[i], withName: "report_documents[]", fileName:docsUrl[i].lastPathComponent, mimeType: "*/*")
//                    print(form)
//                }
//                
//            },
//                      to: "\(Constants.shared.baseURL)\(path)", method: .post , headers: [
//                        "Authorization": "Bearer \(token)",
//                        "Content-Type": "application/json",
//                        "X-device": "ios",
//                        "Accept": "multipart/form-data",
//                        "X-Language":"\(toLanguage)",
//                        "X-Portal": "Patient"
//                      ])
//            .response { resp in
//                print("status code -----------:> \(resp.response?.statusCode ?? 0)")
//                print("url is -----------:> \(Constants.shared.baseURL)\(path)")
//                print("parameters is -----------:> \(parameters)")
//                //            print("headers:-----------:>\(headers)")
//                debugPrint(String(data: resp.data ?? Data(), encoding: .utf8) ?? "no data")
//                switch resp.result {
//                case .success(let value):
//                    do{
//                        let jsonResult = try JSONSerialization.jsonObject(with: value!, options: []) as? [String : Any]
//                        let message = jsonResult?["message"] as? String ?? ""
//                        completion(message, nil, resp.response?.statusCode ?? 0)
//                    } catch let error {
//                        print("couldn't convert response to json:",error)
//                        let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "operation failed"])
//                        completion("operation failed",error, resp.response?.statusCode ?? 0)
//                    }
//                    
//                case .failure(_):
//                    let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "operation failed"])
//                    completion("operation failed",error, resp.response?.statusCode ?? 0)
//                    
//                }
//            }
//        }
//}
//
//
//import UIKit
//import Alamofire
////import MOLH
//
//class MultipartUploadImages
//{
//    static var shared = MultipartUploadImages()
//    func uploadImage(path: String, parameterS: Parameters, photos: [String:UIImage?], photosArray: [String: [UIImage]?]?, completion: @escaping (Int, String?, NSError?) -> Void) {
//        let toLanguage = MOLHLanguage.currentAppleLanguage()
//        let token = GenericUserDefault.shared.getValue(Constants.shared.token)
//        AF.upload(multipartFormData: { (form: MultipartFormData) in
//            
//            for (key, value) in parameterS {
//                if let temp = value as? String {
//                    form.append(temp.data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? Int {
//                    form.append("\(temp)".data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? Double {
//                    form.append("\(temp)".data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? Float {
//                    form.append("\(temp)".data(using: .utf8)!, withName: key)
//                }
//                if let arrayValue = value as? [Any] {
//                    for (index, element) in arrayValue.enumerated() {
//                        let keyObj = "\(key)[\(index)]"
//                        if let productData = try? JSONSerialization.data(withJSONObject: element) {
//                            form.append(productData, withName: keyObj)
//                        }
//                    }
//                }
//            }
//            
//            print(form.boundary)
//            for (key, value) in photos {
//                if let imageData = value?.jpegData(compressionQuality: 0.5) {
//                    form.append(imageData, withName: key, fileName: "file.jpeg", mimeType: "image/png")
//                }
//            }
//            
//            if let photosArray = photosArray {
//                for (key, value) in photosArray {
//                    if let images = value {
//                        for (index, image) in images.enumerated() {
//                            let keyObj = "\(key)[\(index)]"
//                            if let imageData = image.jpegData(compressionQuality: 0.5) {
//                                print("index: \(index), imageData: \(imageData)")
//                                form.append(imageData, withName: keyObj, fileName: "\(key)_\(index).jpeg", mimeType: "image/png")
//                            }
//                        }
//                    }
//                }
//            }
//        },
//        to: "\(Constants.shared.baseURL)\(path)", method: .post, headers: [
//            "Authorization": "Bearer \(token ?? "")",
//            "Content-Type": "application/json",
//            "Accept": "application/json",
//            "X-Language": "\(toLanguage)",
//            "Connection": "keep-alive",
//            "x-source": "ios"
//        ])
//        .responseJSON { resp in
//            print(resp)
//            print(resp.response?.statusCode ?? 0)
//            print("\(Constants.shared.baseURL)\(path) \(parameterS)")
//            debugPrint(resp)
//            switch resp.result {
//            case .success(let value):
//                print("value is \(value)")
//                let data = value as? [String: Any] ?? [String: Any]()
//                let message = data["message"] as? String ?? ""
//                if resp.response?.statusCode ?? 0 == 200 {
//                    completion(1, message, nil)
//                } else {
//                    let data = value as? [String: Any] ?? [String: Any]()
//                    let message = data["message"] as? String ?? ""
//                    completion(0, message, nil)
//                }
//            case .failure(_):
//                let data = resp.value as? [String: Any] ?? [String: Any]()
//                let message = data["message"] as? String
//                let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: message ?? ""])
//                completion(0, nil, error)
//            }
//        }
//    }
//
//}
//
//
//
//class MultipartUploadImageWithModel {
//    typealias networkResultCompletion<M:Decodable> = (Result<M?, NSError>) -> Void
//    
//    typealias networkCompletionError = (NSError) -> Void
//    
//    typealias decodingCompletion<M:Codable> = (_ response:M?, _ error:NSError?) -> Void
//    
//    typealias unAuthorizedCompletion = (NSError) -> Void
//    static var shared = MultipartUploadImageWithModel()
//
//    
//    func uploadImage<M: Codable>(path:String,pdfUrl: [String: URL?] ,parameterS: [String:Any],photos: [String: UIImage?],responseClass: M.Type, completion: @escaping (Result<M?, NSError>) -> Void)  {
//
//        let token = GenericUserDefault.shared.getValue(Constants.shared.token)
//        let toLanguage = MOLHLanguage.currentAppleLanguage()
//        AF.upload(multipartFormData: { (form: MultipartFormData) in
//            
//            for (key, value) in parameterS {
//                if let temp = value as? String {
//                    form.append(temp.data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? Int {
//                    form.append("\(temp)".data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? Double {
//                    form.append("\(temp)".data(using: .utf8)!, withName: key)
//                }
//                if let temp = value as? Float {
//                    form.append("\(temp)".data(using: .utf8)!, withName: key)
//                }
//                else if let arrayValue = value as? [Any] {
//                for (index, element) in arrayValue.enumerated() {
//                                        let keyObj = "\(key)[\(index)]"
//                                        
//                                        if let stringValue = element as? String {
//                                            form.append(stringValue.data(using: .utf8)!, withName: keyObj)
//                                        } else if let intValue = element as? Int {
//                                            let value = "\(intValue)"
//                                            form.append(value.data(using: .utf8)!, withName: keyObj)
//                                        } else if let dictValue = element as? [String: Any], let jsonData = try? JSONSerialization.data(withJSONObject: dictValue) {
//                                            form.append(jsonData, withName: keyObj)
//                                        }
//                                    }
//                                }
//            }
//            // Upload PDF files
//                        for (key, url) in pdfUrl {
//                            if let pdfURL = url, let data = try? Data(contentsOf: pdfURL) {
//                                form.append(data, withName: key, fileName: pdfURL.lastPathComponent, mimeType: "application/pdf")
//                            }
//                        }
//                        
//                        // Upload image files
//                        for (key, image) in photos {
//                            if let photo = image, let data = photo.jpegData(compressionQuality: 0.5) {
//                                form.append(data, withName: key, fileName: "file.jpeg", mimeType: "image/jpeg")
//                            }
//                        }
//
//        },
//                  to: "\(Constants.shared.baseURL)\(path)", method: .post , headers: [
//                "Authorization": "Bearer \(token ?? "")",
//                "Content-Type": "application/json",
//                "Accept": "application/json",
//                "X-Language": "\(toLanguage)",
//                "Connection": "keep-alive",
//                "x-source": "ios"
//        ])
//        .responseJSON { response in
//            print(response.response?.statusCode ?? 0)
//            print("\(Constants.shared.baseURL)\(path) \(parameterS)")
//            debugPrint(response)
////            debugPrint(resp.response)
//
//            print("status is -----------:> \(response.response?.statusCode ?? 0)")
//            debugPrint(response)
//            guard response.error == nil else {
//                self.handleUrlError(Constants.shared.baseURL, error: response.error, completion: { Error in
//                    completion(.failure(Error))
//                    return
//                })
//                return
//            }
//            
//            self.handleUrlStatusCode(targetPath : path,responseData: response.data,code: response.response?.statusCode){ isSuccess,error  in
//                
//                guard isSuccess else {
//                    if error == "Unauthenticated." {
//                        completion(.failure(NSError(domain: Constants.shared.baseURL, code: 401, userInfo: [NSLocalizedDescriptionKey:error ?? ""])))
//                        
//                    }
//                    completion(.failure(NSError(domain: Constants.shared.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey:error ?? ""])))
//                    return
//                }
//                
//                guard let data = response.data else { return }
//                
//                self.decode(fromData: data, toObject: responseClass, completion: { object, error in
//                    guard let object = object , error == nil else {
//                        completion(.failure(error!))
//                        return
//                    }
//                    
//                    print("result is:- \(object)")
//                    
//                    completion(.success(object))
//                })
//                
//            }
//        }
//    }
//    
//    private func buildParams(task: TaskRequest) -> (params:[String: Any], encodingType: ParameterEncoding) {
//        switch task {
//        case .requestPlain:
//            return ([:],URLEncoding.default)
//        case .requestParameters(Parameters: let parameters, encoding: let encoding):
//            return (parameters,encoding)
//        }
//    }
//    
//private func handleUrlStatusCode(targetPath: String ,responseData:Data?,code:Int?, completion:@escaping(Bool,String?)->Void){
//        
//        guard let statusCode = code else {
//            print("there is no status code")
//            return
//        }
//        
//        switch statusCode {
//        case 200,201:
//            completion(true,nil)
//        case 401:
//            //not Authorized
//            guard let data = responseData else { return }
//            decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
//                if targetPath == "login"{
//                    completion(false,result?.message)
//                }
//                else {
//                    GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
//                    GenericUserDefault.shared.setValue("", Constants.shared.token)
//                    MOLH.reset()
////                        UnauthorizedVC.shared.unAuthorized()
//                }
//
//            }
//            
//            
//        case 403:
//            completion(true,nil)
//            
//        default:
//            guard let data = responseData else { return }
//            decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
////                    if result?.message == "invalid request token,please login again" {
////                        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
////                        GenericUserDefault.shared.setValue("", Constants.shared.token)
////                        MOLH.reset()
////                    }
//                completion(false,result?.message)
//            }
//        }
//    }
//    
//    private func handleUrlError(_ target:String, error:Error?,completion:@escaping networkCompletionError){
//        guard let error = error as? URLError else {
//            print("there is url error")
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
//            completion(error)
//            return
//        }
//        
//        switch error.code {
//        case .networkConnectionLost:
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
//            completion(error)
//            return
//        case .timedOut:
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().requestTimeOut])
//            completion(error)
//            return
//            
//        case .notConnectedToInternet:
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
//            completion(error)
//            return
//            
//        case .badServerResponse:
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().badServerResponse])
//            completion(error)
//            return
//            
//        case .badURL:
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().badUrl])
//            completion(error)
//            return
//            
//        default:
//            let error = NSError(domain: target, code: 0, userInfo: [NSLocalizedDescriptionKey:NetworkErrorMessage().genericError])
//            completion(error)
//            return
//        }
//        
//        
//    }
//    
//    private func decode<M:Codable>(fromData data:Data,
//                                   toObject responseClass: M.Type, completion:@escaping decodingCompletion<M>){
//        
//        let decoder = JSONDecoder()
//        
//        decoder.keyDecodingStrategy = .convertFromSnakeCase
//        do {
//            let model:M = try decoder.decode(responseClass, from: data)
//            completion(model,nil)
//        } catch let error {
//            print("decodingError:- \(error)")
//            let decodingError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : NetworkErrorMessage().decodingError])
//            completion(nil,decodingError)
//        }
//        
//    }
//    
//    
//}
