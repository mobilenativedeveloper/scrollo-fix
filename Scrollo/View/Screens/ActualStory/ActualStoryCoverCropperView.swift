//
//  ActualStoryCoverCropperView.swift
//  scrollo
//
//  Created by Artem Strelnik on 21.08.2022.
//

import SwiftUI
import SDWebImageSwiftUI

struct ActualStoryCoverCropperView: View {
    @EnvironmentObject var actualStory: ActualStoryDelegate
    @StateObject var cropperDelegate: CropperDelegate = CropperDelegate()
    @StateObject var UIState: UIStateModel = UIStateModel()
    
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            ZStack(alignment: .center){
                GeometryReader{proxy in
                    ZStack {
                        BluredBackground(image: actualStory.selectedCover!.url)
                        ScrollView.init([.vertical,.horizontal], showsIndicators: false) {
                            WebImage(url: URL(string: actualStory.selectedCover!.url)!)
                                .resizable()
                                .scaledToFill()
                                .scaleEffect(cropperDelegate.scale)
                                .gesture(cropperDelegate.scaleController())
                        }
                        .frame(width: cropperDelegate.cropSize.width, height: cropperDelegate.cropSize.height, alignment: .center)
                        .clipShape(Circle())
                    }
                    .frame(width:proxy.size.width,height: proxy.size.height)
                    .overlay(
                        CoverCollectionView(covers: actualStory.selectedStories)
                            .offset(y: -90)
                            .environmentObject(UIState)
                            .onChange(of: UIState.activeCard, perform: { newValue in
                                actualStory.selectedCover = actualStory.selectedStories[UIState.activeCard - 1]
                            })
                        ,alignment: Alignment(horizontal: .center, vertical: .bottom)
                    )
                }
            }
            HeaderBar()
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            cropperDelegate.downloadImage(from: URL(string: "https://picsum.photos/700/700.jpg")!) { image in
                cropperDelegate.originalImage = image
            }
        }
    }
}

class UIStateModel: ObservableObject {
    @Published var activeCard: Int = 1
    @Published var screenDrag: Float = 0.0
}

private struct CoverCollectionView: View {
    @EnvironmentObject var UIState: UIStateModel
    let spacing: CGFloat = 16
    let widthOfHiddenCards: CGFloat = 150
    let cardHeight: CGFloat = 50
    let covers: [ActualStoryModel]
    
    
    @State var presentationSelectFromAlboum: Bool = false
    
    var body: some View {
        CollectionView(
            numberOfItems: CGFloat(covers.count) + 1,
            spacing: spacing,
            widthOfHiddenCards: widthOfHiddenCards
        ) {
           
            Button(action: {
                presentationSelectFromAlboum.toggle()
                print("presentationSelectFromAlboum")
            }) {
                Image(systemName: "photo")
                    .resizable()
                    .frame(width: 20, height: 18)
                    .foregroundColor(.white)
            }
            .frame(
                width: (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2,
                height: (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2,
                alignment: .center
            )
            .transition(AnyTransition.slide)
            .animation(.default)
            .fullScreenCover(isPresented: self.$presentationSelectFromAlboum, content: {
                ImagePickerView(sourceType: .savedPhotosAlbum) { image in
                    
                }
                .edgesIgnoringSafeArea(.all)
            })
            ForEach(0..<covers.count, id: \.self) { index in
                WebImage(url: URL(string: covers[index].url)!)
                    .resizable()
                    .frame(
                        width: (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2,
                        height: (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2,
                        alignment: .center
                    )
                    .transition(AnyTransition.slide)
                    .animation(.default)
            }
        }
        .overlay(
            Rectangle()
                .stroke(Color.white, lineWidth: 2)
                .frame(width: (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2, height: (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2)
            ,alignment: .center
        )
        .environmentObject(UIState)
    }
}


struct CollectionView<Items : View>: View {
    @EnvironmentObject var UIState: UIStateModel
    @GestureState var isDetectingLongPress = false
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    init(
        numberOfItems: CGFloat,
        spacing: CGFloat,
        widthOfHiddenCards: CGFloat,
        @ViewBuilder _ items: () -> Items
    ) {
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = (UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2)) / 2 //279
    }
    
    func dragGesture () -> some Gesture {
        return DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50 && (self.UIState.activeCard < Int(self.numberOfItems - 1))) {
                
                self.UIState.activeCard = self.UIState.activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
            }
            
            if (value.translation.width > 50 && self.UIState.activeCard > 1) {
                print(self.UIState.activeCard)
                self.UIState.activeCard = self.UIState.activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
        }
    }
    
    var body: some View{
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = ((totalCanvasWidth - UIScreen.main.bounds.width) / 2) + self.cardWidth / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)
        
        var calcOffset = Float(activeOffset)
                
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .center)
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(dragGesture())
    }
}


private struct HeaderBar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image("circle.left.arrow.black")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
            Spacer(minLength: 0)
            Text("Редактировать обложку")
                .font(.system(size: 20))
                .fontWeight(.bold)
                .textCase(.uppercase)
                .foregroundColor(Color(hex: "#2E313C"))
            Spacer(minLength: 0)
            Button(action: {

            }) {
                Image("circle.right.arrow.blue")
                    .resizable()
                    .frame(width: 24, height: 24)
                    .aspectRatio(contentMode: .fill)
            }
        }
        .padding(.horizontal, 23)
        .padding(.bottom)
        .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top)
        .background(VisualEffectView(effect: UIBlurEffect(style: .light)))
    }
}

private struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

private struct BluredBackground: View {
    var image: String
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .center)) {
            WebImage(url: URL(string: image)!)
                .resizable()
            VisualEffectView(effect: UIBlurEffect(style: .light))
        }
        .edgesIgnoringSafeArea(.all)
    }
}

class CropperDelegate: ObservableObject {
    @Published var originalImage: UIImage?
    
    @Published var scale: CGFloat = 1.0
    @Published var lastScale: CGFloat = 1.0
    @Published var maximumScale: CGFloat = 2.0
    @Published var minimumScale: CGFloat = 1.0
    
    @Published var cropSize: CGSize = CGSize(
        width: UIScreen.main.bounds.width,
        height: UIScreen.main.bounds.width
    )
    
    func scaleController () -> some Gesture {
        return MagnificationGesture(minimumScaleDelta: 0.1)
            .onChanged { value in
                let resolvedDelta = value / self.lastScale
                self.lastScale = value
                let newScale = self.scale * resolvedDelta
                self.scale = min(self.maximumScale, max(self.minimumScale, newScale))
            }.onEnded { value in
                self.lastScale = 1.0
            }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    func downloadImage(from url: URL, onDownloaded: @escaping (UIImage) -> Void) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                onDownloaded(UIImage(data: data)!)
            }
        }
    }
}
