//
//  SplashScreenView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 02/01/2021.
//

import SwiftUI

struct SplashScreenView: View {
    @State private var showHomeView = false
    
    @State private var angle: Double = -90
    @State private var opacity: Double = 1
    @State private var scale: CGFloat = 1
    @State private var imgOffset: CGFloat = -800
    @State private var txtOffset: CGFloat = 0

    var body: some View {
        Group {
            if showHomeView {
                AuthView()
            } else {
                ZStack {
                    Color("Drinko Blue")
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 0) {
                        Image("logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 200,
                                   height: 200,
                                   alignment: .center)
                            .offset(y: imgOffset)
                            .scaleEffect(scale)
                            .opacity(opacity)
                        
                        Text("Drinko")
                            .font(.system(size: 66,
                                          weight: .bold,
                                          design: .rounded))
                            .rotation3DEffect(.degrees(angle),
                                              axis: (x: 0.5, y: 0.0, z: 0.0))
                            .foregroundColor(.white)
                            .offset(y: txtOffset)
                            .scaleEffect(scale)
                            .opacity(opacity)

                        Text("It's good to be back!")
                            .font(.system(size: 24,
                                          weight: .bold,
                                          design: .rounded))
                            .rotation3DEffect(.degrees(angle),
                                              axis: (x: 0.5, y: 0.0, z: 0.0))
                            .foregroundColor(.white)
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
                    
                    withAnimation(Animation.linear.delay(2.2)) {
                        showHomeView = true
                    }
                }
            }
        }
    }
}

#if DEBUG
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}
#endif
