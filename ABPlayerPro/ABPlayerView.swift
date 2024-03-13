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



class ViewModel: ObservableObject {
	

	@Published var allTracks: [ AudioTrack ] = []
	
	

	
	
	@Published var audioEngineA = AudioEngine()
	@Published var audioEngineB = AudioEngine()
	@Published var selectedForEditing = AudioEngine()

	
	@Published var waveformModel = WaveformModel(url: emptyTrack.filePath)
	
	
	
	@Published var isPlaying = false
	@Published var isLooped = false
	@Published var playbackPosition: TimeInterval = 0.0
	@Published var normalized = false
	
	let allColors = [ dCS.lighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	var copySectionsBuffer: [Section] = []

	
	let formatter = DateComponentsFormatter()
	
	
	
	
	func switchTrackA(track: AudioTrack) {
		audioEngineA = AudioEngine(track: track)
	}
	func switchTrackB(track: AudioTrack) {
		audioEngineB = AudioEngine(track: track)
	}
	
	func playSong() {
		audioEngineA.audioPlayer?.play()
		audioEngineB.audioPlayer?.play()
		
		isPlaying = true
		audioEngineA.isPlaying = isPlaying
		audioEngineB.isPlaying = isPlaying
		

	}
	func pauseSong() {
		audioEngineA.audioPlayer?.pause()
		audioEngineB.audioPlayer?.pause()
		isPlaying = false
		audioEngineA.isPlaying = isPlaying
		audioEngineB.isPlaying = isPlaying
		
	}
	func playFrom(time: TimeInterval ) {
		audioEngineA.playFrom(time: time)
		audioEngineB.playFrom(time: time)
	}
	func selectedTrackPlayFrom(time: TimeInterval ) {
		selectedForEditing.playFrom(time: time)
		
	}
	func copySections() {
		copySectionsBuffer = selectedForEditing.track.sections
	}
	func pasteSections() {

		selectedForEditing.track.sections = copySectionsBuffer
	}
	func applyChanges() {
		

		let idValue = selectedForEditing.track.id
		for _ in allTracks {
			if let index = allTracks.firstIndex(where: { $0.id == idValue }) {
				
				allTracks.remove(at: index)
				print(allTracks.count)
				allTracks.append(selectedForEditing.track)
				print(allTracks.count)
			}
		}
		
	}

	
	func applyCompensation() {
		let avgA = audioEngineA.resultAvgBuffer
		let avgB = audioEngineB.resultAvgBuffer
		if avgA > avgB {
			print("A > B")
			let difference = avgA - avgB
						
			audioEngineA.adjustVolume( by: Float(difference))
			audioEngineB.defaultVolumeOffset()
		} else {
			print("B > A")
			let difference = avgB - avgA
			
			audioEngineB.adjustVolume( by: Float(difference))
			audioEngineA.defaultVolumeOffset()
		}
	}
	
	func addSection(track: AudioTrack) {
		if track.sections.isEmpty && selectedForEditing.playbackPosition != 0 {
			print("Add section non-zero condition")
			selectedForEditing.track.sections.append(Section(title: "Section", startTime: 0, endTime: selectedForEditing.playbackPosition, color: allColors.randomElement() ?? dCS.bgColor))
		}
		selectedForEditing.track.sections.append(Section(title: "Section", startTime: selectedForEditing.playbackPosition,endTime: selectedForEditing.duration, color: allColors.randomElement() ?? dCS.bgColor))
	}
	func removeSection(track: AudioTrack, id: UUID) {
		
	
	}

	
	
	//files management
	func addNewTrack(fileURL: URL){
		
		
//		let fileURL = destinationURL.appendingPathComponent(file)
		let fileName = fileURL.lastPathComponent
		let title = fileName.replacingOccurrences(of: ".\(fileURL.pathExtension)", with: "")
		let format = fileURL.pathExtension
		waveformModel = WaveformModel(url: fileURL)
		let wave = waveformModel.samples
		
		
		let audioTrack = AudioTrack(filePath: fileURL, title: title, format: format, waveform: wave)
		
		
		
		self.allTracks.append(audioTrack)
		
		
		
	}
	
	func deleteTrack(track: AudioTrack){
		do {
			try FileManager.default.removeItem(at: track.filePath)
			for (index, value) in allTracks.enumerated() {
				if value.id == track.id {
					allTracks.remove(at: index)
				}
			}
			
			print("\(track.title) gone")
		} catch {
			print("Some error")
		}
	}
	
	func createDataFolderIfNeeded() {
			
		let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
		let dataFolderURL = documentsDirectory.appendingPathComponent("ABPro").appendingPathComponent("Tracks")

			do {
				// Check if the folder already exists
				var isDirectory: ObjCBool = false
				if !FileManager.default.fileExists(atPath: dataFolderURL.path, isDirectory: &isDirectory) {
					// If not, create it
					try FileManager.default.createDirectory(at: dataFolderURL, withIntermediateDirectories: true, attributes: nil)
					print("Data folder created successfully")
					print(dataFolderURL)
					
				} else {
					print("Data folder already exists")
					print(dataFolderURL)
				}
			} catch {
				print("Error creating data folder: \(error.localizedDescription)")
			}
		}
	func analizeTrackWaves(track: AudioTrack) {
		waveformModel = WaveformModel(url: track.filePath)
		let wave = waveformModel.samples
		for (index, value) in allTracks.enumerated() {
			if value.id == track.id {
				allTracks.remove(at: index)
			}
			
		}
		let audioTrack = AudioTrack(filePath: track.filePath, title: track.title, format: track.format, waveform: wave)
		allTracks.append(audioTrack)
	}
	
}

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
			
//			viewModel.createDataFolderIfNeeded()
//			viewModel.checkIfFilesExist()
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


extension ABPlayerView {
	
	//MARK: A/B PAGE
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
				
			
			labelLayer
				.padding(.horizontal)

			ZStack {
				
				positionView
				
					
				sections
				
				if track.title != "Empty track" {
				
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
	//MARK: Labels
	var labelLayer: some View {
		HStack {
			let position = isSelectedA ? viewModel.audioEngineA.positionInSeconds : viewModel.audioEngineB.positionInSeconds
			Text(position)
				.foregroundColor(dCS.pastelPurpleLighter)
			
			Spacer()
			
			
			if (isSelectedA ? viewModel.audioEngineA.currentSectionLabel : viewModel.audioEngineB.currentSectionLabel) != "" {
				Text(isSelectedA ? viewModel.audioEngineA.currentSectionLabel : viewModel.audioEngineB.currentSectionLabel)
					.foregroundColor(dCS.pastelPurpleLighter)
					.padding(.horizontal)
					.background(dCS.darkerGray)
					.clipShape(RoundedRectangle(cornerRadius: 10))
			}
			
			
			Spacer()
			
			Text(isSelectedA ? viewModel.audioEngineA.durationInSeconds : viewModel.audioEngineB.durationInSeconds)
				.foregroundColor(dCS.pastelPurpleLighter)
		}
	}
	//MARK: position
	var positionView: some View {

		GeometryReader { geometry in
			let position = viewModel.playbackPosition
			let blockWidth = (geometry.size.width)
			let duration = (isSelectedA ? viewModel.audioEngineA.duration : viewModel.audioEngineB.duration)
			let progressBarWidth = ((blockWidth /  duration ) * position)



			ZStack {

				HStack {

					LinearGradient(colors: [ Color.black, Color.white], startPoint: .leading, endPoint: .trailing)
						.frame(width: (progressBarWidth > 0 ? progressBarWidth : 0 ))



					if progressBarWidth < blockWidth {
						Spacer()
					}
				}
			}
			
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
		
	}
	//MARK: SECTIONS
	var sections: some View {

		GeometryReader { geometry in
			let padding: CGFloat = 0.0000001
			let blockWidth = (geometry.size.width)
			let duration = (isSelectedA ? viewModel.audioEngineA.duration : viewModel.audioEngineB.duration)
			
			ZStack {

//				if isSelectedA {
//					let wave = viewModel.audioEngineA.track.waveform
//
//					ZStack {
//						RoundedRectangle(cornerRadius: 1)
//							.opacity(0.0)
//						HStack(alignment: .center, spacing: 0) {
//							ForEach(wave, id: \.self) { height in
//
//									RoundedRectangle(cornerRadius: 1)
//										.foregroundColor(.white)
//										.frame(height: (height * 100 ))
//							}
//						}
//					}
//					.opacity(0.4)
//
//				}


				HStack(spacing: 0) {
					let track = isSelectedA ? viewModel.audioEngineA.track : viewModel.audioEngineB.track

					
						ForEach(track.sections.sorted(by: { $0.startTime < $1.startTime } )) { section in
							let sectionStart = section.startTime
							let sectionEnd = ((blockWidth / (duration - padding) ) * (section.endTime - sectionStart ))



							sectionView(section: section)
								.frame(width: (sectionEnd >= 0 ? sectionEnd : 0 ))

								.onTapGesture {
									viewModel.playFrom(time: section.startTime)
									dullTap()

								}
//								.onLongPressGesture(minimumDuration: 0.5) {
//									var newValue = section
//									newValue.loop.toggle()
//									track.sections[key] = newValue
////									viewModel.loopSection(section: section, loopOn: newValue.loop)
//
//								}
						}
				}
			}
			.frame(width: blockWidth)
			
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
						
						@State var offsetCounter: CGFloat = 0
						offsetCounter = value.translation.width
						if offsetCounter > 20 {
							offsetCounter = 0
							dullTap()
						}
						
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


extension ABPlayerView {
	//MARK: SET PAGE
	var setPage: some View {
		VStack {
			if editState == false {
				HStack {
					newTrackButton
					tracksAssined
				}
				.padding(.horizontal)
				
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
					selectedTrackLabelLayer
					ZStack {
						selectedTrackPositionView
						selectedTrackSections
						Wav(samples: viewModel.selectedForEditing.track.waveform)
							.opacity(0.4)
					}
						.frame(height: 50)
					selectedTrackJog
						.frame(height: 50)
//					selectedTrackButtons
					
				}
				.padding()
//				.background(dCS.darkerGray)
//				.background(in: RoundedRectangle(cornerRadius: 10))
				
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
//			ForEach(viewModel.allTracks.sorted(by: { $0.title < $1.title })) { track in
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
								.padding()
								.onTapGesture {
									
									viewModel.selectedForEditing = AudioEngine(track: track)
									
									viewModel.selectedForEditing.setupAudioPlayer()
									viewModel.selectedForEditing.audioPlayer?.volume = 1
									sharpTap()
								}
								.onLongPressGesture(minimumDuration: 0.5) {
									showAlert = true
									doubleTap()
									
								}
							
							
							
							
							Spacer()
							
							//							Button {
							//
							//
							//							} label: {
							//								if track.waveform.isEmpty {
							//									Text("ANALYZING")
							//										.scaleEffect(0.5)
							//										.opacity(0.7)
							//										.foregroundColor(dCS.pastelPurpleLighter)
							//										.padding(1)
							//
							//								} else {
							//									Image(systemName: "waveform")
							//										.foregroundColor(dCS.pastelPurpleLighter)
							//										.padding(.horizontal)
							//								}
							//							}
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
//					viewModel.selectedForEditing.track.sections = viewModel.editSectionsBuffer
					viewModel.applyChanges()
					editState = false
				} else {
					editState = true
//					viewModel.editSectionsBuffer = viewModel.selectedForEditing.track.sections
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
	//MARK: SELECTED TRACK LABLES
	var selectedTrackLabelLayer: some View {
		HStack {
			Text(viewModel.selectedForEditing.positionInSeconds)
				.foregroundColor(dCS.pastelPurpleLighter)
			
			Spacer()
			
			
			if (viewModel.selectedForEditing.currentSectionLabel) != "" {
				Text(viewModel.selectedForEditing.currentSectionLabel)
					.foregroundColor(dCS.pastelPurpleLighter)
					.padding(.horizontal)
					.background(dCS.darkerGray)
					.clipShape(RoundedRectangle(cornerRadius: 10))
			}
			
			
			Spacer()
			
			Text(viewModel.selectedForEditing.durationInSeconds)
				.foregroundColor(dCS.pastelPurpleLighter)
		}
	}
	//MARK: SELECTED TRACK SECTIONS
	var selectedTrackSections: some View {

		GeometryReader { geometry in
			let padding: CGFloat = 0.0000001
			let blockWidth = (geometry.size.width)
			let duration = (viewModel.selectedForEditing.duration)
			
			ZStack {




				HStack(spacing: 0) {
					let track = viewModel.selectedForEditing.track

					
						ForEach(track.sections.sorted(by: { $0.startTime < $1.startTime } )) { section in
							let sectionStart = section.startTime
							let sectionEnd = ((blockWidth / (duration - padding) ) * (section.endTime - sectionStart ))
							let sectionDuration = sectionEnd - sectionStart



							sectionView(section: section)
								.frame(width: (sectionEnd >= 0 ? sectionEnd : 0 ))

								.onTapGesture {
									viewModel.selectedTrackPlayFrom(time: section.startTime)
									dullTap()
								}
								.gesture(
									DragGesture(minimumDistance: sectionDuration, coordinateSpace: .local)
										.onChanged { gesture in
											if gesture.translation.width < 0 {
												
											} else {
												
											}
											
										}
										.onEnded { _ in
											
											
										}
								)
							
								
						}
				}
			}
			.frame(width: blockWidth)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
	//MARK: SELECTED TRACK CURRENT POSITION
	var selectedTrackPositionView: some View {

		GeometryReader { geometry in
			let position = viewModel.selectedForEditing.playbackPosition
			let blockWidth = (geometry.size.width)
			let duration = (viewModel.selectedForEditing.duration)
			let progressBarWidth = ((blockWidth /  duration ) * position)



			ZStack {

				HStack {

					LinearGradient(colors: [ Color.black, Color.white], startPoint: .leading, endPoint: .trailing)
						.frame(width: (progressBarWidth > 0 ? progressBarWidth : 0 ))



					Spacer()
				}
			}
			
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
			
				
				ForEach(viewModel.selectedForEditing.track.sections.sorted(by: { $0.startTime < $1.startTime })) { section in
					var colorEdit = false
//
					
					
//					editSectionsView( section: section)

					HStack {
						
						Button {
							if colorEdit {
								colorEdit = false
								print("Color edit is off now")
								
							} else {
								colorEdit = true
								print("Color edit is on now")
							}
							
							
						} label: {
							HStack {
								
								ZStack{
									Circle()
										.foregroundColor(dCS.darkerGray)
										.frame(height: 25)
										.scaleEffect(1.5)
									Circle()
										.foregroundColor(section.color)
										.frame(height: 30)
										.shadow(radius: 10)
								}
								
							}
						}
						

						if !colorEdit {
							
							
							Text(section.title)
								.foregroundColor(dCS.pastelPurpleLighter)
								.padding(.horizontal)
							Spacer()
							
							
							Button {
								
							} label: {
								
								ZStack {
									Circle()
										.foregroundColor(dCS.pastelRed)
										.frame(height: 30)
										.opacity(0.4)
									Image(systemName: "xmark")
										.foregroundColor(.white)
										.opacity(0.7)
								}
								
							}

							
							
						} else {
							Spacer()
							
							sectionEditingView

										
						}
					}
					.padding()
					.background(.black)
					.clipShape(RoundedRectangle(cornerRadius: 10))
				}
				
			}
			.scrollIndicators(.hidden)
			
			HStack {
				
				Button {
					
					viewModel.addSection(track: track)
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
	
	var sectionEditingView: some View {
		HStack {
			
			ForEach(allColors, id: \.self) {  color in
				var selectedColor = dCS.bgColor
				Button {
					selectedColor = color
					print(selectedColor)

				} label: {
					ZStack{

						if color == selectedColor {
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
							.foregroundColor(color)
							.frame(height: 30)
							.shadow(radius: 10)
					}
					.padding(EdgeInsets(top: 0, leading: 3, bottom: 0, trailing: 4))

				}
			}
		}
		
	}
}


struct ABPlayerView_Previews: PreviewProvider {
    static var previews: some View {
		ABPlayerView()
		
    }
}


struct Wav: View {
	var samples: SampleBuffer
	var body: some View {
		GeometryReader { geo in
			
			
			Waveform(samples: samples)
				.foregroundColor(.white)
				.frame(width: geo.size.width, height: (geo.size.height * 2))
			
				.mask(
					Rectangle()
						.frame(height: geo.size.height)
						.offset(x: 0, y: -(geo.size.height / 2))
				)
		}
		
	}
	init(samples: SampleBuffer) {
		self.samples = samples
	}
}
