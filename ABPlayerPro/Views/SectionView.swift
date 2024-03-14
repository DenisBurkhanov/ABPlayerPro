//
//  SectionView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 03.02.2024.
//

import SwiftUI

struct sectionView: View {
	var section: Section
	
	var body: some View {
		ZStack {
			
			
			if section.loop {
				Rectangle()
				.foregroundColor(section.color)
				.opacity(0.8)
					.shadow(radius: 5)
					.ignoresSafeArea()
			} else {
				Rectangle()
					.foregroundColor(section.color)
					.opacity(0.7)
					.ignoresSafeArea()
			}
			VStack {
				
				Spacer()
				
				HStack {

					if section.loop {

						Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
							.resizable()
							.padding(8)
							.scaledToFit()
							.foregroundColor(.white)
							.opacity(0.7)
					}
				}
				
				Spacer()
			}
			
		}
		.ignoresSafeArea()
	}
	
	init(section: Section) {
		self.section = section
	}
	
}
