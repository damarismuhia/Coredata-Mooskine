//
//  DataController.swift
//  Mooskine
//
//  Created by Damaris Muhia on 01/06/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import CoreData
/**
 we have defined this as a class as we dont want to create mutple copies when passing it  bwn VC
 This class will:
    1. Hold a pesistentstore container instance
    2. help us Load persistent Stoore
    3. help us access the context
 NB//After setting the CD stack we need to load pessistent data as when app start up, so we go to app delegate and call the load func there
 */
class DataController{
    //MARK: Access the context
    /**we create a computed propery**/
    var viewContext:NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    //MARK: setting up persistentContainer
    /**this shudnt change over the life of DataController so we make it immutable
     NB:/ to create an instance of store container we need a model name
     */
    let persistentContainer:NSPersistentContainer
    init(modelName:String){
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    //MARK: Load persistent store
    /***we use store container instance to load  persistent store.
     - we ahve defined a closure to ur func load that will be called after loading the store
     ***/
    func load(completion:(()->Void)? = nil){
        persistentContainer.loadPersistentStores { persistentStoreDescription, error in
            guard error == nil else{
                fatalError(error!.localizedDescription)
            }
        }
    }
    
    
    
}
