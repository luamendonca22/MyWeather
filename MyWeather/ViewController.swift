//
//  ViewController.swift
//  MyWeather
//
//  Created by Luana Mendonça on 06/07/2021.
//


// framework Charts
import Charts

// modular front-end framework for developing fast and powerful web interfaces.
import UIKit

// the framework Apple provides to be able to do this (getting the users location)
import CoreLocation

// - Location CoreLocation: to get the weather for the current area/location/getting the users location
// - custom cell with a collection view, a custom way to show the horizontal aspect of the table that shows the hourly forecast for the current day
// - API, request to get to data

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate /*,ChartViewDelegate*/ {

    // ------------------ Outlets ------------------
    
    // to show the weather for the upcoming days
    @IBOutlet var table: UITableView!
    
    //LineChart Object
    //var lineChart = LineChartView()
    
    
    // ------------------ Variables ------------------
    
    
    public var weatherThreeHours : [[ThreeHourWeather]] = []
    
    // Array of weather objects, that will be created later on. first of all i need to create the struct above below
    var models = [ThreeHourWeather]()
    let locationManager = CLLocationManager()
    var current: _WeatherResponse?
    
    // capture the current coordinates of the user. It's an optional variable to begin with
    var currentLocation: CLLocation?
    
    // ------------------ ViewDidLoad ------------------
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Register 2 custom cells: (1) one to handle the collection view custom cell for the horizontal scrolling for hourly forecast; (2) another to handle the normal vertical cell that shows the current day of the week, the weather icon and the lower/upper temperature for the day
     
        // Registers a nib object that contains a cell with the table view under a specified identifier.
        // The order that I register cells is irrelevant as long as the cell is registered before it is used

        table.register(ThreeHourlyTableViewCell.nib(), forCellReuseIdentifier: ThreeHourlyTableViewCell.identifier)

        table.delegate = self
        table.dataSource = self
        
        table.backgroundColor = UIColor(red: 130/255.0, green: 209/255.0, blue: 255/255.0, alpha: 1.0)
        view.backgroundColor = UIColor(red: 130/255.0, green: 209/255.0, blue: 255/255.0, alpha: 1.0)
        
        //Dot chart
        //lineChart.delegate = self
         
    }
    
    // Notifies the view controller that its view was added to a view hierarchy.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupLocation()
    }
    
    // ------------------ Auxiliary Functions  ------------------
    
    // function to convert the data of temperature from fahrenheit to celsius
    func convert_temp(temp: Float) -> Float{
        let celsius = temp - 273.15
        return celsius
    }
    
    // ------------------ Loccation ------------------
    
    func setupLocation(){
        
        locationManager.delegate = self
        
        // Requests the user’s permission to use location services while the app is in use
        locationManager.requestWhenInUseAuthorization()
        
        // Starts the generation of updates that report the user’s current location
        locationManager.startUpdatingLocation()
        
    }
    
    // Tells the delegate that new location data is available
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !locations.isEmpty, currentLocation == nil {
            currentLocation = locations.first
            
            // Stops the generation of location updates.
            locationManager.stopUpdatingLocation()
            
            // Request the weather data for the current location
            requestWeatherForLocation()
        }
    }
    
    // Request the weather data for the current location
    func requestWeatherForLocation(){
        
        // Assure that the currentLocation is not nill rather than keep the variable currentLocation bellow as an option, otherwise the function ends after the guard return
        guard let currentLocation = currentLocation else {
            return
        }
        
        let long = currentLocation.coordinate.longitude
        let lat = currentLocation.coordinate.latitude

        
        // ------------------ API CALL & REQUEST ------------------
        
        // API CALL
        
        // passing the long and lat values through the url and the API key
        let url = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(long)&appid=6e3999e580c9e2905ee4989fb093d34e"
        
        let url2 = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(long)&appid=6e3999e580c9e2905ee4989fb093d34e"

        // API REQUEST
        
        // Creates a task that retrieves the contents of the specified URL, then calls a handler upon completion
        // The completion handler:
        // (1) Verify that the error parameter is nil. If not, a transport error has occurred; handle the error and exit;
        // (2) Check the response parameter to verify that the status code indicates success and that the MIME type is an expected value. If not, handle the server error and exit;
        // (3) Use the data instance as needed.
        
        URLSession.shared.dataTask(with: URL(string: url)!, completionHandler: {data, response, error in
            
            // We  have three objectives with this function: validation -> convert the API data -> update the interface

            // (1) VALIDATION - make sure we got the data back and there is no error
            
            guard let data = data, error == nil else{
                print ("Something went wrong")

                return
            }
            
            // (2) CONVERT DATA to models/some object that we can use in our code
            // object - the struct weather we ireated

            var json: WeatherResponse?
            do{
                json = try JSONDecoder().decode(WeatherResponse.self, from: data)
                
            }
            catch{
                print("Error: \(error)")
            }
            
            // To unwrapp the optional
            guard let result = json else{
                return
            }
            
            // saving the API data into a models list of ThreeHourWeather objects
            let entries = result.list
            self.models.append(contentsOf: entries)
            
            
            // function to convert the timestamp to a day date
            func getDayFromTimestamp(_ timestamp: String) -> Int {
                
                let myTimeInterval = TimeInterval(timestamp) ?? 0
                let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
                let day = Calendar.current.component(.day, from: time)
                return day
            }
            
            // starting to group the data by day
            var group: [ThreeHourWeather] = []
            var lastDayChecked: Int?
            
            // for each element of the list of ThreeHourWeather objects
            result.list.forEach { [weak self] value in
                
                if lastDayChecked != nil {
                    
                    // verify wich day is the object
                    let newDayCheck = getDayFromTimestamp("\(value.dt)")
                    
                    // if the day it's the same as the last
                    if newDayCheck == lastDayChecked {
                        
                        // keeping building the row
                        group.append(value)
                        
                    // if not
                    } else {
                        
                        // it's a new day. Add the objects of the group list.
                        // it's this list that after will be configured to the rows of the collection view, with the temperature by all days of the week
                        self?.weatherThreeHours.append(group)
                        
                        // reset the auxiliar list with the data of a single day
                        group = []
                        
                        // add the object to that auxiliar list
                        group.append(value)
                        
                        // make the last day as the new
                        lastDayChecked = newDayCheck
                    }
                } else {
                    
                    lastDayChecked = getDayFromTimestamp("\(value.dt)")
                    group.append(value)
                }
            }
            
            // (3) UPDATE USER INTERFACE
            
            // Tells the program to make sure the stuff that's going on here is done on the main thread
            DispatchQueue.main.sync {
                
                // Reloads the rows and sections of the table view.
                self.table.reloadData()
            }
            
        // Resumes the task, if it is suspended. To actually get this request to fire off
        }).resume()
        
        print("\(long) | \(lat)")
        
        URLSession.shared.dataTask(with: URL(string: url2)!, completionHandler: {data, response, error in
            
            // We  have three objectives: validation -> convert the API data -> update the interface

            // (1) VALIDATION - make sure we got the data back and there is no error
            
            guard let data = data, error == nil else{
                print ("Something went wrong")

                return
            }
            
            // (2) CONVERT DATA to models/some object that we can use in our code
            // object - the struct weather we ireated

            var json: _WeatherResponse?
            do{
                json = try JSONDecoder().decode(_WeatherResponse.self, from: data)
                
            }
            catch{
                print("Error: \(error)")
            }
            
            // To unwrapp the optional
            guard let result = json else{
                return
            }
            
            // saving the api data into a variable current
            let current = result
            self.current = current
            
            // (3) UPDATE USER INTERFACE
            
            // Tells the program to make sure the stuff that's going on here is done on the main thread
            DispatchQueue.main.sync {
                
                // Reloads the rows and sections of the table view.
                self.table.reloadData()
                
                self.table.tableHeaderView = self.createTableHeader()
            }
            
        // Resumes the task, if it is suspended. To actually get this request to fire off
        }).resume()
        
    }
   
    // building the headerview containing the current weather data
    
    func createTableHeader() -> UIView{
        
        // create a header view to show the current temperature
        let headerView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 360))
        
        headerView.image = UIImage(named: "headerback")
            
        // Configure the three labels with the size and position
        let indicateLabel = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width - 20, height: headerView.frame.size.height/5))
        let tempLabel = UILabel(frame: CGRect(x: 10, y: indicateLabel.frame.size.height - 10, width: view.frame.size.width - 20, height: headerView.frame.size.height/5))
        let iconImageView = UIImageView(frame: CGRect(x: 270, y: tempLabel.frame.size.height - 70, width: 100, height: headerView.frame.size.height/2))
        
        // Add the subviews
        headerView.addSubview(indicateLabel)
        headerView.addSubview(tempLabel)
        headerView.addSubview(iconImageView)


        // Aligment
        indicateLabel.textAlignment = .center
        tempLabel.textAlignment = .center
        
        // unwrapp the optional
        guard let currentWeather = self.current else{
            return UIView()
        }

        // defining the values of the lables text
        indicateLabel.text = "It's now"
        indicateLabel.font = UIFont(name: "Helvetica-Bold", size: 30)
        indicateLabel.textColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.7)
        
        let value_round = currentWeather.main.temp
        tempLabel.text = "\((round(convert_temp(temp: value_round)*10))/10.0)º"
        tempLabel.font = UIFont(name: "Helvetica-Bold", size: 38)
        tempLabel.textColor = UIColor(red: 66/255.0, green: 121/255.0, blue: 153/255.0, alpha: 1.0)
        
        // configure the contentMode of the image view maintaining the aspect ratio
        iconImageView.contentMode = .scaleAspectFit
        
        // Configure the icon
        let Ico = currentWeather.weather[0].icon
        let urlStr = NSURL(string:"https://openweathermap.org/img/w/\(Ico).png")
        let urlData = NSData(contentsOf: urlStr! as URL)
        if urlData != nil {
            iconImageView.image = UIImage(data: urlData! as Data)
        }
        
        /*
        func getDayFromTimestamp(_ timestamp: String) -> Int {
            let myTimeInterval = TimeInterval(timestamp) ?? 0
            let time = Date(timeIntervalSince1970: TimeInterval(myTimeInterval))
            let day = Calendar.current.component(.day, from: time)
            return day
        }
        
        lineChart.frame = CGRect(x: 40, y: 60 + indicateLabel.frame.size.height + tempLabel.frame.size.height, width: 300, height: 200)
        lineChart.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        view.addSubview(lineChart)
        
        var entries = [ChartDataEntry]()
        for i in 0..<models.count {
            entries.append(ChartDataEntry(x: Double(getDayFromTimestamp(models[i].dt_txt)), y: Double(convert_temp(temp: models[i].main.temp))))
        }
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.joyful()
        
        let data = LineChartData(dataSet: set)
        
        lineChart.data = data
        
        */
        
        return headerView
    }
    
    // ------------------ Table ------------------
    
    
    // define the number of sections of the table
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // this is, the section with the collection view
        return 1
    }
    
    // Tells the data source to return the number of rows in a given section of a table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherThreeHours.count
    }
    
    // Asks the data source for a cell to insert in a particular location of the table view.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ThreeHourlyTableViewCell.identifier, for: indexPath) as! ThreeHourlyTableViewCell
        cell.confiure(with: weatherThreeHours[indexPath.row])
        cell.backgroundColor = UIColor(red: 255/255.0, green: 255/255.0, blue: 255/255.0, alpha: 1.0)
        
        return cell
    }
    
    // The size of each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

}
