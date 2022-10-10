//
//  HomeView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 05.10.2022.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: String
    @State var upload: Bool = false
    @Binding var offset: CGFloat
    @Binding var isScrollEnabled: Bool
    
    @State var publicationTextPostViewPresent: Bool = false
    @State var publicationStoryViewPresent: Bool = false
    
    var body: some View {
        NavigationView{
            
            ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                VStack(spacing: 0){
                    GeometryReader{_ in
                        FeedView(offset: $offset)
                            .ignoresSafeArea(SafeAreaRegions.container, edges: .bottom)
                            .opacity(selectedTab == "home" ? 1 : 0)
                            .onAppear(perform: {
                                if selectedTab == "home" {
                                    isScrollEnabled = true
                                }
                            })
                            .onDisappear {
                                isScrollEnabled = false
                            }
                        SearchView()
                            .opacity(selectedTab == "search" ? 1 : 0)
                        ActionsView()
                            .opacity(selectedTab == "activities" ? 1 : 0)
                        ProfileView(userId: UserDefaults.standard.string(forKey: "userId")!)
                            .ignoresSafeArea(SafeAreaRegions.container, edges: .bottom)
                            .opacity(selectedTab == "profile" ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoreDefaultHeaderBar
                
                if self.upload {
                    BlurView(style: .light)
                        .opacity(0.8)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea(.all, edges: .all)
                        .onTapGesture {
                            withAnimation(.easeInOut) {
                                self.upload = false
                            }
                            isScrollEnabled = true
                        }
                }
                HStack(spacing: 0) {
                    TabbarButton(image: "home_inactive", image_active: "home_active", action: {
                        onPressTab(tab: "home")
                        isScrollEnabled = true
                    }, isActive: selectedTab == "home" && !self.upload)
                    Spacer(minLength: 0)
                    TabbarButton(image: "search_inactive", image_active: "search_active", action: {
                        onPressTab(tab: "search")
                        isScrollEnabled = false
                    }, isActive: selectedTab == "search" && !self.upload)
                    Spacer(minLength: 0)
                    TabbarButton(image: "plus_fill_inactive", image_active: "plus_fill_active", action: {
                        withAnimation(.easeInOut(duration: 0.2)){
                            self.upload.toggle()
                        }
                        isScrollEnabled = false
                    }, isActive: self.upload)
                    Spacer(minLength: 0)
                    TabbarButton(image: "alarm_inactive", image_active: "alarm_active", action: {
                        onPressTab(tab: "activities")
                        isScrollEnabled = false
                    }, isActive: selectedTab == "activities" && !self.upload)
                    Spacer(minLength: 0)
                    TabbarButton(image: "profile_inactive", image_active: "profile_active", action: {
                        onPressTab(tab: "profile")
                        isScrollEnabled = false
                    },isActive: selectedTab == "profile" && !self.upload)
                }
                .frame(height: 50)
                .padding(.horizontal, 30)
                .padding(.vertical)
                .background(Color.white.cornerRadius(12))
                .padding(.horizontal)
                .padding(.vertical)
                .padding(.bottom, edges?.bottom ?? 50)
                .overlay(
                    UploadView(
                        show: self.$upload,
                        publicationTextPostViewPresent: $publicationTextPostViewPresent,
                        publicationStoryViewPresent: $publicationStoryViewPresent
                    ),
                    alignment: Alignment(horizontal: .center, vertical: .top)
                )
                .background(
                    ZStack{
                        NavigationLink(destination: PublicationTextPostView()
                                        .ignoreDefaultHeaderBar, isActive: $publicationTextPostViewPresent){ EmptyView() }
                        NavigationLink(destination: PublicationStoryView()
                                        .ignoreDefaultHeaderBar, isActive: $publicationStoryViewPresent){ EmptyView() }
                    }
                )
            }
        }
        .edgesIgnoringSafeArea(.all)
        
    }
    
    func onPressTab (tab: String) {
        withAnimation(.easeInOut(duration: 0.2)){
            if self.upload {
                self.upload = false
            }
            self.selectedTab = tab
        }
    }
}

private struct TabbarButton: View {
    var image: String
    var image_active: String
    var action: () -> Void
    var isActive: Bool
    
    static let color0 = Color(red: 92/255, green: 249/255, blue: 192/255);
    static let color1 = Color(red: 50/255, green: 184/255, blue: 248/255);
    static let color2 = Color(red: 137/255, green: 93/255, blue: 242/255);
    let gradient = Gradient(colors: [Color(hex: "#5B86E5"), Color(hex: "#36DCD8")]);
    var body: some View {
        GeometryReader{proxy in
            Button(action: self.action) {
                VStack(spacing: 0) {
                    Image(isActive ? image_active : image)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                        .background(
                            ZStack {
                                if isActive {
                                    ZStack{}.frame(width: 50, height: 50)
                                        .background(LinearGradient(
                                            gradient: gradient,
                                            startPoint: .init(x: 1.00, y: 0.46),
                                            endPoint: .init(x: 0.00, y: 0.54)
                                          ))
                                        .clipShape(Circle())
                                        .shadow(radius: 20 )
                                }
                            }
                            .frame(width: 50, height: 50)
                        )
                        .offset(y: isActive ? -35 : 0)
                    if isActive {
                        Circle()
                            .fill(Color(hex: "#3EACF7"))
                            .frame(width: 10, height: 10)
                            .offset(y: -15)
                    }
                }.frame(width: 60)
            }
        }
        .frame(height: 30)
    }
}

private struct BlurView: UIViewRepresentable {

    let style: UIBlurEffect.Style

    func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = UIColor(Color(hex: "#D8D2E5").opacity(0.25))
        let blurEffect = UIBlurEffect(style: style)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(blurView, at: 0)
        NSLayoutConstraint.activate([
            blurView.heightAnchor.constraint(equalTo: view.heightAnchor),
            blurView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
        return view
    }

    func updateUIView(_ uiView: UIView,
                      context: UIViewRepresentableContext<BlurView>) {

    }
}

private struct UploadView : View {
    @Binding var show: Bool
    
    @Binding var publicationTextPostViewPresent: Bool
    @Binding var publicationStoryViewPresent: Bool
    
   
    var body : some View {
        if show {
            HStack {
                VStack {
                    Text("загрузить")
                        .foregroundColor(Color(hex: "#333333"))
                        .textCase(.uppercase)
                        .padding(.top, 15)
                    Spacer(minLength: 0)
                    HStack(spacing: 18) {
                        UploadButtonView(icon: "gallery_icon", title: "Фото")
                        UploadButtonView(icon: "message_icon", title: "Пост")
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    show = false
                                }
                                publicationTextPostViewPresent = true
                            }
                        UploadButtonView(icon: "video_icon", title: "История")
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)){
                                    show = false
                                }
                                publicationStoryViewPresent = true
                            }
                    }
                    .padding(.bottom, 34)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 70, height: 164, alignment: .center)
            .background(Color.white)
            .cornerRadius(27.0)
            .overlay(
                Triangle()
                    .fill(Color.white)
                    .frame(width: 22, height: 15, alignment: .center)
                    .rotationEffect(.init(degrees: 180))
                    .offset(y: 15),
                alignment: Alignment(horizontal: .center, vertical: .bottom)
            )
            .offset(y: -194)
        } else {
            Color.clear
        }
    }
}

private struct UploadButtonView : View {
    private let icon : String
    private let title : String
    
    public init (icon: String, title: String) {
        self.icon = icon
        self.title = title
    }
    
    var body: some View {
        ZStack {
            VStack {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 25, height: 25)
                    .shadow(color: .black, radius: 20, x: 0.0, y: 15.0)
                Text(title)
                    .foregroundColor(Color(hex: "#4F4F4F"))
                    .font(.system(size: 12))
                    .textCase(.uppercase)
            }
            .padding()
            .frame(maxWidth: ((UIScreen.main.bounds.width - 90) / 3) - 20)
        }
        .background(Color(hex: "#F3F3F3"))
        .cornerRadius(14)
        .frame(maxWidth: ((UIScreen.main.bounds.width - 90) / 3) - 20, maxHeight: 164 / 2)
    }
}

private struct Triangle: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    path.move(to: CGPoint(x: rect.midX, y: rect.minY))
    path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
    path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
    
    path.closeSubpath()
    
    return path
  }
}
