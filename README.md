![Logo](./DrinkoPro/Assets.xcassets/thumbnail-red.png)

# Professional cocktails at home

Whether you're a newbie cocktail enthusiast, aspiring bartender or simply looking to up your mixology game, this app is your ultimate guide to the world of bartending. From the basics to advanced techniques, you'll learn insider tips and tricks to craft delicious, Instagram-worthy cocktails. Our app is your one-stop-shop for everything you need to know about the most famous cocktails, their history, and how to make them like a pro. Let's shake things up and get started on your cocktail-making journey!

## Table of contents
* [Features](#features)
* [Tech Stack](#tech-stack)


## Features

Discover the ultimate bartending experience with our app's key features:

- Get started on your mixology journey with our 'Learn' section, where you'll master the basics and learn advanced techniques to impress your guests.

- Indulge in over 200 cocktails in our 'Cocktails' section. Mark your favorites and never miss a beat when mixing your go-to drinks.

- Keep track of your ingredients and easily label the ones you need to buy with our 'Cabinet' section. No more scrambling to find the right ingredients when it's time to mix. (COMING SOON...)

- Our app is designed for global users with two supported languages - 🇬🇧 🇮🇹 - get in touch if you'd like to help translating it into more languages 🙌
(You can report bugs and get in touch with the developer in the 'Settings' section)

Whether you're a beginner or an experienced mixologist, our app has everything you need to take your bartending skills to the next level. Download it now and start crafting cocktails like a pro!

Additional Features:
- All the techniques have video examples;

- All the text has been localized to automatically switch between English and Italian 

- Quickly write an email to report bugs and feedbacks;


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

