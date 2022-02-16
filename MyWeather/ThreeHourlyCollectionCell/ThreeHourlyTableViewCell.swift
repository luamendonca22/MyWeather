//
//  ThreeHourlyTableViewCell.swift
//  MyWeather
//
//  Created by Luana Mendonça on 18/07/2021.
//

import UIKit

// UICollectionViewDelegateFlowLayout allows me to 
class ThreeHourlyTableViewCell: UITableViewCell, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource {
   
    // ------------------ Variables ------------------
 
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var dayWeek: UILabel!
    @IBOutlet var collectionBackground: UIImageView!
    
    var models = [ThreeHourWeather]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        collectionView.register(WeatherCollectionViewCell.nib(), forCellWithReuseIdentifier: WeatherCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    // identifier for this costum cell
    static let identifier = "ThreeHourlyTableViewCell"
    
    static func nib() -> UINib{
        return UINib (nibName: "ThreeHourlyTableViewCell", bundle: nil)
    }
    
    // function to return the date from timestamp to "EEE, MMM d" like Thursday, Jun 2
    func getDayFromTimestamp(_ date: Date?) -> String {
        guard let inputDate = date else{
            return ""
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: inputDate)
    }
    
    // configure the cell with the actual content of it (a list of ThreeHourWeather objects)
    func confiure(with models: [ThreeHourWeather]){
        
        self.models = models
        
        // for each item [ThreeHourWeather] show the day
        models.forEach { value in
            
            self.dayWeek.text = getDayFromTimestamp(Date(timeIntervalSince1970: TimeInterval(value.dt)))
            self.dayWeek.font = UIFont(name: "Helvetica-Bold", size: 19)
            self.dayWeek.textColor = UIColor(red: 66/255.0, green: 121/255.0, blue: 153/255.0, alpha: 1.0)
        }
        collectionBackground.backgroundColor = UIColor(red: 130/255.0, green: 209/255.0, blue: 255/255.0, alpha: 1.0)
        collectionView.reloadData()
    }
    
    // Asks the delegate for the size of the specified item’s cell (WWeatherCollectionViewCell, wich contains the objects ThreeHourWeather)
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    // Asks your data source object for the number of items in the specified section, this is, all the items ThreeHourWeather of the API result
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    
    // Asks your data source object for the cell that corresponds to the specified item in the collection view, this is, the cell i created to add the objects of the each item of this collection view.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WeatherCollectionViewCell.identifier, for: indexPath) as! WeatherCollectionViewCell
        cell.configure(with: models[indexPath.row])
        return cell
    }
}
