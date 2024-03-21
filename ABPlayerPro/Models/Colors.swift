//
//  Colors.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 19.11.2023.
//

import SwiftUI

struct DefaultColorScheme {
	var isDarkMode: Bool
	public var dmBG                = Color(#colorLiteral(red: 0.1206690893, green: 0.1256528199, blue: 0.1341503859, alpha: 1))
	public let dmLighterBG         = Color(#colorLiteral(red: 0.1206690893, green: 0.1256528199, blue: 0.1341503859, alpha: 1))
	public let dmDarkerGray        = Color(#colorLiteral(red: 0.3010698557, green: 0.3060462773, blue: 0.3145573139, alpha: 1))
	public let dmlighterGray       = Color(#colorLiteral(red: 0.5010726452, green: 0.5060470104, blue: 0.5231509209, alpha: 1))
	public let pastelGreen         = Color(#colorLiteral(red: 0.3505284786, green: 0.7462508082, blue: 0.6293142438, alpha: 1))
	public let pastelPurple        = Color(#colorLiteral(red: 0.4764783978, green: 0.4419484138, blue: 0.8618849516, alpha: 1))
	public let pastelPurpleLighter = Color(#colorLiteral(red: 0.6180213094, green: 0.5055570602, blue: 0.7161069512, alpha: 1))
	public let pastelYellow        = Color(#colorLiteral(red: 0.947432816, green: 0.6996946335, blue: 0.3541660905, alpha: 1))
	public let pastelRed           = Color(#colorLiteral(red: 0.9420003891, green: 0.4288592339, blue: 0.3954107165, alpha: 1))
	public let pastelBlue          = Color(#colorLiteral(red: 0.329090327, green: 0.5907341838, blue: 0.8692957759, alpha: 1))
	
	public var bgLightMode             = Color(#colorLiteral(red: 0.8061240911, green: 0.8108474612, blue: 0.8230254054, alpha: 1))
	public let darkerGrayLightMode     = Color(#colorLiteral(red: 0.9903541207, green: 0.9556823373, blue: 0.8521113992, alpha: 1))

	
	var bgColor:    Color { isDarkMode ? dmBG: bgLightMode }
	var darkerGray: Color { isDarkMode ? dmDarkerGray: darkerGrayLightMode }
}

let dCS = DefaultColorScheme(isDarkMode: true)



