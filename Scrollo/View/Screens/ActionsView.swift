//
//  ActionsView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 10.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ActionsView: View {
    @StateObject var actions: ActionViewModel = ActionViewModel()
    @State private var selection: String = "Вы"
    private let tabs: [String] = ["Вы", "Запросы"]
    
    @State var refreshing: Bool = false
    
    var body: some View {
        VStack {
            self.tabsHeader()
            VStack {
                TabView(selection: self.$selection) {
                    VStack {
                        if actions.load {
                            if actions.actions.count > 0 {
                                
                                ForEach(0..<actions.actions.count, id: \.self){index in
                                    HStack {
                                        Text(actions.actions[index].title)
                                            .font(.system(size: 18))
                                            .bold()
                                            .textCase(.uppercase)
                                            .foregroundColor(Color(hex: "#2E313C"))
                                            .padding(.top, 16)
                                            .padding(.bottom, 18)
                                            .padding(.horizontal, 8)
                                        Spacer()
                                    }
                                    ForEach(0..<actions.actions[index].data.count, id: \.self){j in
                                        ActionView(action: actions.actions[index].data[j])
                                            .environmentObject(actions)
                                        if (j == actions.actions[index].data.count - 1 && index == actions.actions.count - 1) {
                                            Color.clear.frame(height: 100)
                                        }
                                    }
                                }
                            } else {
                                VStack(alignment: .center) {
                                    Text("Здесь будут показываться ваши cобытия.")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                                        .padding(.horizontal, 40)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .pullToRefresh(refreshing: $refreshing, backgroundColor: Color(hex: "#F9F9F9")) { done in
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
                            actions.getActions {
                                done()
                            }
                        }
                    }
                    .tag("Вы")
                    
                    ScrollView(showsIndicators: false) {
                        
                    }.tag("Запросы")
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment(horizontal: .leading, vertical: .top))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment(horizontal: .leading, vertical: .top))
        .background(Color(hex: "#F9F9F9").ignoresSafeArea(.all))
    }
    
    @ViewBuilder
    private func tabsHeader() -> some View {
        HStack(spacing: 0) {
            ForEach(0..<self.tabs.count, id: \.self) {index in
                ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                    Button(action: {
                        withAnimation(.default) {
                            self.selection = self.tabs[index]
                        }
                    }) {
                        Text(self.tabs[index])
                            .font(.custom(self.selection == self.tabs[index] ? GothamBold : GothamBook, size: 13))
                            .textCase(.uppercase)
                            .foregroundColor(Color(hex: self.selection == self.tabs[index] ? "#5B86E5" :  "#333333"))
                    }
                    .padding(.vertical)
                    .frame(width: (UIScreen.main.bounds.width / CGFloat(self.tabs.count) - 32))
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(hex: "#5B86E5").opacity(self.selection == self.tabs[index] ? 1 : 0))
                        .frame(width: (UIScreen.main.bounds.width / CGFloat(self.tabs.count) - 32), height: 3)
                }
            }
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity)
    }
}

//MARK: Actions
private struct ActionView: View{
    @EnvironmentObject var actions: ActionViewModel
    @State var isFollow: Bool = false
    var action: ActionResponse.ActionModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
//            ActionAvatar(userId: action.creator.id, avatar: action.creator.avatar)
            if let avatar = action.creator.avatar {
                WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .cornerRadius(10)
            } else {
                DefaultAvatar(width: 44, height: 44, cornerRadius: 10)
                    .padding(.trailing, 16)
            }
            Group {
                Text("\(action.creator.login)").font(.custom(GothamBold, size: 14)) + Text(" ") + Text(getActionString()).font(.custom(GothamBook, size: 12)).foregroundColor(Color(hex: "#2E313C")) + Text(getActionSubStringUserLogin()).font(.custom(GothamBold, size: 12)).foregroundColor(Color(hex: "#7737FF")) + Text(getActionSubString()).font(.custom(GothamBook, size: 12)).foregroundColor(Color(hex: "#2E313C")) + Text(" ") + Text(self.howMuchTimeHasPassed()).font(.custom(GothamBold, size: 12)).foregroundColor(Color(hex: "#828796"))
            }
            .padding(.horizontal, 11)
    
            Spacer()
            
            if (action.action == "SENT_FOLLOW_REQUEST" || action.action == "FOLLOW") {
                Button(action: {
                    if (!isFollow) {
                        actions.followOnUser(userId: action.creator.id) {
                            self.isFollow = true
                        }
                    }
                }) {
                    Text(!isFollow ? "Подписаться" : "Написать").font(.custom(GothamBold, size: 10)).foregroundColor(!isFollow ? Color.white : Color(hex: "#444A5E"))
                }
                .padding(.horizontal)
                .padding(.vertical, 10)
                .background(RoundedRectangle(cornerRadius: 9).fill(!isFollow ? Color(hex: "#5B86E5") : Color.clear))
                .background(
                    RoundedRectangle(cornerRadius: 9)
                        .stroke(!isFollow ? Color(hex: "#5B86E5") : Color(hex: "#DDE8E8"), lineWidth: 1)
                    )
            }
            
            if (action.action == "COMMENT_LIKE" || action.action == "COMMENT_DISLIKE" || action.action == "COMMENT_REPLY" || action.action == "POST_LIKE" || action.action == "POST_DISLIKE" || action.action == "POST_COMMENT") {
                if let post = action.post {
                    if let preview = post.preview {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(preview)")!)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .cornerRadius(10)
                    }
                }
            }
            
            
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(action.action == "SENT_FOLLOW_REQUEST" || action.action == "FOLLOW" ? Color.white : Color.clear)
        .cornerRadius(10)
        .padding(.bottom)
        .onAppear {
            actions.checkFollowOnUser(userId: action.creator.id) { follow in
                if (follow == true) {
                    isFollow = true
                } else {
                    isFollow = false
                }
                
            }
        }
    }
    
    func howMuchTimeHasPassed () -> String {
        let actionDate = action.createdAt.split(separator: ".")[0] + "+" + action.createdAt.split(separator: "+")[1]
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: String(actionDate))!
        
        let currentDate = Date()
        var calendar = Calendar.current

        if let timeZone = TimeZone(identifier: "MSK") {
           calendar.timeZone = timeZone
        }

        let diffComponents = calendar.dateComponents([.hour, .minute, .day], from: date, to: currentDate)
        let days = diffComponents.day
        let hours = diffComponents.hour
        let minutes = diffComponents.minute
        
        if (days! > 0) {
            return "\(days!)д"
        } else if (hours! < 1) {
            return "\(minutes!)м"
        } else if (hours! <= 24) {
            return "\(hours!)ч"
        } else {
            return ""
        }
    }
    

    func getActionString () -> String {
        switch action.action {
            case "SENT_FOLLOW_REQUEST":
                return "отправил вам запрос на подписку"
            case "COMMENT_REPLY":
                return "ответил на ваш комментарий "
            case "POST_DISLIKE":
                return "не нравится ваша публикация "
            case "COMMENT_DISLIKE":
                return "не нравится ваш комментарий "
            case "ACCEPT_FOLLOW_REQUEST":
                return "принял ваш запрос"
            case "POST_COMMENT":
            return "прокомментировал вашу публикацию "
            case "COMMENT_LIKE":
                return "нравится ваш комментарий "
            case "POST_LIKE":
                return "нравится ваша публикация "
            default:
                return "подписался(-ась) на ваши обновления"
        }
    }
    
    func getActionSubStringUserLogin () -> String {
        switch action.action {
            case "SENT_FOLLOW_REQUEST":
                return ""
            case "COMMENT_REPLY":
                return "\(action.comment?.comment != nil ? action.receiver.login : "") "
            case "POST_DISLIKE":
                return ""
            case "COMMENT_DISLIKE":
                return "\(action.comment?.comment != nil ? action.receiver.login : "") "
            case "ACCEPT_FOLLOW_REQUEST":
                return ""
            case "POST_COMMENT":
            return "\(action.post?.content != nil ? action.receiver.login : "") "
            case "COMMENT_LIKE":
                return ""
            case "POST_LIKE":
                return ""
            default:
                return ""
        }
    }
    
    func getActionSubString () -> String {
        switch action.action {
            case "SENT_FOLLOW_REQUEST":
                return ""
            case "COMMENT_REPLY":
                return "\(action.comment?.comment ?? "")"
            case "POST_DISLIKE":
                return "\(action.post?.content ?? "")"
            case "COMMENT_DISLIKE":
                return "\(action.comment?.comment ?? "")"
            case "ACCEPT_FOLLOW_REQUEST":
                return ""
            case "POST_COMMENT":
            return "\(action.post?.content ?? "")"
            case "COMMENT_LIKE":
                return "\(action.comment?.comment ?? "")"
            case "POST_LIKE":
                return "\(action.post?.content ?? "")"
            default:
                return ""
        }
    }
}
