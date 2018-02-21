//
//  ViewController.swift
//  Virtual Tourist
//
//  Created by Mohit Arora on 15/02/18.
//  Copyright © 2018 soprateria. All rights reserved.
//

import UIKit
import MapKit
import CoreData
class ViewController: UIViewController,MKMapViewDelegate {

    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var deleteView: UIView!
    
    @IBOutlet var editButton: UIBarButtonItem!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
    
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "latitude", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "pin")
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }
    override func viewDidLoad() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.addPinOnMap(_:)))
        longPress.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(longPress)
        setupFetchedResultsController()
        setUpInitialVC()
        drawPinsOnMap()
        mapView.delegate = self

        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


    @IBAction func editButtonAction(_ sender: Any) {
        if(deleteView.isHidden){
            editButton.title = "Done"
            deleteView.isHidden = false
        } else{
            editButton.title = "Edit"
            deleteView.isHidden = true
        }

    }
    
    func setUpInitialVC(){
        
        self.title = "Virtual Tourist"
        
        deleteView.isHidden = true
    }
    func drawPinsOnMap(){
        
        var savedPins : [MKAnnotation] = []
        for pin in fetchedResultsController.fetchedObjects!{
          
            let latitude = CLLocationDegrees(pin.latitude)
            let longitude = CLLocationDegrees(pin.longitude)
            
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            savedPins.append(annotation)
            
        }
        mapView.addAnnotations(savedPins)
    }
    // Add pin logic
    @IBAction func addPinOnMap(_ sender: UILongPressGestureRecognizer) {
        
        //Only add pins if in the right mode
        if deleteView.isHidden && sender.state == .began {
            
            //Grab coords
            let location = sender.location(in: self.mapView)
            let locCoords = self.mapView.convert(location, toCoordinateFrom: self.mapView)
            
            // Save to context
            let lat : Double = locCoords.latitude
            let lng : Double = locCoords.longitude
            
            
            let pin = Pin(context: dataController.viewContext)
            pin.latitude = lat
            pin.longitude = lng
            try? dataController.viewContext.save()
            
           // let pin = Pin(lat: lat , lng: lng, context: sharedContext)
            // print(pin)
            let latitude = CLLocationDegrees(lat)
            let longitude = CLLocationDegrees(lng)
            
            
            // The lat and long are used to create a CLLocationCoordinates2D instance.
            let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            
            self.mapView.addAnnotation(annotation)
          //  CoreDataStackManager.sharedInstance().saveContext()
            
            // TODO : Enhacement. Start DL of pics in the background
            
        } else {
            
            print("Long press detected but in wrong mode")
            
        }
    }
    
    // Delegate function for maps - Response to taps
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        // Annotation selected. Will want to segue to our other view or delete.
        let pin = Pin(context: dataController.viewContext)
        pin.latitude = (view.annotation?.coordinate.latitude)!
        pin.longitude = (view.annotation?.coordinate.longitude)!
       // let pin = view.annotation as! Pin
        
        if deleteView.isHidden {
            
            performSegue(withIdentifier: "PinPhotosViewController", sender: pin)
        } else {
            
            dataController.viewContext.delete(pin)
            try? dataController.viewContext.save()
            mapView.removeAnnotation(view.annotation!)
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "PinPhotosViewController") {
            navigationItem.title = "OK"
            
            //Pass variables to new VC
            let destinationVC = segue.destination as! PinPhotosViewController
            destinationVC.dataController = dataController
            destinationVC.selectedPin = sender as! Pin
        }
    }
}

extension ViewController:NSFetchedResultsControllerDelegate {
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//        case .insert:
//            tableView.insertRows(at: [newIndexPath!], with: .fade)
//            break
//        case .delete:
//            tableView.deleteRows(at: [indexPath!], with: .fade)
//            break
//        case .update:
//            tableView.reloadRows(at: [indexPath!], with: .fade)
//        case .move:
//            tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
//        switch type {
//        case .insert: tableView.insertSections(indexSet, with: .fade)
//        case .delete: tableView.deleteSections(indexSet, with: .fade)
//        case .update, .move:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//        }
    }
    
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //tableView.endUpdates()
    }
    
}

