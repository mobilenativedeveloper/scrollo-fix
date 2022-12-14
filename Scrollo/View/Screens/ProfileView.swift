//
//  ProfileView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI



struct ProfileView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var offset: CGFloat = 0
    
    @State var user: UserModel.User?
    
    var userId: String
    
    @Binding var isPresented: Bool?
    
    
    @State var editUserPresent: Bool = false
    
    @State var selectedTab: String = "media"
    
    @State var isPublicationSheet: Bool = false
    
    @State var isPresentActualStoryView: Bool = false
    @State var isPresentCreateTextPost: Bool = false
    @State var isPresentCreateMediaPost: Bool = false
    @State var isPresentCreateStory: Bool = false
    
    @State var isSettingsSheet: Bool = false
    
    @State var yourActivityPresent: Bool = false
    @State var interestingPeoplePresent: Bool = false
    @State var settingsPresent: Bool = false
    
    @StateObject var postViewModel: PostViewModel = PostViewModel()
    
    @State var savedPresent: Bool = false
    
    @State var textPosts: [PostModel] = []
    @State var loadTextposts: Bool = false
    
    @State var mediaPost: [[[PostModel]]] = []
    @State var loadMdeiaPost: Bool = false
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            
            VStack(spacing: 15){
                
                GeometryReader{proxy -> AnyView in
                    
                    let minY = proxy.frame(in: .global).minY
                    
                    DispatchQueue.main.async {
                        self.offset = minY
                    }
                    
                    return AnyView(
                        ZStack{
                            if let background = user?.background {
                                WebImage(url: URL(string: "\(API_URL)/uploads/\(background)")!)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: getRect().width, height: minY > 0 ? 180 + minY :  180, alignment: .center)
                                    .cornerRadius(0)
                            }
                            else{
                                LinearGradient(colors: [
                                    Color(hex: "#5B86E5"),
                                    Color(hex: "#36DCD8")
                                ], startPoint: .trailing, endPoint: .leading)
                                    .frame(width: getRect().width, height: minY > 0 ? 180 + minY :  180, alignment: .center)
                                    .cornerRadius(0)
                            }
                            
                            
                            BlurView()
                                .opacity(blurViewOpacity())
                        }
                            .frame(height: minY > 0 ? 180 + minY :  nil)
                            .offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
                    )
                }
                .frame(height: 180)
                .zIndex(1)
                
                
                VStack{
                    ZStack{
                        if let avatar = user?.avatar {
                            WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 101, height: 101)
                                .background(Color(hex: "#f7f7f7"))
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .shadow(color: Color.black.opacity(0.5), radius: 4)
                                .padding(.top, -25)
                                .offset(y: offset < 0 ? getOffset() - 20 : -20)
                                .scaleEffect(getScale())
                        }
                        else{
                            Image("default_avatar")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 101, height: 101)
                                .background(Color(hex: "#f7f7f7"))
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .shadow(color: Color.black.opacity(0.5), radius: 4)
                                .padding(.top, -25)
                                .offset(y: offset < 0 ? getOffset() - 20 : -20)
                                .scaleEffect(getScale())
                        }
                        
                        
                        
                        HStack{
                            
                            if self.userId == UserDefaults.standard.string(forKey: "userId") {
                                NavigationLink(destination: FollowView(firstOpen: "followers", userId: userId)
                                                .ignoreDefaultHeaderBar){
                                    VStack {
                                        Text("\(user?.followersCount ?? 0)")
                                            .font(.system(size: 21))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(hex: "#1F2128"))
                                        Text("????????????????????")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(hex: "#828796"))
                                    }
                                }
                                Spacer()
                                
                                NavigationLink(destination: FollowView(firstOpen: "following", userId: userId)
                                                .ignoreDefaultHeaderBar){
                                    VStack {
                                        Text("\(user?.followingCount ?? 0)")
                                            .font(.system(size: 21))
                                            .fontWeight(.bold)
                                            .foregroundColor(Color(hex: "#1F2128"))
                                        Text("????????????????")
                                            .font(.system(size: 11))
                                            .foregroundColor(Color(hex: "#828796"))
                                    }
                                }
                            }
                            else{
                                VStack {
                                    Text("\(user?.followersCount ?? 0)")
                                        .font(.system(size: 21))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#1F2128"))
                                    Text("????????????????????")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "#828796"))
                                }
                                Spacer()
                                
                                VStack {
                                    Text("\(user?.followingCount ?? 0)")
                                        .font(.system(size: 21))
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(hex: "#1F2128"))
                                    Text("????????????????")
                                        .font(.system(size: 11))
                                        .foregroundColor(Color(hex: "#828796"))
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    .padding(.horizontal)
                    VStack{
                        Text("\(user?.login ?? "")")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#1F2128"))
                        if let career = user?.career {
                            Text(career)
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#5B86E5"))
                                .padding(.top, 1)
                        }
                        if let bio = user?.personal?.bio {
                            Text(bio)
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#828796"))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 50)
                                .padding(.top, 2)
                        }
                        if let website = user?.personal?.website {
                            Link(website, destination: URL(string: website)!)
                                .font(.system(size: 12))
                                .foregroundColor(Color.blue)
                                .padding(.top, 1)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.horizontal)
                    
                    if self.userId == UserDefaults.standard.string(forKey: "userId") {
                        HStack {
                            Text("?????????????????????????? ??????????????")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#2E313C"))
                                .padding(.vertical, 15)
                        }
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color(hex: "#F9F9F9"))
                                .modifier(RoundedEdge(width: 1, color: Color(hex: "#DDE8E8"), cornerRadius: 15))
                        )
                        .padding(.horizontal)
                        .padding(.top, 12)
                        .onTapGesture {
                            withAnimation {
                                editUserPresent.toggle()
                            }
                        }
                    }
                    else{
                        FollowUserControll(userId: userId)
                    }
                    
                    ActualStoryList(userId: userId)
                        .padding(.top)
                    
                    HStack(spacing: 0) {
                        Button(action: {
                            self.selectedTab = "media"
                        }) {
                            Rectangle()
                                .stroke(Color(hex: "#DDE8E8"), style: StrokeStyle(lineWidth: 1))
                                .overlay(
                                    Image(self.selectedTab == "media" ? "profile.media.post.tab.active" : "profile.media.post.tab.inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 22, height: 22)
                                )
                        }
                        Button(action: {
                            self.selectedTab = "text"
                        }) {
                            Rectangle()
                                .stroke(Color(hex: "#DDE8E8"), style: StrokeStyle(lineWidth: 1))
                                .overlay(
                                    Image(self.selectedTab == "text" ? "profile.text.post.tab.active" : "profile.text.post.tab.inactive")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 22, height: 22)
                                )
                        }
                    }
                    .frame(height: 55)
                    .padding(.bottom, 21)
                    .padding(.top)
                    
                    if self.selectedTab == "media" {
                        VStack{
                            if self.loadMdeiaPost {
                                PostCompositionView(posts: self.$mediaPost)
                                    .environmentObject(postViewModel)
                            }
                            else{
                                ProgressView()
                                    .padding(.bottom)
                            }
                            Spacer()
                        }
                        
                        if self.userId == UserDefaults.standard.string(forKey: "userId") {
                            Profile??ompletionView(editUserPresent: $editUserPresent)
                        }
                    }
                    
                    if self.selectedTab == "text" {
                        VStack(alignment: .leading){
                            if self.loadTextposts {
                                ForEach(0..<self.textPosts.count, id: \.self){index in
                                    PostView(post: self.$textPosts[index])
                                        .environmentObject(postViewModel)
                                }
                            }
                            else{
                                ProgressView()
                            }
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    Spacer(minLength: 400)
                    
                }
                .zIndex(-offset > 80 ? 0 : 1)
            }
        }
        .background(Color(hex: "#F9F9F9"))
        .overlay(
            
            HStack {
                if self.userId == UserDefaults.standard.string(forKey: "userId") {
                    Button(action: {
                        self.isPublicationSheet.toggle()
                    }, label: {
                        Image("profile.plus.white")
                    })
                        .bottomSheet(isPresented: $isPublicationSheet, detents: [.custom(350)]) {
                            AddPublicationSheet(
                                isPresentActualStoryView: $isPresentActualStoryView,
                                isPresentCreateTextPost: $isPresentCreateTextPost,
                                isPresentCreateMediaPost: $isPresentCreateMediaPost,
                                isPresentCreateStory: $isPresentCreateStory
                            )
                        }
                    Spacer(minLength: 0)
                    Button(action: {
                        self.isSettingsSheet.toggle()
                    }, label: {
                        Image("profile.menu.icon")
                    })
                        .bottomSheet(isPresented: $isSettingsSheet, detents: [.custom(440)], backgroundColor: .clear) {
                            SettingsSheet(
                                yourActivityPresent: self.$yourActivityPresent,
                                savedPresent: self.$savedPresent,
                                interestingPeoplePresent: self.$interestingPeoplePresent,
                                editUserPresent: self.$editUserPresent,
                                settingsPresent: self.$settingsPresent
                            )
                        }
                }
                else{
                    Button(action: {
                        if isPresented != nil{
                            isPresented = false
                        }
                        else if presentationMode != nil{
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image("big_arrow_left_white")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                    Spacer(minLength: 0)
                    Button(action: {
                        
                    }) {
                        Color.clear
                            .frame(width: 24, height: 24)
                            
                    }
                    .opacity(0)
                }
            }
            .padding()
                .padding(.top, edges?.top ?? 10)
            ,alignment: .top
        )
        .background(
            ZStack{
                NavigationLink(destination: YourActivityView()
                                .ignoreDefaultHeaderBar, isActive: self.$yourActivityPresent, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: SavedView()
                                .environmentObject(postViewModel)
                                .ignoreDefaultHeaderBar, isActive: self.$savedPresent, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: InterestingPeopleView()
                                .ignoreDefaultHeaderBar, isActive: self.$interestingPeoplePresent, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: ActualStoryView()
                                .ignoreDefaultHeaderBar, isActive: self.$isPresentActualStoryView, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: SettingsView()
                                .ignoreDefaultHeaderBar, isActive: self.$settingsPresent, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: PublicationTextPostView()
                                .ignoreDefaultHeaderBar, isActive: self.$isPresentCreateTextPost, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: PublicationMediaPostView()
                                .ignoreDefaultHeaderBar, isActive: self.$isPresentCreateMediaPost, label: {
                                    EmptyView()
                                })
                NavigationLink(destination: PublicationStoryView()
                                .ignoreDefaultHeaderBar, isActive: self.$isPresentCreateStory, label: {
                                    EmptyView()
                                })
                
            }
        )
        .ignoresSafeArea(.all, edges: .top)
        .fullScreenCover(isPresented: $editUserPresent, content: {
            EditUserProfile(user: $user, onUpdateProfile: {
                getProfile(completion: {
                    
                })
            })
        })
        .onAppear {
            getProfile(completion:{})
            postViewModel.getUserMediaPosts(userId: userId) { compositionPost in
                self.mediaPost = compositionPost
                self.loadMdeiaPost = true
            }
            postViewModel.getUserTextPosts(userId: userId) { posts in
                self.textPosts = posts
                self.loadTextposts = true
            }
        }
    }
    
    func getProfile (completion: @escaping()->Void) -> Void {
        
        let url = URL(string: "\(API_URL)\(API_USER)\(userId)")!
        
        guard let request = Request(url: url, httpMethod: "GET", body: nil) else {return}
        
        URLSession.shared.dataTask(with: request) {data, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            guard let data = data else {return}
            
            if response.statusCode == 200 {
                guard let json = try? JSONDecoder().decode(UserModel.User.self, from: data) else {return}
                DispatchQueue.main.async {
                    self.user = json
                    completion()
                }
            }
        }.resume()
    }
    
//    func checkFollowOnUser(userId: String, completion: @escaping (Bool?) -> Void) {
//        let url = URL(string: "\(API_URL)\(API_CHECK_FOLLOW_ON_USER)\(userId)")!
//        
//        if let request = Request(url: url, httpMethod: "GET", body: nil) {
//            URLSession.shared.dataTask(with: request){data, response, error in
//                if let _ = error {
//                    return
//                }
//
//                guard let response = response as? HTTPURLResponse else {return}
//
//                if response.statusCode == 200 {
//                    if let json = try? JSONDecoder().decode(ResponseResult.self, from: data!) {
//                        DispatchQueue.main.async {
//                            if json.result == true {
//                                completion(true)
//                            } else {
//                                completion(false)
//                            }
//                        }
//                    }
//                }
//            }.resume()
//        }
//    }
    
//    func followOnUser(userId: String, completion: @escaping () -> Void) -> Void {
//        let url = URL(string: "\(API_URL)\(API_FOLLOW_ON_USER)")!
//
//        let body: [String: String] = [
//            "userId": userId
//        ]
//
//        if let request = Request(url: url, httpMethod: "POST", body: body) {
//            URLSession.shared.dataTask(with: request){data, response, error in
//                if let _ = error {
//                    return
//                }
//
//                guard let response = response as? HTTPURLResponse else {return}
//
//                if response.statusCode == 200 {
//                    completion()
//                    print(response)
//                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
//                        print(json)
//                    }
//                } else {
//                    print(response)
//                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
//                        print(json)
//                    }
//                    return
//                }
//
//            }.resume()
//        }
//    }
//
//    func unFollowOnUser(userId: String, completion: @escaping () -> Void) -> Void {
//        let url = URL(string: "\(API_URL)\(API_FOLLOW_ON_USER)\(userId)")!
//
//
//        if let request = Request(url: url, httpMethod: "DELETE", body: nil) {
//            URLSession.shared.dataTask(with: request){data, response, error in
//                if let _ = error {
//                    return
//                }
//
//                guard let response = response as? HTTPURLResponse else {return}
//
//                if response.statusCode == 200 {
//                    completion()
//                    print(response)
//                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
//                        print(json)
//                    }
//                }
//            }.resume()
//        }
//    }
    
    func getOffset()->CGFloat{
        let progress = (-offset / 80) * 20
        
        return progress <= 20 ? progress : 20
    }
    
    func getScale()->CGFloat{
        let progress = -offset / 80
        
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        
        return scale < 1 ? scale : 1
    }
    
    func blurViewOpacity()->Double{
        let progress = -(offset + 80) / 150
        
        return Double(-offset > 80 ? progress : 0)
    }
}

private struct BlurView: UIViewRepresentable{
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemChromeMaterialDark))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

struct FollowUserControll: View {
    @StateObject var followViewModel: FollowViewModel = FollowViewModel()
    @State var load: Bool = false
    @State var followOnHim: Bool = false
    let userId: String

    init (userId: String) {
        self.userId = userId
    }

    var body: some View {
        HStack {
            Spacer()
            Button(action: {
                if !self.load {
                    self.handleFollow()
                }
            }) {
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color(hex: self.followOnHim ? "#36DCD8" : "#5B86E5"))
                    .frame(width: 151, height: 45, alignment: .center)
                    .overlay(
                        self.Loading(),
                        alignment: .center
                    )
            }
            Spacer(minLength: 10)
            Button(action: {}) {
                Capsule(style: .continuous)
                    .stroke(Color(hex: "#DDE8E8"), style: StrokeStyle(lineWidth: 1))
                    .frame(width: 151, height: 45, alignment: .center)
                    .overlay(
                        Text("????????????????")
                            .foregroundColor(Color(hex: "#2E313C")),
                        alignment: .center
                    )
            }
            Spacer()
        }
        .padding(.top, 14)
        .onAppear(perform: {
            followViewModel.checkFollowOnFollower(userId: userId, completion: {status in
                if let status = status {
                    if status {
                        self.followOnHim = true
                    } else {
                        self.followOnHim = false
                    }
                }
            })
        })
    }

    @ViewBuilder
    private func Loading() -> some View {
        if self.load {
            ProgressView()
        } else {
            Text(self.followOnHim ? "???? ??????????????????" : "??????????????????????")
                .foregroundColor(Color.white)
        }
    }

    private func handleFollow() {
        self.load = true
        if self.followOnHim {
            followViewModel.unFollowOnUser(userId: userId, completion: {_ in 
                DispatchQueue.main.async {
                    self.followOnHim = false
                    self.load = false
                }
            })
        } else {
            followViewModel.followOnUser(userId: userId, completion: {_ in 
                DispatchQueue.main.async {
                    self.followOnHim = true
                    self.load = false
                }
            })
        }
    }
}

private struct ActualStoryList: View{
    var userId: String
    var body: some View{
        VStack{
            if self.userId == UserDefaults.standard.string(forKey: "userId") {
                VStack(alignment: .leading){
                    Text("???????????????????? ???? ??????????????")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .fontWeight(.bold)
                    Text("???????????????????? ???????? ???????????? ?????????????? ?? ??????????????")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.trailing, 70)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 5)
                .padding(.horizontal)
            }
            
            ScrollView(.horizontal, showsIndicators: false){
                HStack(spacing: 20){
                    if self.userId == UserDefaults.standard.string(forKey: "userId") {
                        NavigationLink(destination: ActualStoryView()
                                        .ignoreDefaultHeaderBar){
                            VStack{
                                Circle()
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                    .frame(width: 60, height: 60)
                                    .overlay(
                                        Image(systemName: "plus")
                                            .foregroundColor(.black)
                                    )
                                Text("????????????????")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                            }
                        }
                        .buttonStyle(FlatLinkStyle())
                    }
                    ForEach(0..<5, id: \.self){_ in
                        if self.userId == UserDefaults.standard.string(forKey: "userId") {
                            NavigationLink(destination: ActualStoryView()
                                            .ignoreDefaultHeaderBar){
                                VStack{
                                    Circle()
                                        .fill(Color.gray.opacity(0.2))
                                        .frame(width: 60, height: 60)
                                    Text("")
                                        .font(.system(size: 12))
                                        .foregroundColor(.black)
                                }
                            }
                            .buttonStyle(FlatLinkStyle())
                        }
                        else{
                            VStack{
                                Circle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(width: 60, height: 60)
                                Text("")
                                    .font(.system(size: 12))
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

private struct AddPublicationSheet: View {
    @Environment(\.presentationMode) var presentation: Binding<PresentationMode>
    @Binding var isPresentActualStoryView: Bool
    @Binding var isPresentCreateTextPost: Bool
    @Binding var isPresentCreateMediaPost: Bool
    @Binding var isPresentCreateStory: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.white
            
            VStack {
                RoundedRectangle(cornerRadius: 40)
                    .fill(Color(hex: "#F2F2F2"))
                    .frame(width: 40, height: 4)
                    .padding(.top, 15)
                    .padding(.bottom, 24)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("????????????????")
                            .font(.custom(GothamBold, size: 20))
                            .foregroundColor(Color(hex: "#2E313C"))
                            .textCase(.uppercase)
                        Spacer(minLength: 0)
                        Button(action: {}) {
                            Image("rounded.rectangle.plus")
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 34)
                    Sepparator()
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                        self.isPresentCreateMediaPost.toggle()
                    }) {
                        AddPublicationItem(icon: "publication", title: "????????????????????")
                    }
                    Sepparator()
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                        self.isPresentCreateTextPost.toggle()
                    }) {
                        AddPublicationItem(icon: "post", title: "????????")
                    }
                    Sepparator()
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                        self.isPresentCreateStory.toggle()
                    }) {
                        AddPublicationItem(icon: "story", title: "??????????????")
                    }
                    Sepparator()
                    Button(action: {
                        presentation.wrappedValue.dismiss()
                        self.isPresentActualStoryView.toggle()
                    }) {
                        AddPublicationItem(icon: "actual.story", title: "???????????????????? ???? ??????????????")
                    }
                    Sepparator()
                }
            }
            .padding(.top, 20)
        }
        .cornerRadius(25)
        .ignoresSafeArea()
    }
}

private struct AddPublicationItem: View {
    var icon: String
    var title: String
    
    var body: some View {
        HStack(spacing: 0) {
            Image(icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 23, height: 23)
                .padding(.trailing, 14)
            Text(title)                     .font(.custom(GothamBook, size: 16))
                .textCase(.uppercase)
                .foregroundColor(.black)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 24)
    }
}

private struct Sepparator: View {
    let sepparatorGradient: LinearGradient = LinearGradient(colors: [Color(hex: "#C4C4C4").opacity(0), Color(hex: "#C4C4C4"), Color(hex: "#C4C4C4").opacity(0)], startPoint: .leading, endPoint: .trailing)
    
    var body: some View {
        Rectangle()
            .fill(sepparatorGradient)
            .frame(height: 1)
    }
}

private struct SettingsSheet: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var yourActivityPresent: Bool
    @Binding var savedPresent: Bool
    @Binding var interestingPeoplePresent: Bool
    @Binding var editUserPresent: Bool
    @Binding var settingsPresent: Bool
    
    let time: CGFloat = 0.2
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 40)
                .fill(Color(hex: "#F2F2F2"))
                .frame(width: 40, height: 4)
                .padding(.top, 15)
                .padding(.bottom, 24)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    yourActivityPresent.toggle()
                }
            }) {
                HStack {
                    Image("your.activity")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("???????? ????????????????????")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E313C"))
                    Spacer(minLength: 0)
                }
                .padding()
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    savedPresent.toggle()
                }
            }) {
                HStack {
                    Image("saves")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("??????????????????????")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E313C"))
                    Spacer(minLength: 0)
                }
                .padding()
            }
            Button(action: {}) {
                HStack {
                    Image("favorite")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("?????????????? ????????????")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E313C"))
                    Spacer(minLength: 0)
                }
                .padding()
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    interestingPeoplePresent.toggle()
                }
            }) {
                HStack {
                    Image("add.friend")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("???????????????????? ????????")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E313C"))
                    Spacer(minLength: 0)
                }
                .padding()
            }
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    withAnimation {
                        editUserPresent.toggle()
                    }
                }
            }) {
                HStack {
                    Image("edit.profile")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
                    Text("?????????????????????????? ??????????????")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                        .foregroundColor(Color(hex: "#2E313C"))
                    Spacer(minLength: 0)
                }
                .padding()
            }
            Spacer(minLength: 0)
            Button(action: {
                presentationMode.wrappedValue.dismiss()
                DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                    settingsPresent.toggle()
                }
            }) {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color(hex: "#F2F2F2"))
                        .frame(height: 1)
                    HStack {
                        Image("settings")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                        Text("??????????????????")
                            .font(.system(size: 14))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#2E313C"))
                        Spacer(minLength: 0)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 17)
                }
            }
        }
        .background(Color.white)
        .frame(width: screen_rect.width - 40)
        .cornerRadius(25)
    }
}

private struct Profile??ompletion: Identifiable {
    var id = UUID().uuidString
    var icon: String
    var title: String
    var subtitle: String
    var buttonText: String
}

private struct Profile??ompletionView: View{
    @Binding var editUserPresent: Bool
    let completions: [Profile??ompletion] = [
        Profile??ompletion(icon: "person.2", title: "?????????????? ?????????? ?????? ????????????????", subtitle: "?????????????????????? ???? 5 ?????? ?????????? ??????????????????.", buttonText: "?????????? ??????"),
        Profile??ompletion(icon: "person", title: "?????????????? ???????? ??????", subtitle: "???????????????? ?????? ?? ??????????????, ?????????? ???????????? ??????????, ?????? ?????? ????.", buttonText: "?????????????????????????? ??????"),
        Profile??ompletion(icon: "person.circle", title: "???????????????? ???????? ??????????????", subtitle: "???????????????? ???????? ?????? ???????????? ?????????????? Scrollo", buttonText: "???????????????? ????????"),
        Profile??ompletion(icon: "text.alignleft", title: "???????????????? ??????????????????", subtitle: "???????????????????? ?????????? ?????????????????????? ?????????????? ?? ????????.", buttonText: "?????????????????????????? ??????????????????"),
        
    ]
    
    @State var currentIndex: Int = 0
    
    var body: some View{
        VStack{
            VStack(alignment: .leading){
                Text("?????????????????? ??????????????")
                    .fontWeight(.bold)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .padding(.bottom, 1)
                (
                    Text("0 ???? 4").font(.system(size: 12)).foregroundColor(Color(hex: "#01da2d")) + Text(" ????????????").font(.system(size: 12)).foregroundColor(.gray)
                )
            }
            .padding(.horizontal)
            .padding(.top)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            SnapCarousel(spacing: 10, trailingSpace: 190, index: $currentIndex, items: completions) {completion in
                GeometryReader{proxy in
                    ??ompletionCard(completion: completion, proxy: proxy, editUserPresent: $editUserPresent)
                }
            }
            .padding(.top)
        }
    }
}

private struct ??ompletionCard: View{
    var completion: Profile??ompletion
    var proxy: GeometryProxy
    @Binding var editUserPresent: Bool
    var body: some View{
        VStack{
            Image(systemName: completion.icon)
                .font(.system(size: 30))
                .foregroundColor(Color(hex: "#6c6c6c"))
                .padding()
                .background(
                    Circle()
                        .stroke(Color(hex: "#6c6c6c"), lineWidth: 1)
                )
                .padding(.vertical)
            Text(completion.title)
                .font(.system(size: 14))
                .fontWeight(.bold)
                .foregroundColor(Color(hex: "#191919"))
                .frame(width: proxy.size.width/1.2)
                .padding(.bottom, 4)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Text(completion.subtitle)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "#a3a3a3"))
                .frame(width: proxy.size.width/1.2)
                .padding(.bottom)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
            Button(action: {
                withAnimation {
                    editUserPresent.toggle()
                }
            }){
                Text(completion.buttonText)
                    .font(.system(size: 12))
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 13)
                    .background(Color(hex: "#efefef").cornerRadius(5))
                    .padding(.bottom)
            }
            
            
        }
        .frame(width: proxy.size.width, height: 230)
        .background(Color(hex: "#F9F9F9").cornerRadius(10))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#ededed"))
        )
        
    }
}

struct PostCompositionView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var posts: [[[PostModel]]]
    
    var body: some View {
        VStack(alignment: .leading) {
            ForEach(0..<posts.count, id: \.self) {index in
                CompositionStack(stack: $posts[index])
                    .environmentObject(postViewModel)
            }
        }
        .padding(.horizontal, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
}

struct CompositionStack: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var stack: [[PostModel]]
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            
            if stack.count == 3{
                Spacer(minLength: 0)
            }
            
            ForEach(0..<stack.count, id: \.self) {index in
                CompositionColumn(posts: $stack[index], columnIndex: index)
                    .environmentObject(postViewModel)
               
            }
            if stack.count <= 3{
                Spacer(minLength: 0)
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct CompositionColumn: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var posts: [PostModel]
    var columnIndex: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(0..<posts.count, id: \.self) {index in
                UIPostCompositionView(post: $posts[index], index: index, columnIndex: columnIndex)
                    .environmentObject(postViewModel)
            }
        }
    }
}

struct UIPostCompositionView: View {
    @EnvironmentObject var postViewModel: PostViewModel
    @Binding var post: PostModel
    var index: Int
    var columnIndex: Int
    let size = (UIScreen.main.bounds.width / 3) - 16
    
    var body: some View {
        if post.files[0].type == "IMAGE" {
            if let path = post.files[0].filePath {
                NavigationLink(destination: PostOverview(post: $post)
                                .environmentObject(postViewModel)
                                .ignoreDefaultHeaderBar) {
                    WebImage(url: URL(string: "\(API_URL)/uploads/\(path)")!)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: self.getHeight())
                        .clipped()
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(6)
                }
                                .buttonStyle(FlatLinkStyle())
            }
        } else {
//            if let path = post.files[0].filePath {
//                NavigationLink(destination:
//                                PostDetailView(post: $post).ignoreDefaultHeaderBar
//                ) {
//                    VideoThumbnail(video: URL(string: "\(API_URL)/uploads/\(path)")!, width: size, height: self.getHeight())
//                }
//            }
        }
    }
    
    func getHeight () -> CGFloat {
        if columnIndex == 0 && index == 0 {
            return 121
        }
        if columnIndex == 0 && index == 1 {
            return 189
        }
        if columnIndex == 1 && index == 0 {
            return 189
        }
        if columnIndex == 1 && index == 1 {
            return 121
        }
        if columnIndex == 2 && index == 0 {
            return 121
        }
        if columnIndex == 2 && index == 1 {
            return 189
        }
        return 0
    }
}
