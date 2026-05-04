//
//  Constants.swift
//  LifeCare
//
//
//  Created by AMNY on 07/04/2025.
//

import Foundation
class Constants {
    static var shared = Constants()

    let isCashier = "isCashier"
    var isAR: Bool { return (MOLHLanguage.currentAppleLanguage() == "ar") }
    let baseURL =  "https://ajjil.appssquare.com/public/api/"
    let developerMode = false
    let userDataKey = "userDataKey"
    let resetLanguage = "resetLanguage"
    var onboarding = "onboarding"
    let token = "userTokenKey"
    let branchId = "branch_id"
    let returnCode = "returnCode"
    let userName = "userName"
    let registerFinish  = "No"
    let phone = "phone"
    let email = "email"
    let gender = "gender"
    let dateOfBirth = "dateOfBirth"
    let profileImageURL = "profileImageURL"
    let deviceToken = "deviceToken"
    let unReadNotificationCount = "unread"
    let notificationOnOrOff = "notificationOnOrOff"
    let userType = "userType"
    let needsVerification = "needVerification"
    let passwordChanged = "passwordChanged"
    let isActiveNotification = "isActiveNotification"
    let searchArray = "searchArray"
    let completeProfile = "completeProfile"
    
    static var registerId: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "registerId") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "registerId")
        }
    }
    
    static var invitationType: String {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "invitationType") as? String ?? ""
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "invitationType")
        }
    }
    
    static var isGuestMode: Bool {
        get {
            let ud = UserDefaults.standard
            return ud.value(forKey: "isGuestMode") as? Bool ?? true
        }
        set(token) {
            let ud = UserDefaults.standard
            ud.set(token, forKey: "isGuestMode")
        }
    }
}
