//
//  Enrollment.swift
//  ClassManager
//
//  Created by 김남건 on 2022/10/12.
//

import Foundation
import FirebaseFirestore

struct Enrollment {
    let ID: String
    let classID: String?
    let userName: String?
    let phoneNumber: String?
    let enrolledDate: Date?
    var paid: Bool?
    let paymentType: String?
    let attendence: Bool?
    let info: String?
    
    init(ID: String, classID: String?, userName: String?, phoneNumber: String?, enrolledDate: Date?, paid: Bool?, paymentType: String? = nil, attendence: Bool? = nil, info: String? = nil) {
        self.ID = ID
        self.classID = classID
        self.userName = userName
        self.phoneNumber = phoneNumber
        self.enrolledDate = enrolledDate
        self.paid = paid
        self.paymentType = paymentType
        self.attendence = attendence
        self.info = info
    }
    
    init(documentSnapShot: DocumentSnapshot) {
        self.ID = documentSnapShot["ID"] as? String ?? ""
        self.classID = documentSnapShot["classID"] as? String
        self.userName = documentSnapShot["userName"] as? String
        self.phoneNumber = documentSnapShot["phoneNumber"] as? String
        self.enrolledDate = (documentSnapShot["enrolledDate"] as? Timestamp)?.dateValue() ?? Date()
        self.paid = documentSnapShot["paid"] as? Bool
        self.paymentType = documentSnapShot["paymentType"] as? String
        self.attendence = documentSnapShot["attendence"] as? Bool
        self.info = documentSnapShot["info"] as? String
    }
}
