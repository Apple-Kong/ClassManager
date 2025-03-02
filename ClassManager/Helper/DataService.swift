//
//  DataService.swift
//  ClassManager
//
//  Created by Jiyoung Park on 2022/10/12.
//

import Foundation
import FirebaseFunctions
import FirebaseFirestore
import FirebaseFirestoreSwift

struct DataService {
    static let shared = DataService()
    
    private init() {}
    
    let studioRef = Firestore.firestore().collection("studios")
    let classRef = Firestore.firestore().collection("classes")
    let linkRef = Firestore.firestore().collection("link")
    let enrollmentRef = Firestore.firestore().collection("enrollment")
    let suspendedRef = Firestore.firestore().collection("suspended")
    let studentRef = Firestore.firestore().collection("student")
    
    func createStudio(ID: String, email: String, name: String, location: String?, notice: Notice?, halls: [Hall]) {
        let studio = Studio(ID: ID, email: email, name: name, location: location, notice: notice, halls: halls)
        do {
            try studioRef.document("\(ID)").setData(from: studio)
        } catch let error {
            print("Error writing studio to Firestore: \(error)")
        }
    }
    
    func createClass(studioID: String, title: String, instructorName: String, date: Date, durationMinute: Int, repetition: Int, hall: Hall?, isPopUP: Bool) {
        do {
            for idx in 0..<repetition {
                let classDate = Calendar.current.date(byAdding: .day, value: idx * 7, to: date)
                let classID = instructorName + dateIdString(from: classDate) // UUID().uuidString
                let danceClass = Class(ID: classID, studioID: studioID, title: title, instructorName: instructorName, date: classDate, durationMinute: durationMinute, hall: hall, applicantsCount: 0, isPopUp: isPopUP)
                if Constant.shared.classes == nil {
                    Constant.shared.classes = [Class]()
                }
                Constant.shared.classes!.append(danceClass)
                try classRef.document("\(classID)").setData(from: danceClass)
            }
        } catch let error {
            print("Error writing class to Firestore: \(error)")
        }
    }
    
    func requestStudioBy(email: String) async throws -> Studio? {
        let snapshot = try await studioRef.whereField("email", isEqualTo: email).getDocuments()
        
        return try snapshot.documents.compactMap { document in
            try document.data(as: Studio.self)
        }.first
    }
    
    func requestStudioBy(studioID: String) async throws -> Studio? {
        let document = try await studioRef.document(studioID).getDocument()
        
        return try? document.data(as: Studio.self)
    }
    
    func requestAllClasses() async throws -> [Class]? {
        let snapshot = try await classRef.getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Class.self)
        }
    }
    
    func requestAllClassesBy(studioID: String) async throws -> [Class]? {
        let snapshot = try await classRef.whereField("studioID", isEqualTo: studioID).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Class.self)
        }
    }
    
    func requestLink(studioID: String) async throws -> Link? {
        let document = try await linkRef.document(studioID).getDocument()
        
        return try? document.data(as: Link.self)
    }
    
    func requestEnrollmentsBy(classID: String) async throws -> [Enrollment]? {
        let snapshot = try await enrollmentRef.whereField("classID", isEqualTo: classID).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Enrollment.self)
        }
    }
    
    func requestSuspendedClassesBy(studioID: String) async throws -> SuspendedClasses? {
        let document = try await suspendedRef.document(studioID).getDocument()
        
        return try? document.data(as: SuspendedClasses.self)
    }
    
    func updateClass(classID: String, studioID: String, title: String, instructorName: String, date: Date, durationMinute: Int, repetition: Int, hall: Hall?, applicantsCount: Int, isPopUP: Bool) {
        do {
            let danceClass = Class(ID: classID, studioID: studioID, title: title, instructorName: instructorName, date: date, durationMinute: durationMinute, hall: hall, applicantsCount: applicantsCount, isPopUp: isPopUP)
            Constant.shared.classes = Constant.shared.classes!.filter({ $0.ID != classID })
            Constant.shared.classes!.append(danceClass)
            try classRef.document("\(classID)").setData(from: danceClass)
        } catch let error {
            print("Error writing class to Firestore: \(error)")
        }
    }
    
    func updateAttendance(enrollments: [Enrollment]) {
        enrollments.forEach { enrollment in
            enrollmentRef.document("\(enrollment.ID)").updateData([
                "attendance": enrollment.attendance ?? false
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
        }
    }
    
    func updateSuspendedClasses(classID: String, studioID: String) async {
        do {
            let suspendedClasses = try await requestSuspendedClassesBy(studioID: studioID)
            var ids = [String]()
            if suspendedClasses != nil {
                ids = suspendedClasses!.IDs ?? []
            }
            ids.append(classID)
            let newSuspendedClasses = SuspendedClasses(studioID: studioID, IDs: ids)
            try suspendedRef.document(studioID).setData(from: newSuspendedClasses)
            Constant.shared.suspendedClasses = newSuspendedClasses
        } catch {
            print(error)
        }
    }
    
    func deleteClass(classID: String) {
        classRef.document(classID).delete() { err in
            if let err = err {
                print("Error removing document: \(err)")
            } else {
                print("Document successfully removed!")
            }
        }
        Constant.shared.classes = Constant.shared.classes?.filter({ $0.ID != classID })
    }
    
    private func dateIdString(from date: Date?) -> String {
        if let date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-HH:mm"
            
            return dateFormatter.string(from: date)
        } else {
            return "xx:xx"
        }
    }
    
    func requestAllEnrollments(of studioID: String) async throws -> [Enrollment]? {
        let snapshot = try await enrollmentRef.getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Enrollment.self)
        }
    }
    
    func requestAllStudents(of studioID: String) async throws -> [Student]? {
        let snapshot = try await studentRef
            .whereField("studioID", isEqualTo: studioID)
            .order(by: "name")
            .getDocuments()
            
        return snapshot.documents.compactMap { document in
            try? document.data(as: Student.self)
        }
    }
    
    func requestAllClassesBy(classIDs: [String]) async throws -> [Class]? {
        let snapshot = try await classRef.whereField("ID", in: classIDs).getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Class.self)
        }
    }
    
    func updateEnrollment(enrollment: Enrollment) {
        enrollmentRef.document(enrollment.ID).updateData([
            "isRefunded": enrollment.isRefunded ?? false
        ])
    }
    
    func updateEnrollments(enrollments: [Enrollment]) {
        enrollments.forEach { enrollment in
            enrollmentRef.document("\(enrollment.ID)").updateData([
                "paid": enrollment.paid ?? false,
                "isRefunded": enrollment.isRefunded ?? false,
                "refundReason": enrollment.refundReason ?? ""
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
        }
    }
    
    func updateStudentEnrollments(student: Student) {
        student.enrollments.forEach { $0.matchedClass = nil }
        do {
            studentRef.document("\(student.ID)").updateData([
                "enrollments": try student.enrollments.encode()
            ]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                }
            }
        } catch {
            print(error)
        }
    }
    
    func updateStudentCoupons(student: Student, coupons: [Coupon]) {
        studentRef.document("\(student.ID)").updateData([
            "coupons": coupons
        ]) { err in
            if let err = err {
                print("Error updating document: \(err)")
            }
        }
    }
    
    func requestSuspendedAlimTalk(to: String, disableSms: Bool, from: String, studioName: String, studentName: String, instructorName: String, genre: String, time: String, suspended: String, studioPhoneNumber: String) {
        
        let data : [String : Any] = [
            "to" : to,
            "disableSms" : disableSms,
            "from" : from,
            "studioName" : studioName,
            "studentName" : studentName,
            "instructorName" : instructorName,
            "genre" : genre,
            "time" : time,
            "suspended" : suspended,
            "studioPhoneNumber" : studioPhoneNumber,
        ]
        
        lazy var functions = Functions.functions(region: "us-central1")
        
        functions.httpsCallable("sendSolapiRequest").call(data) { (result, error) in
            
            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    let code = FunctionsErrorCode(rawValue: error.code)
                    let message = error.localizedDescription
                    print(code?.rawValue ?? -1)
                    print(message)
                }
            }
            
            if let res = result {
                let resdic = res.data as? [String:Any]
                print(resdic?["logger"] ?? "")
            }
        }
    }
}

extension DataService {
    struct DummyData {
        static let notice = Notice(imageURL: "dummyimageURL", description: "sampledescription", bankAccount: nil)
        static let halls = [Hall(name: "hall A", capacity: 20), Hall(name: "hall B", capacity: 40)]
        static let hall = Hall(name: "hall A", capacity: 20)
    }
}

extension DataService {
    enum StudioName: String {
        case BonafideSample
        case MovidicSample
        case NewFlareSample
        case BuntStudioSample
        
        func getStudioName() -> String {
            switch self {
            case .BonafideSample:
                return "보나파이드 스튜디오"
            case .MovidicSample:
                return "모비딕 스튜디오"
            case .NewFlareSample:
                return "뉴플레어 댄스학원"
            case .BuntStudioSample:
                return "번트 스튜디오"
            }
        }
        
        func getStudioPhoneNumber() -> String {
            switch self {
            case .BonafideSample:
                return "010-4375-0530"
            case .MovidicSample:
                return "010-8566-4646 / 070-7499-1955"
            case .NewFlareSample:
                return "010-6504-6603"
            case .BuntStudioSample:
                return "010-2440-5830"
            }
        }
    }
}
