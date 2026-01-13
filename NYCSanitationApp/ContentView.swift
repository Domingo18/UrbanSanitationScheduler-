//
//  ContentView.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/5/26.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = AddressViewModel()
    @State private var query = ""
    @State private var address: String = ""

    var body: some View {
        VStack{
            
            if viewModel.isLoading {
                ProgressView("Loading content...")
                // The spinner with an optional label
                    .padding()
            }
            if let geo = viewModel.geoResult {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Normalized Address:")
                        .font(.headline)
                    Text("\(geo.houseNumber) \(geo.streetName)")
                    Text("Borough: \(geo.borough)")
                    Text("Sanitation District: \(geo.sanitationDistrict ?? "Unknown")")
                    Text("Trash Schedule: \(geo.sanitationTrashSchedule ?? "Unknown")")
                    Text("Recycling Schedule: \(geo.sanitationRecyclingSchedule ?? "Unknown")")
                    Text("Large Items Schedule: \(geo.sanitationLargeItemsSchedule ?? "Unknown")")
                }
            }

            TextField("Enter your address", text: $address)
                .textFieldStyle(.roundedBorder)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await viewModel.lookupAddress(address)
                    }
                }
    


            List(viewModel.addresses) { address in
                VStack(alignment: .leading) {
                    Text(address.address)
                    Text(address.pickupDays.joined(separator: ", "))
                        .font(.caption)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadFromAPI()
            }

            
        }
    }
}
#Preview {
    ContentView()
}
