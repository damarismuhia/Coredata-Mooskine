//
//  GenericDataSource.swift
//  Mooskine
//
//  Created by Damaris Muhia on 01/06/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit
class GenericDataSource<EntityType:NSManagedObject,CellType:UITableViewCell>:NSObject,UITableViewDataSource,NSFetchedResultsControllerDelegate{
    private let tableView: UITableView
    private let managedObjectContext: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<EntityType>
    private let cellIdentifier: String
    private let configure: (CellType, EntityType) -> Void
    
    init(tableView:UITableView, managedObjectContext:NSManagedObjectContext,fetchRequest:NSFetchRequest<EntityType>,cellIdentifier: String,configure:@escaping (CellType,EntityType)->Void){
        ///NB:when you subclass a class and override the designated initializer (the initializer defined in the superclass), you need to ensure that all the properties of the subclass are initialized before calling super.init()
        self.tableView = tableView
        self.managedObjectContext = managedObjectContext
        self.cellIdentifier = cellIdentifier
        self.configure = configure
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                              managedObjectContext: managedObjectContext,
                                                              sectionNameKeyPath: nil, cacheName: nil)
        super.init()

        fetchedResultsController.delegate = self
        do {
              try fetchedResultsController.performFetch()
            } catch {
              print("Error fetching results: \(error)")
              // You can show an alert or perform any other appropriate action to notify the user about the error.
            }
        tableView.dataSource = self
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sections = fetchedResultsController.sections else {
            return 0
        }
        let currentSection = sections[section]
        return currentSection.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! CellType
        let object = fetchedResultsController.object(at: indexPath)
        configure(cell, object)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    
    /**notifies the receiver that a fetched object has been changed due to an add, remove, move or update
     -its called whener frc receives a notification, that an object has been added, deleted or changed
     @Param type ->type of event is refleted by type param, whiere NSFetchedResultsChangeType is an enum that can be  insert, delete, move,update
     @Param newIndexPath contain the indexPath of the  row  to insert in a case if insert
     @Param indexPath contain the indexPath of the  row  to delete in a case if deletion
     
     */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        @unknown default:
            break
        }
    }
    
    /*** controllerWillChangeContent - called before a batch of updates
     */
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    /*** controllerDidChangeContent - called to end  updates on table view
     */
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
}

