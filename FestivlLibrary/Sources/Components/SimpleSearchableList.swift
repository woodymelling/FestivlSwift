//
//  SwiftUIView.swift
//  
//
//  Created by Woodrow Melling on 12/6/22.
//

import SwiftUI
import Utilities

struct UseNativeSearchBarEnvironmentKey: EnvironmentKey {
    static var defaultValue = true
}

extension EnvironmentValues {
    var useNativeSearchBar: Bool {
        get { self[UseNativeSearchBarEnvironmentKey.self] }
        set { self[UseNativeSearchBarEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func useNativeSearchBar(_ shouldUse: Bool) -> some View {
        self.environment(\.useNativeSearchBar, shouldUse)
    }
}


public struct SimpleSearchableList<
    Data: RandomAccessCollection,
    Content: View,
    NothingView: View
>: View where Data.Element: Identifiable & Searchable {
    @Environment(\.useNativeSearchBar) var useNativeSearchBar
    
    var data: Data
    @Binding var searchText: String
    var isLoading: Bool
    var content: (Data.Element) -> Content
    var emptyContent: () -> NothingView
    
    public init(
        data: Data,
        searchText: Binding<String>,
        isLoading: Bool,
        rowContent: @escaping (Data.Element) -> Content,
        emptyContent: @escaping () -> NothingView  = { EmptyView() }
    ) {
        self.data = data
        self._searchText = searchText
        self.isLoading = isLoading
        self.content = rowContent
        self.emptyContent = emptyContent
    }
    
    public var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else {
                let filteredData = data.filterForSearchTerm(searchText)
                
                if filteredData.isEmpty {
                    if searchText == "" {
                        emptyContent()
                    } else {
                        
                        NoResultsView(searchText: searchText)
                            .frame(maxHeight: .infinity)
                    }
                } else {
                    List {
                        ForEach(filteredData, content: content)
                    }
                    .listStyle(.plain)
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
