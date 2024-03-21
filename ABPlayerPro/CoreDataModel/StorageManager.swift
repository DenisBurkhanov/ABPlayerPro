//
//  StorageManager.swift
//  ABPlayerPro
//
//  Created by Денис Бурханов on 19.03.2024.
//

import Foundation
import AVFoundation
import CoreData
import SwiftUI

final class StorageManager {
	let allColors = [ dCS.dmlighterGray, dCS.pastelPurple, dCS.pastelBlue, dCS.pastelGreen, dCS.pastelYellow, dCS.pastelRed]
	static let shared = StorageManager()
	let container: NSPersistentContainer
	
	var savedSectionsEntities: [ SectionEntity ] = []
	var savedSectionsDeEntitisized: [ Section ] = []
	var updatedAllTRacks: [AudioTrack] = []
	
	//CoreData storage management
	
	func addSectionsToStorage(of track: AudioTrack){
		removeSectionsOf(track: track)
		for section in track.sections {
			let newSectionEntity = SectionEntity(context: container.viewContext)
			newSectionEntity.id = section.id
			newSectionEntity.trackTitle = track.filePath.lastPathComponent
			newSectionEntity.title = section.title
			newSectionEntity.startTime = section.startTime
			newSectionEntity.endTime = section.endTime
			newSectionEntity.colorRed = section.colorInDoubles.0
			newSectionEntity.colorGreen = section.colorInDoubles.1
			newSectionEntity.colorBlue = section.colorInDoubles.2
			newSectionEntity.colorAlpha = section.colorInDoubles.3
			
			
			saveData()
			
		}
		
	}
	
	func removeSectionsOf(track: AudioTrack) {
		let trackTitle = track.filePath.lastPathComponent
		let fetchRequest: NSFetchRequest = SectionEntity.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "trackTitle == %@", trackTitle)
		
		do {
			let result = try container.viewContext.fetch(fetchRequest)
			for objectToRemove in result {
				container.viewContext.delete(objectToRemove)
				saveData()
			}
			
			print("\(result.count) object(s) with title \(trackTitle) removed.")
		} catch {
			print("Error removing objects: \(error.localizedDescription)")
		}
	}
	
	func saveData() {
		do {
			try container.viewContext.save()
			print("Items saved")
		} catch let error {
			print("Error while saving: \(error)")
		}
	}
	
	func fetchSectionsOfTrack(named trackTitle: String) {
		
		let fetchRequest = NSFetchRequest<SectionEntity>(entityName: "SectionEntity")
		let predicate = NSPredicate(format: "trackTitle == %@", trackTitle)
		fetchRequest.predicate = predicate
		do {
			
			savedSectionsEntities = try container.viewContext.fetch(fetchRequest)
			
		} catch let error {
			print("Fetch error \(error.localizedDescription)")
		}
		
		deEntitization(of: savedSectionsEntities)
		
	}
	
	func deEntitization(of entitiesArray: [SectionEntity]){
	
		for entity in entitiesArray {
			let id = entity.id ?? UUID()
			let title = entity.title ?? ""
			let startTime = entity.startTime
			let endTime = entity.endTime
			
			//
			let colorRed = entity.colorRed
			let colorGreen = entity.colorGreen
			let colorBlue = entity.colorBlue
			let colorAlpha = entity.colorAlpha
			let color = Color(red: colorRed, green: colorGreen, blue: colorBlue, opacity: colorAlpha)
			
			let newSection = Section(id: id, title: title, startTime: startTime, endTime: endTime, color: color)
				savedSectionsDeEntitisized.append(newSection)
			}
		print("entitiesArray has \(entitiesArray.count) elements")
		savedSectionsEntities = []
	}
	
	func addFetchedSectionsOf(tracks: [AudioTrack], sections: [Section]) -> [AudioTrack]{
		
		var buffer = tracks
		
		for (index, track) in tracks.enumerated() {
			
			fetchSectionsOfTrack(named: track.filePath.lastPathComponent)
			
			var trackSectionsAdded = track
			
			trackSectionsAdded.sections = sections
			buffer.remove(at: index)
			buffer.append(trackSectionsAdded)
			
		}
		return buffer
	}
	
	func updateAllTracksWithSections(allTracks: [AudioTrack]){

		for track in allTracks {
			
			fetchSectionsOfTrack(named: track.filePath.lastPathComponent)
			deEntitization(of: savedSectionsEntities)
			var newTrack = track
			newTrack.sections = savedSectionsDeEntitisized
			updatedAllTRacks.append(newTrack)
		}
		savedSectionsDeEntitisized.removeAll()
		
	}
	
	init() {
		container = NSPersistentContainer(name: "SectionModel")
		container.loadPersistentStores { (description, error)  in
			if let error = error {
				print("Error loading CoreData \(error)")
			} else {
				print("Successfuly loaded container")
			}
			
		}
	}
}
