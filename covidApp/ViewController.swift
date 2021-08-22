//
//  ViewController.swift
//  covidApp
//
//  Created by Payal on 25/04/21.
//

import UIKit
import CoreLocation
import Charts


class ViewController: UIViewController, CLLocationManagerDelegate, ChartViewDelegate {

    // Define a endpoint
    let endPoint = "https://corona.lmao.ninja/v2/"
    var locationManager: CLLocationManager?
    var countryName: String!
    
    //Dfine outlets
    @IBOutlet weak var totalCases: UILabel!
    @IBOutlet weak var totalRecovered: UILabel!
    @IBOutlet weak var totalDeaths: UILabel!
    @IBOutlet weak var totalCountry: UILabel!
    @IBOutlet weak var recoveredCountry: UILabel!
    @IBOutlet weak var totalUserCountry: UILabel!
    @IBOutlet weak var recoveredUserCountry: UILabel!
    @IBOutlet weak var deathsUserCountry: UILabel!
    @IBOutlet weak var userLocationName: UILabel!
    
    @IBOutlet weak var barChart: BarChartView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        getLocation()
        getCovidTotalData()
        barChart.delegate = self
        getChartData()
    }

    // To get authorization from user to access their location data
    func getLocation(){
        
        let status: CLAuthorizationStatus = locationManager!.authorizationStatus
        
        if status ==  .notDetermined{
            locationManager?.requestAlwaysAuthorization()
       
        }else if status == .authorizedAlways || status == .authorizedWhenInUse{
            locationManager?.startUpdatingLocation()
            
        }
        else{
            print("Authorization status is: \(status.rawValue)")
        }
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            
        if manager.authorizationStatus == .authorizedAlways {
                print("Authorization Received")
            manager.startUpdatingLocation()
            } else if manager.authorizationStatus == .authorizedWhenInUse {
                print("Limited Authorization Received")
                manager.startUpdatingLocation()
            } else {
                print("Denied")
            }
        }
 
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        let lastLocation = locations.last!

        let lat = lastLocation.coordinate.latitude
        let lon = lastLocation.coordinate.longitude
        
        let location = CLLocation(latitude: lat, longitude: lon)
        
        // call method using location
        location.fetchCityAndCountry { [self] city, country, error in
            guard let country = country, error == nil else { return }
            self.countryName = country
        }
        

    }
    
    // function which use api to get world covid data
    func getCovidTotalData(){
        
        let session = URLSession.shared
        let queryAll = "all?"
        let queryUrl = URL(string: endPoint + queryAll)!
        print(queryUrl)
        
        let task = session.dataTask(with: queryUrl){ [self]
            data, response, error in
            
            //check if there was an error or data absent
            if error != nil || data == nil{
                print("Client Error!")
                return
            }
            
            //check http error code
            let r = response as? HTTPURLResponse
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server Error \(String(describing: r?.statusCode))")
                return
            }
            
            // Check the correct type of data using MIME
            guard let mime = response.mimeType, mime == "application/json" else{
                print("Incorrect MIME Type: \(String(describing: r?.mimeType))")
                return
            }
            
            // Fetch required elements form the json query
        
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                print(json ?? "Error- No JSON Received")
                
            
                let worldtotalCase = json?["cases"] as? Double
                let worldrecovered = json?["recovered"] as? Double
                let worlddeaths = json?["deaths"] as? Double

                getCovidCountryData(worldTotal: worldtotalCase!, recoveredtotal: worldrecovered!)
                
                DispatchQueue.main.async {
                    self.totalCases.text = String(worldtotalCase!)
                    self.totalRecovered.text = String(worldrecovered!)
                    self.totalDeaths.text = String(worlddeaths!)
                }
                
            }catch{
                print("Error in JSON")
            }
        }
        task.resume()
    }
    
    
    // update api to get two countries data
    func getCovidCountryData(worldTotal: Double, recoveredtotal: Double){
        
        
        let session = URLSession.shared
        // set selected country to india
        let queryCountry = "countries/india,"
        // countryName refers to the country from user location
        let queryUrl = URL(string: endPoint + queryCountry + countryName)!
        print(queryUrl)
       
        
        let task = session.dataTask(with: queryUrl){ [self]
            data, response, error in
            
            //check if there was an error or data absent
            if error != nil || data == nil{
                print("Client Error!")
                return
            }
            
            //check http error code
            let r = response as? HTTPURLResponse
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server Error \(String(describing: r?.statusCode))")
                return
            }
            
            // Check the correct type of data using MIME
            guard let mime = response.mimeType, mime == "application/json" else{
                print("Incorrect MIME Type: \(String(describing: r?.mimeType))")
                return
            }
            
            // Fetch required elements form the json query
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [Any]
                print(json ?? "Error- No JSON Received")
               
                let country0 = json?[0] as? [String:Any]
                let country1 = json?[1] as? [String:Any]
                
                let totalCase = country0?["cases"] as? Double
                let recovered = country0?["deaths"] as? Double

                //calculate % of total cases in india with the world total cases and recovered %
                let totalPercentage = (totalCase!/worldTotal) * 100
                let recoveredPercentage = (recovered!/recoveredtotal) * 100

                DispatchQueue.main.async {
                    self.totalCountry.text = String(format: "%.2f", totalPercentage) + "%"
                    self.recoveredCountry.text = String(format: "%.2f", recoveredPercentage) + "%"
                }
                
                // data for the user location country
                let totalCase1 = country1?["cases"] as? Double
                let recovered1 = country1?["recovered"] as? Double
                let deaths1 = country1?["deaths"] as? Double
                
                DispatchQueue.main.async {
                    self.userLocationName.text = "Country Name: \(countryName!)"
                    self.totalUserCountry.text = String(totalCase1!)
                    self.recoveredUserCountry.text = String(recovered1!)
                    self.deathsUserCountry.text = String(deaths1!)
                }
                
            }catch{
                print("Error in JSON")
            }
        }
        task.resume()
    }
    
    // function for chart data
    func getChartData() {
        
        // api which contains historical data of last 30 days
        let query = "historical/india?lastdays=30"
        let queryUrl = URL(string: endPoint + query)!

        let session = URLSession.shared

        print(queryUrl)
        let task = session.dataTask(with: queryUrl){
            data, response, error in
            
            //check if there was an error or data absent
            if error != nil || data == nil{
                print("Client Error!")
                return
            }
            
            //check http error code
            let r = response as? HTTPURLResponse
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                print("Server Error \(String(describing: r?.statusCode))")
                return
            }
            
            // Check the correct type of data using MIME
            guard let mime = response.mimeType, mime == "application/json" else{
                print("Incorrect MIME Type: \(String(describing: r?.mimeType))")
                return
            }
            
            // Fetch required elements form the json query
            do{
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String:Any]
                print(json ?? "Error- No JSON Received")
               
                let timeline = json?["timeline"] as? [String:Any]
                let cases = timeline?["cases"] as? [String:Double]
                print(cases!)
                
                var e = [BarChartDataEntry]()
                
                let x = cases!.map{a -> String in
                    return a.key
                }
                
                self.barChart.xAxis.valueFormatter = DefaultAxisValueFormatter(block: {(i, _ ) in
                    return x[Int(i)]
                })
                
                var i = 0
                for d in cases!{
                    e.append(BarChartDataEntry(x:Double(i), y: d.value))
                    i += 1
                }
                
                DispatchQueue.main.async {
                    
                    let set = BarChartDataSet(entries: e,label: "Cases in India")
                    let data = BarChartData(dataSet: set)
                    self.barChart.data = data
                    
                }
                
            }catch{
                print("Error in JSON")
            }
        }
        task.resume()
    }
  
}

// extension using CLGeocoder to retrieve country name from lat and lon

extension CLLocation {
    func fetchCityAndCountry(completion: @escaping (_ city: String?, _ country:  String?, _ error: Error?) -> ()) {
        CLGeocoder().reverseGeocodeLocation(self) { completion($0?.first?.locality, $0?.first?.country, $1) }
    }
}
