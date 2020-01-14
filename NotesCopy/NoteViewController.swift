//
//  NoteViewController.swift
//  NotesCopy
//
//  Created by Harrison Cook on 1/9/20.
//  Copyright © 2020 Harrison Cook. All rights reserved.
//

import UIKit
import CoreData

protocol UpdateNoteDelegate {
    func updateNoteInfo(_ fullText: String,_ postionOfNote: Int);
}

class NoteViewController: UIViewController, UITextViewDelegate {

    var note: NSManagedObject!
    var notePos: Int!
    @IBOutlet weak var noteMain: UITextView!
    var delegate: UpdateNoteDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noteMain.delegate = self
        guard let note = note else{
            return
        }
        let bodyOptional = note.value(forKey: "body") as? String
        guard let body = bodyOptional else {
            return
        }
        noteMain.text = body
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = self.delegate {
            let body = note.value(forKey: "body") as? String
            if(noteMain.text != body){
                delegate.updateNoteInfo(noteMain.text, notePos)
            }
        }
    }
}
