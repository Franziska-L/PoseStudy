//
//  UserData.swift
//  PoseStudy
//
//  Created by Franziska Lang on 14.01.21.
//

import Foundation

struct UserData: Codable {

    var ID: String = ""
    var demographic: DemographicData = DemographicData()
    var health: HealtData = HealtData()
    var measured: [MeasuredData] = [MeasuredData]()
    
    enum CodingKeys: String, CodingKey {
        case ID
        case demographic = "Demographic"
        case health = "Health Status"
        case measured = "Data"
    }
}

struct DemographicData: Codable {
    var age = "0"
    var gender = ""
    var mass = "0"
    var height = "0"
    
    enum CodingKeys: String, CodingKey {
        case age = "Age"
        case gender = "Gender"
        case mass = "mass"
        case height = "Height"
    }
}

struct HealtData: Codable {
    var medication: String = ""
    var cardiovascularDiseases: String = ""
    var musculoskeletalDiseases: String = ""
    var neuromuscularDisorder: String = ""
    var highBlood: String = ""
    var diabetes: String = ""
    var nothing: String = ""
    var other: String = ""
    
    enum CodingKeys: String, CodingKey {
        case medication = "Medication"
        case cardiovascularDiseases = "Cardiovascular Diseases"
        case musculoskeletalDiseases = "Musculoskeletal Diseases"
        case neuromuscularDisorder = "Neuromuscular Disorder"
        case highBlood = "High Blood"
        case diabetes = "Diabetes"
        case nothing = "Nothing"
        case other = "Other"
    }
}

struct MeasuredData: Codable {
    var startTime: Int64 = Int64()
    var endTime: Int64 = Int64()
    
    var ecgDataStream: [Int32] = [Int32]()
    var ecgDataStreamPerSecond: [[Int32]] = [[Int32]]()
    var ecgDataTimestamp = [Int64]()
    
    var hrDataStream: [UInt8] = [UInt8]()
    var hrDataStreamPerSec: [UInt8] = [UInt8]()
    var hrDataTimestamp = [Int64]()

    var rrsDataStream: [[Int]] = [[Int]]()
    var rrMsDataStream: [[Int]] = [[Int]]()

    var rrDataTimestamp = [Int64]()
    
    enum CodingKeys: String, CodingKey {
        case startTime = "Start Time"
        case endTime = "End Time"
        case ecgDataStream = "ECG"
        case ecgDataStreamPerSecond = "ECGs"
        case ecgDataTimestamp = "ECG Timestamp"
        case hrDataStream = "HR"
        case hrDataStreamPerSec = "HRs"
        case hrDataTimestamp = "HR Timestamp"
        case rrsDataStream = "RRs"
        case rrMsDataStream = "RRms"
        case rrDataTimestamp = "RR Timestamp"
    }
}


