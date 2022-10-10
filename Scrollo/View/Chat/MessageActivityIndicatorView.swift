//
//  MessageActivityIndicatorView.swift
//  scrollo
//
//  Created by Artem Strelnik on 15.09.2022.
//

import SwiftUI
import Combine

struct MessageActivityIndicatorView: View{
    
    let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    let timing: Double
        
    let maxCounter = 3
    @State var counter = 0
        
    let frame: CGSize
    let primaryColor: Color

    init(color: Color = .black, size: CGFloat = 50, speed: Double = 0.5) {
        timing = speed / 2
        timer = Timer.publish(every: timing, on: .main, in: .common).autoconnect()
        frame = CGSize(width: size, height: size)
        primaryColor = color
    }

    var body: some View {
        HStack(spacing: 5) {
            ForEach(0..<maxCounter) { index in
                Circle()
                    .offset(y: counter == index ? -frame.height / 10 : frame.height / 10)
                    .fill(primaryColor)
                }
        }
        .frame(width: frame.width, height: frame.height, alignment: .center)
        .onReceive(timer, perform: { _ in
            withAnimation(.easeInOut(duration: timing * 2)) {
                counter = counter == (maxCounter - 1) ? 0 : counter + 1
            }
        })
    }
}
