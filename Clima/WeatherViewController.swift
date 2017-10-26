//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON



class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate{
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "186e839a7845a692a887de904c3dab45"
    
    let weatherForecast = "http://api.openweathermap.org/data/2.5/forecast"

    //TODO: Declare instance variables here
    
    let locationManager = CLLocationManager()

    let weatherDataModel = WeatherDataModel()
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
   @IBOutlet weak var foreCastImage: UIImageView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
      
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    

    func getWeatherData(url: String, parameters: [String : String]){
        
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON{
            
        response in
            if response.result.isSuccess{
                
                print("Sucess! Got weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
               
                self.updateWeatherData(json: weatherJSON)
                self.updateUIwithWeatherData()
                
            } else {
                
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
            
        }
    }
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWeatherData(json : JSON){
        
        if let tempResult = json["main"]["temp"].double {
        
        weatherDataModel.temperature = Int(tempResult - 273.5)
        
        weatherDataModel.city = json["name"].stringValue
        weatherDataModel.condition = json["weather"][0]["id"].intValue
        weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
            
        } else {
            
            cityLabel.text = "Weather unavailable"
            
        }
    }
    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIwithWeatherData() {
        
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(weatherDataModel.temperature)º"
        
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
        
       foreCastImage.image = UIImage(named: weatherDataModel.weatherIconName)
    
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //get last location which is the most accurate one for that object in that array
        let location = locations[locations.count-1]
        
        //make sure the accuracy is enough by not making it negative
        
        if location.horizontalAccuracy > 0 {
            
            
            //stop updating takes alot of energy if it keeps updating
            
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longtitude = \(location.coordinate.longitude), latitude = \(location.coordinate.latitude)")
            
            
            let longtitude = String(location.coordinate.longitude)
            let latitude = String(location.coordinate.latitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longtitude, "appid" : APP_ID]
            
            
            getWeatherData(url: WEATHER_URL, parameters: params)
            
            getWeatherData(url: weatherForecast, parameters: params)
            
        }
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        print(error)
        
        cityLabel.text = "Location Unavailable"
        
        
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredNewCityName(city: String) {
        
        let params : [ String : String] = ["q": city, "appid": APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
       getWeatherData(url: weatherForecast, parameters: ["q": city, "appid": APP_ID])
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName" {
            
            
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
            
        }
        
    }
    
    
    
}


