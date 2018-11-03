//
//  PracticeWrongModel.swift
//  WePeiYang
//
//  Created by JasonEWNL on 2018/8/25.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import Foundation

// MARK: Network
struct PracticeWrongHelper {
    static func getWrong(success: @escaping (PracticeWrongModel)->(), failure: @escaping (Error)->()) {
        SolaSessionManager.solaSession(baseURL: PracticeAPI.root, url: PracticeAPI.special + "/getQues/1", success: { dic in
            log(dic)
            if let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0)), let practiceWrong = try? PracticeWrongModel(data: data) {
                success(practiceWrong)
            } else { debugPrint("WARNING -- PracticeWrongHelper.getWrong") }
        }) { error in
            failure(error)
            debugPrint("ERROR -- PracticeWrongHelper.getWrong")
        }
    }

    static func addMistakeQues(quesId: String, quesType: String, usrAns: String) {
        var message: String = ""
        let mistakeQuesData: Dictionary<String, String> = [ "tid": "1",
                                                            "ques_id": quesId,
                                                            "ques_type": quesType,
                                                            "error_answer": usrAns]
        SolaSessionManager.solaSession(type: .post, baseURL: PracticeAPI.root, url: "/special/addQues/1", parameters: mistakeQuesData, success: { dic in
            log(dic)
         }, failure: { err in
            log(err)
         })
    }

    static func deleteWrong(quesType: String, quesID: String) {
        SolaSessionManager.solaSession(type: .post, baseURL: PracticeAPI.root, url: PracticeAPI.special + "/deleteQues/1", parameters: ["ques_type": quesType, "ques_id": quesID], success: { dic in
            log(dic)
            log(quesType)
            log(quesID)
            
        }) { _ in
            
            debugPrint("ERROR -- PracticeWrongHelper.deleteWrong")
        }
    }
}

// MARK: - Model
struct PracticeWrongModel: Codable {
    let errorCode: Int
    let message: String
    var data: [PracticeWrongData] // 基于数据和页面改为变量
    
    enum CodingKeys: String, CodingKey {
        case errorCode = "error_code"
        case message, data
    }
}

struct PracticeWrongData: Codable {
    let quesID: Int
    let classID, courseID, quesType, content: String
    let option: [String]
    let answer: String
    let isCollected, isMistake: Int
    let errorOption: String
    
    enum CodingKeys: String, CodingKey {
        case quesID = "ques_id"
        case classID = "class_id"
        case courseID = "course_id"
        case quesType = "ques_type"
        case content, option, answer
        case isCollected = "is_collected"
        case isMistake = "is_mistake"
        case errorOption = "error_option"
    }
}

// MARK: - Initialization
extension PracticeWrongModel {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PracticeWrongModel.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        errorCode: Int? = nil,
        message: String? = nil,
        data: [PracticeWrongData]? = nil
        ) -> PracticeWrongModel {
        return PracticeWrongModel(
            errorCode: errorCode ?? self.errorCode,
            message: message ?? self.message,
            data: data ?? self.data
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension PracticeWrongData {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(PracticeWrongData.self, from: data)
    }
    
    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }
    
    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }
    
    func with(
        quesID: Int? = nil,
        classID: String? = nil,
        courseID: String? = nil,
        quesType: String? = nil,
        content: String? = nil,
        option: [String]? = nil,
        answer: String? = nil,
        isCollected: Int? = nil,
        isMistake: Int? = nil,
        errorOption: String? = nil
        ) -> PracticeWrongData {
        return PracticeWrongData(
            quesID: quesID ?? self.quesID,
            classID: classID ?? self.classID,
            courseID: courseID ?? self.courseID,
            quesType: quesType ?? self.quesType,
            content: content ?? self.content,
            option: option ?? self.option,
            answer: answer ?? self.answer,
            isCollected: isCollected ?? self.isCollected,
            isMistake: isMistake ?? self.isMistake,
            errorOption: errorOption ?? self.errorOption
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
