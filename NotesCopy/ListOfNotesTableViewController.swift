//
//  ListOfNotesTableViewController.swift
//  NotesCopy
//
//  Created by Harrison Cook on 1/8/20.
//  Copyright © 2020 Harrison Cook. All rights reserved.
//

import UIKit
import CoreData

class ListOfNotesTableViewController: UITableViewController, UpdateNoteDelegate {

    var notes: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Note")
        do{
            try notes = managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError{
            print("Could not fetch \(error).")
        }
    }
    @IBAction func addNoteButton(_ sender: UIBarButtonItem) {
        guard let appDelegate =
          UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Note", in: managedContext)!
        let note = NSManagedObject(entity: entity,
        insertInto: managedContext)
        note.setValue("", forKey: "title")
        note.setValue("", forKey: "body")
        note.setValue(Date(), forKey: "lastEdit")
        do{
            try managedContext.save()
            notes.append(note)
            tableView.reloadData()
            performSegue(withIdentifier: "createNote", sender: note)
        }catch {
            fatalError("Didnt save")
        }
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let remove = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            do {
                managedContext.delete(self.notes[indexPath.row])
                try managedContext.save()
                self.notes.remove(at: indexPath.row)
                tableView.reloadData()
            }catch{
                fatalError("Didnt delete")
            }
            completionHandler(true)
        }
        let swipeActionConfig = UISwipeActionsConfiguration(actions: [remove])
        swipeActionConfig.performsFirstActionWithFullSwipe = false
        return swipeActionConfig
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? NoteViewController {
            if(segue.identifier == "clickNote"){
                destination.note = notes[tableView.indexPathForSelectedRow!.row]
                destination.notePos = tableView.indexPathForSelectedRow!.row
                destination.delegate = self
            }
            if(segue.identifier == "createNote"){
                destination.note = notes[notes.count-1]
                destination.notePos = notes.count-1
                destination.delegate = self
            }
        }
    }
    
    func updateNoteInfo(_ fullText: String,_ postionOfNote: Int){
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let note = notes[postionOfNote]
        if(fullText==""){
            managedContext.delete(note)
            notes.remove(at: postionOfNote)
        }
        else{
            var textInArray = fullText.components(separatedBy: " ")
            for (index, text) in textInArray.enumerated() {
                if text == ""{
                    if index<textInArray.count{
                        textInArray.remove(at: index)
                    }
                }
            }
            if(textInArray.count>0){
                note.setValue(textInArray[0], forKey: "title")
                textInArray.dropFirst()
                note.setValue(textInArray.joined(separator: " "), forKey: "body")
                note.setValue(Date(), forKey: "lastEdit")
            }
        }
        do{
            try managedContext.save()
            tableView.reloadData()
        }catch{
            fatalError("Didnt save")
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        let note = notes[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "listOfNoteTitles", for: indexPath)
        let lastEdit = note.value(forKeyPath: "lastEdit")
        dateFormatter.dateFormat = "MM/dd/yy"
        cell.textLabel?.text = note.value(forKeyPath: "title") as? String
        cell.detailTextLabel?.text = dateFormatter.string(from: lastEdit as! Date)
        return cell
    }

}
