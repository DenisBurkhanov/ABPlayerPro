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
	@State var haptix = Haptix()
	
	@State private var isShowingDocumentPicker = false
	@State private var showAlert = false
	
	@State var loudnessAnalyzingStatus = false
	@State var loudnessTimer = 0
	@State var analizerCounter: TimeInterval = 0
	@State var analizerStatus = false
	@State var isCompensationAvailable = false
	
	@State private var isSelectedA = true
	@State private var duration: TimeInterval = 0.0
	
	@State private var nameOffset: CGFloat = 0
	@State private var scale: CGFloat = 0
	@State private var selectedTrackNumber = 0
	@State private var editState = false
	@State private var isKeyboardVisible = false
	
	@State private var volA: CGFloat = 0
	@State private var volB: CGFloat = 0
	@State private var isGearShown: Bool = false
	@State private var gearAngle: Double = 0
	@State var libChecker = LibChecker()
	
	var dbNumbers: [Double] = [-30, -20, -14, -12, -10, -7, -5, -3, -2, -1, 0]
	
	let timer = Timer.publish(every: 0.0001, on: .main, in: .common).autoconnect()
	
	
	
	
	
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
			haptix.prepareHaptix()
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
					haptix.sharpTap()
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
					haptix.sharpTap()
					isGearShown = true
					DispatchQueue.global().async {
						viewModel.createDataFolderIfNeeded()
						libChecker.checkIfFilesExist()
						DispatchQueue.main.async {
							withAnimation {
								isGearShown = false
								viewModel.allTracks = libChecker.bufferForAllTRacks
								appState = 1
								haptix.doubleTap()
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

			
			MeterBridge(vm: viewModel, engineNumber: isSelectedA ? 1 : 2)
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
				
				
					ZStack {
						if viewModel.audioEngineA.track.id != emptyTrack.id {
							WaveformView(samples: viewModel.audioEngineA.track.waveform)
								.opacity(isSelectedA ? 0.7 : 0.0)
						}
						
						if viewModel.audioEngineB.track.id != emptyTrack.id {
							WaveformView(samples: viewModel.audioEngineB.track.waveform)
								.opacity(isSelectedA ? 0.0 : 0.7)
						}
					
				}
					
				SectionsBlock(vm: viewModel, engineNumber: isSelectedA ? 1 : 2)
				
				
			}
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.padding(.horizontal)
				
			Jog(vm: viewModel, isItABPage: true)
				.padding(.horizontal)
				.frame(height: 65)
			
			playBlock
				.scaleEffect(0.9)
				.padding(.horizontal)
		}
	}
	
	
	
	//MARK: TRACK PICKER
	var tracksAssined: some View {
		Button {
			if appState == 1 {
				withAnimation(.smooth) {
					appState = 2
//					prepareHaptix()
					haptix.doubleTap()
				}
				
			} else if appState == 2 {
				withAnimation(.snappy) {
					appState = 1
//					prepareHaptix()
					haptix.doubleTap()
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
	//MARK: PLAY BLOCK
	var playBlock: some View {
		ZStack {
			Button {
				if !viewModel.isPlaying {
					viewModel.playSong()
				} else {
					viewModel.pauseSong()
				}
				
				haptix.sharpTap()
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
							haptix.sharpTap()
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
						.frame(height: 65)
					}
					if isCompensationAvailable {
						Button {
							if !viewModel.normalized {
								viewModel.normalized = true
//								viewModel.audioEngineA.audioPlayer?.pause()
//								viewModel.audioEngineB.audioPlayer?.pause()
//								viewModel.isPlaying = false
								viewModel.applyCompensation()
								if isSelectedA {
									viewModel.audioEngineB.audioPlayer?.volume = 0
								} else {
									viewModel.audioEngineA.audioPlayer?.volume = 0
								}
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
							
							haptix.doubleTap()
						} label: {
							ZStack {
								Circle()
									.foregroundColor(dCS.pastelBlue)
		
								Image(systemName: "equal.circle")
									.font(.system(size: 40))
									.foregroundColor(viewModel.normalized ? dCS.bgColor : dCS.lighterGray)
									.shadow(radius: 10)
							}
							.frame(height: 65)
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
				
				//MARK: Header
				HStack {
					newTrackButton
					tracksAssined
				}
				.padding(.horizontal)
				
				//MARK: LIST OF ALL TRACKS or TEXT
				if !viewModel.allTracks.isEmpty {
					listOfTracks
						.padding(.horizontal)
				} else {
					Spacer()
					Text("Press + button to add tracks")
						.foregroundStyle(dCS.pastelPurpleLighter)
					Spacer()
				}
				
				if viewModel.selectedForEditing.track.id != emptyTrack.id {
					
					basementNormalView //Polezno
						.padding(.horizontal)
				}
				
			} else {
		
				trackNameTitleView
				
				Spacer()
				editView
					.padding()
				if !isKeyboardVisible{
					basementEditView
						.padding(.horizontal)
				}
				
				
			}
			
			
			
		}
		.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
			self.isKeyboardVisible = true
		}
		.onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
			self.isKeyboardVisible = false
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
							haptix.sharpTap()
							
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
									haptix.sharpTap()
								}
								.onLongPressGesture(minimumDuration: 0.5) {
									showAlert = true
									haptix.doubleTap()
									
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
							haptix.sharpTap()
							
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
						haptix.sharpTap()
						
					} label: {
						Text("Delete")
					}

				}
			}
		}
		.scrollIndicators(.hidden)
	}
	//MARK: SELECTED TRACK TITTLE
	var basementNormalView: some View {
		VStack{
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
				
				trackNameTitleView
				
				Spacer()
				
				Button {
					editState = true
					haptix.sharpTap()
				} label: {
					ZStack {
						Circle()
							.foregroundColor(dCS.pastelBlue)
							.shadow(radius: 10)
						Text("EDIT")
							.font(.system(size: 13))
							.foregroundColor(dCS.bgColor)
					}
					.frame(height: 50)
				}
			}
			
			LabelsBlock(vm: viewModel, isItABPage: false, isSelectedA: isSelectedA)
			ZStack {
				PositionView(vm: viewModel, engineNumber: 0)
				
				
				WaveformView(samples: viewModel.selectedForEditing.track.waveform)
					.opacity(0.4)
				
				
				if !editState {
					SectionsBlock(vm: viewModel, engineNumber: 0)
				} else {
					editMarkUpSections
				}
				
				
			}
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.frame(height: 50)
			Jog(vm: viewModel, isItABPage: false)
				.frame(height: 50)

		}
		
		
	}
	var basementEditView: some View {
		VStack {
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
				
				Spacer()
				
				Button {
					viewModel.applyChanges()
					editState = false
					haptix.sharpTap()
				} label: {
					ZStack {
						Circle()
							.foregroundColor(dCS.pastelBlue)
							.shadow(radius: 10)
						
						Text("APPLY")
							.font(.system(size: 13))
							.foregroundColor(dCS.bgColor)
						
					}
					.frame(height: 50)
				}
			}
			
			LabelsBlock(vm: viewModel, isItABPage: false, isSelectedA: isSelectedA)
			ZStack {
				PositionView(vm: viewModel, engineNumber: 0)
				
				
				WaveformView(samples: viewModel.selectedForEditing.track.waveform)
					.opacity(0.4)
				
				
				if !editState {
					SectionsBlock(vm: viewModel, engineNumber: 0)
				} else {
					editMarkUpSections
				}
				
				
			}
				.clipShape(RoundedRectangle(cornerRadius: 10))
				.frame(height: 50)
			Jog(vm: viewModel, isItABPage: false)
				.frame(height: 50)
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
	//MARK: SELECTED TRACK EDITOR
	var editView: some View {
		VStack {

			let track = viewModel.selectedForEditing.track
		
			
			//MARK: LIST OF SECTIOS
			ScrollView {
				
				
				ForEach(track.sections.indices, id: \.self) { index in

					SectionCardView(vm: viewModel, sectionIndex: index)
				}
				
			}
			.scrollIndicators(.hidden)
			
			
			//MARK: ADD NEW SECTION BUTTON
			if !isKeyboardVisible {
				Button {
					
					viewModel.addSection(track: track)
					viewModel.selectedForEditing.track.fillMarkUpSections()
					haptix.sharpTap()
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
	var trackNameTitleView: some View {
		Text("\(viewModel.selectedForEditing.track.title).\(viewModel.selectedForEditing.track.format)")
			.foregroundColor(dCS.pastelPurpleLighter)
			.font(.title2)
			.lineLimit(1)
			.minimumScaleFactor(0.5)
	}

}

struct SectionCardView: View {
	@ObservedObject var vm: ViewModel
	@State var colorEdit = false
	
	let allColors = [ dCS.lighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	
	var sectionIndex: Int
	
	
	var body: some View {
		HStack {
			Button {
				colorEdit.toggle()
			} label: {
				HStack {
					
					ZStack{
						Circle()
							.foregroundColor(dCS.darkerGray)
							.frame(height: 25)
							.scaleEffect(1.5)
						Circle()
							.foregroundColor(vm.selectedForEditing.track.sections[sectionIndex].color)
							.frame(height: 30)
							.shadow(radius: 10)
					}
					
				}
			}
			
			if !colorEdit {
				textEditView
			} else {
				colorEditView
			}
		}
			.padding()
			.background(.black)
			.clipShape(RoundedRectangle(cornerRadius: 10))
	}
	var textEditView: some View {
		HStack {
			
			TextField("Section", text: $vm.selectedForEditing.track.sections[sectionIndex].title)
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
							vm.selectedForEditing.playFrom(time: vm.selectedForEditing.track.sections[sectionIndex].startTime)
							vm.selectedForEditing.audioPlayer?.play()
						})
					
						.onEnded { _ in
							vm.selectedForEditing.audioPlayer?.pause()
							
						}
				)
		}
	}
	var colorEditView: some View {
		HStack {
		
			Spacer()
			//MARK: ALL CHOOSABLE COLORS
			ForEach(allColors.indices, id: \.self) {  index in
				
				//MARK: COLOR SELECT BUTTON
				Button {
					
					vm.selectedForEditing.track.sections[sectionIndex].color = allColors[index]
					colorEdit = false

				} label: {
					ZStack{

						if allColors[index] == vm.selectedForEditing.track.sections[sectionIndex].color {
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
	init(vm: ViewModel, sectionIndex: Int) {
		self.vm = vm
		self.sectionIndex = sectionIndex
	}
}


#Preview {
	ABPlayerView()
}
