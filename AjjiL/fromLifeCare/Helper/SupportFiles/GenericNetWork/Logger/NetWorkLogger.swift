//
//  NetWorkLogger.swift
//  Taakad
//
//  Created by Mohamed on 1/26/21.
//  Copyright © 2021 AppsSquare.com. All rights reserved.
//

import UIKit

class NetWorkLogger {
    
    static var shared = NetWorkLogger()
    
    func scheduleNotifications(url: String, statusCode: Int, headers: String, params: [String: Any],  method: String, response: Any) {
        
        let content = UNMutableNotificationContent()
        let requestIdentifier = "rajanNotification"
        
        content.badge = 1
        content.title = "End point: \(url)"
        content.subtitle = "StatusCode: \(statusCode)"
        content.body = "Header: \(headers)" + "\n" + "\(params)" + "\n" + "Response is \(response)"
        content.categoryIdentifier = "actionCategory"
        content.sound = UNNotificationSound.default
        
        // If you want to attach any image to show in local notification
        switch statusCode { // add more status code if you want
        case 400:
            content.attachments = [addImage(status: .error)]
        case 200:
            content.attachments = [addImage(status: .success)]
        case 401:
            content.attachments = [addImage(status: .unValide)]
        default:
            content.attachments = [addImage(status: .elseStatus)]
        }
        
        let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: 1.0, repeats: false)
        
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { (error:Error?) in
            guard error == nil else {
                print(error?.localizedDescription ?? "some unknown error")
                return
            }
            
            // save notifications in the NotificationsModel
            let requestData = LocalNotificationsModel(url: "soon", endPoint: url, response: "\(response)", header: "\(headers)", method: "\(method)", params: "\(params)", statusCode: statusCode)
            LocalNotificationsModel.allData.append(requestData)
        }
    }
    
    
    private func addImage(status: NetworkStatusImages) -> UNNotificationAttachment {
        let imageURL = createLocalUrl(forImageNamed: status.rawValue)
        let attachment = try! UNNotificationAttachment(identifier: "image", url: imageURL!, options: [:])
        return attachment
    }
    
    private func createLocalUrl(forImageNamed name: String) -> URL? {
        
        let fileManager = FileManager.default
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        let url = cacheDirectory.appendingPathComponent("\(name).png")
        
        guard fileManager.fileExists(atPath: url.path) else {
            guard
                let image = UIImage(named: name),
                let data = image.pngData()
                else { return nil }
            
            fileManager.createFile(atPath: url.path, contents: data, attributes: nil)
            return url
        }
        return url
    }
}

struct LocalNotificationsModel {
    static var allData = [LocalNotificationsModel]()
    let url, endPoint, response, header, method, params: String
    let statusCode: Int
    
    static func getData() -> [LocalNotificationsModel] {
        var returnData = [LocalNotificationsModel]()
        for reversed in LocalNotificationsModel.allData.reversed() {
            returnData.append(reversed)
        }
        return returnData
    }
}

enum NetworkStatusImages: String {
    case success = "success"
    case error = "error"
    case unValide = "valide"
    case elseStatus = "else"
}
