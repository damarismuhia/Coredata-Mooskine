//
//  GenericFRC.swift
//  Mooskine
//
//  Created by Damaris Muhia on 01/06/2023.
//  Copyright © 2023 Udacity. All rights reserved.
//

import Foundation
import CoreData

class GenericFRC<EntityType:NSManagedObject>:NSObject,NSFetchedResultsControllerDelegate{
    private let managedObjectContext: NSManagedObjectContext
    private let fetchedResultsController: NSFetchedResultsController<EntityType>
    
    init(managedObjectContext:NSManagedObjectContext,fetchRequest:NSFetchRequest<EntityType>){
        ///NB:when you subclass a class and override the designated initializer (the initializer defined in the superclass), you need to ensure that all the properties of the subclass are initialized before calling super.init()
        self.managedObjectContext = managedObjectContext
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
    }
    /**notifies the receiver that a fetched object has been changed due to an add, remove, move or update
     -its called whener frc receives a notification, that an object has been added, deleted or changed
     @Param type ->type of event is refleted by type param, whiere NSFetchedResultsChangeType is an enum that can be  insert, delete, move,update
     @Param newIndexPath contain the indexPath of the  row  to insert in a case if insert
     @Param indexPath contain the indexPath of the  row  to delete in a case if deletion
     
     */
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        @unknown default:
//            break
//        }
//    }
//    
//    /*** controllerWillChangeContent - called before a batch of updates
//     */
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//    /*** controllerDidChangeContent - called to end  updates on table view
//     */
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }
}
