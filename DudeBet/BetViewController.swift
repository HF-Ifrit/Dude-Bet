//
//  BetViewController.swift
//  BettingApp
//
//  Created by Daniel Miles on 5/2/18.
//  Copyright © 2018 Daniel Miles. All rights reserved.
//

import Foundation
import UIKit
import EventKit
class BetViewController : UIViewController {
    
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var event: BetEvent!
    
    @IBOutlet weak var entrant: UITextField!
    
    @IBOutlet weak var choiceSelection: UISegmentedControl!
    
    @IBOutlet weak var betAmount: UITextField!
    
    @IBAction func saveButton(_ sender: UIButton) {
        if let name = entrant.text, let bet = Int(betAmount.text!) {
        
            let choice = choiceSelection.selectedSegmentIndex
            let entrant = Entrant(entity: Entrant.entity(), insertInto: context)
            
            entrant.setValue(name, forKey: "entrantName")
            entrant.setValue(bet, forKey: "betAmount")
            entrant.setValue(choice, forKey: "currChoice")
            
            entrant.addToEvents(event)

            do
            {
                try context.save()
            }
            catch
            {
                print("Failed to save")
            }
            
            
            
            
        }
        performSegue(withIdentifier: "saveEntrant", sender: self)
    }
    
  
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Check if there is a calendar for betting events; Create one if there isn't
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        choiceSelection.setTitle(event.choice1, forSegmentAt: 0 )
        choiceSelection.setTitle(event.choice2, forSegmentAt: 1)
    }
}
