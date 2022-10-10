//
//  ChatSettingsView.swift
//  scrollo
//
//  Created by Artem Strelnik on 16.09.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatSettingsView: View {
    @State var notifyMessage: Bool = false
    @State var notifyOff: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HeaderBar()
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading){
                    Text("Уведомления")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                        .padding(.horizontal, 23)
                    
                    Toggle("Включить уведомления о сообщениях", isOn: $notifyMessage)
                        .font(.system(size: 15))
                        .padding(.horizontal, 23)
                    Toggle("Отключить уведомления чата", isOn: $notifyOff)
                        .font(.system(size: 15))
                        .padding(.horizontal, 23)
                    
                    Text("Другие действия")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 23)
                    
                    Button(action: {}){
                        Text("Поиск в переписке")
                            .font(.system(size: 15))
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 23)
                    
                    Text("Фото и видео")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 23)
                    
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack(spacing: 3){
                            ForEach(0..<3, id:\.self){_ in
                                WebImage(url: URL(string: "https://picsum.photos/80/80?random=\(Int.random(in: 0..<4))"))
                                    .resizable()
                                    .frame(width: 80, height: 80)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(5)
                                    .transition(.opacity)
                            }
                        }
                        .padding(.horizontal, 23)
                    }
                    
                    
                    Text("Участники")
                        .font(.system(size: 15))
                        .fontWeight(.bold)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 23)
                    
                    
                    VStack{
                        ForEach(0..<2, id:\.self){_ in
                            HStack{
                                WebImage(url: URL(string: "https://picsum.photos/50/50?random=\(Int.random(in: 0..<5))"))
                                    .resizable()
                                    .frame(width: 50, height: 50)
                                    .background(Color.gray.opacity(0.2))
                                    .clipShape(Circle())
                                    .transition(.opacity)
                                Text("User login")
                                    .font(.system(size: 15))
                                    .fontWeight(.bold)
                                    .padding(.leading, 5)
                            }
                        }
                    }
                    .padding(.horizontal, 23)
                }
            }
        }
    }
}

private struct HeaderBar: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View{
        HStack(spacing: 0) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("circle_close")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
            .frame(width: 24, height: 24)
            .padding(.leading, 23)
            Spacer()
            Text("Подробности")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundColor(Color(hex: "#2E313C"))
            Spacer()
            Color.clear.frame(width: 24, height: 24)
        }
        .padding(.bottom)
    }
}
