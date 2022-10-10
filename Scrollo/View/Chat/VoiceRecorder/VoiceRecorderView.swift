//
//  VoiceRecordView.swift
//  scrollo
//
//  Created by Artem Strelnik on 15.09.2022.
//

import SwiftUI

struct VoiceRecorderView: View {
    @Binding var isVoiceRecord: Bool
    var onSendAudio: (URL)->Void
    @StateObject var audioRecorder: AudioRecorderViewModel = AudioRecorderViewModel()
    
    @State private var isRecordAnimating: Bool = false
    var animationDuration: Double = 1
    
    static let timeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
    
    var body: some View{
        if isVoiceRecord{
            HStack{
                Button(action: {
                    withAnimation(.easeInOut){
                        audioRecorder.isRecording.toggle()
                        isVoiceRecord.toggle()
                    }
                }) {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                }
                .padding(.leading)
                Spacer()
                
                AudioVisualizationView()
                    .frame(height: 20)
                    .environmentObject(audioRecorder)
                    .onChange(of: audioRecorder.audio) { newValue in
                        if let audio = newValue {
                            onSendAudio(audio)
                        }
                    }
                
                Spacer()
                Circle()
                    .fill(Color.red)
                    .frame(width: 10, height: 10, alignment: .center)
                    .scaleEffect(self.isRecordAnimating ? 1 : 0.6)
                    .animation(Animation.easeInOut(duration: animationDuration).repeatForever(autoreverses: true),
                                   value: self.isRecordAnimating)
                
                Text("\(Self.timeFormatter.string(from: audioRecorder.recordingTime) ?? "00:00")")
                    .foregroundColor(.white)
                Button(action: {
                    audioRecorder.isRecording.toggle()
                }) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 22))
                        .foregroundColor(.white)
                        .frame(width: 20, height: 20)
                }
                .padding(.trailing)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(gradient: Gradient(colors: [
                    Color(hex: "#36DCD8"),
                    Color(hex: "#5B86E5")
                ]), startPoint: .leading, endPoint: .trailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .clipped()
            .onAppear{
                self.isRecordAnimating.toggle()
                audioRecorder.isRecording.toggle()
            }
        }
    }
}
