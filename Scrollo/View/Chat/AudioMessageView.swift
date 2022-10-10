//
//  AudioMessageView.swift
//  scrollo
//
//  Created by Artem Strelnik on 15.09.2022.
//

import SwiftUI
import DSWaveformImage
import AVFoundation

struct AudioMessageView: View {
    @EnvironmentObject var player: AudioPlayer
    
    @Binding var message: MessageModel
    
    @State var configuration: Waveform.Configuration = Waveform.Configuration(
        style: .striped(.init(color: UIColor(Color(hex: "#080808")), width: 3, spacing: 3)),
        position: .middle
    )
    
    @State private var playValue: TimeInterval = 0.0
    @State private var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    @State var audioURL: URL?
    
    var body: some View {
        HStack(alignment: .top, spacing: 10){
            if message.type == "STARTER" {
                Spacer(minLength: 25)
                if audioURL != nil {
                    HStack(spacing: 2.0) {
                        if player.isPlaying && player.id == message.id {
                            Button(action: {
                                player.stopPlayback()
                            }){
                                Image(systemName: "pause.circle")
                                    .font(.system(size: 23))
                                    .foregroundColor(Color(hex: "#5B86E5"))
                                    .frame(width: 23, height: 23)
                                    .padding(.trailing, 8)
                            }
                        } else {
                            Button(action: {
                                player.id = message.id
                                player.startPlayback(audio: audioURL!)
                                self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                            }){
                                Image(systemName: "play.circle")
                                    .font(.system(size: 23))
                                    .foregroundColor(Color(hex: "#5B86E5"))
                                    .frame(width: 23, height: 23)
                                    .padding(.trailing, 8)
                            }
                        }
                        
                        
                        Rectangle()
                            .fill(player.isPlaying && player.id == message.id ? Color(hex: "#5B86E5").opacity(0.5) : Color(hex: "#5B86E5"))
                            .overlay(Color(hex: "#5B86E5").frame(width: player.isPlaying && player.id == message.id ? getCurrentWidth() : 0),alignment: .leading)
                            .mask(WaveformViewTest(audioURL: $audioURL, configuration: $configuration))
                        
                        
                        
                        Text(player.isPlaying && player.id == message.id ? "\(Self.timeFormatter.string(from: playValue) ?? "00:00")" : "\(Self.timeFormatter.string(from: getDuration()) ?? "00:00")")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#5B86E5"))
                            .frame(width: 40)
                            .padding(.leading, 8)
                            .onReceive(timer) { _ in
                                    if player.isPlaying && player.id == message.id {
                                        if let currentTime = player.audioPlayer?.currentTime {
                                            self.playValue = currentTime
                                        }
                                    }
                                    else {
                                        self.timer.upstream.connect().cancel()
                                    }
                                }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(Color(hex: "#5B86E5").opacity(0.15))
                    .clipShape(CustomCorner(radius: 10, corners: [.topLeft, .bottomLeft, .bottomRight]))
                }
            }
            else {
                Image("testUserPhoto")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .cornerRadius(8)
                    .clipped()
                if audioURL == nil {
                    MessageActivityIndicatorView(color: Color(hex: "#efefef"), size: 40)
                }
                else {
                    HStack(spacing: 2.0) {
                        if player.isPlaying && player.id == message.id {
                            Button(action: {
                                player.stopPlayback()
                            }){
                                Image(systemName: "pause.circle")
                                    .font(.system(size: 23))
                                    .foregroundColor(Color(hex: "#080808"))
                                    .frame(width: 23, height: 23)
                                    .padding(.trailing, 8)
                            }
                        } else {
                            Button(action: {
                                player.id = message.id
                                player.startPlayback(audio: audioURL!)
                                self.timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
                            }){
                                Image(systemName: "play.circle")
                                    .font(.system(size: 23))
                                    .foregroundColor(Color(hex: "#080808"))
                                    .frame(width: 23, height: 23)
                                    .padding(.trailing, 8)
                            }
                        }
                        
                        
                        Rectangle()
                            .fill(player.isPlaying && player.id == message.id ? Color(hex: "#a8a8a8") : Color(hex: "#080808"))
                            .overlay(Color(hex: "#080808").frame(width: player.isPlaying && player.id == message.id ? getCurrentWidth() : 0),alignment: .leading)
                            .mask(WaveformViewTest(audioURL: $audioURL, configuration: $configuration))
                        
                        
                        
                        Text(player.isPlaying && player.id == message.id ? "\(Self.timeFormatter.string(from: playValue) ?? "00:00")" : "\(Self.timeFormatter.string(from: getDuration()) ?? "00:00")")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#2E313C"))
                            .frame(width: 40)
                            .padding(.leading, 8)
                            .onReceive(timer) { _ in
                                    if player.isPlaying && player.id == message.id {
                                        if let currentTime = player.audioPlayer?.currentTime {
                                            self.playValue = currentTime
                                        }
                                    }
                                    else {
                                        self.timer.upstream.connect().cancel()
                                    }
                                }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(Color(hex: "#F2F2F2"))
                    .clipShape(CustomCorner(radius: 10, corners: [.topRight, .bottomLeft, .bottomRight]))
                }
                Spacer(minLength: 25)
            }
        }
        .padding(.vertical)
        .id(message.id)
        .onAppear{
            if message.type == "STARTER" {
                withAnimation(.easeInOut) {
                    self.audioURL = message.audio!
                }
            }
            else {
                downloadFile(withUrl: message.audio!) { filePath in
                    withAnimation(.easeInOut) {
                        self.audioURL = filePath
                    }
                }
            }
        }
    }
    
    func downloadFile(withUrl url: URL, completion: @escaping ((_ filePath: URL)->Void)){
        let filename = UUID().uuidString + ".mp3"
        let documentDirectory = FileManager.default.urls(for: .documentDirectory,
                                                    in: .userDomainMask)[0]
        let audioName = documentDirectory.appendingPathComponent(filename)
        
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: url)
                try data.write(to: audioName, options: .atomic)
                print("saved at \(audioName.absoluteString)")
                DispatchQueue.main.async {
                    completion(audioName)
                }
            } catch {
                print("an error happened while downloading or saving the file")
            }
        }
    }
    
    func getCurrentWidth() -> CGFloat {
        let pDuration = (player.audioPlayer!.currentTime*100)/self.getDuration()
        
        let progress = (200*pDuration)/100

        return progress
    }
    
    func getDuration()-> Double {
        let asset = AVURLAsset(url: self.audioURL!)
        return Double(asset.duration.value) / Double(asset.duration.timescale)
    }
}


