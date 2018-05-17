//
//  EventDetailViewController.swift
//  BettingApp
//
//  Created by Daniel Miles on 5/1/18.
//  Copyright © 2018 Daniel Miles. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class EventDetailViewController: UIViewController
{
    var eventStore : EKEventStore!
    var event : BetEvent!
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var calendar : EKCalendar?
    
    @IBOutlet weak var addToCalendarButton: UIButton!
    
    @IBOutlet weak var removeFromCalendarButton: UIButton!
    
    
    @IBOutlet weak var choiceSegment: UISegmentedControl!
    
    @IBOutlet weak var finishText: UILabel!
    
    @IBOutlet weak var choice1Participants: UITextView!
    @IBOutlet weak var choice2Participants: UITextView!
    
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var navItem: UINavigationItem!
    
    @IBAction func deleteButton(_ sender: UIButton) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "BetEvent")
        fetchRequest.predicate = NSPredicate(format: "eventName == %@", event.eventName!)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch _ as NSError {}
    }
    
    @IBAction func reportMatch(_ sender: UIButton) {
        
        if (!event.completed) {
            let (group1, group2) = fetchData()
            var combined = [Entrant]()
            var winners : [Entrant]
            for entrant in group1 {
                combined.append(entrant)
            }
            for entrant in group2 {
                combined.append(entrant)
            }
            let winner = choiceSegment.selectedSegmentIndex
            choice1Participants.text = ""
            choice2Participants.text = ""
            if winner == 0 {
                winners = PariMutuelBet.computeWinnings(allBetters: combined, winningBetters: group1)
                for entrant in winners {
                    choice1Participants.text = choice1Participants.text + entrant.entrantName! + " has won $" +
                        String(entrant.betAmount) + "!\n"
                }
            }
            else {
                winners = PariMutuelBet.computeWinnings(allBetters: combined, winningBetters: group2)
                for entrant in winners {
                    choice2Participants.text = choice2Participants.text + entrant.entrantName! + " has won $" +
                        String(entrant.betAmount) + "!\n"
                }
            }
            event.completed = true
        }
    }

    

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }

    //Can return empty values; check for empty when using results if necessary.
    override func viewWillAppear(_ animated: Bool)
    {
        let (_, _) = fetchData()
        choiceSegment.setTitle(event.choice1, forSegmentAt: 0)
        choiceSegment.setTitle(event.choice2, forSegmentAt: 1)
        calendar = eventStore.calendars(for: .event)[eventStore.calendars(for: .event).index(where: {(cal: EKCalendar) -> Bool in
            return cal.title == "Bet Events Calendar"
        })!]
        checkCalendarStatus()
        
    }
    
    func checkCalendarStatus()
    {
        //Check if this event is already in the calendar to determine if user can add it to their calendar or not
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: "\(Calendar.current.component(.year, from: Date()))-01-01")
        let endDate = formatter.date(from: "\(Calendar.current.component(.year, from: Date()))-12-31")
        let predicate =  eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: [calendar!])
        let events = eventStore.events(matching: predicate)
        
        if !events.contains(where: {(ev: EKEvent) -> Bool in return ev.title == event.eventName!})
        {
            addToCalendarButton.isEnabled = true
            removeFromCalendarButton.isEnabled = false
        }
        else
        {
            addToCalendarButton.isEnabled = false
            removeFromCalendarButton.isEnabled = true
        }
    }
    
    @IBAction func addEventToCalendar(_ sender: Any)
    {
        let newEvent = EKEvent.init(eventStore: eventStore)

        newEvent.title = event.eventName!
        newEvent.calendar = calendar
        //Getting date components for the start, end, and alarm dates (if there is an alarm)
        
        newEvent.startDate = event.startDate!
        newEvent.endDate = event.endDate
        
        do
        {
            try eventStore.save(newEvent, span: EKSpan.thisEvent, commit: true)
        }
        catch
        {
            //Error handling if there is an issue with saving the event
        }
        
        checkCalendarStatus()
    }
    
    @IBAction func removeEventFromCalendar(_ sender: Any)
    {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: "\(Calendar.current.component(.year, from: Date()))-01-01")
        let endDate = formatter.date(from: "\(Calendar.current.component(.year, from: Date()))-12-31")
        let predicate =  eventStore.predicateForEvents(withStart: startDate!, end: endDate!, calendars: [calendar!])
        
        let events = eventStore.events(matching:predicate)
        let currEvent = events[events.index(where: {(ev: EKEvent) -> Bool in
            return ev.title == event.eventName
        })!]
        
        
        do
        {
            try eventStore.remove(currEvent, span: EKSpan.thisEvent)
            try eventStore.commit()
        }
        catch
        {
            print("Failed to remove event")
        }
        
        checkCalendarStatus()
    }
    
    func fetchData() -> ([Entrant], [Entrant]) {
        var choice1Entrants, choice2Entrants : [Entrant]
        let choice1Fetch = NSFetchRequest<Entrant>(entityName: "Entrant")
        let choice2Fetch = NSFetchRequest<Entrant>(entityName: "Entrant")
        choice1Fetch.predicate = (NSPredicate(format: "currChoice == %@ AND ANY events.eventName == %@", NSNumber(value: 0), event.eventName!))
        choice2Fetch.predicate = (NSPredicate(format: "currChoice == %@ AND ANY events.eventName == %@", NSNumber(value: 1), event.eventName!))
        do
        {
            try choice1Entrants = context.fetch(choice1Fetch)
            try choice2Entrants = context.fetch(choice2Fetch)
            reloadText(choice1Entrants, choice2Entrants)
            return (choice1Entrants, choice2Entrants)
        }
        catch
        {
            print("Unable to fetch Bet Events")
        }
        return ([Entrant](), [Entrant]())
    }
    
    
    func reloadText(_ choice1: [Entrant], _ choice2: [Entrant]) -> () {
        choice1Participants.text = ""
        choice2Participants.text = ""
        finishText.text = ""
        if (event.completed) {
            finishText.text = "This event has ended. Thank you for playing!"
        }
        else {
            for entrant in choice1 {
                choice1Participants.text = choice1Participants.text + "\n" + entrant.entrantName! + ": $" + String(entrant.betAmount)
            }
            for entrant in choice2 {
                choice2Participants.text = choice2Participants.text + "\n" + entrant.entrantName! + ": $" + String(entrant.betAmount)
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        super.prepare(for: segue, sender: sender)
    
        if segue.identifier == "addBet" {
            let betVC = segue.destination as! BetViewController
            betVC.event = self.event
        }
    }
    
    @IBAction func unwindToDetail(segue: UIStoryboardSegue) {
            let (_,_) = fetchData()
    }
}

