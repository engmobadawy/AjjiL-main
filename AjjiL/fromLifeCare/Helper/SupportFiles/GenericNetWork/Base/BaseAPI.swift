//
//  BaseAPI.swift

//

import Foundation
//import Alamofire
//import MOLH

//class BaseAPI<T: TargetType> {
//    typealias networkResultCompletion<M:Decodable> = (Result<M?, NSError>) -> Void
//    
//    typealias networkCompletionError = (NSError) -> Void
//    
//    typealias decodingCompletion<M:Codable> = (_ response:M?, _ error:NSError?) -> Void
//    
//    typealias unAuthorizedCompletion = (NSError) -> Void
//    
//    func fetchData<M: Codable>(target: T, responseClass: M.Type, bool: Bool? = true, completion:@escaping (Result<M?, NSError>) -> Void) {
//        
//        let method = Alamofire.HTTPMethod(rawValue: target.methods.rawValue)
//        let headers = Alamofire.HTTPHeaders(target.headers ?? [:])
//        let params = buildParams(task: target.task)
//        
//        AF.request(target.baseURL + target.path, method: method, parameters: params.0, encoding:  params.1, headers:  headers).responseJSON { (response) in
//            print("status is -----------:> \(response.response?.statusCode ?? 0)")
//            print("url is -----------:> \(target.path)")
//            print("parameters is -----------:> \(params)")
//            print("response is -----------:> \(response)")
//            let notificationCount = response.response?.headers["UnReadNotification-Count"]
//            GenericUserDefault.shared.setValue(notificationCount, Constants.shared.unReadNotificationCount)
//
//               let headerActive = response.response?.headers["Active-Notification"]  ?? ""
//            GenericUserDefault.shared.setValue(headerActive, Constants.shared.notificationOnOrOff)
//            debugPrint(response)
//            guard response.error == nil else {
//                self.handleUrlError(target, error: response.error, completion: { Error in
//                    completion(.failure(Error))
//                    return
//                })
//                return
//            }
//            
//            self.handleUrlStatusCode(targetPath : target.path,responseData: response.data,code: response.response?.statusCode){ isSuccess,error  in
//                
//                guard isSuccess else {
//                    if error == "Unauthenticated." {
//                        completion(.failure(NSError(domain: target.baseURL, code: 401, userInfo: [NSLocalizedDescriptionKey:error ?? ""])))
//                        
//                    }
//                    completion(.failure(NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey:error ?? ""])))
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
//    private func buildParams(task: TaskRequest) -> (params:[String: Any], encodingType: ParameterEncoding) {
//            switch task {
//            case .requestPlain:
//                return ([:],URLEncoding.default)
//            case .requestParameters(Parameters: let parameters, encoding: let encoding):
//                return (parameters,encoding)
//            }
//        }
//        
//    private func handleUrlStatusCode(targetPath: String ,responseData:Data?,code:Int?, completion:@escaping(Bool,String?)->Void){
//            
//            guard let statusCode = code else {
//                print("there is no status code")
//                return
//            }
//            
//            switch statusCode {
//            case 200,201:
//                completion(true,nil)
//            case 401:
//                //not Authorized
//                
//                guard let data = responseData else { return }
//                decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
//                    if targetPath == "auth/login" || targetPath == "patients/clinical-data" {
//                        completion(false,result?.message)
//                    }
//                    else {
//                        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
//                        GenericUserDefault.shared.setValue("", Constants.shared.token)
//                        MOLH.reset()
////                        UnauthorizedVC.shared.unAuthorized()
//                    }
//
//                }
//                
//            case 403:
//                guard let data = responseData else { return }
//                decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
//                    if targetPath == "auth/login" {
//                        GenericUserDefault.shared.setValue(true, Constants.shared.needsVerification)
//                        completion(false,result?.message)
//                    }
//                    else {
//                        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
//                        GenericUserDefault.shared.setValue("", Constants.shared.token)
//                        MOLH.reset()
////                        UnauthorizedVC.shared.unAuthorized()
//                    }
//
//                }
//                completion(false,nil)
//            default:
//                guard let data = responseData else { return }
//                decode(fromData: data, toObject: BaseNetworkResponseErrorModel.self) { result, error in
////                    if result?.message == "invalid request token,please login again" {
////                        GenericUserDefault.shared.setValue(true, Constants.shared.resetLanguage)
////                        GenericUserDefault.shared.setValue("", Constants.shared.token)
////                        MOLH.reset()
////                    }
//                    completion(false,result?.message)
//                }
//            }
//        }
//        
//        private func handleUrlError(_ target:T, error:Error?,completion:@escaping networkCompletionError){
//            guard let error = error as? URLError else {
//                print("there is url error")
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
//                completion(error)
//                return
//            }
//            
//            switch error.code {
//            case .networkConnectionLost:
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
//                completion(error)
//                return
//            case .timedOut:
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().requestTimeOut])
//                completion(error)
//                return
//                
//            case .notConnectedToInternet:
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().noInternetConnection])
//                completion(error)
//                return
//                
//            case .badServerResponse:
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().badServerResponse])
//                completion(error)
//                return
//                
//            case .badURL:
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey: NetworkErrorMessage().badUrl])
//                completion(error)
//                return
//                
//            default:
//                let error = NSError(domain: target.baseURL, code: 0, userInfo: [NSLocalizedDescriptionKey:NetworkErrorMessage().genericError])
//                completion(error)
//                return
//            }
//            
//            
//        }
//        
//        private func decode<M:Codable>(fromData data:Data,
//                                       toObject responseClass: M.Type, completion:@escaping decodingCompletion<M>){
//            
//            let decoder = JSONDecoder()
//            
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
//            do {
//                let model:M = try decoder.decode(responseClass, from: data)
//                completion(model,nil)
//            } catch let error {
//                print("decodingError:- \(error)")
//                let decodingError = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : NetworkErrorMessage().decodingError])
//                completion(nil,decodingError)
//            }
//            
//        }
//        
//        
//    }


struct NetworkErrorMessage {
    
    let genericError = "Something went wrong, Please try again later.".localized()
    
    let noInternetConnection = "The Internet connection appears to be offline.".localized()
    
    let requestTimeOut = "Request Timeout, Please try again later.".localized()
    
    let badServerResponse = "Bad Server Response, Please try again later.".localized()
    
    let badUrl = "There is something Wrong with Url".localized()
    
    let decodingError = "Couldn't decode Json response"
    
}

struct BaseNetworkResponseErrorModel: Codable {
    var message: String?
    var status: Bool?
}
