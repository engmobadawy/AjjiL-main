//
//  String+Ext.swift
//  AjjiL
//
//  Created by mohamed mahmoud sobhy badawy on 01/03/2026.
//


import UIKit


extension String {
    func localized() -> String {
        return NSLocalizedString(self, comment: "")
    }

    var capitalizeFirstLetter: String {
        if self.count == 0 { return self }
        return prefix(1).uppercased() + dropFirst()
    }

  var floatValue: Float {
      return (self as NSString).floatValue
  }

    //To check text field or String is blank or not
    var isBlank: Bool {
        get {
            let trimmed = trimmingCharacters(in: CharacterSet.whitespaces)
            return trimmed.isEmpty
        }
    }

    // validate name
    var isValidName: Bool {
        if(self.count >= 2 && self.count <= 30){
            return true
        }else{
            return false
        }
    }

    
    // validate name
    var isValidMessage: Bool {
        if(self.count >= 3){
            return true
        }else{
            return false
        }
    }
    
    var isValidReason: Bool {
        if(self.count >= 2 && self.count <= 500){
            return true
        }else{
            return false
        }
    }
    //validate full name
    var validateName: Bool {
          let nameArray: [String] = self.split { $0 == " " }.map { String($0) }
          if nameArray.count >= 3 {
              return true
          }else{
              return false
          }
      }

    //validate code
    var isValidCode: Bool {
        if self == "1111", self.count == 4 {
            return true
        }
        return false
    }

    //Validate Email
    var isValidEmail: Bool {
        do {
            let regex = try NSRegularExpression(pattern: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}", options: .caseInsensitive)
            return regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, self.count)) != nil
        } catch {
            return false
        }
    }

    func isEmailValid() -> Bool {
        let emailTest = NSPredicate(format: "SELF MATCHES %@",
                                            "^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$")
        return emailTest.evaluate(with: self)
    }


    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }

    func isPasswordConfirm(password: String, confirmPassword: String) -> Bool {
        if password == confirmPassword{
            return true
        } else {
            return false
        }
    }

    var isNumber: Bool {
        get {
            return !self.isEmpty && self.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
        }
    }

    //validate Password
    var isValidPassword: Bool {
        //        let passwordTest = NSPredicate(format: "SELF MATCHES %@",
        //                                               "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,15}$")
        //        return passwordTest.evaluate(with: self)
        return self.count >= 8
    }

    var isValidSaudiPhoneNumber: Bool {
           let saudiNumberRegex = "^(009665|9665|\\+9665|05|5)(5|0|3|6|4|9|1|8|7)([0-9]{7})$"
           let predicate = NSPredicate(format: "SELF MATCHES %@", saudiNumberRegex)
           return predicate.evaluate(with: self)
       }
    
    func isPasswordValid() -> Bool {
//        let passwordTest = NSPredicate(format: "SELF MATCHES %@",
//                                               "^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z]).{8,15}$")
//        return passwordTest.evaluate(with: self)
        return self.count >= 8
    }

    func camelCaseToWords() -> String {
        return unicodeScalars.reduce("") {
            if CharacterSet.uppercaseLetters.contains($1) {
                return ($0 + " " + String($1))
            }
            else {
                return $0 + String($1)
            }
        }
    }

    public var convertDigitsToEng : String {
            let arabicNumbers = ["٠": "0", "١": "1", "٢": "2", "٣": "3", "٤": "4", "٥": "5", "٦": "6", "٧": "7", "٨": "8", "٩": "9"]
            var txt = self
            let _ = arabicNumbers.map { txt = txt.replacingOccurrences(of: $0, with: $1)}
            return txt
    }
    
        func matches(pattern: String) -> Bool {
            return self.range(of: pattern, options: .regularExpression) != nil
        }
        
        func toYMDFormat() -> String? {
            let inputFormatter = DateFormatter()
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd"
            
            let formats = ["yyyy-MM-dd", "MM/dd/yyyy", "dd/MM/yyyy", "dd-MM-yyyy"]
            
            for format in formats {
                inputFormatter.dateFormat = format
                if let date = inputFormatter.date(from: self) {
                    return outputFormatter.string(from: date)
                }
            }
            
            return nil
        }




    func formatExpiryDate() -> Self {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "MM/yy"
        if let date = inputFormatter.date(from: self) {
            // DateFormatter to output the date string in the new format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            // Convert Date back to string
            return outputFormatter.string(from: date)
        } else {
            return "Invalid date"
        }
    }

    func formatDateToString() -> Self {
            let inputFormatter = DateFormatter()
            inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            // Formatter to output the date in "YYYY/MM" format
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "MM/yy"

            // Parse the input date string into a Date object
            if let date = inputFormatter.date(from: self) {
                // Format the Date object into the desired output string
                return outputFormatter.string(from: date)
            } else {
                // Return a default or error message if parsing fails
                return "Invalid date"
            }
        }
}
