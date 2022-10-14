//
//  TestView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 13.10.2022.
//

import SwiftUI

struct TestView: View {
    @State var currentOffset: CGFloat = 0
    @State var prevOffste: CGFloat = 0
    var body: some View {
        ZStack{
            VStack{
                VStack{
                    ScrollView{
                        Text("ScrollView")
                    }
                }
                .frame( maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.green)
            }
            .frame(width: getRect().width)
            .background(Color.red)
            .ignoresSafeArea()
            VStack{
                Color.blue
            }
            .frame(width: getRect().width)
            .offset(x: getRect().width)
            .ignoresSafeArea()
        }
        .frame(width: getRect().width * 2)
        .offset(x: self.currentOffset)
        .ignoresSafeArea()
        .simultaneousGesture(
            DragGesture()
                .onChanged({ value in
                    let offsetX = value.translation.width + self.prevOffste
                    
                    if offsetX < 0 && offsetX > -(getRect().width){
                        self.currentOffset = offsetX
                    }
                    
                })
                .onEnded({ value in
                    let offsetX = value.translation.width + self.prevOffste
                    
                    if offsetX < -(getRect().width/2){
                        withAnimation {
                            self.currentOffset = -getRect().width
                        }
                        self.prevOffste = -getRect().width
                    }
                    else{
                        withAnimation {
                            self.currentOffset = 0
                        }
                        self.prevOffste = 0
                    }
//                    else if offsetX < getRect().width{
//                        withAnimation {
//                            self.currentOffset = 0
//                        }
//                    }
                    
                    
                })
        )
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
