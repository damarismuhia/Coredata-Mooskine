//
//  NotesListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotesListViewController: UIViewController, UITableViewDataSource {
    /// A table view that displays a list of notes for a notebook
    @IBOutlet weak var tableView: UITableView!
    var dataContoller:DataController!
    var fetchedResultContoller:NSFetchedResultsController<Note>!
    /// The notebook whose notes are being displayed
    var notebook: Notebook!

    /// A date formatter for date text in note cells
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = notebook.name
        navigationItem.rightBarButtonItem = editButtonItem
        setUpFetchedResultContller()
}
fileprivate func setUpFetchedResultContller() {
    let fetchResult:NSFetchRequest<Note> = Note.fetchRequest()
    let predicate = NSPredicate(format: "notebook == %@", notebook)
    fetchResult.predicate = predicate
    let sortDescr = NSSortDescriptor(key: "creationDate", ascending: false)
    fetchResult.sortDescriptors = [sortDescr]
    fetchedResultContoller = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: dataContoller.viewContext, sectionNameKeyPath: nil, cacheName: "\(notebook.name)")
    fetchedResultContoller.delegate = self
    do{
        try fetchedResultContoller.performFetch()
    }catch{
        print("Unable to fetch notebooks \(error.localizedDescription)")
    }
}

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: false)
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        fetchedResultContoller = nil
    }

    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        addNote()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    // Adds a new `Note` to the end of the `notebook`'s `notes` array
    func addNote() {
        let note = Note(context: dataContoller.viewContext)
        note.name = "New note"
        note.creationDate = Date()
        note.notebook = notebook
        try? dataContoller.viewContext.save()
    }

    // Deletes the `Note` at the specified index path
    func deleteNote(at indexPath: IndexPath) {
    //    notebook.removeNote(at: indexPath.row)
        let notToDelete = fetchedResultContoller.object(at: indexPath)
        dataContoller.viewContext.delete(notToDelete)
        try? dataContoller.viewContext.save()
        
    }

    func updateEditButtonState() {
        if let sections = fetchedResultContoller.sections{
            navigationItem.rightBarButtonItem?.isEnabled = sections[0].numberOfObjects > 0
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }

    // -------------------------------------------------------------------------
    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultContoller.sections?.count ?? 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return number of object(row) in section
        return fetchedResultContoller.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //return the object at a given indexPath in the fetched result
        let aNote = fetchedResultContoller.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.defaultReuseIdentifier, for: indexPath) as! NoteCell

        // Configure cell
        cell.textPreviewLabel.text = aNote.name
        if let creationDate = aNote.creationDate{
            cell.dateLabel.text = dateFormatter.string(from: creationDate)

        }

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNote(at: indexPath)
        default: () // Unsupported
        }
    }


    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NoteDetailsViewController, we'll configure its `Note`
        // and its delete action
        if let vc = segue.destination as? NoteDetailsViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.note = fetchedResultContoller.object(at: indexPath)
                vc.dataContoller = dataContoller

                vc.onDelete = { [weak self] in
                    if let indexPath = self?.tableView.indexPathForSelectedRow {
                        self?.deleteNote(at: indexPath)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
}
extension NotesListViewController:NSFetchedResultsControllerDelegate{
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
