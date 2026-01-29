//
//  AddressRowView.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/16/26.
//
import SwiftUI

struct AddressRowView: View {
    let geo: GeoClientAddress

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(geo.houseNumber) \(geo.streetName)")
                .font(.headline)

            Text("Borough: \(geo.borough)")
                .font(.subheadline)

            HStack {
                Text("Trash: \(geo.sanitationTrashSchedule ?? "—")")
                Text("Recycling: \(geo.recyclingScheduleText)")
                Text("Bulk: \(geo.bulkScheduleText)")
            }
            .font(.caption)
        }
    }
}
