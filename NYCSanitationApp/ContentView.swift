//
//  ContentView.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/5/26.
//

import SwiftUI

struct ContentView: View {

    @StateObject private var viewModel = AddressViewModel()

    @State private var streetAddressLine1 = ""
    @State private var borough = ""

    var body: some View {
        NavigationStack {

            VStack(spacing: 16) {

                // MARK: Address Input
                VStack(spacing: 12) {
                    TextField("Enter your street address", text: $streetAddressLine1)
                        .textFieldStyle(.roundedBorder)

                    TextField("Enter your borough", text: $borough)
                        .textFieldStyle(.roundedBorder)

                    Button("Submit") {
                        Task {
                            let address = "\(streetAddressLine1), \(borough)"
                            await viewModel.lookupAddress(address)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)

                // MARK: - Loading
                if viewModel.isLoading {
                    ProgressView("Loading content...")
                        .padding()
                }

                // MARK: - Current Lookup Result
                if let geo = viewModel.geoResult {
                    ScheduleView(geo: geo)
                }

                // MARK: - Saved Addresses
                List {
                    ForEach(viewModel.savedAddresses) { geo in
                        NavigationLink(value: geo) {
                            AddressRowView(geo: geo)
                        }
                    }
                    .onDelete(perform: viewModel.deleteAddress)
                }
                .listStyle(.plain)

            }
            .padding()
            .navigationTitle("Sanitation Schedule")

            // MARK: - Navigation
            .navigationDestination(for: GeoClientAddress.self) { geo in
                ScheduleView(geo: geo)
            }
            .onAppear {
                viewModel.loadSavedAddresses()
            }
        }
    }
}

#Preview{
    ContentView()
}
