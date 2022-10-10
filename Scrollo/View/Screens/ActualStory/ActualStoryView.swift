//
//  ActualStory.swift
//  scrollo
//
//  Created by Artem Strelnik on 21.08.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ActualStoryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var actualStoryDelegate: ActualStoryDelegate = ActualStoryDelegate()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("circle.xmark.black")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                    Spacer(minLength: 0)
                    Text(actualStoryDelegate.selectedStories.count > 0 ? "Выбрано: \(actualStoryDelegate.selectedStories.count)" : "Истории")
                        .font(.system(size: 20))
                        .fontWeight(.bold)
                        .textCase(.uppercase)
                        .foregroundColor(Color(hex: "#2E313C"))
                    Spacer(minLength: 0)
                    Button(action: {
                        if actualStoryDelegate.selectedStories.count > 0 {
                            actualStoryDelegate.actualStoryCoverView.toggle()
                        }
                    }) {
                        Image("circle.right.arrow.blue")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                }
                .padding(.horizontal, 23)
                .padding(.bottom)
                ScrollView(showsIndicators: false) {
                    makeGrid()
                }
                Spacer()
            }
            .edgesIgnoringSafeArea(.bottom)
            .background(
                NavigationLink(destination: ActualStoryCoverView()
                                .environmentObject(actualStoryDelegate)
                                .ignoreDefaultHeaderBar, isActive: $actualStoryDelegate.actualStoryCoverView, label: {
                    EmptyView()
                }).hidden()
            )
            .ignoreDefaultHeaderBar
        }
    }
    
    private func makeGrid() -> some View {
        let count = actualStoryDelegate.actualStories.count
        let rows = count / actualStoryDelegate.columns + (count % actualStoryDelegate.columns == 0 ? 0 : 1)
            
        return VStack(alignment: .leading, spacing: 9) {
            ForEach(0..<rows) { row in
                HStack(spacing: 9) {
                    ForEach(0..<actualStoryDelegate.columns) {column in
                        let index = row * actualStoryDelegate.columns + column
                        if index < count {
                            Button(action: {
                                if let index = actualStoryDelegate.selectedStories.firstIndex(where: {$0.id == actualStoryDelegate.actualStories[index].id}) {
                                    actualStoryDelegate.selectedStories.remove(at: index)
                                } else {
                                    actualStoryDelegate.selectedStories.append(actualStoryDelegate.actualStories[index])
                                }
                            }) {
                                StoryCardPreviewView(selectedStories: actualStoryDelegate.selectedStories, story: actualStoryDelegate.actualStories[index], index: index, size: actualStoryDelegate.size)
                            }
                            .buttonStyle(FlatLinkStyle())
                        } else {
                            AnyView(EmptyView())
                                .frame(width: actualStoryDelegate.size, height: 180)
                        }
                    }
                }
            }
        }
        .padding(.top, 10)
        .padding(.horizontal, 9)
    }
}


private struct StoryCardPreviewView: View {
    var selectedStories: [ActualStoryModel]
    var story: ActualStoryModel
    var index: Int
    var size: CGFloat
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ZStack(alignment: .topTrailing) {
                WebImage(url: URL(string: story.url)!)
                    .resizable()
                    .indicator(.activity)
                    .transition(.fade(duration: 0.5))
                    .scaledToFill()
                    .frame(width: size, height: 180)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .clipped()
                    .overlay(
                        Color.white.opacity(self.checkSelect() ? 0.4 : 0)
                    )
                
                let number = self.getNumber()
                
                ZStack {
                    Circle()
                        .strokeBorder(Color.white,lineWidth: 1)
                        .background(Circle().foregroundColor(self.checkSelect() ? Color(hex: "#66b0ff") : Color.white.opacity(0.3)))
                        .frame(width: 20, height: 20)
                    if number != -1 {
                        Text("\(number)")
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                    }
                        
                }
                .frame(width: 20, height: 20)
                .offset(x: -7, y: 7)
                
            }
            if (index + 4) % 2 == 0  || index == 0{
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: 38, height: 38)
                    .overlay(
                        VStack(spacing: 0){
                            Text("\(index + 1)")
                                .font(.system(size: 15))
                                .fontWeight(.semibold)
                                .foregroundColor(.black)
                            Text("марта")
                                .font(.system(size: 9))
                                .foregroundColor(.black)
                        }
                    )
                    .offset(x: 10, y: 10)
            }
        }
    }
    
    func getNumber () -> Int {
        
        if let i = selectedStories.firstIndex(where: { $0.id == story.id}) {
            
            return i + 1
        } else {
            
            return -1
        }
    }
    func checkSelect () -> Bool {
        
        if let _ = selectedStories.firstIndex(where: { $0.id == story.id}) {
            
            return true
        } else {
            
            return false
        }
    }
}

struct ActualStoryModel {
    var id = UUID().uuidString
    var url: String
}

class ActualStoryDelegate: ObservableObject {
    let actualStories: [ActualStoryModel] = [
        ActualStoryModel(url: "https://images.unsplash.com/photo-1660570153201-adf2c9b87a72?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1660554969989-99b47174f499?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=687&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1661010854342-acfc962a0352?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1648240925834-7cd64180fff0?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1660866838212-df428c885827?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=870&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1660645341155-7b15047325ff?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1554797589-7241bb691973?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=436&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1601823984263-b87b59798b70?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1522383225653-ed111181a951?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=876&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1542931287-023b922fa89b?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80"),
        ActualStoryModel(url: "https://images.unsplash.com/photo-1505069446780-4ef442b5207f?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=387&q=80")
    ]
    
    let columns = 3
    let size = (UIScreen.main.bounds.width / 3) - 12
    
    @Published var selectedStories: [ActualStoryModel] = []
    
    @Published var name: String = ""
    let characterLimit: Int = 15
    
    @Published var selectedCover: ActualStoryModel?
    
    @Published var cropperPresent: Bool = false
    @Published var actualStoryCoverView: Bool = false
}
