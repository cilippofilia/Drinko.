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
