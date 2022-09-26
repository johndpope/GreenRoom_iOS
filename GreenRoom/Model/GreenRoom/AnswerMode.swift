//
//  AnswerMode.swift
//  GreenRoom
//
//  Created by Doyun Park on 2022/09/26.
//

import Foundation

enum Mode: Equatable {
    
    case edit
    case written(answer: Answer)
    case unWritten
    
}
