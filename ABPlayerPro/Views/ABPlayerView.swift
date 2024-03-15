//
//  ContentView.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 19.11.2023.
//

import SwiftUI
import AVFoundation
import CoreHaptics
import Waveform





struct ABPlayerView: View {
	
	@ObservedObject private var viewModel = ViewModel()
	@State var appState = 0
	@State var haptixEngine: CHHapticEngine?
	
	
	@State private var isShowingDocumentPicker = false
	@State private var showAlert = false
	
	@State var loudnessAnalyzingStatus = false
	@State var loudnessTimer = 0
	@State var analizerCounter: TimeInterval = 0
	@State var analizerStatus = false
	@State var isCompensationAvailable = false
	
	@State private var isSelectedA = true
	@State private var duration: TimeInterval = 0.0
	@State private var jogOffset: CGFloat = 0.0
	@State private var nameOffset: CGFloat = 0
	@State private var scale: CGFloat = 0
	@State private var selectedTrackNumber = 0
	@State private var editState = false
//	@State var sectionsForRenaming: [Section] = []
	
	@State private var volA: CGFloat = 0
	@State private var volB: CGFloat = 0
	@State private var isGearShown: Bool = false
	@State private var gearAngle: Double = 0
	@State var libChecker = LibChecker()
	
	var dbNumbers: [Double] = [-30, -20, -14, -12, -10, -7, -5, -3, -2, -1, 0]
	
	let timer = Timer.publish(every: 0.0001, on: .main, in: .common).autoconnect()
	let allColors = [ dCS.lighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	
	
	
	
    var body: some View {
		ZStack {
			
			Rectangle()
				.ignoresSafeArea()
				.foregroundColor(dCS.bgColor)
			
			//Top of the view Hierarchie
				
			if appState == 0 {
				startPage
				
			} else if appState == 1 {
				setPage
				
			} else if appState == 2 {
				abPage
			}
			
		}
		.onAppear() {
			

			configureAudioSession()
			prepareHaptix()
		}
		.onReceive(timer) { _ in
			if isGearShown {
				gearAngle += 0.05
			} else {
				gearAngle = 0
			}
			
			
			if loudnessAnalyzingStatus {
				loudnessTimer += 1
				viewModel.audioEngineA.collectBuffer()
				viewModel.audioEngineB.collectBuffer()
				
				if loudnessTimer == 3500 {
					
					loudnessAnalyzingStatus = false
					loudnessTimer = 0
					viewModel.audioEngineA.calcResultAvgBuffer()
					viewModel.audioEngineB.calcResultAvgBuffer()
					sharpTap()
					isCompensationAvailable = true
					
					
					
					
				}
				
			}
			
			withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
				viewModel.playbackPosition = (isSelectedA ? viewModel.audioEngineA.playbackPosition : viewModel.audioEngineB.playbackPosition)
				if appState == 2 {
					viewModel.audioEngineA.meterValues()
					viewModel.audioEngineB.meterValues()
				}
			}
			
			
			if appState == 2 {
				viewModel.audioEngineA.getSectionLabel(forPlaybackPosition: viewModel.playbackPosition)
				viewModel.audioEngineB.getSectionLabel(forPlaybackPosition: viewModel.playbackPosition)
				viewModel.selectedForEditing.audioPlayer?.stop()
			} else if appState == 1 {
				viewModel.selectedForEditing.getSectionLabel(forPlaybackPosition: viewModel.selectedForEditing.playbackPosition)
			}
		}
	}
}


//MARK: STARTING PAGE
extension ABPlayerView {
	var startPage: some View {
		ZStack {
			VStack{
				Rectangle()
					.foregroundStyle(dCS.pastelBlue)
					.frame(height: 100)
					.blur(radius: 150)
					
				Spacer()
				Rectangle()
					.foregroundStyle(dCS.pastelPurple)
					.frame(height: 100)
					.blur(radius: 150)
			}
			.ignoresSafeArea()
			
			VStack {
				Text("A/B test on the go")
					.fontWeight(.light)
					.foregroundColor(.gray)
					.opacity(0.5)
				Spacer()
				if isGearShown {
					Image(systemName: "gear")
						.font(.largeTitle)
						.foregroundColor(dCS.darkerGray)
						.rotationEffect(Angle(degrees: gearAngle))
						.opacity(1)
						.shadow(radius: 10)
				} else {
					Image(systemName: "gear")
						.font(.largeTitle)
						.foregroundColor(dCS.darkerGray)
						.opacity(0)
				}
				
				Spacer()
				Button {
					sharpTap()
					isGearShown = true
					DispatchQueue.global().async {
						viewModel.createDataFolderIfNeeded()
						libChecker.checkIfFilesExist()
						DispatchQueue.main.async {
							withAnimation {
								isGearShown = false
								viewModel.allTracks = libChecker.bufferForAllTRacks
								appState = 1
								doubleTap()
							}
							
						}
					}
					
					
				} label: {
					ZStack{
						
						Text("Analize tracks in your library")
							.foregroundColor(dCS.pastelPurpleLighter)
							.padding()
							.padding(.horizontal)
							.background(dCS.darkerGray)
							.clipShape(RoundedRectangle(cornerRadius: 10))
							.opacity(0.8)
					}
					.shadow(radius: 10)
						
				}
				
				Spacer()
				Spacer()
			}
		}
	}
}

//MARK: A/B PAGE
extension ABPlayerView {
	
	//MARK: A/B PAGE Structure
	var abPage: some View {
		VStack {
			let track = isSelectedA ? viewModel.audioEngineA.track : viewModel.audioEngineB.track
			
			meters
				.frame(height: 24)
				.padding(.horizontal)
			
			tracksAssined
				.padding(.horizontal)
			
			abButton
				.scaleEffect(0.9)
				.padding()
				
			
			LabelsBlock(vm: viewModel, isItABPage: true, isSelectedA: isSelectedA)
				.padding(.horizontal)

			ZStack {
				
				PositionView(vm: viewModel, engineNumber: isSelectedA ? 1 : 2)
				
					
				SectionsBlock(vm: viewModel, engineNumber: isSelectedA ? 1 : 2)
				
				if track.id != emptyTrack.id {
				
					Wav(samples: track.waveform)
						.opacity(0.4)
				}
				
				
					 
					
			}
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.padding(.horizontal)
				
			jog
				.padding(.horizontal)
				.frame(height: 65)
			
			playBlock
				.scaleEffect(0.9)
				.padding(.horizontal)
		}
	}
	
	
	
	//MARK: METERS
	var meters: some View {
		
		
		GeometryReader(content: { geometry in
			
			let elementHeight = geometry.size.height / 4
			let elementWidth = (geometry.size.width - 0)
			let leftChannel  = ( isSelectedA ? viewModel.audioEngineA.logPowerL : viewModel.audioEngineB.logPowerL )
			let rightChannel = ( isSelectedA ? viewModel.audioEngineA.logPowerR : viewModel.audioEngineB.logPowerR )
			let leftPeak     = (isSelectedA ? viewModel.audioEngineA.peakL : viewModel.audioEngineB.peakL )
			let rightPeak    = (isSelectedA ? viewModel.audioEngineA.peakR : viewModel.audioEngineB.peakR)
			let correlation  = (leftChannel - rightChannel)
			
			let meterColor = dCS.pastelBlue
			
			
			
			
			HStack {
				VStack(spacing: 1) {
					//MARK: Digits
					HStack{
						
						ZStack {
							ForEach(dbNumbers, id: \.self) { db in
								let log = pow(10, db / 20.0)
								let dbint = Int(db)
								
								Text("\(dbint)")
									.font(.system(size: 7))
									.foregroundColor(.white)
									.frame(height: elementHeight)
									.offset(x: (elementWidth * log) - 5)
								
							}
							
						}
						
						Spacer()
					}
					Rectangle()
						.frame(width: elementWidth, height: elementHeight)
						.foregroundColor(dCS.darkerGray)
					
						.overlay(
							ZStack {
								//MARK: Marks
								HStack {
									ZStack{
										ForEach(dbNumbers, id: \.self) { db in
											let log = pow(10, db / 20.0)
											
											Rectangle()
												.foregroundColor(.white)
												.frame(width: 1, height: elementHeight)
												.offset(x: (elementWidth * log) )
												.opacity(0.4)
											
										}
									}
									Spacer()
								}
								
								
								//MARK: LEFT CHANNEL
								ZStack {
									//Average
									HStack {
										Rectangle()
										
											.foregroundColor(meterColor)
											.frame(width: leftChannel * elementWidth, height: elementHeight)
											.opacity(0.9)
										if leftChannel < 0.99 {
											Spacer()
										} else {
											Spacer()
												.frame(width: 0)
										}
										
									}
									//Peak
									HStack {
										Rectangle()
										
											.foregroundColor(meterColor)
											.frame(width: 2, height: elementHeight)
											.offset(x: leftPeak * elementWidth)
											.opacity(0.9)
										Spacer()
										
										
									}
								}
							}
						)
					Rectangle()
						.frame(width: elementWidth, height: elementHeight)
						.foregroundColor(dCS.darkerGray)
					
						.overlay(
							ZStack {
								//MARK: Marks
								HStack {
									ZStack{
										ForEach(dbNumbers, id: \.self) { db in
											let log = pow(10, db / 20.0)
											
											Rectangle()
												.foregroundColor(.white)
												.frame(width: 1, height: elementHeight)
												.offset(x: (elementWidth * log) )
												.opacity(0.4)
											
										}
									}
									Spacer()
								}
								
								//MARK: RIGHT CHANNEL
								ZStack {
									//Average
									HStack {
										Rectangle()
											.frame(width: rightChannel * elementWidth, height: elementHeight)
											.foregroundColor(meterColor)
											.opacity(0.9)
										if leftChannel < 0.99 {
											Spacer()
										} else {
											Spacer()
												.frame(width: 0)
										}
										
									}
									//Peak
									HStack {
										Rectangle()
										
											.foregroundColor(meterColor)
											.frame(width: 2, height: elementHeight)
											.offset(x: rightPeak * elementWidth)
											.opacity(0.9)
										Spacer()
										
									}
								}
							}
						)
					
					Rectangle()
						.frame(width: elementWidth, height: elementHeight)
						.foregroundColor(dCS.darkerGray)
					
						.overlay(
							HStack {
								ZStack {
									Rectangle()
										.frame(width: elementWidth / 100, height: elementHeight)
										.foregroundColor(.white)
									
									//MARK: CORRELATION
									Rectangle()
										.frame(width: 0.01 * elementWidth, height: elementHeight)
										.foregroundColor(meterColor)
										.offset(x: (-correlation * (elementWidth / 2)), y: 0)
									
								}
								
							}
						)
				}
			}
			
			
			
			
		})
	}
	//MARK: TRACK PICKER
	var tracksAssined: some View {
		Button {
			if appState == 1 {
				withAnimation(.smooth) {
					appState = 2
					prepareHaptix()
					doubleTap()
				}
				
			} else if appState == 2 {
				withAnimation(.snappy) {
					appState = 1
					prepareHaptix()
					doubleTap()
				}
				
				viewModel.audioEngineA.audioPlayer?.stop()
				viewModel.audioEngineB.audioPlayer?.stop()
				viewModel.isPlaying = false
				viewModel.normalized = false
				isCompensationAvailable = false
			}
		} label: {
			var volOffsetAInDB: String {
				 let decibelValue = 20 * log10(viewModel.audioEngineA.volumeOffset)
				return String(format: "%.2f dB", decibelValue)
			}
			
			var volOffsetBInDB: String {
				 let decibelValue = 20 * log10(viewModel.audioEngineB.volumeOffset)
				return String(format: "%.2f dB", decibelValue)
			}
			HStack {
				
				VStack {
					
					HStack {
						Text("\(viewModel.audioEngineA.track.title).\(viewModel.audioEngineA.track.format)")
							.foregroundColor(dCS.pastelPurpleLighter)
							.lineLimit(1)
						Spacer()
						
						if viewModel.normalized {
							Text(volOffsetAInDB)
						}
						
						Image(systemName: "a.circle.fill")
							.foregroundColor( loudnessAnalyzingStatus ? dCS.pastelRed : dCS.pastelBlue )
						
							.background(dCS.darkerGray, in: RoundedRectangle(cornerRadius: 12, style: .continuous ))
					}
					HStack {
						Text("\(viewModel.audioEngineB.track.title).\(viewModel.audioEngineB.track.format)")
							.foregroundColor(dCS.pastelPurpleLighter)
							.lineLimit(1)
						Spacer()
						
						if viewModel.normalized {
							Text(volOffsetBInDB)
						}
												
						Image(systemName: "b.circle.fill")
							.foregroundColor(loudnessAnalyzingStatus ? dCS.pastelRed : dCS.pastelBlue)
							.background(dCS.darkerGray, in: RoundedRectangle(cornerRadius: 12, style: .continuous ))
					}
				}
				.padding(10)
				.background(dCS.darkerGray ,in: RoundedRectangle(cornerRadius: 10))
			}
		}
	}
	//MARK: A/B BUTTON
	var abButton: some View {
		HStack {

			
			Button {
				withAnimation(.spring()) {
					if !isSelectedA {
						isSelectedA = true
						viewModel.audioEngineA.audioPlayer?.volume = viewModel.audioEngineA.volumeOffset
						viewModel.audioEngineB.audioPlayer?.volume = 0
//						print("A: \(String(describing: viewModel.audioEngineA.audioPlayer!.volume))")
//						print("B: \(String(describing: viewModel.audioEngineB.audioPlayer!.volume))")
					} else {
						isSelectedA = false
						viewModel.audioEngineA.audioPlayer?.volume = 0
						viewModel.audioEngineB.audioPlayer?.volume = viewModel.audioEngineB.volumeOffset
//						print("A: \(String(describing: viewModel.audioEngineA.audioPlayer!.volume))")
//						print("B: \(String(describing: viewModel.audioEngineB.audioPlayer!.volume))")
						
					}
				}
			} label: {
				
					ZStack {
						RoundedRectangle(cornerRadius: 75)
						
							.foregroundColor(dCS.darkerGray)
						HStack {
							if !isSelectedA {
								Spacer()
							}
							
							Circle()
								.padding(8)
								.foregroundColor(dCS.pastelBlue)
								.shadow(radius: 10)
							
							if isSelectedA {
								Spacer()
							}
							
							
						}
						
						
						HStack {
							
							Text("A")
								.bold()
								.font(.system(size: 60))
								.foregroundColor(isSelectedA ? dCS.darkerGray : dCS.lighterGray)
								.padding(39)
								.padding(.horizontal)
								
							Spacer()
							
							Text("B")
								.bold()
								.font(.system(size: 60))
								.foregroundColor(isSelectedA ? dCS.lighterGray : dCS.darkerGray)
								.padding(33)
								.padding(.horizontal)
								.offset(x: 4, y: 0)
							
							Spacer()
						}
					}
				
			}
			.frame(width: 300, height: 150)
			

		}
		
		

	}
	
	//MARK: JOG
	var jog: some View {
		HStack {
			
			ZStack {
				
				HStack(spacing: 40) {
					ForEach((0 ..< 9), id: \.self) { _ in
						Rectangle()
							.frame(width: 2)
							.foregroundColor(dCS.pastelPurpleLighter)
							.opacity(0.5)
							.shadow(radius: 3)
					}
				}
				.offset(x: jogOffset, y: 0)
				Rectangle().opacity(0.000001)
			}
			.gesture(
				DragGesture()
					.onChanged { value in

						if viewModel.isPlaying {
							viewModel.audioEngineA.audioPlayer?.pause()
							viewModel.audioEngineB.audioPlayer?.pause()
						}
						
						viewModel.audioEngineA.scrub(offsetTime: value.translation.width)
						viewModel.audioEngineB.scrub(offsetTime: value.translation.width)
						jogOffset = value.translation.width
						
						
						
					}
					.onEnded({ value in
						jogOffset = 0
						if viewModel.isPlaying {
							viewModel.audioEngineA.audioPlayer?.play()
							viewModel.audioEngineB.audioPlayer?.play()
						}
					})
			)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
	//MARK: PLAY BLOCK
	var playBlock: some View {
		ZStack {
			Button {
				if !viewModel.isPlaying {
					viewModel.playSong()
				} else {
					viewModel.pauseSong()
				}
				
				sharpTap()
			} label: {
				ZStack {
					Circle()
						.foregroundColor(dCS.pastelBlue)
						.blur(radius: 70)
						.opacity(1)
					Circle()
						.foregroundColor(dCS.darkerGray)
						.scaleEffect(1.1)
					Circle()
						.foregroundColor(dCS.pastelBlue)
						.shadow(radius: 10)
					
					
					if viewModel.isPlaying {
						Image(systemName: "pause.fill")
							.scaleEffect(3)
							.foregroundColor(dCS.bgColor)
					} else if viewModel.playbackPosition > viewModel.audioEngineA.duration {
						Image(systemName: "play.fill")
							.scaleEffect(3)
							.foregroundColor(dCS.bgColor)
					} else {
						Image(systemName: "play.fill")
							.scaleEffect(3)
							.foregroundColor(dCS.bgColor)
					}
				}
				.frame(height: 150)
				.scaleEffect(0.9)
				
			}
			
			HStack(alignment: .bottom) {
				
				VStack {
					Button {
						if !loudnessAnalyzingStatus {
							loudnessAnalyzingStatus = true
							sharpTap()
						}
						
	
					} label: {
						ZStack {
							Circle()
								.foregroundColor(dCS.pastelBlue)
	
							Image(systemName: "record.circle")
								.font(.system(size: 40))
								.foregroundColor(loudnessAnalyzingStatus ? dCS.pastelRed : dCS.bgColor)
								.shadow(radius: 10)
						}
						.frame(height: 75)
					}
					if isCompensationAvailable {
						Button {
							if !viewModel.normalized {
								viewModel.normalized = true
								viewModel.applyCompensation()
							} else {
								viewModel.normalized = false
								if isSelectedA {
									viewModel.audioEngineA.defaultVolumeOffset()
									viewModel.audioEngineB.audioPlayer?.volume = 0
								} else {
									viewModel.audioEngineA.audioPlayer?.volume = 0
									viewModel.audioEngineB.defaultVolumeOffset()
								}
								
								
							}
							
							doubleTap()
						} label: {
							ZStack {
								Circle()
									.foregroundColor(dCS.pastelBlue)
		
								Image(systemName: "equal.circle")
									.font(.system(size: 40))
									.foregroundColor(viewModel.normalized ? dCS.bgColor : dCS.lighterGray)
									.shadow(radius: 10)
							}
							.frame(height: 75)
						}
					}
					
				}
				.frame(width: 60)
				.offset(x: -20)
				
				
				
				
				Spacer()
				
				
				
				
				
				
				Button {
	
				} label: {
					ZStack {
						Circle()
							.foregroundColor(dCS.pastelBlue)
	
						Image(systemName: "bubble.right.fill")
							.foregroundColor(dCS.bgColor)
					}
					.frame(height: 75)
				}
				.frame(width: 60)
				.opacity(0.0)
			}
		}
		
		.padding()
	}
}

//MARK: SETUP/LIST PAGE
extension ABPlayerView {
	//MARK: SET PAGE  Structure
	var setPage: some View {
		VStack {
			if editState == false {
				HStack {
					newTrackButton
					tracksAssined
				}
				.padding(.horizontal)
				//MARK: LIST OF ALL TRACKS
				if !viewModel.allTracks.isEmpty {
					listOfTracks
						.padding(.horizontal)
				} else {
					Spacer()
					Text("Press + button to add tracks")
						.foregroundStyle(dCS.pastelPurpleLighter)
					Spacer()
				}
			}
			
			
			if viewModel.selectedForEditing.track.id != emptyTrack.id {
				VStack {
					if editState == true {
						editView
					}
					selectedTrackTitle
					LabelsBlock(vm: viewModel, isItABPage: false, isSelectedA: isSelectedA)
					ZStack {
						PositionView(vm: viewModel, engineNumber: 0)
						
						
						Wav(samples: viewModel.selectedForEditing.track.waveform)
							.opacity(0.4)
						
						
						if !editState {
							SectionsBlock(vm: viewModel, engineNumber: 0)
						} else {
							editMarkUpSections
						}
						
						
					}
						.clipShape(RoundedRectangle(cornerRadius: 10))
						.frame(height: 50)
					selectedTrackJog
						.frame(height: 50)
					
					
				}
				.padding()

				
			}
			
			Spacer()
			
		}
	}
	
	
	//MARK: ADD NEW TRACK
	var newTrackButton: some View {

		Button {
	
			isShowingDocumentPicker = true
		} label: {
			Image(systemName: "plus")
				.foregroundColor(dCS.pastelBlue)
				.font(.system(size: 30))
				.padding()
//				.background(dCS.darkerGray ,in: RoundedRectangle(cornerRadius: 10))
				.background(dCS.darkerGray ,in: Circle())
		}
		.fileImporter(isPresented: $isShowingDocumentPicker, allowedContentTypes: [.audio]) { result in
			do {
				let fileURL = try result.get()
				
				let documentsURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
				let destinationURL = documentsURL.appendingPathComponent("ABPro").appendingPathComponent("Tracks").appendingPathComponent(fileURL.lastPathComponent)
				
				
				if fileURL.startAccessingSecurityScopedResource(){
					
					// Save the file to the documents folder
					try FileManager.default.copyItem(at: fileURL, to: destinationURL)
					
					fileURL.stopAccessingSecurityScopedResource()
				}
				viewModel.addNewTrack(fileURL: destinationURL)
				
				
				func documentsURL() -> URL {
					FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
				}
			} catch {
				// Handle error
				print("Error: \(error)")
			}
			
			
		}
		
	}
	//MARK: LIST OF ALL TRACKS
	var listOfTracks: some View {
		
		ScrollView {

			ForEach(viewModel.allTracks) { track in
				
				HStack {
					if viewModel.audioEngineA.track.id == track.id {
						Image(systemName: "a.circle.fill")
							.foregroundColor(dCS.pastelBlue)
							.font(.system(size: 25))
						
					} else {
						Button {
							viewModel.switchTrackA(track: track)
							viewModel.audioEngineA.setupAudioPlayer()
							sharpTap()
							
							if isSelectedA {
								viewModel.audioEngineB.audioPlayer?.volume = 0
							} else {
								viewModel.audioEngineA.audioPlayer?.volume = 0
							}
						} label: {
							Image(systemName: "circle.dotted")
								.foregroundColor(dCS.pastelBlue)
								.opacity(0.7)
								.font(.system(size: 25))
						}
					}
					
					Spacer()
					
					
					
					
					ZStack {
						if viewModel.selectedForEditing.track.id == track.id {
							
							ZStack {
								RoundedRectangle(cornerRadius: 10)
									.foregroundColor(dCS.darkerGray)
								
							}
							
						}
						
						
						HStack {
							
							
							
							
							Text("\(track.title).\(track.format)")
								.foregroundColor(dCS.pastelPurpleLighter)
								.font(.system(size: 15))
								.lineLimit(1)
								.minimumScaleFactor(0.5)
								.padding()
								.onTapGesture {
									
									viewModel.selectedForEditing = AudioEngine(track: track)
//									sectionsForRenaming = viewModel.selectedForEditing.track.sections
									viewModel.selectedForEditing.setupAudioPlayer()
									viewModel.selectedForEditing.audioPlayer?.volume = 1
									sharpTap()
								}
								.onLongPressGesture(minimumDuration: 0.5) {
									showAlert = true
									doubleTap()
									
								}
							
							
							
							
							Spacer()
							
							
						}
					}
					
					
					
					
					
					
					
					Spacer()
					if viewModel.audioEngineB.track.id == track.id {
						Image(systemName: "b.circle.fill")
							.foregroundColor(dCS.pastelBlue)
							.font(.system(size: 25))
					} else {
						Button {
							viewModel.switchTrackB(track: track)
							viewModel.audioEngineB.setupAudioPlayer()
							sharpTap()
							
							if isSelectedA {
								viewModel.audioEngineB.audioPlayer?.volume = 0
							} else {
								viewModel.audioEngineA.audioPlayer?.volume = 0
							}
							
						} label: {
							Image(systemName: "circle.dotted")
								.foregroundColor(dCS.pastelBlue)
								.font(.system(size: 25))
								.opacity(0.7)
						}
						
					}
				}
				.alert("Delete track?",isPresented: $showAlert) {
					Button(role: .destructive) {
						viewModel.deleteTrack(track: track)
						sharpTap()
						
					} label: {
						Text("Delete")
					}

				}
			}
		}
		.scrollIndicators(.hidden)
	}
	//MARK: SELECTED TRACK TITTLE
	var selectedTrackTitle: some View {
		HStack {
			Button {
					if !(viewModel.selectedForEditing.audioPlayer?.isPlaying ?? false) {
						viewModel.selectedForEditing.audioPlayer?.play()
					} else {
						viewModel.selectedForEditing.audioPlayer?.pause()
					}
				} label: {
					ZStack {
						Circle()
							.foregroundColor(dCS.pastelBlue)
							.shadow(radius: 10)

						if  viewModel.selectedForEditing.audioPlayer?.isPlaying ?? false {
							Image(systemName: "pause.fill")
								.scaleEffect(1.8)
								.foregroundColor(dCS.bgColor)
						} else {
							Image(systemName: "play.fill")
								.scaleEffect(1.8)
								.foregroundColor(dCS.bgColor)
						}
					}
					.frame(height: 50)
				}
			
			Spacer()
			if editState {
				
				Button {
					viewModel.copySections()
				} label: {
					ZStack {
						Circle()
							.foregroundColor(dCS.pastelBlue)
							.shadow(radius: 10)
						Text("COPY")
							.font(.system(size: 13))
							.foregroundColor(dCS.bgColor)
					}
					.frame(height: 50)
				}
				
				Button {
					viewModel.pasteSections()
//					viewModel.selectedForEditing.track.sections = sectionsForRenaming
				} label: {
					ZStack {
						Circle()
							.foregroundColor(dCS.pastelBlue)
							.shadow(radius: 10)
						Text("PASTE")
							.font(.system(size: 13))
							.foregroundColor(dCS.bgColor)
					}
					.frame(height: 50)
				}
	
			} else {
				Text("\(viewModel.selectedForEditing.track.title).\(viewModel.selectedForEditing.track.format)")
					.foregroundColor(dCS.pastelPurpleLighter)
					.font(.title2)
			}
			
			
			Spacer()
			
			Button {
				if editState {
					
					viewModel.applyChanges()
					editState = false
				} else {
					editState = true
				}
				
				sharpTap()
			} label: {
				ZStack {
					Circle()
						.foregroundColor(dCS.pastelBlue)
						.shadow(radius: 10)
					if editState == false {
						Text("EDIT")
							.font(.system(size: 13))
							.foregroundColor(dCS.bgColor)
					} else {
						Text("APPLY")
							.font(.system(size: 13))
							.foregroundColor(dCS.bgColor)
					}
				}
				.frame(height: 50)
			}
		}
		
		
	}
	//MARK: MarkUp View
	var editMarkUpSections: some View {

		GeometryReader { geometry in
			
			let blockWidth = (geometry.size.width)
			let duration = (viewModel.selectedForEditing.duration)
			
			ZStack {
				
				
				let track = viewModel.selectedForEditing.track
				
				
				ForEach(track.sections.sorted(by: { $0.startTime < $1.startTime } )) { section in
					let sectionStart = section.startTime
					let sectionOffset = blockWidth / duration
					
					Rectangle()
						.foregroundColor(section.color)
						.frame(width: 4)
						.overlay {
							RoundedRectangle(cornerRadius: 10)
								.stroke(lineWidth: 1)
								.foregroundColor(.black)
						}
					
						.offset(x: -(blockWidth / 2))
						.offset(x: sectionStart * sectionOffset)
					
				}
				
			}
			.frame(width: blockWidth)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
	//MARK: SELECTED TRACK JOG
	var selectedTrackJog: some View {
		HStack {
			
			ZStack {
				
				HStack(spacing: 40) {
					ForEach((0 ..< 9), id: \.self) { _ in
						Rectangle()
							.frame(width: 2)
							.foregroundColor(dCS.pastelPurpleLighter)
							.opacity(0.5)
					}
				}
				.offset(x: jogOffset, y: 0)
				Rectangle().opacity(0.000001)
			}
			.gesture(
				DragGesture()
					.onChanged { value in
						viewModel.selectedForEditing.audioPlayer?.rate = 0.5
						
						viewModel.selectedForEditing.scrub(offsetTime: value.translation.width)
						jogOffset = value.translation.width
						
						
					}
					.onEnded({ value in
						jogOffset = 0
						viewModel.selectedForEditing.audioPlayer?.rate = 1
						
					})
			)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
	//MARK: SELECTED TRACK EDITOR
	var editView: some View {
		VStack {

			let track = viewModel.selectedForEditing.track
			

			Text("\(track.title).\(track.format)")
				.foregroundColor(dCS.pastelPurpleLighter)
				.font(.title2)
			
			Spacer()
			
			
			ScrollView {
			
				
				ForEach(track.sections.indices, id: \.self) { index in
					let colorEdit = false

					HStack {
						
						Button {
						
						} label: {
							HStack {
								
								ZStack{
									Circle()
										.foregroundColor(dCS.darkerGray)
										.frame(height: 25)
										.scaleEffect(1.5)
									Circle()
										.foregroundColor(track.sections[index].color)
										.frame(height: 30)
										.shadow(radius: 10)
								}
								
							}
						}
						

						if !colorEdit {
							
							
							Text("Section")
								.foregroundColor(dCS.pastelPurpleLighter)
								.padding(.horizontal)
							Spacer()
							
							
							
							Image(systemName: "play.fill")
								.foregroundColor(.white)
								.font(.system(size: 20))
								.opacity(0.7)
								.padding(.horizontal)
								
								.gesture(
									DragGesture(minimumDistance: 0)
										.onChanged({ _ in
											sharpTap()
											viewModel.selectedForEditing.playFrom(time: viewModel.selectedForEditing.track.sections[index].startTime)
											viewModel.selectedForEditing.audioPlayer?.play()
										})
										
										.onEnded { _ in
											viewModel.selectedForEditing.audioPlayer?.pause()
											
										}
								)

							
							
						} else {
							Spacer()
							
							colorEditingView

										
						}
					}
					.padding()
					.background(.black)
					.clipShape(RoundedRectangle(cornerRadius: 10))
				}
				
			}
			.scrollIndicators(.hidden)
			
			HStack {
				//MARK: ADD BUTTON
				Button {
					
					viewModel.addSection(track: track)
					viewModel.selectedForEditing.track.fillMarkUpSections()
//					sectionsForRenaming = viewModel.selectedForEditing.track.sections
					sharpTap()
				} label: {
					HStack {
						ZStack{
							Circle()
								.foregroundColor(dCS.darkerGray)
								.frame(height: 25)
								.scaleEffect(1.5)
							Circle()
								.foregroundColor(dCS.lighterGray)
								.frame(height: 30)
								.shadow(radius: 10)
							Image(systemName: "plus")
								.foregroundColor(.white)
								.fontWeight(.bold)
								.scaleEffect(1.3)
								.opacity(0.7)
						}
						
						Text("ADD SECTION")
							.foregroundColor(dCS.pastelPurpleLighter)
							.padding(.horizontal)
						Spacer()
						
					}
					.padding()
					.background(.black)
					.clipShape(RoundedRectangle(cornerRadius: 10))
					
				}
				
				
			}
		}
	}
	
	var colorEditingView: some View {
		HStack {
			//MARK: ALL CHOOSABLE COLORS
			ForEach(allColors.indices, id: \.self) {  index in
				@State var selectedColor = dCS.bgColor
				//MARK: COLOR SELECT BUTTON
				Button {
//					viewModel.selectedForEditing.track.sections[index].color = allColors[index]
					

				} label: {
					ZStack{

						if selectedColor == allColors[index] {
							Circle()
								.foregroundColor(.white)
								.frame(height: 25)
								.scaleEffect(1.5)
						} else {
							Circle()
								.foregroundColor(dCS.darkerGray)
								.frame(height: 25)
								.scaleEffect(1.5)
						}

						Circle()
							.foregroundColor(allColors[index])
							.frame(height: 30)
							.shadow(radius: 10)
					}
					.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 4))

				}
			}
		}
		
	}
}



#Preview {
	ABPlayerView()
}
