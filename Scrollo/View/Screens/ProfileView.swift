//
//  ProfileView.swift
//  Scrollo
//
//  Created by Artem Strelnik on 07.10.2022.
//

import SwiftUI

struct ProfileView: View {
    
    @State var offset: CGFloat = 0
    
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
                            
                            Image("story1")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: getRect().width, height: minY > 0 ? 180 + minY :  180, alignment: .center)
                                .cornerRadius(0)
                            
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
                    HStack(spacing: 0){
                        VStack {
                            Text("120")
                                .font(.system(size: 21))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#1F2128"))
                            Text("подписчики")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#828796"))
                        }
                        Spacer()
                        Image("testUserPhoto")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75)
                            .clipShape(RoundedRectangle(cornerRadius: 25))
                            .offset(y: offset < 0 ? getOffset() - 20 : -20)
                            .scaleEffect(getScale())
                        Spacer()
                        VStack {
                            Text("300")
                                .font(.system(size: 21))
                                .fontWeight(.bold)
                                .foregroundColor(Color(hex: "#1F2128"))
                            Text("подписки")
                                .font(.system(size: 11))
                                .foregroundColor(Color(hex: "#828796"))
                        }
                    }
                    .padding(.top, -25)
                    
                }
                .padding(.horizontal)
                .zIndex(-offset > 80 ? 0 : 1)
            }
        }
        .ignoresSafeArea(.all, edges: .top)
    }
    
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
