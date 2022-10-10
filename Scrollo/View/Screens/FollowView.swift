//
//  FollowView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct FollowView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var followViewModel: FollowViewModel = FollowViewModel()
    var firstOpen: String
    @State var currentTab: String = "followers"
    @Namespace var animation
    
    @State var refreshing: Bool = false
    
    var body: some View {
        VStack(spacing: 0){
            
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("circle_close")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("login")
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: "#1F2128"))
                Spacer(minLength: 0)
                Button(action: {
                   
                }) {
                    Color.clear
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.bottom)
            .padding(.horizontal)
            
            HStack(spacing: 0) {
                TabButton(title: "0 Подписчики", currentTab: $currentTab, animation: animation, id: "followers")
                TabButton(title: "0 Подписки", currentTab: $currentTab, animation: animation, id: "following")
            }
            .padding(.horizontal)
            
            Spacer(minLength: 0)
            
            VStack{
                
                if currentTab == "followers" {
                    VStack {
                        if followViewModel.loadFollowers {
                            VStack {
                                if followViewModel.followers.count == 0{
                                    Image("user.plue.circle.outlined")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(Color(hex: "#333333"))
                                        .padding(.bottom, 5)
                                        .padding(.top, 30)
                                    Text("Подписчики")
                                        .font(.system(size: 19))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#333333"))
                                        .padding(.bottom, 5)
                                    Text("Здесь будут отображаться все люди, которые на вас подписаны.")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                else{
                                    ForEach(0..<followViewModel.followers.count, id: \.self) {index in
                                        let follower = followViewModel.followers[index]
                                        FollowersItemView(follow: follower)
                                            .environmentObject(followViewModel)
                                    }
                                }
                            }
                            .pullToRefresh(refreshing: $refreshing, backgroundColor: Color.white, onRefresh: { done in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    followViewModel.getFollowers{
                                        done()
                                    }
                                }
                                
                            })
                        } else {
                            ProgressView()
                        }
                    }
                }
                
                if currentTab == "following" {
                    VStack {
                        if followViewModel.loadFollowing{
                            VStack {
                                if followViewModel.following.count == 0{
                                    Image("user.plue.circle.outlined")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 70, height: 70)
                                        .foregroundColor(Color(hex: "#333333"))
                                        .padding(.bottom, 5)
                                        .padding(.top, 30)
                                    Text("Люди, на обновления которых вы подписаны")
                                        .font(.system(size: 19))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#333333"))
                                        .multilineTextAlignment(.center)
                                        .padding(.bottom, 5)
                                    Text("Люди, на которых вы подпишитесь, будут отображаться здесь..")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color.gray.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                                else{
                                    ForEach(0..<followViewModel.following.count, id: \.self) {index in
                                        let following = followViewModel.following[index]
                                        FollowingItemView(follow: following)
                                            .environmentObject(followViewModel)
                                    }
                                }
                            }
                            .pullToRefresh(refreshing: $refreshing, backgroundColor: Color.white, onRefresh: { done in
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    followViewModel.getFollowing{
                                        done()
                                    }
                                }
                                
                            })
                        }
                        else{
                            ProgressView()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: Alignment(horizontal: .leading, vertical: .top))
            
        }
        .onAppear{
            currentTab = firstOpen
            followViewModel.getFollowers{
                
            }
            followViewModel.getFollowing{
                
            }
        }
    }
}



private struct FollowersItemView : View {
    @EnvironmentObject var followViewModel: FollowViewModel
    @State var isFollowed: Bool? = nil
    var follow: FollowersResponse.FollowerModel

    var body : some View {
        HStack(alignment: .center, spacing: 0) {
            if let avatar = follow.followedUser.avatar{
                WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .cornerRadius(10)
                    .padding(.trailing, 16)
            } else {
                DefaultAvatar(width: 44, height: 44, cornerRadius: 10)
                    .padding(.trailing, 16)
            }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(follow.followedUser.login!)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.bottom, 4)
                Text(follow.followedUser.career ?? "")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#828796"))
                Spacer()
            }
            Spacer()
            Button(action: {
                if isFollowed == true{
                    followViewModel.unFollowOnUser(userId: follow.followedUser.id) { status in
                        if status == true{
                            withAnimation(.easeInOut){
                                isFollowed = false
                            }
                        }
                    }
                }
                else if isFollowed == false{
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    followViewModel.followOnUser(userId: follow.followedUser.id) { status in
                        if status == true{
                            withAnimation(.easeInOut){
                                isFollowed = true
                            }
                        }
                    }
                }
            }) {
                Text(isFollowed == true ? "Вы подписаны" : "Подписаться")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                    .foregroundColor(isFollowed == true ? .black : .white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 9)
                    .background(isFollowed == true ? Color(hex: "#efefef") : Color(hex: "#5B86E5"))
                    .cornerRadius(6)
                    .opacity(isFollowed == nil ? 0 : 1)
                    .overlay{
                        if isFollowed == nil{
                            ProgressView()
                        }
                    }
            }
            
            Button(action: {
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                followViewModel.deleteFollower(userId: follow.followedUser.id) { status in
                    if status == true{
                        withAnimation(.easeInOut){
                            followViewModel.followers.removeAll(where: {$0.followedUser.id == follow.followedUser.id})
                        }
                    }
                }
            }){
                Image(systemName: "xmark.circle")
                    .font(.title2)
                    .foregroundColor(.black)
            }
            .frame(width: 23, height: 23)
            .padding(.leading, 20)
        }
        .padding(.top, 5)
        .padding(.bottom, 10)
        .padding(.horizontal)
        .onAppear {
            followViewModel.checkFollowOnFollower(userId: follow.followedUser.id) { isFollowed in
                if isFollowed == true {
                    withAnimation(.easeInOut){
                        self.isFollowed = true
                    }
                }
                else {
                    withAnimation(.easeInOut){
                        self.isFollowed = false
                    }
                }
            }
        }
    }
}

private struct FollowingItemView : View {
    @EnvironmentObject var followViewModel: FollowViewModel
    @State var isFollowed: Bool = true
    var follow: FollowersResponse.FollowerModel
    
    var body : some View {
        HStack(alignment: .center, spacing: 0) {
            if let avatar = follow.followOnUser.avatar{
                WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                    .resizable()
                    .frame(width: 44, height: 44)
                    .cornerRadius(10)
                    .padding(.trailing, 16)
            } else {
                DefaultAvatar(width: 44, height: 44, cornerRadius: 10)
                    .padding(.trailing, 16)
            }

            VStack(alignment: .leading, spacing: 0) {
                Spacer()
                Text(follow.followOnUser.login!)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.bottom, 4)
                Text(follow.followOnUser.career ?? "")
                    .font(.system(size: 12))
                    .fontWeight(.bold)
                    .foregroundColor(Color(hex: "#828796"))
                Spacer()
            }
            Spacer()
            Button(action: {
                if isFollowed {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    followViewModel.unFollowOnUser(userId: follow.followOnUser.id) { status in
                        if status == true{
                            withAnimation(.easeInOut){
                                isFollowed = false
                            }
                        }
                    }
                } else {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    followViewModel.followOnUser(userId: follow.followOnUser.id) { status in
                        if status == true{
                            withAnimation(.easeInOut){
                                isFollowed = true
                            }
                        }
                    }
                }
            }) {
                Text(isFollowed ? "Вы подписаны" : "Подписаться")
                    .font(.system(size: 10))
                    .fontWeight(.bold)
                    .foregroundColor(isFollowed ? .black : .white)
                    .padding(.horizontal, 22)
                    .padding(.vertical, 9)
                    .background(isFollowed ? Color(hex: "#efefef") : Color(hex: "#5B86E5"))
                    .cornerRadius(6)
            }
        }
        .padding(.top, 5)
        .padding(.bottom, 10)
        .padding(.horizontal)
    }
    
}
