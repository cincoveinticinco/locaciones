//
//  LocationData.swift
//  AcciontvUpload
//
//  Created by 525 on 13/9/17.
//  Copyright © 2017 525. All rights reserved.
//

import Foundation
import SQLite

class LocationData {
    
    let path: String
    let db: Connection?
    
    let locations = Table("locations")
    let productions = Table("productions")
    let photos = Table("photos")
    
    let id = SQLite.Expression<Int64>("id")
    let serverId = SQLite.Expression<Int64>("id_server")
    let locationName = SQLite.Expression<String?>("name")
    let locationAddress = SQLite.Expression<String?>("address")
    let locationCity = SQLite.Expression<String?>("city")
    let locationPostalCode = SQLite.Expression<String?>("postal_code")
    let locationRequest = SQLite.Expression<Data>("request")
    let locationPhotoNumber = SQLite.Expression<Int>("number_photos")
    let locationUnit = SQLite.Expression<String?>("location_unit")
    
    let productionTableId = SQLite.Expression<Int64>("id")
    let productionId = SQLite.Expression<Int>("id_production")
    let productionLocationId = SQLite.Expression<Int>("id_location")
    let productionScriptName = SQLite.Expression<String?>("script_name")
    
    let photoId = SQLite.Expression<Int64>("id")
    let photoUrl = SQLite.Expression<String?>("url")
    let photoLocationId = SQLite.Expression<Int64>("id_location")
    
    static let data = LocationData()
    
    init() {
        self.path = NSSearchPathForDirectoriesInDomains(
            .documentDirectory, .userDomainMask, true
            ).first!
        do {
            self.db = try Connection("\(path)/accionDB.sqlite3")
            createTables()
        } catch {
            self.db = nil
            print (error)
        }
        
        
    }
    
    
    func createTables() {
        do {
            try db?.run(locations.create(ifNotExists: true) { loc in
                print(".... Creating TABLE Locations")
                loc.column(id, primaryKey: .autoincrement)
                loc.column(serverId, unique: false, defaultValue: nil)
                loc.column(locationName, unique: true)
                loc.column(locationAddress, unique: true)
                loc.column(locationCity)
                loc.column(locationPostalCode)
                loc.column(locationRequest)
                loc.column(locationPhotoNumber)
                loc.column(locationUnit)
            })
            try db?.run(productions.create(ifNotExists: true) { prod in
                print(".... Creating TABLE Productions")
                prod.column(productionTableId, primaryKey: .autoincrement)
                prod.column(productionId, unique: false)
                prod.column(productionLocationId, unique: true)
                prod.column(productionScriptName, unique: true)
            })
            try db?.run(photos.create(ifNotExists: true) { photo in
                print(".... Creating TABLE Photos")
                photo.column(photoId, primaryKey: .autoincrement)
                photo.column(photoLocationId, unique: false)
                photo.column(photoUrl, unique: false)
            })
        } catch {
            print(error)
        }
    }
    
    func addLocation(name: String, address: String, city: String, postalCode: String, unit: String?, req: Data) -> Int64? {
        do {
            let insert = locations.insert(serverId <- 0,
                                          locationName <- name,
                                          locationAddress <- address,
                                          locationCity <- city,
                                          locationPostalCode <- postalCode,
                                          locationUnit <- unit,
                                          locationRequest <- req,
                                          locationPhotoNumber <- 0)
            let rowid = try db!.run(insert)
            
            return rowid
        } catch {
            print(error)
            return nil
        }
    }
    
    func addProduction(locationId: Int, prodId: Int, scriptName: String) -> Int64? {
        do {
            let insert = productions.insert(//productionTableId <- id,
                                          productionId <- prodId,
                                          productionLocationId <- locationId,
                                          productionScriptName <- scriptName)
            let rowid = try db!.run(insert)
            
            return rowid
        } catch {
            print(error)
            return nil
        }
    }
    
    func addPhoto(path: String, locationId: Int) -> Int64? {
        do {
            let insert = photos.insert(photoUrl <- path,
                                        photoLocationId <- Int64(locationId))
            let rowid = try db!.run(insert)
            
            return rowid
        } catch {
            print(error)
            return nil
        }
    }
    
    func deleteLocation(locationId: Int64) -> Bool {
        do {
            let location = locations.filter(id == locationId)
            try db!.run(location.delete())
            print(" ")
            print("--- Deleting location with id : \(locationId)")
            return true
        } catch {
            print("Delete failed: \(error)")
        }
        return false
    }
    
    func updateLocation(locationId:Int64, newLocation: LocationModel) -> Bool {
        let location = locations.filter(id == locationId)
        do {
            let update = location.update([
                locationName <- newLocation.name,
                locationAddress <- newLocation.address,
                locationCity <- newLocation.city,
                locationUnit <- newLocation.unit,
                locationPostalCode <- newLocation.postalCode
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
    }
    
    func updateLocationServerId(locationId:Int64, remoteId: Int64) -> Bool {
        let location = locations.filter(id == locationId)
        do {
            let update = location.update([
                serverId <- remoteId
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update failed: \(error)")
        }
        
        return false
    }
    
    func updateLocationPhotoNumber(locationId: Int64, numberOfPhotos: Int) -> Bool {
        let location = locations.filter(serverId == locationId)
        do {
            let update = location.update([ locationPhotoNumber <- numberOfPhotos
                ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Update location photo number failed: \(error)")
        }
        return false
    }
    
    func updatePhoto(locationId:Int64, url: String) -> Bool {
        let photo = photos.filter(photoLocationId == locationId)
        do {
            let update = photo.update([
                photoUrl <- url ])
            if try db!.run(update) > 0 {
                return true
            }
        } catch {
            print("Photo update failed:  \(error)")
        }
        
        return false
    }
    
    func getLocations() -> [LocationModel] {
        var locations = [LocationModel]()
        
        do {
            for location in try db!.prepare(self.locations) {
                let loc = LocationModel()
                loc.id = Int(location[serverId])
                loc.rowId = location[id]
                loc.name = location[locationName]!
                loc.address = location[locationAddress]
                loc.city = location[locationCity]
                loc.postalCode = location[locationPostalCode]
                loc.unit = location[locationUnit]
                loc.numberOfPics = location[locationPhotoNumber]
                if Int(location[serverId]) != 0 {
                    loc.status = .Uploaded
                }

                let thumbs = photos.filter(photoLocationId == location[serverId])
                for thumb in try db!.prepare(thumbs) {
                    print("Here is a image row in Thumbs TABLE")
                    print(thumb[photoUrl] ?? "NO IMAGE")
                    do {

                        let fullNameArr = thumb[photoUrl]!.components(separatedBy: "/")
                        print(fullNameArr)
                        
                        let fileManager = FileManager.default
                        let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(fullNameArr.last!)
                        if fileManager.fileExists(atPath: imagePAth){
                            loc.thumbnail = UIImage(contentsOfFile: imagePAth)
                        }else{
                            print("No Image")
                        }
                        
                        
                    } catch {
                        print("Error while try Data(url) \(error)")
                    }
                }
                
                locations.append(loc)
            }
        } catch {
            print("Select failed: \(error)")
        }
        
        return locations
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getLocationByAddress(addressText: String) -> Int64? {
        let loc = locations.filter(locationAddress == addressText)
        for location in try! db!.prepare(loc) {
            return location[id]
        }
        
        return nil
    }
    
    func getLocationById(locId: Int64) -> Int64? {
        let loc = locations.filter(serverId == locId)
        for location in try! db!.prepare(loc) {
            return location[id]
        }
        
        return nil
    }
    
    func selectAll() {
        for location in try! db!.prepare(self.locations) {
            print("id: \(location[id]), serverId: \(location[serverId]), name: \(location[locationName]), address: \(location[locationAddress])")
            print("request:     \(location[locationRequest])")
        }
    }
    
    func selectAllFromProductions() {
        for production in try! db!.prepare(self.productions) {
            print("id local: \(production[productionTableId]), id Production: \(production[productionId]), name: \(production[productionScriptName]), locationId: \(production[productionLocationId])")
        }
    }
    
    func selectAllFromPhotos() {
        for photo in try! db!.prepare(self.photos) {
            print("id local: \(photo[photoId]), id location: \(photo[photoLocationId]), url: \(photo[photoUrl])")
        }
    }
    
    func destroyDB(){
        do{
            try db?.run(locations.delete())
            try db?.run(productions.delete())
            try db?.run(photos.delete())
            
        }catch{
            
            print ("Error on delete")
        }
    }
    
    func deleteJSONDataFromDisk() -> Bool {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filePath = documentsURL.appendingPathComponent("info_location.json").path
        
        do{
            try FileManager.default.removeItem(atPath: filePath)
            return true;
        }catch{
            print(error.localizedDescription)
        }
        return false;
    }
}

