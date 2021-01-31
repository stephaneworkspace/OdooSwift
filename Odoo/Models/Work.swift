//
//  Work.swift
//  Odoo
//
//  Created by Stéphane Bressani on 31.01.21.
//

import Foundation

struct Work: Codable {
    var activity: String?,
        product_name: String?,
        worked_hour: Float64?,
        product_list_price: Float64?,
        price_raw: Float64?,
        product_description_sale: String?,
        note: String?
}
