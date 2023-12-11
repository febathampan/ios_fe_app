//
//  ViewController.swift
//  Feba_Thampan_FE_8953147
//
//  Created by user234888 on 12/9/23.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var currentLocation: MKMapView!
    
    let locationManager = CLLocationManager()

        override func viewDidLoad() {
            super.viewDidLoad()

            // Do any additional setup after loading the view.
            if CLLocationManager.locationServicesEnabled() {
                locationManager.delegate = self
                locationManager.desiredAccuracy = kCLLocationAccuracyBest
                locationManager.requestWhenInUseAuthorization()
                locationManager.requestAlwaysAuthorization()
                locationManager.startUpdatingLocation()
                locationManager.startMonitoringSignificantLocationChanges()
            }
        }
        
           
    
    func navigateToMapScene(cityName: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Use your storyboard name
        
        if let mapViewController = storyboard.instantiateViewController(withIdentifier: "Map") as? MapViewController {
            
            // Pass data to the second view controller
            mapViewController.receivedData = cityName
            
            navigationController?.pushViewController(mapViewController, animated: false)
            
        }}
    func navigateToNewsScene(cityName: String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Use your storyboard name

        if let newsViewController = storyboard.instantiateViewController(withIdentifier: "News") as? NewsTableViewController {
                     
                     // Pass data to the second view controller
                     newsViewController.selectedCity = cityName
                     
                     navigationController?.pushViewController(newsViewController, animated: false)
                     
                 }

    }
    func navigateToWhetherScene(cityName: String){
        
        // Instantiate the second view controller from the storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Use your storyboard name
        if let weatherViewController = storyboard.instantiateViewController(withIdentifier: "Weather") as? WeatherViewController {
            
            // Pass data to the second view controller
            weatherViewController.receivedData = cityName
            
            navigationController?.pushViewController(weatherViewController, animated: false)
            
        }
        
    }
        
    
    @IBAction func showDiscoverLocationAlert(_ sender: Any) {
   
        // Create the alert controller
         let alertController = UIAlertController(title: "Input Required", message: "Please enter the name of the city", preferredStyle: .alert)

         // Add a text field to the alert controller
         alertController.addTextField { (cityTextField) in
             cityTextField.placeholder = "Enter city name"
         }

         // Create the OK action
         let newsAction = UIAlertAction(title: "News", style: .default) { (_) in
             // Retrieve the city name entered by the user
             if let cityName = alertController.textFields?[0].text {
                 // Geocode the city name to get coordinates
                 self.navigateToNewsScene(cityName: cityName)

             }
         }
        let mapAction = UIAlertAction(title: "Map", style: .default) { (_) in
             // Retrieve the city name entered by the user
             if let cityName = alertController.textFields?[0].text {
                 // Geocode the city name to get coordinates
                self.navigateToMapScene(cityName: cityName)
             }
         }
        let weatherAction = UIAlertAction(title: "Weather", style: .default) { (_) in
             // Retrieve the city name entered by the user
             if let cityName = alertController.textFields?[0].text {
                 // Geocode the city name to get coordinates
                 self.navigateToWhetherScene(cityName: cityName)
             }
         }

         // Add the action to the alert controller
         alertController.addAction(newsAction)
         alertController.addAction(weatherAction)
         alertController.addAction(mapAction)

         // Present the alert controller
         self.present(alertController, animated: true, completion: nil)

    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let userLocation = locations.last?.coordinate else {
            return
        }

        
        let region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        currentLocation.setRegion(region, animated: true)

        // Add a pin to mark the user's location
        let annotation = MKPointAnnotation()
        annotation.coordinate = userLocation
        annotation.title = "Current Location"
        currentLocation.addAnnotation(annotation)

        // Stop updating location
        locationManager.stopUpdatingLocation()
    }
    
    
}

