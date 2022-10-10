//
//  ConfidentialityView.swift
//  scrollo
//
//  Created by Artem Strelnik on 08.07.2022.
//

import SwiftUI

struct ConfidentialityView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var confidentiality: ConfidentialityViewModel = ConfidentialityViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image("comments_back")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 24, height: 24)
                }
                Spacer(minLength: 0)
                Text("Конфиденциальность")
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
            .padding(.top)
            .padding(.horizontal)
            .padding(.bottom, 30)
            if confidentiality.load {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Могут оставить комментарии")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding(.bottom, 15)
                        VStack {
                            CustomToggle(label: "Все", tag: "ALL", selection: confidentiality.confidentiality.writeComments, action: {
                                confidentiality.confidentiality.writeComments = "ALL"
                                confidentiality.changeConfidentiality(body: [
                                    "writeComments": "ALL"
                                ])
                            })
                            CustomToggle(label: "Ваши подписчики", tag: "FOLLOWERS", selection: confidentiality.confidentiality.writeComments, action: {
                                confidentiality.confidentiality.writeComments = "FOLLOWERS"
                                confidentiality.changeConfidentiality(body: [
                                    "writeComments": "FOLLOWERS"
                                ])
                            })
                            CustomToggle(label: "Ваши подписки", tag: "FOLLOWINGS", selection: confidentiality.confidentiality.writeComments, action: {
                                confidentiality.confidentiality.writeComments = "FOLLOWINGS"
                                confidentiality.changeConfidentiality(body: [
                                    "writeComments": "FOLLOWINGS"
                                ])
                            })
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Могут вас отмечать")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding(.bottom, 15)
                        VStack {
                            CustomToggle(label: "Все", tag: "ALL", selection: confidentiality.confidentiality.mark, action: {
                                confidentiality.confidentiality.mark = "ALL"
                                confidentiality.changeConfidentiality(body: [
                                    "mark": "ALL"
                                ])
                            })
                            CustomToggle(label: "Ваши подписчики", tag: "FOLLOWERS", selection: confidentiality.confidentiality.mark, action: {
                                confidentiality.confidentiality.mark = "FOLLOWERS"
                                confidentiality.changeConfidentiality(body: [
                                    "mark": "FOLLOWERS"
                                ])
                            })
                            CustomToggle(label: "Ваши подписки", tag: "FOLLOWINGS", selection: confidentiality.confidentiality.mark, action: {
                                confidentiality.confidentiality.mark = "FOLLOWINGS"
                                confidentiality.changeConfidentiality(body: [
                                    "mark": "FOLLOWINGS"
                                ])
                            })
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Могут написать вам сообщение")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(Color.black)
                            .padding(.bottom, 15)
                        VStack {
                            CustomToggle(label: "Все", tag: "ALL", selection: confidentiality.confidentiality.writeMessage, action: {
                                confidentiality.confidentiality.writeMessage = "ALL"
                                confidentiality.changeConfidentiality(body: [
                                    "writeMessage": "ALL"
                                ])
                            })
                            CustomToggle(label: "Ваши подписчики", tag: "FOLLOWERS", selection: confidentiality.confidentiality.writeMessage, action: {
                                confidentiality.confidentiality.writeMessage = "FOLLOWERS"
                                confidentiality.changeConfidentiality(body: [
                                    "writeMessage": "FOLLOWERS"
                                ])
                            })
                            CustomToggle(label: "Ваши подписки", tag: "FOLLOWINGS", selection: confidentiality.confidentiality.writeMessage, action: {
                                confidentiality.confidentiality.writeMessage = "FOLLOWINGS"
                                confidentiality.changeConfidentiality(body: [
                                    "writeMessage": "FOLLOWERS"
                                ])
                            })
                        }
                        .padding(.horizontal)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 15)
                }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .background(Color(hex: "#F9F9F9"))
    }
    
    @ViewBuilder
    func CustomToggle (label: String, tag: String, selection: String, action: @escaping () -> Void) -> some View {
        Button(action: {
            action()
        }) {
            HStack {
                Text("\(label)")
                    .font(.system(size: 12))
                    .fontWeight(Font.Weight.semibold)
                    .foregroundColor(Color(hex: "#4F4F4F"))
                Spacer(minLength: 0)
                Circle()
                    .strokeBorder(Color(hex: "#50555C"), lineWidth: 0.5)
                    .background(Circle().fill(selection == tag ? Color(hex: "#5B86E5") : Color(hex: "#FCFCFE")))
                    .frame(width: 13, height: 13)
                    .animation(.default)
            }
            .padding(.bottom, 12)
        }
    }
}

struct ConfidentialityView_Previews: PreviewProvider {
    static var previews: some View {
        ConfidentialityView()
    }
}
