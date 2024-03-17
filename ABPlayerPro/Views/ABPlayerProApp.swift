//
//  ABPlayerProApp.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 19.11.2023.
//

import SwiftUI

@main
struct ABPlayerProApp: App {
	@State var haptix = Haptix()
    var body: some Scene {
        WindowGroup {
            ABPlayerView()
				.defaultTextColor() 
        }
    }
}
