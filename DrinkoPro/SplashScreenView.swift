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
                #if os(macOS)
                MacHomeView()
                #elseif os(iOS)
                HomeView()
                #endif
            } else {
                animatedLogo
            }
        }
    }

    private var animatedLogo: some View {
        ZStack {
            Color("Dr. Blue")
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    #if os(iOS)
                    .frame(
                        width: sizeClass == .compact ? frameSize : frameSize * 1.5,
                        height: sizeClass == .compact ? frameSize : frameSize * 1.5
                    )
                    #elseif os(macOS)
                    .frame(width: frameSize)
                    #endif
                    .offset(y: imgOffset)
                    .opacity(opacity)

                Text("Drinko.")
                    #if os(iOS)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    #elseif os(macOS)
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    #endif
                    .rotation3DEffect(
                        .degrees(angle),
                        axis: (x: 0.5, y: 0.0, z: 0.0)
                    )
                    .foregroundStyle(.white)
                    #if os(iOS)
                    .scaleEffect(sizeClass == .compact ? 1.5 : 2)
                    #endif
                    .opacity(opacity)
            }
        }
        .opacity(showHomeView ? 0 : 1)
        .task {
            // Logo slides in
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                imgOffset = 0
            }

            // Text rotates in after a brief delay
            try? await Task.sleep(for: .milliseconds(400))
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                angle = 0
            }

            // Hold the animation for a moment
            try? await Task.sleep(for: .milliseconds(1000))

            // Fade out smoothly
            withAnimation(.easeOut(duration: 0.4)) {
                opacity = 0
            }

            // Transition to home view after fade completes
            try? await Task.sleep(for: .milliseconds(400))
            showHomeView = true
        }
    }
}

#if DEBUG
#Preview {
    SplashScreenView()
}
#endif
