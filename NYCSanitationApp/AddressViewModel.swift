//
//  AddressViewModel.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/6/26.
//

import Foundation


@MainActor
class AddressViewModel: ObservableObject {
    
    @Published var addresses: [Address] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var geoResult: GeoClientAddress?

    
    
    
    func loadSample() {
        
        isLoading = true
        
        defer {
            isLoading = false
        }
        
        guard let url = Bundle.main.url(forResource: "addresses", withExtension: "json")
        else {
            errorMessage = "Failed to load JSON file"
            print("❌ JSON file not found in bundle")
            return
        }
        
        print("✅ JSON file found:", url)
        
        guard let data = try? Data(contentsOf: url)
        else {
            errorMessage = "Failed to read JSON data"
            print($errorMessage)
            return
        }
        
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let decoded = try decoder.decode([Address].self, from: data)
            self.addresses = decoded
            print("✅ Decoded addresses count:", decoded.count)
            
        } catch {
            self.errorMessage = error.localizedDescription
            print("decoding failed", error)
        }
        
        
    }
    func loadFromAPI() async {
        
        isLoading = true
        
        defer { isLoading = false }
        
        guard let url = URL(string: "https://jsonkeeper.com/b/YD8HE")
        else {
            errorMessage = "Invalid URL"
            return
        }
        
        do{
            let (data, _) = try await URLSession.shared.data(from: url)
            print("Data recieved", data.count)
            
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let decoded = try decoder.decode([Address].self, from: data)
            self.addresses = decoded
            print("✅ Decoded addresses count:", decoded.count)
            
        } catch {
            errorMessage = error.localizedDescription
            print("API Error:", error)
        }
    }
    
    func parseAddress(_ input: String)
    -> (house: String, street: String, borough: String)? {

        print("I'm parsing: \(input)")
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        print(cleaned)
        let parts = cleaned.split(separator: ",", maxSplits: 1)
        print(parts)
        let addressPart = String(parts[0]).trimmingCharacters(in: .whitespaces)
        var boroughPart = parts.count == 2
            ? String(parts[1]).trimmingCharacters(in: .whitespaces)
            : "0"
        
        switch boroughPart {
        case "Manhattan":
            boroughPart = "1"
        case "Bronx":
            boroughPart = "2"
        case "Brooklyn":
            boroughPart = "3"
        case "Queens":
            boroughPart = "4"
        case "StatenIsland":
            boroughPart = "5"
        default:
            boroughPart = "nnnnn"
        }

        let tokens = addressPart.split(separator: " ")
        guard let first = tokens.first,
              first.rangeOfCharacter(from: .decimalDigits) != nil
        else {
            return nil
        }

        let houseNumber = String(first)
        let street = tokens.dropFirst().joined(separator: " ")
        guard !street.isEmpty else { return nil }

        return (
            house: houseNumber,
            street: street,
            borough: boroughPart
        )
    }
    
    func lookupAddress(_ input: String) async {
        errorMessage = nil
        geoResult = nil
        print("I started looking up")
        guard let parsed = parseAddress(input) else {
            errorMessage = "Could not understand address"
            return
        }

        do {
            let geo = try await geocodeAddress(
                houseNumber: parsed.house,
                street: parsed.street,
                borough: parsed.borough
            )
            
            print(geo)

            self.geoResult = geo

            print("Sanitation District:", geo.sanitationDistrict ?? "none")

        } catch {
            errorMessage = error.localizedDescription
            print("something went wronghere")
        }
    }
    
    func geocodeAddress(
        houseNumber:    String,
        street:         String,
        borough:        String
    ) async throws -> GeoClientAddress {
        let API_KEY = "bQeThWmZq4t7wXzB"
        let baseURL = "https://geoservice.planning.nyc.gov/geoservice/geoservice.svc/Function_1B?"
        
        var components = URLComponents(string: baseURL)

        let items = [
            URLQueryItem(name: "Borough", value: borough),
            URLQueryItem(name: "AddressNo", value: houseNumber),
            URLQueryItem(name: "StreetName", value: street),
            URLQueryItem(name: "Key", value: API_KEY)
        ]

        components?.queryItems = items

        guard let url = components?.url else {
            throw URLError(.badURL)
        }
        print(url)

        let (data, responseCode) = try await URLSession.shared.data(from: url)
        print(responseCode)
        
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(GeoClientResponse.self, from: data)
        let d = response.display

        let address = GeoClientAddress(
            houseNumber: d.out_hnd?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "",
            streetName: d.out_stname1?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "",
            borough: d.out_boro_name1?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "",
            sanitationDistrict: d.out_san_dist_section?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "",
            sanitationTrashSchedule: d.out_san_reg?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "",
            sanitationRecyclingSchedule: d.out_san_recycle?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? "",
            sanitationLargeItemsSchedule: d.out_san_bulk?
                .trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) ?? ""
            
        )

        return address

    }
    
        
    
}
    
    
