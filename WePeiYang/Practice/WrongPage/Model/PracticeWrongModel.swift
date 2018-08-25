//
//  PracticeWrongModel.swift
//  WePeiYang
//
//  Created by JasonEWNL on 2018/8/25.
//  Copyright © 2018年 twtstudio. All rights reserved.
//

import Foundation

struct PracticeWrongHelper {
    static func getWrong(success: @escaping (PracticeWrongModel)->(), failure: @escaping (Error)->()) {
        SolaSessionManager.solaSession(baseURL: PracticeAPI.root, url: PracticeAPI.special + "/getQues/1", token: TwTUser.shared.token, success: { dic in
            if let data = try? JSONSerialization.data(withJSONObject: dic, options: JSONSerialization.WritingOptions.init(rawValue: 0)), let practiceWrong = try? PracticeWrongModel(data: data) {
                success(practiceWrong)
            }
        }) { error in
            failure(error)
        }
    }
}

struct PracticeWrongModel: Codable {
    let status: Int
    let tid: String
    let wrongQuestions: [WrongQuestion]
}

struct WrongQuestion: Codable {
    let id, classID, courseID, type: Int
    let content: String
    let option: [String]
    let answer: String
    let isCollected, isMistake: Int
    let errorOption: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case classID = "class_id"
        case courseID = "course_id"
        case type, content, option, answer
        case isCollected = "is_collected"
        case isMistake = "is_mistake"
        case errorOption = "error_option"
    }
}

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
        status: Int? = nil,
        tid: String? = nil,
        wrongQuestions: [WrongQuestion]? = nil
        ) -> PracticeWrongModel {
        return PracticeWrongModel(
            status: status ?? self.status,
            tid: tid ?? self.tid,
            wrongQuestions: wrongQuestions ?? self.wrongQuestions
        )
    }
    
    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }
    
    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}

extension WrongQuestion {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(WrongQuestion.self, from: data)
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
        id: Int? = nil,
        classID: Int? = nil,
        courseID: Int? = nil,
        type: Int? = nil,
        content: String? = nil,
        option: [String]? = nil,
        answer: String? = nil,
        isCollected: Int? = nil,
        isMistake: Int? = nil,
        errorOption: String? = nil
        ) -> WrongQuestion {
        return WrongQuestion(
            id: id ?? self.id,
            classID: classID ?? self.classID,
            courseID: courseID ?? self.courseID,
            type: type ?? self.type,
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

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}