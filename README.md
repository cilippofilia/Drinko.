![Logo](./Drinko/Assets.xcassets/thumbnail-red.imageset/thumbnail-red.png)

# Professional cocktails at home

Whether you want to start making cocktails, you are a beginner bartender or simply a cocktail aficionado, this app will guide you through the basics of bartending, teach you some tips and tricks and tell you more abou the most known cocktails.


## Table of contents
* [Features](#features)
* [Tech Stack](#tech-stack)


## Features

Key Features:
- Learn the basics and more advanced techniques in the 'Learn' section;

- Discover more than 35 classic cocktails divided by category in the 'Cocktails' section and mark your favorites so you will easily see them;

- Keep track of your ingredients and label the ones you want to buy, by using the 'Cabinet' section;

- Two languages supported, report bugs and get in touch with the dev, in the 'Settings' app;

Additional Features:
- All the techniques have video examples;

- All the text has been localized to automatically switch between English and Italian

- In-app mail view to report bugs and feedbacks;

- Pick your favorite app icon;


## Tech Stack

**Swift: UIKit (only used inside MailView) & SwiftUI**

Core and fundation of the whole app developed and shipped entirly using SwiftUI. 
The whole app is taylored to perfection for every iPhone and 
in order to achive the best user experience possible, and that native look and feel, I have implemented the following frameworks:

- **CloudKit**:
    Used for storing user settings and share it across multiple devices, like preferred settings and language.

- **Combine**:
    To handle asyc events in case of in-app purchases.

- **CoreData**:
    Used to keep track and store the items created by the user inside the 'Cabinet' section.

- **MessageUI**:
    Used to recive feedback and bugs directly from the testers, and users, without leaving the app.
   
- **StoreKit**:
    To support in-app purchases mainly used to learn how to implement and use the framework it in the app.

- **Figma**:
    Main tool to sketch, design, wireframe and style app icons, logos, AppStore Connect previews.

- **GitHub**:
    Used to work on updates and future release of the app.

