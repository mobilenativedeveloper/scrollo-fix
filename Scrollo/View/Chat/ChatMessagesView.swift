//
//  ChatMessagesView.swift
//  scrollo
//
//  Created by Artem Strelnik on 14.09.2022.
//

import SwiftUI
import AVFoundation
import AVKit
import Photos
import SDWebImageSwiftUI

struct ChatMessagesView: View {
    @StateObject var messageViewModel: MessageViewModel = MessageViewModel()
    @ObservedObject var player: AudioPlayer = AudioPlayer()
    
    @State var isPresentSelectAttachments: Bool = false
    
    //Voice recorder
    @State var isRequestPermission: Bool = false
    @State var isVoiceRecord: Bool = false
    
    // Photo viewer
    @Namespace var animation
    @State var isExpanded: Bool = false
    @State var expandedMedia: MessageModel?
    @State var loadExpandedContent: Bool = false
    @State var offset: CGSize = .zero
    
    //Video viewer
    @State var showVideo: Bool = false
    @State var selectedVideo: MessageModel?
    
    var user: ChatListModel.ChatModel.ChatUser
    
    @State var profilePresent: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            
            HeaderBar(user: user, profilePresent: $profilePresent)
            
            ScrollView(showsIndicators: false) {
                ScrollViewReader{scrollReader in
                    VStack(spacing: 16) {
                        DetailUserView(user: user, profilePresent: $profilePresent)
                            .padding(.bottom, messageViewModel.messages.count == 0 ? 300 : 0)
                        Spacer()
                        .frame(minWidth: 0, maxWidth: .infinity, minHeight:0, maxHeight: .infinity, alignment: Alignment.topLeading)
                        ForEach(0..<messageViewModel.messages.count, id: \.self){index in
                            if messageViewModel.messages[index].content != nil {
                                TextMessageView(message: $messageViewModel.messages[index])
                            }
                            else if messageViewModel.messages[index].audio != nil {
                                AudioMessageView(message: $messageViewModel.messages[index])
                                    .environmentObject(player)
                            }
                            else if messageViewModel.messages[index].image != nil || messageViewModel.messages[index].asset?.asset.mediaType == .image {
                                ImageMessageView(message: $messageViewModel.messages[index], animation: animation, isExpanded: $isExpanded, expandedMedia: $expandedMedia)
                            }
                            else if messageViewModel.messages[index].video != nil || messageViewModel.messages[index].asset?.asset.mediaType == .video {
                                VideoMessageView(message: $messageViewModel.messages[index], showVideo: $showVideo, selectedVideo: $selectedVideo)
                            }
                        }
                        .onChange(of: messageViewModel.messages) { (value) in
                            scrollReader.scrollTo(value.last?.id)
                        }
                    }
                    .padding()
                    .rotationEffect(Angle(degrees: 180))
                }
            }
            .rotationEffect(Angle(degrees: 180))
            
            Spacer(minLength: 0)
            
            VStack(spacing: 0) {
                
                HStack(spacing: 0) {
                    
                    TextField("Написать сообщение...", text: $messageViewModel.message)
                    
                    Button(action: {
                        permission()
                    }) {
                        Image("microphone")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 8)
                    
                    Button(action: {
                        UIApplication.shared.endEditing()
                        isPresentSelectAttachments.toggle()
                    }) {
                        Image("image")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 8)
                    

                    Button(action: {
                        if !messageViewModel.message.isEmpty{
                            withAnimation(.easeInOut){
                                messageViewModel.sendMessage(message: MessageModel(type: "STARTER", content: messageViewModel.message))
                                
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                withAnimation(.easeInOut){
                                    messageViewModel.sendMessage(message: MessageModel(type: "RECIVER", content: "MatreshkaVPN безотказный и простой в использовании анонимайзер позволяющий вам посещать любые сайты и приложения, на которые наложены ограничения провайдером, оставаясь полностью анонимным. Matreshka не просто подменяет локацию вашего устройства, но и передает все ваши запросы в зашифрованном виде, переводя устройство в режим “невидимки”. Высокая скорость соединения, неограниченный трафик и различное расположение сервером обеспечат вам комфортное использование любых сайтов и приложений. MatreshkaVPN не мешает работе остальных приложений и не снижает скорость вашего интернета."))
                                
                                    messageViewModel.sendMessage(message: MessageModel(type: "RECIVER", audio: URL(string: "https://zvukogram.com/index.php?r=site/download&id=43127")))
                                    
                                    messageViewModel.sendMessage(message: MessageModel(type: "RECIVER", audio: URL(string: "https://zvukogram.com/index.php?r=site/download&id=43101")))
                                    
                                    messageViewModel.sendMessage(message: MessageModel(type: "RECIVER", audio: URL(string: "https://zvukogram.com/index.php?r=site/download&id=43103")))
                                    
                                    messageViewModel.sendMessage(message: MessageModel(type: "RECIVER", audio: URL(string: "https://zvukogram.com/index.php?r=site/download&id=78804")))
                                    
                                    messageViewModel.sendMessage(message: MessageModel(type: "RECIVER", image: "story1"))
                                
                                }
                            }
                            messageViewModel.message = String()
                        }
                    }) {
                        Image("send")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                }
                .padding(.horizontal)
                .frame(height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(hex: "#DDE8E8"), lineWidth: 1)
                )
                // MARK: This bug when opened screen muted sound
                .overlay{
                    if isVoiceRecord{
                        VoiceRecorderView(isVoiceRecord: $isVoiceRecord, onSendAudio: {audio in
                            messageViewModel.sendMessage(message: MessageModel(type: "STARTER", audio: audio))
                            isVoiceRecord.toggle()
                        })
                    }
                }
            }
            .padding()
            .background(Color.white)
            .overlay(
                Color(hex: "#F2F2F2")
                    .frame(height: 1)
                ,alignment: .top
            )
            .shadow(color: Color(hex: "#1e5385").opacity(0.03), radius: 10, x: 0, y: -12)
        }
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .overlay{
            if isPresentSelectAttachments{
                SelectAttachmentsView(isPresent: $isPresentSelectAttachments, sendMedia: { media in
                    media.forEach { asset in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation(.easeInOut){
                                messageViewModel.sendMessage(message: MessageModel(type: "STARTER", asset: asset))
                            }
                        }
                    }
                })
            }
        }
        .overlay(content: {
            Rectangle()
                .fill(.black)
                .opacity(loadExpandedContent ? 1 : 0)
                .opacity(offsetProgress())
                .ignoresSafeArea()
        })
        .overlay(ImageOverviewView(loadExpandedContent: $loadExpandedContent, isExpanded: $isExpanded, expandedMedia: $expandedMedia, animation: animation, offset: $offset, offsetProgress: offsetProgress())
        )
        .overlay{
            if let video = selectedVideo, showVideo {
                VideoViewer(showVideo: $showVideo, video: $selectedVideo)
            }
        }
        .navigationView(isPresent: $profilePresent, content: {
            ProfileView(userId: user.id)
        })
        .alert(isPresented: $isRequestPermission){
            Alert(title: Text("Разрешить доступ к микрофону"), message: Text("Чтобы отправлять голосовые сообщения, предоставьте этому приложению доступ к микрофону в настройках устройства"), primaryButton: .default(Text("Отмена")), secondaryButton: .default(Text("Настройки")){
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            })
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
    }
    
    func offsetProgress()->CGFloat{
        let progress = offset.height / 100
        if progress < 1{
            return 1
        } else {
            return 1 - (progress < 1 ? progress : 1)
        }
    }
    
    func permission(){
        switch AVAudioSession.sharedInstance().recordPermission {
            case .granted:
                withAnimation(.easeInOut(duration: 0.2)){
                    isVoiceRecord.toggle()
                }
            case .denied:
                isRequestPermission.toggle()
            case .undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ granted in
                    if (granted){
                        withAnimation(.easeInOut(duration: 0.2)){
                            isVoiceRecord.toggle()
                        }
                    } else {
                        isRequestPermission.toggle()
                    }
                })
            @unknown default:
                print("Unknown case")
            }
    }
}

private struct HeaderBar: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isPresentChatSettings: Bool = false
    var user: ChatListModel.ChatModel.ChatUser
    @Binding var profilePresent: Bool
    
    var body: some View{
        HStack {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("circle.left.arrow.black")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
            .padding(.trailing, 10)
            
            HStack(spacing: 8) {
                Button(action: {
                    withAnimation{
                        profilePresent = true
                    }
                }){
                    if let avatar = user.avatar {
                        WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)"))
                            .resizable()
                            .scaledToFill()
                            .frame(width: 32, height: 32)
                            .cornerRadius(8)
                            .padding(.trailing, 5)
                    } else {
                        DefaultAvatar(width: 32, height: 32, cornerRadius: 8)
                            .padding(.trailing, 5)
                    }
                }
                .buttonStyle(FlatLinkStyle())
                Button(action: {
                    isPresentChatSettings.toggle()
                }){
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Max Jacobson")
                            .font(.custom(GothamBold, size: 14))
                            .foregroundColor(Color(hex: "#444A5E"))
                        Text("jacobs_max")
                            .font(.custom(GothamBook, size: 12))
                            .foregroundColor(Color(hex: "#828796"))
                    }
                }
                .overlay(
                    NavigationLink(destination: ChatSettingsView().ignoreDefaultHeaderBar, isActive: $isPresentChatSettings, label: {
                        EmptyView()
                    })
                )
                
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct PlayerView: UIViewControllerRepresentable {
    
    var player: AVPlayer
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let view = AVPlayerViewController()
        view.player = player
        view.showsPlaybackControls = false
        view.videoGravity = .resizeAspectFill
        return view
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}

struct VideoViewer: View{
    @Binding var showVideo: Bool
    @Binding var video: MessageModel?
    
    @State var player: AVPlayer?
    @State var isPlayed: Bool = false
    @State var isHowing: Bool = false
    @State var isHowingContent: Bool = false
    @State var offset: CGSize = .zero
    
    @State var showHeader: Bool = false
    
    @State var hidePlayIcon: Bool = false
    
    var body: some View{
        ZStack{
            if let player = self.player, isHowing{
                ZStack{
                    Rectangle()
                        .fill(.black)
                        .opacity(isHowingContent ? 1 : 0)
                        .opacity(offsetProgress())
                        .ignoresSafeArea()
                    PlayerView(player: player)
                        .frame(width: UIScreen.main.bounds.width , height: UIScreen.main.bounds.height)
                        .offset(y: offset.height)
                        .onTapGesture(perform: {
                            if self.showHeader{
                                withAnimation(.easeInOut(duration: 0.3)){
                                    self.showHeader = false
                                }
                            }else{
                                withAnimation(.easeInOut(duration: 0.3)){
                                    self.showHeader = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        self.showHeader = false
                                    }
                                }
                            }
                            if self.isPlayed{
                                withAnimation(.easeInOut(duration: 0.3)){
                                    self.player?.pause()
                                    self.isPlayed = false
                                }
                            }
                            else{
                                withAnimation(.easeInOut(duration: 0.3)){
                                    self.player?.play()
                                    self.isPlayed = true
                                }
                            }
                        })
                        .gesture(
                            DragGesture()
                                .onChanged({ value in
                                    withAnimation(.easeInOut(duration: 0.3)){
                                        offset = value.translation
                                        
                                        self.hidePlayIcon = true
                                    }
                                })
                                .onEnded({ value in
                                    let height = value.translation.height
                                    if height > 0 && height > 100{
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            isHowingContent = false
                                        }
                                        withAnimation(.easeInOut(duration: 0.3).delay(0.05)){
                                            self.isHowing = false
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                            offset = .zero
                                            self.player?.pause()
                                            showVideo = false
                                            video = nil
                                        }
                                    }
                                    else{
                                        withAnimation(.easeInOut(duration: 0.3)){
                                            offset = .zero
                                            self.hidePlayIcon = false
                                        }
                                    }
                                })
                        )
                    
                    if !self.isPlayed{
                        Image(systemName: "play.fill")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                            .opacity(hidePlayIcon ? 0 : 0.6)
                            .opacity(offsetProgress())
                            .transition(.scale)
                    }
                }
                .edgesIgnoringSafeArea(.all)
                .transition(.move(edge: .bottom))
            }
            
        }
        .overlay(alignment: .top, content:{
            if self.showHeader{
                HStack(spacing: 10){
                    Spacer(minLength: 10)
                    
                    Button(action: {
                        
                    }){
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)){
                            self.isHowingContent = false
                        }
                        withAnimation(.easeInOut(duration: 0.3).delay(0.05)){
                            self.isHowing = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                offset = .zero
                                self.player?.pause()
                                showVideo = false
                                video = nil
                            }
                        }
                    }){
                        Image(systemName: "xmark")
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 10)
                }
                .padding()
                .padding(.top, 20)
                .background(Color.black.opacity(0.6))
                .transition(.move(edge: .top))
                .opacity(self.isHowingContent ? 1 : 0)
                .opacity(offsetProgress())
            }
        })
        .onAppear {
            initVideo(video: self.video!.asset!.asset) { av in
                withAnimation(.easeInOut(duration: 0.3)){
                    self.player = av
                    self.player?.play()
                    self.isPlayed = true
                    self.isHowing = true
                    withAnimation(.easeInOut(duration: 0.3).delay(0.3)){
                        self.isHowingContent = true
                    }
                }
            }
        }
    }
    
    func initVideo(video: PHAsset, completion: @escaping(AVPlayer?)->Void) {
        PHImageManager().requestAVAsset(forVideo: video, options: nil) { asset, _, _ in
            let avAsset = asset as! AVURLAsset
            completion(AVPlayer(url: avAsset.url))
        }
    }
    
    func offsetProgress()->CGFloat{
        let progress = offset.height / 100
        if progress < 1{
            return 1
        } else {
            return 1 - (progress < 1 ? progress : 1)
        }
    }
        
}
