//
//  SwipeToActionTips.swift
//  DrinkoPro
//
//  Created by Filippo Cilia on 14/01/2024.
//

import SwiftUI
import TipKit

struct SwipeToFavoriteTip: Tip, Identifiable {
    var id = UUID()
    
    var title: Text {
        Text("Swipe right")
    }

    var message: Text? {
        Text("To mark your favorite cocktails")
    }

    var image: Image? {
        Image(systemName: "heart.fill")
    }
}

struct SwipeToCartTip: Tip, Identifiable {
    var id = UUID()
    
    var title: Text {
        Text("Swipe right")
    }

    var message: Text? {
        Text("To add a product to your cart so you know what is missing from your cabinet with a quick glance.")
    }

    var image: Image? {
        Image(systemName: "cart.badge.plus")
    }
}
