//
//  PopularPublicQuestion.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/29.
//

import Foundation

/** 인기 질문을 조회하는 Model */
struct PopularPublicQuestion: Codable {
    let id: Int
    let categoryName, profileImage, name: String
    let participants: Int
    let question, expiredAt: String
}

