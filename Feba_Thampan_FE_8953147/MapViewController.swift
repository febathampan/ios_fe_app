//
//  MapViewController.swift
//  Feba_Thampan_FE_8953147
//
//  Created by user234888 on 12/9/23.
//

import UIKit
import MapKit

class MapViewController: UIViewController,MKMapViewDelegate, CLLocationManagerDelegate {

    
        @IBOutlet weak var mapView: MKMapView!
        @IBOutlet weak var zoomSlider: UISlider!

        private var locationManager = CLLocationManager()
        private var destinationCoordinate: CLLocationCoordinate2D?
        private var selectedMode: MKDirectionsTransportType = .automobile
    var receivedData: String?


        override func viewDidLoad() {
            super.viewDidLoad()
           
            // Set up map view
            mapView.delegate = self
            mapView.showsUserLocation = true
            mapView.userTrackingMode = .follow

            // Set up location manager
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            // Access and use the received data
                    if let name = receivedData, !name.isEmpty{
                        print("Received data: \(name)")
                        geoCodeCityAndShowRoute(cityName: name)
                    }else {
                        geoCodeCityAndShowRoute(cityName: "Waterloo")
                        }
        }

        // MARK: - Map Functions

        // Function to add a pin to the map
        private func addPin(coordinate: CLLocationCoordinate2D, title: String) {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = title
            mapView.addAnnotation(annotation)
        }


    // Function to create and display a route on the map
    private func showRoute() {
        guard let userLocation = locationManager.location?.coordinate, let destinationCoordinate = destinationCoordinate else {
            return
        }
        let sourcePlacemark = MKPlacemark(coordinate: userLocation)
            let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)

            let sourceItem = MKMapItem(placemark: sourcePlacemark)
            let destinationItem = MKMapItem(placemark: destinationPlacemark)

            let request = MKDirections.Request()
            request.source = sourceItem
            request.destination = destinationItem
            request.transportType = selectedMode

            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                guard let route = response?.routes.first else {
                    if let error = error {
                        print("Error calculating route: \(error.localizedDescription)")
                    }
                    return
                }

                // Remove previous overlays
                self.mapView.removeOverlays(self.mapView.overlays)

                // Add new route overlay
                self.mapView.addOverlay(route.polyline, level: .aboveRoads)

                // Fit the map to the route
                let edgePadding = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, edgePadding: edgePadding, animated: true)
            }
        }

        // MARK: - MapView Delegate

        // Function to display the polyline on the map
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 3.0
            return renderer
        }

        // MARK: - UI Actions
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        print(sender.value)
        let regionRadius: CLLocationDistance = CLLocationDistance(sender.value)
           let coordinateRegion = MKCoordinateRegion(
               center: mapView.userLocation.coordinate,
               latitudinalMeters: regionRadius,
               longitudinalMeters: regionRadius
           )
           mapView.setRegion(coordinateRegion, animated: true)
        }

  
    @IBAction func changeDestination(_ sender: Any) {
    showChangeDestinationAlert()
        }

        // Function to handle the mode buttons (Auto, Bike, Walking)
    @IBAction func modeButtonTapped(_ sender: UISegmentedControl) {
        print(sender.selectedSegmentIndex)
            switch sender.selectedSegmentIndex {
            case 0:
                selectedMode = .automobile
            case 1:
                selectedMode = .walking
            case 2:
                selectedMode = .any
            default:
                break
            }

                showRoute()
            
        }

        // MARK: - Location Manager Delegate

        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            // Center the map on the user's location
            if let location = locations.last {
                let regionRadius: CLLocationDistance = 1000
                let coordinateRegion = MKCoordinateRegion(
                    center: location.coordinate,
                    latitudinalMeters: regionRadius,
                    longitudinalMeters: regionRadius
                )
                mapView.setRegion(coordinateRegion, animated: true)
            }
        }

        // Function to show an alert for changing the destination
        private func showChangeDestinationAlert() {
            let alertController = UIAlertController(
                    title: "Change Destination",
                    message: "Enter the name of the new city:",
                    preferredStyle: .alert
                )

                alertController.addTextField { textField in
                    textField.placeholder = "City name"
                }

                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                let changeAction = UIAlertAction(title: "Change", style: .default) { _ in
                    if let cityName = alertController.textFields?.first?.text {
                        self.geoCodeCityAndShowRoute(cityName: cityName)
                    }
                }

                alertController.addAction(cancelAction)
                alertController.addAction(changeAction)

                present(alertController, animated: true, completion: nil)

        }

        // Function to geocode the entered city and show the route
        private func geoCodeCityAndShowRoute(cityName: String) {
            let geoCoder = CLGeocoder()

                geoCoder.geocodeAddressString(cityName) { placemarks, error in
                    guard let placemark = placemarks?.first,
                          let location = placemark.location else {
                        print("Error geocoding city: \(error?.localizedDescription ?? "")")
                        return
                    }

                    self.destinationCoordinate = location.coordinate

                    // Clear existing pins and overlays
                    self.mapView.removeAnnotations(self.mapView.annotations)
                    self.mapView.removeOverlays(self.mapView.overlays)

                    self.addPin(coordinate: self.mapView.userLocation.coordinate, title: "Start Point")

                    // Add new pin for the received city
                    self.addPin(coordinate: location.coordinate, title: cityName)

                    // Show route to the received city
                    self.showRoute()
                }
        }


}
