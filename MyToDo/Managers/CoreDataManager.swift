//
//  CoreDataManager.swift
//  MyToDo
//
//  Created by Cali Castle  on 10/4/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import CoreData

final class CoreDataManager {
    
    // MARK: - Properties
    
    private(set) lazy var mainManagedObjectContext: NSManagedObjectContext = {
        // Initialize Managed Object Context
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.parent = self.privateManagedObjectContext
        
        return managedObjectContext
    }()
    
    private lazy var privateManagedObjectContext: NSManagedObjectContext = {
        let managedObjectContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        // Configure Managed Object Context
        managedObjectContext.persistentStoreCoordinator = self.persistentStoreCoordinator
        
        return managedObjectContext
    }()
    
    private lazy var managedObjectModel: NSManagedObjectModel = {
        // Fetch Model URL
        guard let modelURL = Bundle.main.url(forResource: self.modelName, withExtension: "momd") else { fatalError("Unable to Find Data Model") }
        
        // Initialize Managed Object Model
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else { fatalError("Unable to Load Data Model") }
        
        return managedObjectModel
    }()
    
    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Initialize Persistent Store Coordinator
        let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // Helpers
        let fileManager = FileManager.default
        let storeName = "\(self.modelName).sqlite"
        
        // URL Documents Directory
        let documentsDirectoryURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        // URL Persistent Store
        let persistentStoreURL = documentsDirectoryURL.appendingPathComponent(storeName)
        
        do {
            // Add Persistent Store
            let options = [
                NSMigratePersistentStoresAutomaticallyOption : true,
                NSInferMappingModelAutomaticallyOption       : true
            ]
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: persistentStoreURL, options: options)
        } catch {
            fatalError("Unable to Add Persistent Store")
        }
        
        return persistentStoreCoordinator
    }()
    
    private let modelName: String
    
    // MARK: - Initialization
    
    /// Initializer of CoreDataManager
    /// - Parameter modelName: The name of the model
    init(modelName: String) {
        self.modelName = modelName
        
        setupNotificationHandling()
    }
    
    /// Set Up Notification Observer Handling
    private func setupNotificationHandling() {
        let notificationCenter = NotificationCenter.default
        
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        
        notificationCenter.addObserver(self, selector: #selector(saveChanges(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    @objc func saveChanges(_ notification: Notification) {
        saveChanges()
    }
    
    /// Try Saving the Managed Object Context to the Persistent Store
    private func saveChanges() {
        mainManagedObjectContext.performAndWait {
            do {
                if self.mainManagedObjectContext.hasChanges {
                    try self.mainManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                
                print("Unable to Save Changes of Main Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
        
        self.privateManagedObjectContext.perform {
            do {
                if self.privateManagedObjectContext.hasChanges {
                    try self.privateManagedObjectContext.save()
                }
            } catch {
                let saveError = error as NSError
                
                print("Unable to Save Changes of Private Managed Object Context")
                print("\(saveError), \(saveError.localizedDescription)")
            }
        }
    }
}
