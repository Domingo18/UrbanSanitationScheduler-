//
//  GeoClientDTO.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/11/26.
//

import Foundation


struct GeoClientResponse: Decodable {
    let display: GeoClientDisplay
}

struct GeoClientDisplay: Decodable {
        let out_hnd: String?
        let out_stname1: String?
        let out_boro_name1: String?
        let out_san_dist_section: String?
        let out_cd: String?

        let out_san_bulk: String?
        let out_san_org_pick_up: String?
        let out_san_recycle: String?
        let out_san_reg: String?
    }

struct GeoClientAddress {
    let houseNumber: String
    let streetName: String
    let borough:    String
    let sanitationDistrict:     String?
    let sanitationTrashSchedule: String?
    let sanitationRecyclingSchedule: String?
    let sanitationLargeItemsSchedule: String?
}




