//
//  PinPhotosViewController.swift
//  Virtual Tourist
//
//  Created by Mohit Arora on 15/02/18.
//  Copyright © 2018 soprateria. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PinPhotosViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,MKMapViewDelegate {
    
    /// The notebook whose notes are being displayed
    var selectedPin: Pin!
    
    var dataController:DataController!
    
    var fetchedResultsController:NSFetchedResultsController<Photo>!
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    @IBOutlet weak var newCollectionButton: UIButton!
    var photoImages = [UIImage]()
    // MARK: Collection view delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(photoImages.count == 0){
            return 21
        }else{
            return photoImages.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let collectionCell  = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.photoCollectionViewCell, for: indexPath) as? PhotoCell
        if(photoImages.count > 0){
            collectionCell?.reloadCellWithImage(imageFetched: photoImages[indexPath.row])
        }else{
            collectionCell?.reloadCellWithPlaceHolder()
        }
        
        return collectionCell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }

    override func viewDidLoad() {
        
        configureFlowLayout()
        
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.collectionViewLayout = flowLayout
        
        mapView.delegate = self
        
        photosCollectionView.register(UINib(nibName: Constants.photoCollectionViewCell, bundle: nil), forCellWithReuseIdentifier:Constants.photoCollectionViewCell)
        
        drawPinOnMap()
       setupFetchedResultsController()
       fetchImagesForController()
       // getImageFromFlickrApi()
        super.viewDidLoad()
    }
    
    @IBAction func newCollectionTapped(_ sender: Any) {
        
        photoImages.removeAll()
        photosCollectionView.reloadData()
        getImageFromFlickrApi()
    }
    //MARK: Private Methods
    
    func configureFlowLayout(){
        
        let space:CGFloat = CGFloat(Constants.numberOfCellsInRow)
        let dimension = (view.frame.size.width - (2 * space)) / CGFloat(Constants.numberOfCellsInRow)
        
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
    }
    
    func getImageFromFlickrApi(){
        FlickrClient.sharedInstance().getImagesFromFlickr(latitude: selectedPin.latitude, longitude: selectedPin.longitude, pageNumber: 3) { (result, error) in
            performUIUpdatesOnMain {
                
                self.photoImages = result ;
                self.savePhotosToLocalStorage(photosArray: self.photoImages)
                self.photosCollectionView.reloadData()
            }

        }
    }
    
    func savePhotosToLocalStorage(photosArray:[UIImage]){
        for photo in photosArray{
            addPhotosForPin(photo: photo)
        }
    }
    
    func fetchImagesForController(){
//        if(fetchedResultsController.sections![0].numberOfObjects > 0){
//            for photoData in fetchedResultsController.fetchedObjects!{
//                self.photoImages.append(UIImage(data:photoData.photo!,scale:1.0)!)
//            }
//        }else{
            getImageFromFlickrApi()
     //   }
    }
    
    func drawPinOnMap(){
        
        let latitude = CLLocationDegrees(selectedPin.latitude)
        let longitude = CLLocationDegrees(selectedPin.longitude)

        // The lat and long are used to create a CLLocationCoordinates2D instance.
        let coordinate = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        
        mapView.addAnnotation(annotation)
        mapView.centerCoordinate = annotation.coordinate
        
    }
    
    func addPhotosForPin(photo:UIImage){
            let photos = Photo(context: dataController.viewContext)
        let imageData : Data = UIImagePNGRepresentation(photo)!
        photos.photo = imageData
        photos.pin = selectedPin
        try? dataController.viewContext.save()
    }
    
    func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", selectedPin)
        fetchRequest.predicate = predicate
        let sortDescriptor = NSSortDescriptor(key: "photo", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: "\(selectedPin)-photos")
        fetchedResultsController.delegate = self

        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("The fetch could not be performed: \(error.localizedDescription)")
        }
    }

}


    extension PinPhotosViewController:NSFetchedResultsControllerDelegate {
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//            switch type {
//            case .insert:
//                tableView.insertRows(at: [newIndexPath!], with: .fade)
//                break
//            case .delete:
//                tableView.deleteRows(at: [indexPath!], with: .fade)
//                break
//            case .update:
//                tableView.reloadRows(at: [indexPath!], with: .fade)
//            case .move:
//                tableView.moveRow(at: indexPath!, to: newIndexPath!)
//            }
        }
        
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//            let indexSet = IndexSet(integer: sectionIndex)
//            switch type {
//            case .insert: tableView.insertSections(indexSet, with: .fade)
//            case .delete: tableView.deleteSections(indexSet, with: .fade)
//            case .update, .move:
//                fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert or .delete should be possible.")
//            }
        }
        
        
        func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            //tableView.beginUpdates()
        }
        
        func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
            //tableView.endUpdates()
        }
        
}

