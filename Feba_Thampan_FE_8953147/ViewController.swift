//
//  ViewController.swift
//  Feba_Thampan_FE_8953147
//
//  Created by user234888 on 12/9/23.
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    
    @IBOutlet weak var weatherLocation: UILabel!
    @IBOutlet weak var currentWeather: UILabel!
    @IBOutlet weak var weatherImage: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var windLabel: UILabel!
    
    
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
        
        

        
        func getWeatherAPI(latatiduCord: String, longitudeCord: String) {
            guard let url = URL(string:"https://api.openweathermap.org/data/2.5/weather?lat=\(latatiduCord)&lon=\(longitudeCord)&appid=3c9f7ef5c40f00e9188febcb2a8024ae&units=metric") else {
                return}
            let task = URLSession.shared.dataTask(with: url) { [self]
                data, response, error in
                /* print(data!)
                 if let data = data, let string = String(data: data, encoding: .utf8){
                 print(string)*/
                if let data = data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let jsonData = try jsonDecoder.decode(Weather.self, from: data)
                        print(jsonData.name)
                        print(jsonData.coord)
                        Task {@MainActor in
                            self.weatherLocation.text = jsonData.name
                            self.currentWeather.text = jsonData.weather[0].main
                            self.temperatureLabel.text = String(jsonData.main.temp) + " °"
                            self.humidityLabel.text = "Humidity : "+String(jsonData.main.humidity)+"%"
                            // convert m/h to km/h by multiplying 3.6
                            let windSpeedKMH = String(format: "%.f", jsonData.wind.speed * 3.6)
                            self.windLabel.text = "Wind : "+String(windSpeedKMH)+"km/h"
                            let iconCode = jsonData.weather[0].icon
                            print(iconCode)
                            let iconUrl = URL(string: "https://openweathermap.org/img/wn/\(iconCode).png")!
                            self.WeatherIcon(IconURL: iconUrl, weatherIconView: self.weatherImage)
                        }
                        
                    } catch {
                        print("SOME ERROR")
                    }
                }
            }
            task.resume()
        }
            //method to convert URL to Image
            func WeatherIcon(IconURL: URL, weatherIconView: UIImageView) {
                    let task = URLSession.shared.dataTask(with: IconURL) { data, _, _ in
                        guard let data = data else { return }
                        DispatchQueue.main.async { // Make sure you're on the main thread here
                            weatherIconView.image = UIImage(data: data)
                        }
                    }
                    task.resume()
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
        
       /* func geocodeCityAndCallAPI(_ cityName: String) {
            let geocoder = CLGeocoder()

            geocoder.geocodeAddressString(cityName) { (placemarks, error) in
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    // Handle geocoding error if needed
                } else if let location = placemarks?.first?.location {
                    // Use the obtained coordinates
                    let latitude = location.coordinate.latitude
                    let longitude = location.coordinate.longitude

                    // Do something with the latitude and longitude
                    print("City: \(cityName), Latitude: \(latitude), Longitude: \(longitude)")

                    // Call weather API with city coordinates
                    self.getWeatherAPI(latatiduCord: String(latitude), longitudeCord: String(longitude))
                }
            }
        }*/

    
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
    
    
    
}

