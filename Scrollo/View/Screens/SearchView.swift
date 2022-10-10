//
//  SearchView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 10.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct SearchView: View {
    @StateObject var searchViewModel : SearchViewModel = SearchViewModel()
    @FocusState private var isSearch : Bool
    @State private var searchTextFieldOnLongPressColor : Color = Color.primary.opacity(0.06)
    
    @State var refreshing: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack {
                VStack (spacing: 0) {
                    HStack(spacing: 0) {
                        HStack {
                            TextField("Поиск", text: self.$searchViewModel.searchText)
                                .focused(self.$isSearch)
                                .onSubmit {
//                                    if self.searchViewModel.searchText.count > 0 {
//                                        self.searchHistoryViewModel.saveUserSearchedHistory(user: self.searchViewModel.searchText)
//                                    }
                                }
                                .onChange(of: self.isSearch) { newValue in
//                                    if !self.searchHistoryViewModel.isSearch && newValue {
//                                        withAnimation(.default) {
//                                            self.searchHistoryViewModel.isSearch = true
//                                        }
//                                    }
                                }
                            if self.searchViewModel.searchText.count > 0 {
                                Button(action: {
                                    self.searchViewModel.searchText = ""
                                }) {
                                    Image(systemName: "multiply.circle.fill")
                                        .font(.title3)
                                        .foregroundColor(Color.gray)
                                }
                            } else {
                                Image(systemName: "magnifyingglass")
                                    .font(.title3)
                                    .foregroundColor(Color.gray)
                            }

                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal)
                        .background(self.searchTextFieldOnLongPressColor)
                        .cornerRadius(10)
                        .padding(self.isSearch ? .leading : .horizontal)
                        .onTapGesture(perform: {
                            self.isSearch = true
                        })
                        .onLongPressGesture(minimumDuration: 0.5, maximumDistance: 100, pressing: {
                                                    pressing in
                            if pressing {
                                self.searchTextFieldOnLongPressColor = Color.primary.opacity(0.08)
                            }
                            if !pressing {
                                self.searchTextFieldOnLongPressColor = Color.primary.opacity(0.06)
                            }
                        }, perform: {})

                        if self.isSearch {
                            Button(action: {
                                withAnimation(.default) {
                                    self.isSearch = false
//                                    self.searchViewModel.searchText = String()
//                                    UIApplication.shared.endEditing()
                                }
                            }) {
                                Text("Отмена")
                                    .foregroundColor(.black)
                            }
                            .padding(.horizontal)
                        }
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 0) {
                            ForEach(0..<10, id: \.self) {index in
                                HashTagButtom(index: index, title: "ThisTag")
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 18)
                    .frame(height: self.isSearch ? 0 : nil)
                    .opacity(self.isSearch ? 0 : 1)
                }
            }
            .background(Color.white)
            
            ZStack(alignment: .top) {
                VStack(spacing: 0){
                    if let images = self.searchViewModel.images {
                        SearchCompositionLayout(items: images, id: \.id, spacing: 11) {item in
                            GeometryReader{proxy in

                            let size = proxy.size

                            WebImage(url: URL(string: item.download_url))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: size.height)
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 23)
                        .padding(.bottom, 200)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(.clear)
                    } else {
                        HStack {
                            Spacer(minLength: 0)
                            ProgressView()
                            Spacer(minLength: 0)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparatorTint(.clear)
                    }
                }
                .pullToRefresh(refreshing: $refreshing, backgroundColor: Color.white) { done in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.3) {
                        done()
                    }
                }
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

private struct HashTagButtom : View {
    
    @State private var isActive : Bool = false
    
    private let index : Int
    private let title : String
    
    init (index : Int, title : String) {
        self.index = index
        self.title = title
    }
    
    var body: some View {
        Button(action: {
            self.isActive.toggle()
        }) {
            Text("# \(self.title)")
                .font(Font.custom(GothamBook, size: 12))
                .foregroundColor(Color(hex: "#5B86E5"))
                .padding(.horizontal, 11)
                .padding(.vertical, 5)
                .overlay(
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(self.isActive ? Color(hex: "#5B86E5") : Color(hex: "#5B86E5").opacity(0.1), lineWidth: 1)
                )
        }
        .background(self.isActive ? Color.white : Color(hex: "#5B86E5").opacity(0.1)).cornerRadius(7)
        .padding(.trailing, self.index == 9 ? 0 : 8)
        .onAppear {
            self.isActive = index == 0 ? true : false
        }
    }
}

private struct SearchCompositionLayout<Content, Item, ID>  : View where Content: View, Item: RandomAccessCollection, Item.Element: Hashable , ID: Hashable {
    
    private let content: (Item.Element) ->  Content
    private let id: KeyPath<Item.Element, ID>
    private let items: Item
    private let spacing: CGFloat
     
    init (items: Item, id: KeyPath<Item.Element, ID>, spacing: CGFloat = 5, @ViewBuilder content: @escaping (Item.Element) -> Content ) {
        self.items = items
        self.id = id
        self.content = content
        self.spacing = spacing
    }
    
    var body : some View {
        LazyVStack(spacing: self.spacing ) {
            ForEach(self.generateColumns(), id: \.self) {row in
                
                self.RowView(row: row)
            }
        }
    }
    
    private func layoutType (row: [Item.Element]) -> LayoutType {
        
        let index = self.generateColumns().firstIndex { item in
            return item == row
        } ?? 0
        
        var types: [LayoutType] = []
        
        self.generateColumns().forEach {_ in
            if types.isEmpty {
                
                types.append(.type1)
            } else if types.last == .type1 {
                
                types.append(.type2)
            } else if types.last == .type2 {
                 
                types.append(.type3)
            } else if types.last == .type3 {
                
                types.append(.type1)
            } else { }
        }
        
        return types[index ]
    }
    
    @ViewBuilder
    private func RowView (row: [Item.Element ]) -> some View {
        
        GeometryReader {proxy in
            
            let width = proxy.size.width
            let height = (proxy.size.height - spacing) / 2
            let type = self.layoutType(row: row)
            let columnWidth = (width > 0 ? ((width - (spacing * 2 )) / 3 ) : 0)
            
            HStack(spacing: self.spacing) {
                if type == .type1 {
                    self.SafeView(row: row, index: 0)
                    VStack(spacing: self.spacing) {
                        self.SafeView(row: row, index: 1)
                            .frame(height: height)
                        self.SafeView(row: row, index: 2)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                }
                
                if type == .type2 {
                    HStack(spacing: self.spacing) {
                        self.SafeView(row: row, index: 2)
                            .frame(width: columnWidth)
                        self.SafeView(row: row, index: 1)
                            .frame(width: columnWidth)
                        self.SafeView(row: row, index: 0)
                            .frame(width: columnWidth)
                    }
                }
                
                if type == .type3 {
                    VStack(spacing: self.spacing) {
                        self.SafeView(row: row, index: 0)
                            .frame(height: height)
                        self.SafeView(row: row, index: 1)
                            .frame(height: height)
                    }
                    .frame(width: columnWidth)
                    self.SafeView(row: row, index: 2 )
                }
            }
        }
        .frame(height: self.layoutType(row: row) ==  .type1 || self.layoutType(row: row) ==  .type3 ? 250 : 120 )
    }
    
    @ViewBuilder
    private func SafeView(row: [Item.Element], index: Int) -> some View {
        
        if (row.count -  1) >= index {
            content(row[index ])
        }
    }
    
    private func generateColumns() -> [[Item.Element]] {
        var columns: [[Item.Element]] = []
        var row: [Item.Element] = []
        
        for item in items {
            
            if row.count == 3 {
                columns.append(row)
                row.removeAll()
                row.append(item )
            } else {
                row.append(item)
            }
        }
        
        columns.append(row)
        row.removeAll()
        return columns
    }
}

enum LayoutType {
    case type1
    case type2
    case type3
}
