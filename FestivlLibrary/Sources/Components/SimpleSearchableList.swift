//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 12/6/22.
//

import SwiftUI
import Utilities


public struct SimpleSearchableList<Data: RandomAccessCollection, Content: View>: View where Data.Element: Identifiable & Searchable {
    
    var data: Data
    @Binding var searchText: String
    var isLoading: Bool
    var content: (Data.Element) -> Content
    
    public init(data: Data, searchText: Binding<String>, isLoading: Bool, content: @escaping (Data.Element) -> Content) {
        self.data = data
        self._searchText = searchText
        self.isLoading = isLoading
        self.content = content
    }
    
    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                let filteredData = data.filterForSearchTerm(searchText)
                
                if filteredData.isEmpty {
                    NoResultsView(searchText: searchText)
                } else {
                    List {
                        ForEach(filteredData, content: content)
                    }
                }
            }
        }
        .searchable(text: $searchText)
    }
}

public struct NoResultsView: View {
    
    public init(searchText: String) {
        self.searchText = searchText
    }
    
    var searchText: String
    
    public var body: some View {
        VStack {
            Image(systemName: "magnifyingglass")
                .resizable()
                .foregroundColor(.systemGray)
                .frame(square: 40)
            
            Text("No Results for \"\(searchText)\"")
                .font(.title2)
                .bold()
            
            Text("Check the spelling or try a new search.")
                .font(.subheadline)
                .foregroundColor(.systemGray)
        }
    }
}

struct SimpleSearchableList_Previews: PreviewProvider {
    struct Simple: Identifiable, Searchable {
        var searchTerms: [String] {
            [String(id)]
        }
        
        var id: Int
    }
    
    struct Wrapper: View {
        @State var searchText: String = "blah"
        
        var body: some View {
            SimpleSearchableList(
                data: (0...10).map { Simple(id: $0) },
                searchText: $searchText,
                isLoading: false
            ) {
                Text(String($0.id))
            }
            .navigationTitle("Preview List")
        }
    }
    
    static var previews: some View {
        NavigationView {
            Wrapper()
        }
    }
}
