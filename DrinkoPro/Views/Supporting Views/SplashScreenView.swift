//
//  SplashScreenView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 19/09/2023.
//

import SwiftUI

struct SplashScreenView: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showHomeView = false
    @State private var angle: Double = -90
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    @State private var imgOffset: CGFloat = -800
    @State private var txtOffset: CGFloat = 0
    @State private var frameSize: CGFloat = 200

    var body: some View {
        Group {
            if showHomeView {
                HomeView()
            } else {
                animatedLogo
            }
        }
    }

    private var animatedLogo: some View {
        ZStack {
            Color("Dr. Blue")
                .ignoresSafeArea()

            VStack {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: sizeClass == .compact ? frameSize : frameSize * 1.75,
                           height: sizeClass == .compact ? frameSize : frameSize * 1.75,
                           alignment: .center)
                    .offset(y: imgOffset)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("Drinko.")
                    .font(.system(sizeClass == .compact ? .title : .largeTitle, design: .rounded, weight: .bold))
                    .rotation3DEffect(.degrees(angle),
                                      axis: (x: 0.5, y: 0.0, z: 0.0))
                    .foregroundStyle(.white)
                    .offset(y: txtOffset)
                    .scaleEffect(scale)
                    .opacity(opacity)

                Text("It's good to be back!")
                    .font(.system(sizeClass == .compact ? .title3 : .title2, design: .rounded))
                    .bold()
                    .rotation3DEffect(.degrees(angle),
                                      axis: (x: 0.5, y: 0.0, z: 0.0))
                    .foregroundStyle(.white)
                    .offset(y: txtOffset)
                    .scaleEffect(scale)
                    .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.interactiveSpring(response: 0.5,
                                             dampingFraction: 0.6,
                                             blendDuration: 0.7)) {
                imgOffset = 0
            }
            withAnimation(Animation.interactiveSpring(response: 0.5,
                                                      dampingFraction: 0.6,
                                                      blendDuration: 0.7)
                .delay(0.4)) {
                    angle = 0
                }
            withAnimation(Animation.linear.delay(1.8)) {
                opacity = 0
            }
            withAnimation(Animation.linear.delay(1.8)) {
                showHomeView = true
            }
        }
    }
}

#if DEBUG
#Preview {
    SplashScreenView()
}
#endif
