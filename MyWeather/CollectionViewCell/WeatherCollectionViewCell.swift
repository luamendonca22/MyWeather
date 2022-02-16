//
//  WeatherCollectionViewCell.swift
//  MyWeather
//
//  Created by Luana Mendonça on 19/07/2021.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // identifier for this costum cell
    static let identifier = "WeatherCollectionViewCell"
    
    static func nib() -> UINib{
        return UINib (nibName: "WeatherCollectionViewCell", bundle: nil)
    }
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var tempLabel: UILabel!
    @IBOutlet var time: UILabel!
    
    // configure the cell with the actual content of it (a ThreeHourWeather object)
    
    func convert_temp(temp: Float) -> Float{
        let celsius = temp - 273.15
        return celsius
    }
    
    func configure(with models: ThreeHourWeather){
        self.tempLabel.text = "\(Int(convert_temp(temp: models.main.temp)))º"
        
        let time = models.dt_txt
        let result = time.split(separator: " ")
        
        let hour = result[1].components(separatedBy: [":"])
        self.time.text = "\(hour[0])"
        
        // Configure the icon
        let Ico = models.weather[0].icon
        let urlStr = NSURL(string:"https://openweathermap.org/img/w/\(Ico).png")
        let urlData = NSData(contentsOf: urlStr! as URL)
        if urlData != nil {
            self.iconImageView.image = UIImage(data: urlData! as Data)
        }
        self.iconImageView.contentMode = .scaleAspectFit

    }
    
}
