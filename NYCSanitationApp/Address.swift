//
//  Address.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/6/26.
//

import Foundation


struct Address: Codable, Identifiable {
    let id:                        UUID
    let address:                 String
    let sanitationDistrict:      String?
    let sanitationTrashSchedule: String?
    let sanitationRecyclingSchedule: String?
    let sanitationLargeItemsSchedule: String?
    
}
