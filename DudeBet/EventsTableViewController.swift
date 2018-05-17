//
//  ViewController.swift
//  BettingApp
//
//  Created by Daniel Miles on 5/1/18.
//  Copyright © 2018 Daniel Miles. All rights reserved.
//

import UIKit
import EventKit
import CoreData

class EventsTableViewController: UITableViewController
{
    let eventStore = EKEventStore()
    var context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var betEvents : [BetEvent]!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //Check if there is a calendar for betting events; Create one if there isn't
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let calStatus = EKEventStore.authorizationStatus(for: EKEntityType.event)
        switch(calStatus)
        {
        case .notDetermined:
            //First-time the app has been ran; Request permission to use user's calendar
            requestCalendarAccess()
            createBetCalendar()
            break;
        case .authorized:
            //Once authorized, we can proceed with using the app as normal
            createBetCalendar()
            loadBetEvents()
            tableView.reloadData()
            break;
        case .restricted, .denied:
            //Unable to get permission so we can't do anything with calendars (could show a new view that leads users to settings
            print("Calendar not allowed")
            break;
        }
    }
    
    //Makes dedicated calendar for application
    func createBetCalendar()
    {
        if !eventStore.calendars(for: .event).contains(where:
            {(calendar: EKCalendar) -> Bool in
                return calendar.title == "Bet Events Calendar"
        })
        {
            let bettingCalendar = EKCalendar(for: .event, eventStore: eventStore)
            bettingCalendar.title = "Bet Events Calendar"
            
            let sourcesInEventStore = eventStore.sources
            
            //Get the Local source to assign to the new calendar's source property
            bettingCalendar.source = sourcesInEventStore.filter{
                (source: EKSource) -> Bool in
                source.sourceType.rawValue == EKSourceType.local.rawValue}.first!
            
            //Try to save the new calendar, handle with an alert if an error occurred
            do
            {
                try eventStore.saveCalendar(bettingCalendar, commit: true)
                UserDefaults.standard.set(bettingCalendar.calendarIdentifier, forKey: "EventTrackerPrimaryCalendar")
            }
            catch
            {
                //Error handling for issues with saving calendar
            }
        }
    }
    
    //Specify number of rows
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return betEvents.count
    }
    
    //Create table cells
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! EventTableViewCell
        
        cell.titleLabel.text = betEvents[indexPath.row].eventName
        return cell
    }
    
    func requestCalendarAccess()
    {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted
            {
                DispatchQueue.main.async(execute:
                    {
                        print("Calendar access granted")
                        self.loadBetEvents()
                        self.tableView.reloadData()
                })
            }
            else
            {
                DispatchQueue.main.async(execute:
                    {
                        print("Calendar access not granted")
                })
            }
        })
    }
    
    func loadBetEvents()
    {
        do
        {
            try betEvents = context.fetch(BetEvent.fetchRequest())
        }
        catch
        {
            print("Unable to fetch Bet Events")
        }
        
    }
    
    @IBAction func unwindToEventView(segue: UIStoryboardSegue)
    {
        if segue.identifier == "newEvent"
        {
            context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "showDetail"
        {
            let detailVC = segue.destination as! EventDetailViewController
            
            detailVC.eventStore = eventStore
            let selectedEventIndex = tableView.indexPathForSelectedRow?.row
            let selectedEvent = betEvents[selectedEventIndex!]
            
            detailVC.event = selectedEvent
            detailVC.navItem.title = selectedEvent.eventName
            
        }
        else if segue.identifier == "newBetEvent"
        {
            
        }
    }
}

