//
//  WeatherViewController.swift
//  Feba_Thampan_FE_8953147
//
//  Created by user234888 on 12/9/23.
//

import UIKit

class WeatherViewController: UIViewController {

 let weatherApi = "https://api.openweathermap.org/data/2.5/weather?"
    let weatherApiKey = "173c5d2d2b354722ef79a5ecb76cf4e1"
let getWeatherIconUrl = "https://openweathermap.org/img/wn/"
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    
    @IBOutlet weak var windSpeedLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    var receivedData: String?
    var cityName: String?
    var currentWeather: String?
    var wind: String?
    var humidity: String?
    var temperature: String?
    var _weatherIcon = UIImage()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Access and use the received data
                if let name = receivedData, !name.isEmpty{
                    print("Received data: \(name)")
                    getWeatherInformation(name)
                }else {
                    getWeatherInformation("Waterloo")
                }
        // Do any additional setup after loading the view.
    }
    
    
    func getWeatherInformation(_ cityName : String){
            
            let weatherApiCall = weatherApi+"q="+cityName+"&appid="+weatherApiKey
            
            print(weatherApiCall)
            
            // Note this shouls be a VAR in when used in an application as the URL value will change with each call!
            // Create an instance of a URLSession Class and assign the value of your URL to the The URL in the Class
            let urlSession = URLSession(configuration:.default)
            let url = URL(string: weatherApiCall)

            // Check for Valid URL
            if let url = url {
                // Create a variable to capture the data from the URL
                let dataTask = urlSession.dataTask(with: url) { (data, response, error) in
                    
                    // If URL is good then get the data and decode
                    if let data = data {
                        print (data)
                        let jsonDecoder = JSONDecoder()
                        do {
                            // Create an variable to store the structure from the decoded stucture
                            let readableData = try jsonDecoder.decode(Weather.self, from: data)
                            
                            //setting values to all variables
                            self.cityName = readableData.name
                            self.currentWeather = readableData.weather[0].description
                          //self.temperature = " \(Double(readableData.main.temp)-273.15)°C"
                            
                            let temperatureCelsius = String(format: "%.2f", Double(readableData.main.temp) - 273.15)
                            self.temperature = "\(temperatureCelsius)°C"
                            let humidityPercentage = Int(readableData.main.humidity)
                            self.humidity = "Humidity: \(humidityPercentage)%"

                            let windSpeedKmPerHour = String(format: "%.2f", readableData.wind.speed * 3.6) // Conversion from m/s to km/h
                            self.wind = "Wind: \(windSpeedKmPerHour) km/h"
                            
                            //self.humidity = "Humidity: \(Double(readableData.main.humidity))"
                           // self.wind = "Wind: \(Double(readableData.wind.speed))"
                            
                            //getting weather icon
                            let weatherIconUrl = self.getWeatherIconUrl+readableData.weather[0].icon+".png"
                            
                            if let iconURL = URL(string: weatherIconUrl),
                               let imageData = try? Data(contentsOf: iconURL),
                               let weatherIcon = UIImage(data: imageData) {
                               
                                self._weatherIcon = weatherIcon
                                
                            } else {
                                // Handle the case where the image couldn't be loaded
                                print("Error loading weather icon")
                            }
                            
                            //calling function to make display changes
                            self.updateLabels()
                            
                            
                            
                        }
                        //Catch the Broken URL Decode
                        catch {
                            print ("Can't Decode")
                            
                        }
                        
                    }
                    
                }
                dataTask.resume()// Resume the datatask method
                dataTask.response
            }

        }
    
    
    func updateLabels(){
        DispatchQueue.main.async {
            
            self.temperatureLabel.text = self.temperature
            self.humidityLabel.text = self.humidity
            self.windSpeedLabel.text = self.wind
            self.locationLabel.text = self.cityName
            self.conditionLabel.text = self.currentWeather
            self.weatherImage.image = self._weatherIcon
            
        }
        
        
    }
    //Icon API
    
    
    @IBAction func changeCity(_ sender: Any) {
 
        // Create the alert controller
         let alertController = UIAlertController(title: "Input Required", message: "Please enter the name of the city", preferredStyle: .alert)

         // Add a text field to the alert controller
         alertController.addTextField { (newCity) in
             newCity.placeholder = "Enter city name"
         }
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            // Retrieve the city name entered by the user
            if let newCity = alertController.textFields?[0].text {
                self.getWeatherInformation(newCity)
            }
        }
        // Add a cancel action
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)

        
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
