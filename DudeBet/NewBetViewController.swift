//
//  NewBetViewController.swift
//  BettingApp
//
//  Created by Daniel Miles on 5/2/18.
//  Copyright © 2018 Daniel Miles. All rights reserved.
//

import UIKit

class NewBetViewController: UIViewController {

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    @IBOutlet weak var eventTitleText: UITextField!
    
    @IBOutlet weak var betAmountText: UITextField!
    
    @IBOutlet weak var startPicker: UIDatePicker!
    
    @IBOutlet weak var endPicker: UIDatePicker!
   
    @IBOutlet weak var choice1Text: UITextField!
    
    @IBOutlet weak var choice2Text: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    
    @IBAction func saveEvent(_ sender: Any)
    {
        if let title = eventTitleText.text, let amount = betAmountText.text
        {
            let newEvent = BetEvent.init(entity: BetEvent.entity(), insertInto: context)
            
            newEvent.setValue(title, forKey: "eventName")
            newEvent.setValue(Int(amount), forKey: "betAmount")
            newEvent.setValue(startPicker.date, forKey: "startDate")
            newEvent.setValue(endPicker.date, forKey: "endDate")
            newEvent.setValue(choice1Text.text, forKey: "choice1")
            newEvent.setValue(choice2Text.text, forKey: "choice2")
            newEvent.setValue(false, forKey: "completed")
            //newEvent.setValue(false, forKey: "completed")
            
            do
            {
                try context.save()
            }
            catch
            {
                print("Failed to save")
            }
            performSegue(withIdentifier: "newEvent", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
