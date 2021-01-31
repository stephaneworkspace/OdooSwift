//
//  DayWork.swift
//  Odoo
//
//  Created by Stéphane Bressani on 31.01.21.
//

import Foundation

struct DayWork: Decodable {
    var day: String?,
        work: Array<Work>?
}
