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
    var useNativeSearchBar: Bool
    var content: (Data.Element) -> Content
    
    public init(
        data: Data,
        searchText: Binding<String>,
        isLoading: Bool = false,
        useNativeSearchBar: Bool = true,
        content: @escaping (Data.Element) -> Content
    ) {
        self.data = data
        self._searchText = searchText
        self.isLoading = isLoading
        self.useNativeSearchBar = useNativeSearchBar
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
                        .frame(maxHeight: .infinity)
                } else {
                    List {
                        ForEach(filteredData, content: content)
                    }
                }
            }
        }
        .if(useNativeSearchBar) {
            $0.searchable(text: $searchText)
        }
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
        .multilineTextAlignment(.center)
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
        NavigationStack {
            Wrapper()
        }
    }
}
