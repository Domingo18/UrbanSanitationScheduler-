//
//  AddressViewModel.swift
//  NYCSanitationApp
//
//  Created by Domingo Urena on 1/6/26.
//

import Foundation


@MainActor
class AddressViewModel: ObservableObject {
    
    @Published var savedAddresses: [GeoClientAddress] = []
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var geoResult: GeoClientAddress?
    private let savedAddressKey = "saved_geo_address"
    private let pickUpDays: [PickupDay] = []
    
    
    
    //parse through the address, and format to use for the API Call
    func parseAddress(_ input: String)
    -> (house: String, street: String, borough: String)? {

        
        let cleaned = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return nil }

        
        let parts = cleaned.split(separator: ",", maxSplits: 1)
    
        let addressPart = String(parts[0]).trimmingCharacters(in: .whitespaces)
        var boroughPart = parts.count == 2
            ? String(parts[1]).trimmingCharacters(in: .whitespaces)
            : "0"
        
        let boroughCleaned = boroughPart.lowercased()
        switch boroughCleaned {
        case "manhattan":
            boroughPart = "1"
        case "bronx":
            boroughPart = "2"
        case "brooklyn":
            boroughPart = "3"
        case "queens":
            boroughPart = "4"
        case "statenisland":
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
    
    
    //main function to produce an address for the UI to display
    func lookupAddress(_ input: String) async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil
        geoResult = nil
      
        //first normalize the address for our call later on
        guard let parsed = parseAddress(input) else {
            errorMessage = "Could not understand address"
            return
        }

        //use our parsed address components to initialize our geocodeAddress call
        do {
            let geo = try await geocodeAddress(
                houseNumber: parsed.house,
                street: parsed.street,
                borough: parsed.borough
            )
            
            print(geo)

            //set the geoResult variable to our result
            self.geoResult = geo
            //save the address in user defaults for persistance
            saveAddress(geo)

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
        
        //Contruct a URL using an address
        
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
    
        // Initriate a async API Call with the contructed URL
        let (data, _) = try await URLSession.shared.data(from: url)
         
        //decode required data from the geoservice function 1B response
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(GeoClientResponse.self, from: data)
        let d = response.display

        // parse and intialize a geoclientaddress object using the data from our api response
        let address = GeoClientAddress(
            id: UUID(),
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
    
    func saveAddress(_ address: GeoClientAddress) {
        do {
            var current = savedAddresses
            current.append(address)

            let data = try JSONEncoder().encode(current)
            UserDefaults.standard.set(data, forKey: "savedAddresses")

            savedAddresses = current
        } catch {
            print("Failed to save addresses:", error)
        }
    }


    func loadSavedAddresses() {
        guard let data = UserDefaults.standard.data(forKey: "savedAddresses") else {
            return
        }

        do {
            savedAddresses = try JSONDecoder().decode([GeoClientAddress].self, from: data)

        } catch {
            print("Failed to load saved addresses:", error)
        }
    }
    
    func deleteAddress(at offsets: IndexSet) {
        var current = savedAddresses
        current.remove(atOffsets: offsets)
        
        do {
            let data = try JSONEncoder().encode(current)
            UserDefaults.standard.set(data, forKey: "savedAddresses")
            
            savedAddresses = current
        } catch {
            print("Failed to delete address")
        }
    }
    
   

        
    

}
    
    
