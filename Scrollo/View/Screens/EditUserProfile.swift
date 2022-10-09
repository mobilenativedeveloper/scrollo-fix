//
//  EditUserProfile.swift
//  Scrollo
//
//  Created by Artem Strelnik on 08.10.2022.
//

import SwiftUI
import SDWebImageSwiftUI
import PhotoSelectAndCrop

struct EditUserProfile: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @Binding var user: UserModel.User?
    
    @State var showingOptions: Bool = false
    @State var optionsMenu: EditUserTumbs = .avatar
    @State var isGalleryPickerBackground: Bool = false
    
    @State var selectedBackground: UIImage = UIImage()
    @State var selectedAvatar: UIImage = UIImage()
    
    
    private let genders = ["Мужской", "Женский"]
    @State var genderSelection: String = ""
    
    @State var avatar: String? = nil
    @State var background: String? = nil
    @State var name: String = ""
    @State var login: String = ""
    @State var career: String = ""
    @State var website: String = ""
    @State var bio: String = ""
    @State var email: String = ""
    @State var phone: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            
            VStack{
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("circle.xmark.black")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                    }
                    Spacer(minLength: 0)
                    VStack(spacing: 4) {
                        Text(user!.login!)
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#828796"))
                        Text("Ваш профиль")
                            .font(.system(size: 20))
                            .fontWeight(.bold)
                            .textCase(.uppercase)
                            .foregroundColor(Color(hex: "#2E313C"))
                    }
                    Spacer(minLength: 0)
                    Button(action: {
                        updateUserProfile()
                    }) {
                        Image("circle.blue.checkmark")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .aspectRatio(contentMode: .fill)
                        }
                }
                .padding(.horizontal)
                Rectangle()
                    .fill(Color(hex: "#F2F2F2"))
                    .frame(height: 1)
                    .padding(.horizontal, 27)
            }
            
            if user != nil{
                ScrollView(showsIndicators: false){
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(spacing: 0) {
                            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .bottom)) {
                                if let avatar = user!.avatar {
                                    WebImage(url: URL(string: "\(API_URL)/uploads/\(avatar)")!)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 87, height: 87)
                                        .clipped()
                                        .background(Color(hex: "#f7f7f7"))
                                        .cornerRadius(22)
                                } else {
                                    DefaultAvatar(width: 87, height: 87, cornerRadius: 22)
                                        .clipped()
                                }
                                Image("edit.user.photo")
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .offset(x: 7, y: 5)
                            }
                            .frame(width: (screen_rect.width - 44) / 3, height: 100, alignment: Alignment(horizontal: .leading, vertical: .center))
                            .shadow(color: Color(hex: "#909eab").opacity(0.1), radius: 7, y: 10)
                            .padding(.trailing, 23)
                            .onTapGesture {
                                self.optionsMenu = .avatar
                                self.showingOptions.toggle()
                            }
                            ZStack {
                                VStack {
                                    Image(systemName: "plus")
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 16, height: 17)
                                        .clipped()
                                        .foregroundColor(Color(hex: textBgColor()))
                                    Text("выберите обложку вашего аккаунта")
                                        .font(.system(size: 10))
                                        .foregroundColor(Color(hex: textBgColor()))
                                        .frame(width: 110)
                                        .multilineTextAlignment(.center)
                                        .lineLimit(2)
                                }
                            }
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                                    .fill(Color(hex: "#828796"))
                                    .frame(width: (screen_rect.width - 44) / 2, height: 70)
                            )
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(style: StrokeStyle(lineWidth: 1))
                                    .fill(Color(hex: "#828796"))
                                    .frame(width: (screen_rect.width - 44) / 1.8, height: 87)
                            )
                            .background(UserBackgroundView(background: user!.background))
                            .frame(width: (screen_rect.width - 44) / 1.8, height: 87)
                            .onTapGesture {
                                self.optionsMenu = .background
                                self.showingOptions.toggle()
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.vertical, 15)
                        .padding(.horizontal, 27)
                                            
                        EdtiProfileTextField(text: $name, label: "Имя", isLarge: false)
                        EdtiProfileTextField(text: $login, label: "Аккаунт", isLarge: false)
                        EdtiProfileTextField(text: $career, label: "Карьера", isLarge: false)
                        EdtiProfileTextField(text: $website, label: "Сайт", isLarge: false)
                        EdtiProfileTextField(text: $bio, label: "О себе", isLarge: true)
                        
                        Text("Персональные данные")
                            .font(.system(size: 18))
                            .fontWeight(.bold)
                            .foregroundColor(Color(hex: "#2E313C"))
                            .padding(.top, 9)
                            .padding(.bottom, 6)
                            .padding(.horizontal, 27)

                        EdtiProfileTextField(text: $email, label: "Email", isLarge: false)
                        EdtiProfilePhoneTextField(text: $phone, label: "Телефон")

                        HStack {
                            Text("Пол")
                                .font(.system(size: 14))
                                .foregroundColor(Color(hex: "#828796"))
                                .padding(.vertical, 15)
                                .padding(.trailing, 24)
                                .frame(width: (UIScreen.main.bounds.width - 54) / 3.5, alignment: Alignment(horizontal: .leading, vertical: .center))
                            VStack(alignment: .leading, spacing: 0) {
                                Picker("Выберите пол", selection: $genderSelection) {
                                    ForEach(genders, id: \.self) {
                                        Text($0)
                                            .font(Font.headline.weight(.semibold))
                                            .font(.system(size: 14))
                                            .foregroundColor(Color(hex: "#000000"))
                                            .padding(.vertical, 15)
                                    }
                                }
                                Rectangle()
                                    .fill(Color(hex: "#F2F2F2"))
                                    .frame(height: 1)
                            }
                        }
                        .padding(.horizontal, 27)
                        
                        
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                }
            }
            else{
                Spacer(minLength: 0)
                ProgressView()
            }
            
            Spacer(minLength: 0)
        }
        .fullScreenCover(isPresented: $isGalleryPickerBackground, content: {
            ImageGalleryPicker(isPresented: $isGalleryPickerBackground, originalImage: "https://picsum.photos/200/300?random=1")
        })
        .actionSheet(isPresented: $showingOptions) {
            if optionsMenu == .background {
                return ActionSheet(title: Text("Добавить Фон профиля"), buttons: [
                    .default(Text("Сделать фото")) {
//                        self.sourceTypeBackground = .camera
//                        self.isGalleryPickerBackground.toggle()
                    },
                    .default(Text("Выбрать из галереи")) {
//                        self.sourceTypeBackground = .photoLibrary
                        self.isGalleryPickerBackground.toggle()
                    },
                    .cancel(Text("Отмена"))
                ])
            } else {
                return ActionSheet(title: Text("Добавить фото профиля"), buttons: [
                    .default(Text("Сделать фото")) {
//                        self.sourceTypeAvatar = .camera
//                        self.isGalleryPickerAvatar.toggle()
                    },
                    .default(Text("Выбрать из галереи")) {
//                        self.sourceTypeAvatar = .photoLibrary
//                        self.isGalleryPickerAvatar.toggle()
                    },
                    .cancel(Text("Отмена"))
                ])
            }
        }
        .onAppear {
            self.avatar = user!.avatar
            self.background =  user!.background
            self.name =  user!.personal?.name ?? ""
            self.login =  user!.login!
            self.career =  user!.career ?? ""
            self.website =  user!.personal?.website ?? ""
            self.bio =  user!.personal?.bio ?? ""
            self.email =  user!.email ?? ""
            self.phone =  user!.phone ?? ""
            
            if user!.personal?.gender == "F" {
                self.genderSelection = "Женский"
            } else {
                self.genderSelection = "Мужской"
            }
        }
    }
    
    func textBgColor () -> String {
        if let background = user!.background {
            if !background.isEmpty && selectedBackground == nil {
                return "#ffffff"
            }
        } else if selectedBackground != UIImage() {
            return "#ffffff"
        } else {
            return "#828796"
        }
        return "#828796"
    }
    
    func updateUserProfile(){
        
        if self.login.isEmpty {
            print("login.isEmpty")
            return
        }
        if self.email.isEmpty {
            print("email.isEmpty")
            return
        }
        
        if self.phone.count < 16 && self.phone.count > 1 {
            print("phone fail")
            return
        }
        
        let url = URL(string: "\(API_URL)\(API_USER)")!
        
        let body: [String: String] = [
            "name": self.name,
            "login": self.login,
            "email": self.email,
            "phone": self.phone,
            "bio": self.bio,
            "gender": self.genderSelection == "Женский" ? "F" : "M",
            "website": self.website,
            "career": self.career
        ]
        
        guard let request = Request(url: url, httpMethod: "PATCH", body: body) else {return}
        
        URLSession.shared.dataTask(with: request){_, response, _ in
            guard let response = response as? HTTPURLResponse else {return}
            print("updateUserProfile: \(response.statusCode)")
            if response.statusCode == 200 {
                DispatchQueue.main.async {
                    user!.personal?.name = self.name
                    user!.login = self.login
                    user!.career = self.career
                    user!.personal?.website = self.website
                    user!.personal?.bio = self.bio
                    user!.email = self.email
                    user!.phone = self.phone
                }
            }
            
        }
        .resume()
    }
}

private struct UserBackgroundView: View{
    var background: String?
    
    var body: some View{
        if let background = self.background {
            WebImage(url: URL(string: "\(API_URL)/uploads/\(background)")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: (screen_rect.width - 44) / 1.8, height: 87)
                .cornerRadius(15)
        } else {
            Color.clear
        }
    }
}

private struct EdtiProfileTextField : View {
    @Binding var text: String
    var label: String
    
    var isLarge: Bool
    let width: CGFloat = UIScreen.main.bounds.width - 54
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#828796"))
                .padding(.vertical, 15)
                .padding(.trailing, 24)
                .frame(width: width / 3.5, alignment: Alignment(horizontal: .leading, vertical: .center))
            VStack(spacing: 0) {
                if !isLarge {
                    TextField("", text: $text)
                        .font(Font.headline.weight(.semibold))
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#000000"))
                        .padding(.vertical, 15)
                } else {
                    ZStack(alignment: .leading) {
                        TextEditor(text: $text)
                            .font(Font.headline.weight(.semibold))
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: "#000000"))
                            .frame(minHeight: 50, maxHeight: 50, alignment: .topLeading)
                            .padding(.vertical, 15)
                    }
                }
                Rectangle()
                    .fill(Color(hex: "#F2F2F2"))
                    .frame(height: 1)
            }
        }
        .frame(width: width)
        .padding(.horizontal, 27)
    }
}

private struct EdtiProfilePhoneTextField : View {
    @Binding var text: String
    var label: String
    
    let width: CGFloat = screen_rect.width - 54
    let phoneMask: String = "+X XXX XXX XX XX"
    
    var body: some View {
        
        HStack {
            Text(label)
                .font(.system(size: 14))
                .foregroundColor(Color(hex: "#828796"))
                .padding(.vertical, 15)
                .padding(.trailing, 24)
                .frame(width: width / 3.5, alignment: Alignment(horizontal: .leading, vertical: .center))
            VStack(spacing: 0) {
                TextField("+0 000 000 00 00", text: $text)
                    .keyboardType(.numberPad)
                    .onChange(of: text, perform: { value in
                        if value.count > 16 {
                            text = String(value.prefix(16))
                        } else {
                            text = format(with: phoneMask, phone: value)
                        }
                      })
                    .font(Font.headline.weight(.semibold))
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#000000"))
                    .padding(.vertical, 15)
                Rectangle()
                    .fill(Color(hex: "#F2F2F2"))
                    .frame(height: 1)
            }
        }
        .frame(width: width)
        .padding(.horizontal, 27)
    }
    func format(with mask: String, phone: String) -> String {
        let numbers = phone.replacingOccurrences(of: "[^0-9]", with: "", options: .regularExpression)
        var result = ""
        var index = numbers.startIndex

        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

enum EditUserTumbs {
    case avatar
    case background
}

private struct ImageGalleryPicker: View{
    
    @Binding var isPresented: Bool
    
    var originalImage: String?
    
    @State var inputImage: UIImage?
    
    @State var inputImageAspectRatio: CGFloat = 0.0
    
    @State var displayW: CGFloat = 0.0
    @State var displayH: CGFloat = 0.0
    
    @State var currentAmount: CGFloat = 0
    @State var zoomAmount: CGFloat = 1.0
    @State var currentPosition: CGSize = .zero
    @State var newPosition: CGSize = .zero
    @State var horizontalOffset: CGFloat = 0.0
    @State var verticalOffset: CGFloat = 0.0
    
    let inset: CGFloat = 15
    
    
    var body: some View{
        
        ZStack{
            
            ZStack{
                
                Color.black.opacity(0.8)
                if originalImage != nil {
                    if inputImage != nil {
                        Image(uiImage: inputImage!)
                            .resizable()
                            .scaleEffect(zoomAmount + currentAmount)
                            .scaledToFill()
                            .aspectRatio(contentMode: .fit)
                            .offset(x: self.currentPosition.width, y: self.currentPosition.height)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                            .clipped()
                    }
                    else{
                        ProgressView()
                    }
                } else {
                    Image("story1")
                        .resizable()
                        .scaledToFill()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color(.systemGray2))
                }
            }
            
            Rectangle()
                .fill(Color.black).opacity(0.55)
                .mask(HoleShapeMask().fill(style: FillStyle(eoFill: true)))
            
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: imageDataToUIImage)
        .gesture(
            MagnificationGesture()
                .onChanged { amount in
                    self.currentAmount = amount - 1
                }
                .onEnded { amount in
                    self.zoomAmount += self.currentAmount
                    if zoomAmount > 4.0 {
                        withAnimation {
                            zoomAmount = 4.0
                        }
                    }
                    self.currentAmount = 0
                    withAnimation {
                        repositionImage()
                    }
                }
        )
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                }
                .onEnded { value in
                    self.currentPosition = CGSize(width: value.translation.width + self.newPosition.width, height: value.translation.height + self.newPosition.height)
                    self.newPosition = self.currentPosition
                    withAnimation {
                        repositionImage()
                    }
                }
        )
    }
    
    func imageDataToUIImage(){
        guard let originalImage = self.originalImage else { return }
        guard let url = URL(string: originalImage) else { return }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            DispatchQueue.main.async {
                
                let image = UIImage(data: data)
                
                guard let currentImage = image else { return }
                
                let w = currentImage.size.width
                let h = currentImage.size.height
                inputImage = currentImage
                inputImageAspectRatio = w / h
                
            }
        }
        task.resume()
    }
    
    
    func HoleShapeMask() -> Path {
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        let insetRect = CGRect(x: inset, y: inset, width: UIScreen.main.bounds.width - ( inset * 2 ), height: UIScreen.main.bounds.height - ( inset * 2 ))
        var shape = Rectangle().path(in: rect)
        shape.addPath(Circle().path(in: insetRect))
        return shape
    }

    private func getAspect() -> CGFloat {
        let screenAspectRatio = UIScreen.main.bounds.width / UIScreen.main.bounds.height
        return screenAspectRatio
    }
    
    ///Positions the image selected to fit the screen.
    func resetImageOriginAndScale() {
        let screenAspect: CGFloat = getAspect()

        withAnimation(.easeInOut){
            if inputImageAspectRatio >= screenAspect {
                displayW = UIScreen.main.bounds.width
                displayH = displayW / inputImageAspectRatio
            } else {
                displayH = UIScreen.main.bounds.height
                displayW = displayH * inputImageAspectRatio
            }
            currentAmount = 0
            zoomAmount = 1
            currentPosition = .zero
            newPosition = .zero
        }
    }

    func repositionImage() {

        ///Setting the display width and height so the imputImage fits the screen
        ///orientation.
        let screenAspect: CGFloat = getAspect()
        let diameter = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

        if screenAspect <= 1.0 {
            if inputImageAspectRatio > screenAspect {
                displayW = diameter * zoomAmount
                displayH = displayW / inputImageAspectRatio
            } else {
                displayH = UIScreen.main.bounds.height * zoomAmount
                displayW = displayH * inputImageAspectRatio
            }
        } else {
            if inputImageAspectRatio < screenAspect {
                displayH = diameter * zoomAmount
                displayW = displayH * inputImageAspectRatio
            } else {
                displayW = UIScreen.main.bounds.width * zoomAmount
                displayH = displayW / inputImageAspectRatio
            }
        }

        horizontalOffset = (displayW - diameter ) / 2
        verticalOffset = ( displayH - diameter) / 2

        ///Keep the user from zooming too far in. Adjust as required in your individual project.
        if zoomAmount > 4.0 {
                zoomAmount = 4.0
        }

        ///If the view which presents the ImageMoveAndScaleSheet is embeded in a NavigationView then the vertical offset is off.
        ///A value of 0.0 appears to work when the view is not embeded in a NAvigationView().

        ///When it is embedded in a NvaigationView, a value of 4.0 seems to keep images displaying as expected.
        ///This appears to be a SwiftUI bug. So, we "pad" the function with this "adjust". YMMV.

        let adjust: CGFloat = 0.0

        ///The following if statements keep the image filling the circle cutout in at least one dimension.
        if displayH >= diameter {
            if newPosition.height > verticalOffset {
                print("1. newPosition.height > verticalOffset")
                    newPosition = CGSize(width: newPosition.width, height: verticalOffset - adjust + inset)
                    currentPosition = CGSize(width: newPosition.width, height: verticalOffset - adjust + inset)
            }

            if newPosition.height < ( verticalOffset * -1) {
                print("2. newPosition.height < ( verticalOffset * -1)")
                    newPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - adjust - inset)
                    currentPosition = CGSize(width: newPosition.width, height: ( verticalOffset * -1) - adjust - inset)
            }

        } else {
            print("else: H")
                newPosition = CGSize(width: newPosition.width, height: 0)
                currentPosition = CGSize(width: newPosition.width, height: 0)
        }

        if displayW >= diameter {
            if newPosition.width > horizontalOffset {
                print("3. newPosition.width > horizontalOffset")
                    newPosition = CGSize(width: horizontalOffset + inset, height: newPosition.height)
                    currentPosition = CGSize(width: horizontalOffset + inset, height: currentPosition.height)
            }

            if newPosition.width < ( horizontalOffset * -1) {
                print("4. newPosition.width < ( horizontalOffset * -1)")
                    newPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: newPosition.height)
                    currentPosition = CGSize(width: ( horizontalOffset * -1) - inset, height: currentPosition.height)

            }

        } else {
            print("else: W")
                newPosition = CGSize(width: 0, height: newPosition.height)
                currentPosition = CGSize(width: 0, height: newPosition.height)
        }

        ///This statement is needed in case of a screenshot.
        ///That is, in case the user chooses a photo that is the exact size of the device screen.
        ///Without this function, such an image can be shrunk to less than the
        ///size of the cutrout circle and even go negative (inversed).
        ///If "processImage()" is run in this state, there is a fatal error. of a nil UIImage.
        ///
        if displayW < diameter - inset && displayH < diameter - inset {
            resetImageOriginAndScale()
        }
    }
}

