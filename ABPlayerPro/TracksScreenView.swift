//
//  TracksScreenView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 10.12.2023.
//

import SwiftUI

struct TracksScreenView: View {
	
	@State var assinedToA: AudioTrack? = nil
	@State var assinedToB: AudioTrack? = nil
	@State var selectedForEditing: AudioEngine? = anubisEngine
	@State var dragOffset: CGFloat = 0
	@State var pickerSelection: Int = 0
	var trackATitle: String  {
		return (assinedToA != nil ? String ("\(assinedToA!.title).\(assinedToA!.format)") : "not selected" )
	}
	var trackBTitle: String  {
		return (assinedToB != nil ?  String ("\(assinedToB!.title).\(assinedToB!.format)") : "not selected" )
	}
	
	
	
	@State var allTracks: [AudioTrack] = [defaultTrackMock, defaultTrackDont, defaultTrackAnubis, moon4, moon5]
	
	
    var body: some View {
		ZStack {
			Rectangle()
				.foregroundColor(dCS.bgLighterColor)
				.ignoresSafeArea()
			VStack {
				tracksAssined
					.padding(.horizontal)
				
				listOfTracks
					.padding(.horizontal)
					.onAppear {
						
					}
				
					editingField
						.padding()
				
				
				Spacer()
			}
			
		}
    }
	
	var tracksAssined: some View {
		HStack {
			Button {
				
			} label: {
				Image(systemName: "icloud.and.arrow.down.fill")
					.foregroundColor(dCS.pastelBlue)
				.padding(20)
				.background(dCS.darkerGray ,in: RoundedRectangle(cornerRadius: 10))
			}

			Button {
				
			} label: {
				HStack {
					Button {
						
					} label: {
						VStack {
							
							HStack {
								Text(trackATitle)
									.foregroundColor(dCS.pastelPurpleLighter)
									.lineLimit(2)
								Spacer()
								
								Image(systemName: "a.circle.fill")
									.foregroundColor(dCS.pastelBlue)
								
									.background(dCS.darkerGray, in: RoundedRectangle(cornerRadius: 12, style: .continuous ))
							}
							HStack {
								Text(trackBTitle)
									.foregroundColor(dCS.pastelPurpleLighter)
									.lineLimit(2)
								Spacer()
								
								
								Image(systemName: "b.circle.fill")
									.foregroundColor(dCS.pastelBlue)
									.background(dCS.darkerGray, in: RoundedRectangle(cornerRadius: 12, style: .continuous ))
							}
						}
						.padding(10)
						.background(dCS.darkerGray ,in: RoundedRectangle(cornerRadius: 10))
					}
					
				}
			}
		}

	}
	var listOfTracks: some View {
	
		ScrollView {
			ForEach(allTracks) { track in
				
				
				HStack {
					if assinedToA?.id == track.id {
						Image(systemName: "a.circle.fill")
							.foregroundColor(dCS.pastelBlue)
					} else {
						Image(systemName: "a.circle.fill")
							.foregroundColor(dCS.pastelBlue)
							.opacity(0)
					}
					
					Spacer()
					
					
					
					
					ZStack {
						if selectedForEditing?.track.id == track.id {
							RoundedRectangle(cornerRadius: 10)
								.foregroundColor(dCS.darkerGray)
						}
						
						
						HStack {
							Button {
								selectedForEditing?.track = track
								
							} label: {
								Text("\(track.title).\(track.format)")
									.foregroundColor(dCS.pastelPurpleLighter)
									.padding(5)
									.font(.system(size: 14))
							}

							
							
							Spacer()
							
							Button {
								
								
							} label: {
								if track.waveform.isEmpty {
									Text("ANALYZING")
										.scaleEffect(0.6)
										.opacity(0.7)
										.foregroundColor(dCS.pastelPurpleLighter)
										.padding(1)
										
								} else {
									Image(systemName: "waveform")
										.foregroundColor(dCS.pastelPurpleLighter)
										.padding(.horizontal)
								}
							}

							
							
						}
							
					}
					
							
					
					
					
					
					Spacer()
					if assinedToB?.id == track.id {
						Image(systemName: "b.circle.fill")
							.foregroundColor(dCS.pastelBlue)
					} else {
						Image(systemName: "b.circle.fill")
							.foregroundColor(dCS.pastelBlue)
							.opacity(0)
					}
				}
				
			}
		}
		.frame(height: 180)
	}
	var editingField: some View {
		
		ZStack {
//			RoundedRectangle(cornerRadius: 10)
//				.foregroundColor(dCS.darkerGray)
			VStack {
				Text("A     < < <   swipe to assign    > > >     B")
					.scaleEffect(0.7)
					.foregroundColor(dCS.pastelPurpleLighter)
					.padding(.horizontal)
					.opacity(0.5)
				
				HStack {
					Text("\(selectedForEditing?.track.title ?? "").\(selectedForEditing?.track.format ?? "") ")
						.foregroundColor(dCS.pastelPurpleLighter)
						.padding(.horizontal)
						.background(in: RoundedRectangle(cornerRadius: 10))
						.font(.title2)
						.offset(x: dragOffset)
						.gesture(
						DragGesture(minimumDistance: 20)
							.onChanged({ value in
								if value.translation.width < 0 {
									assinedToA = selectedForEditing?.track
									withAnimation {
										dragOffset = value.translation.width
									}
								} else {
									assinedToB = selectedForEditing?.track
									withAnimation {
										dragOffset = value.translation.width
									}
								}
							})
							.onEnded({ value in
								
								withAnimation {
									dragOffset = 0
								}
							})
							
						)
					
					
					
				}
				
				
				//Sections
				//Volume offsets
				//Delay offsets
				//Play button
				Spacer()
			}
		}
	}
	var sectionEditing: some View {
		VStack {
			
				
			}
		}
	
	var offsets: some View {
		VStack{
			Text("liyfg")
		}
	}
		
}

struct TracksScreenView_Previews: PreviewProvider {
    static var previews: some View {
        TracksScreenView()
    }
}
