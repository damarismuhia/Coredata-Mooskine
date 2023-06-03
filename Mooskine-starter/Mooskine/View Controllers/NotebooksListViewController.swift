//
//  NotebooksListViewController.swift
//  Mooskine
//
//  Created by Josh Svatek on 2017-05-31.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import CoreData

class NotebooksListViewController: UIViewController,UITableViewDataSource {
    /// A table view that displays a list of notebooks
    @IBOutlet weak var tableView: UITableView!
   var fetchedResultContoller: NSFetchedResultsController<Notebook>!
    var dataSource: GenericDataSource<Notebook, NotebookCell>!
    var dataContoller:DataController!
 
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = UIImageView(image: #imageLiteral(resourceName: "toolbar-cow"))
        navigationItem.rightBarButtonItem = editButtonItem
      //  configureDataSource()
        setUpFetchedResultContller()
    }
    fileprivate func setUpFetchedResultContller() {
        let fetchResult:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescr = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchResult.sortDescriptors = [sortDescr]
        fetchedResultContoller = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: dataContoller.viewContext, sectionNameKeyPath: nil, cacheName: "notebooks")
        fetchedResultContoller.delegate = self
        do{
            try fetchedResultContoller.performFetch()
        }catch{
            print("Unable to fetch notebooks \(error.localizedDescription)")
        }
    }
    fileprivate func configureDataSource() {
        let fetchResult:NSFetchRequest<Notebook> = Notebook.fetchRequest()
        let sortDescr = NSSortDescriptor(key: "creationDate", ascending: false)
        fetchResult.sortDescriptors = [sortDescr]
        fetchedResultContoller = NSFetchedResultsController(fetchRequest: fetchResult,
                                                               managedObjectContext: dataContoller.viewContext,
                                                               sectionNameKeyPath: nil,
                                                            cacheName: "notebooks")
        dataSource = GenericDataSource(tableView: tableView, managedObjectContext: dataContoller.viewContext, fetchRequest: fetchedResultContoller.fetchRequest, cellIdentifier: NotebookCell.defaultReuseIdentifier){ cell, notebook in
            // Configure the cell with the notebook data
                cell.nameLabel.text = notebook.name
                if let count = notebook.notes?.count {
                let pageString = count == 1 ? "page" : "pages"
                cell.pageCountLabel.text = "\(count) \(pageString)"
            }
        }
        tableView.dataSource = dataSource
        
        
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
       // fetchedResultContoller = nil
    }
    // -------------------------------------------------------------------------
    // MARK: - Actions

    @IBAction func addTapped(sender: Any) {
        presentNewNotebookAlert()
    }

    // -------------------------------------------------------------------------
    // MARK: - Editing

    /// Display an alert prompting the user to name a new notebook. Calls
    /// `addNotebook(name:)`.
    func presentNewNotebookAlert() {
        let alert = UIAlertController(title: "New Notebook", message: "Enter a name for this notebook", preferredStyle: .alert)

        // Create actions
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] action in
            if let name = alert.textFields?.first?.text {
                self?.addNotebook(name: name)
            }
        }
        saveAction.isEnabled = false

        // Add a text field
        alert.addTextField { textField in
            textField.placeholder = "Name"
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: .main) { notif in
                if let text = textField.text, !text.isEmpty {
                    saveAction.isEnabled = true
                } else {
                    saveAction.isEnabled = false
                }
            }
        }

        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    /// Adds a new notebook to the end of the `notebooks` array
    func addNotebook(name: String) {
        let notebook = Notebook(context: dataContoller.viewContext)
        notebook.name = name
        notebook.creationDate = Date()
        do{
            try dataContoller.viewContext.save()
        }catch{
            print("\(error as NSError)")
        }
        updateEditButtonState()
        //MARK: replaced by reloadNoteBooks to update the UI
//        notebooks.insert(notebook, at: 0)
//        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .fade)
//
    }
    

    /// Deletes the notebook at the specified index path
    func deleteNotebook(at indexPath: IndexPath) {
        let notebokktodelete = fetchedResultContoller.object(at: indexPath)
        dataContoller.viewContext.delete(notebokktodelete)
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
        return fetchedResultContoller.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let aNotebook = fetchedResultContoller.object(at: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: NotebookCell.defaultReuseIdentifier, for: indexPath) as! NotebookCell

        // Configure cell
        cell.nameLabel.text = aNotebook.name
        if let count = aNotebook.notes?.count{
            let pageString = count == 1 ? "page" : "pages"
            cell.pageCountLabel.text = "\(count) \(pageString)"
        }
        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete: deleteNotebook(at: indexPath)
        default: () // Unsupported
        }
    }
    // -------------------------------------------------------------------------
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If this is a NotesListViewController, we'll configure its `Notebook`
        if let vc = segue.destination as? NotesListViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                vc.notebook = fetchedResultContoller.object(at: indexPath)
                vc.dataContoller = dataContoller
            }
        }
    }
}

extension NotebooksListViewController:NSFetchedResultsControllerDelegate{
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
