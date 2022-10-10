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
    @State var isFocused: Bool = false
    @State var isRevealed: Bool = false
    @State private var searchTextFieldOnLongPressColor : Color = Color.primary.opacity(0.06)
    
    @State var refreshing: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack {
                VStack (spacing: 0) {
                    HStack(spacing: 0) {
                        HStack {
                            MyTextField(text: self.$searchViewModel.searchText,  isRevealed: $isRevealed, isFocused: $isFocused, placeholder: "Поиск")
                                .frame(height: 29)
                            if self.searchViewModel.searchText.count > 0 {
                                Button(action: {
                                    withAnimation(.easeInOut){
                                        self.searchViewModel.searchText = ""
                                    }
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
                        .padding(self.isFocused ? .leading : .horizontal)
                        .onTapGesture(perform: {
                            withAnimation(.easeInOut){
                                isFocused = true
                            }
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

                        if self.isFocused {
                            Button(action: {
                                withAnimation(.default) {
                                    self.isFocused = false
                                    self.searchViewModel.searchText = String()
                                    UIApplication.shared.endEditing()
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
                    .frame(height: (self.isFocused || searchViewModel.searchText.count > 0) ? 0 : nil)
                    .opacity((self.isFocused || searchViewModel.searchText.count > 0) ? 0 : 1)
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
                
                VStack{
                    ForEach(0..<searchViewModel.users.count, id: \.self){index in
                        SearchUserItem(user: searchViewModel.users[index])
                    }
                }
                .padding(.top)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)
                .opacity((self.isFocused || searchViewModel.searchText.count > 0) ? 1 : 0)
                .transition(.opacity)
            }
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}

private struct SearchUserItem: View {
    let user: UserModel.User

    
    var body: some View {
        NavigationLink(destination: ProfileView(userId: user.id)
                        .ignoreDefaultHeaderBar){
            HStack(alignment: .center, spacing: 0) {
                    if let avatar = self.user.avatar {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 44, height: 44)
                            .cornerRadius(10)
                            .padding(.trailing, 13)
                    } else {
                        DefaultAvatar(width: 44, height: 44, cornerRadius: 10)
                            .padding(.trailing, 13)
                    }
                
                VStack(alignment: .leading) {
                    Text(self.user.login ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#2E313C"))
                    Text(self.user.career ?? "")
                        .font(.system(size: 12))
                        .foregroundColor(Color(hex: "#828796"))
                }
                Spacer(minLength: 0)
                Button(action: {
                    
                }) {
                    Image("circle.xmark.black")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 28)
        }
        .buttonStyle(FlatLinkStyle())
    }
}

struct MyTextField: UIViewRepresentable {

    @State var isEnabled: Bool = true
    @Binding var text: String
    @Binding var isRevealed: Bool
    @Binding var isFocused: Bool
    var placeholder: String
     // 2
    func makeUIView(context: UIViewRepresentableContext<MyTextField>) -> UITextField {
        let tf = UITextField(frame: .zero)
        tf.placeholder = placeholder
        tf.isUserInteractionEnabled = true
        tf.delegate = context.coordinator
        return tf
    }

    func makeCoordinator() -> MyTextField.Coordinator {
        return Coordinator(text: $text, isEnabled: $isEnabled,  isFocused: $isFocused)
    }

    // 3
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.isSecureTextEntry = isRevealed
    }

    // 4
    class Coordinator: NSObject, UITextFieldDelegate {
        @Binding var text: String
        @Binding var isFocused: Bool

        init(text: Binding<String>, isEnabled: Binding<Bool>, isFocused: Binding<Bool>) {
            _text = text
            _isFocused = isFocused
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                withAnimation(.easeInOut){
                    self.isFocused = true
                }
            }
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            DispatchQueue.main.async {
                withAnimation(.easeInOut){
                    self.isFocused = false
                }
            }
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return false
        }
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
