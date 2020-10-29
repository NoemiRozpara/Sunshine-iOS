//
//  ContentView.swift
//  Sunshine
//
//  Created by Noemi on 29/10/2020.
//

import SwiftUI
import Combine

struct City: Identifiable, Hashable {
    let id = UUID()
    let name: String
}

struct ContentView: View {
    @ObservedObject private var model = CitiesSearchModel()
    @State private var cityName = ""
    var body: some View {
        VStack {
            TextField("City name (min. 3 characters)", text: $model.query)
            List(model.cities) { city in
                Text(city.name)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class CitiesSearchModel: ObservableObject {
    private let citiesToSearch: [City] = [
        City(name: "Barcelona"),
        City(name: "Bolonia"),
        City(name: "San Diego"),
        City(name: "Berlin"),
        City(name: "Viena"),
        City(name: "Paris"),
        City(name: "Tokio"),
    ]
    
//    in
    @Published var query = ""
//    out
    @Published var cities: [City] = []
    
    private var cancellableSet: Set<AnyCancellable> = []
    
    private var citiesSearchPublisher: AnyPublisher<[City], Never> {
        $query
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .map { queryTerm in
                if queryTerm.count < 3 {
                    return []
                }
                return self.citiesToSearch.compactMap { (city: City) -> City? in
                    return city.name.contains(queryTerm)
                        ? city
                        : nil
                }
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        citiesSearchPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.cities, on: self)
            .store(in: &cancellableSet)
    }
}
