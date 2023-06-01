//
//  ReadMeView.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 22/04/2023.
//

import SwiftUI

struct ReadMeView: View {
    @State private var text: LocalizedStringKey =
"""
Welcome to the exciting world of cocktails! This app is your ultimate guide to crafting the perfect drink, whether you're a seasoned bartender or just starting as a home enthusiast. It's a perfect blend of my personal experience behind the bar, insights from friends and colleagues, and information collected from reliable sources on the internet and various books.

But, let's face it, taste is subjective, and there's no one-size-fits-all approach to making cocktails. However, this app will be your trusty companion to help you discover new recipes, perfect your favorites, and even create your signature cocktail.

From refreshing tropical blends to sophisticated sips, we've got you covered. You'll find everything from classic cocktails to modern twists, so get ready to impress your guests with your newfound mixology skills.

But, at the end of the day, the most important thing is that you enjoy the cocktail sitting in front of you. So, use this app as a guideline, experiment with different ingredients and techniques, and most importantly, have fun! Who knows, you might even uncover some professional bartending tips and tricks along the way.

So, are you ready to shake things up and craft some delicious drinks? Let's raise a glass and cheers to endless possibilities!
"""

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Text(text)
                    .multilineTextAlignment(.leading)
            }
            .frame(width: screenWidthPlusMargins)
        }
        .navigationBarTitle("Drinko")
    }
}

struct ReadMeView_Previews: PreviewProvider {
    static var previews: some View {
        ReadMeView()
    }
}
