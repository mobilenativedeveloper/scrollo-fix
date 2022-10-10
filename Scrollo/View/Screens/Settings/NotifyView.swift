//
//  NotifyView.swift
//  scrollo
//
//  Created by Artem Strelnik on 08.07.2022.
//

import SwiftUI

struct NotifyView: View {
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var notifyViewModel: NotifySettingsViewModel = NotifySettingsViewModel()
    
    var body: some View {
        VStack {
                HStack {
                    Button(action: {
                        if notifyViewModel.load {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }) {
                        Image("comments_back")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 24, height: 24)
                    }
                    Spacer(minLength: 0)
                    Text("Уведомления")
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
                .padding(.bottom)
            
            if notifyViewModel.load {
                ScrollView {
                    VStack(spacing: 0) {
                        Toggle(isOn: $notifyViewModel.disableAll, label: {
                            Text("Выключить все")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.offAll()
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .padding(.bottom)
                        Toggle(isOn: $notifyViewModel.notify.newFollowers, label: {
                            Text("Новые подписчики")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.changeSettingsNotify(body: ["newFollowers": !notifyViewModel.notify.newFollowers])
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        Toggle(isOn: $notifyViewModel.notify.newComments, label: {
                            Text("Новые комментарии")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.changeSettingsNotify(body: ["newComments": !notifyViewModel.notify.newComments])
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        Toggle(isOn: $notifyViewModel.notify.newMessages, label: {
                            Text("Новые сообщения")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.changeSettingsNotify(body: ["newMessages": !notifyViewModel.notify.newMessages])
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        Toggle(isOn: $notifyViewModel.notify.newReactions, label: {
                            Text("Новые реакции на ваш контент")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.changeSettingsNotify(body: ["newReactions": !notifyViewModel.notify.newReactions])
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        Toggle(isOn: $notifyViewModel.notify.newFollowingsPublications, label: {
                            Text("Новые публикации подписки")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.changeSettingsNotify(body: ["newFollowingsPublications": !notifyViewModel.notify.newFollowingsPublications])
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        Toggle(isOn: $notifyViewModel.notify.newFollowersPublications, label: {
                            Text("Новые публикации подписчики")
                                .font(.system(size: 12))
                                .foregroundColor(Color.black)
                                .fontWeight(Font.Weight.semibold)
                        })
                            .onTapGesture {
                                notifyViewModel.changeSettingsNotify(body: ["newFollowersPublications": !notifyViewModel.notify.newFollowersPublications])
                            }
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                    }
                }
            } else {
                Spacer()
                ProgressView()
                Spacer()
            }
        }
        .background(Color(hex: "#F9F9F9"))
    }
}

struct NotifyView_Previews: PreviewProvider {
    static var previews: some View {
        NotifyView()
    }
}
