//
//  ForecastData.swift
//  MyWeather
//
//  Created by Luana Mendonça on 21/07/2021.
//

import Foundation

// ------------------ Structs ------------------

// To define the weather data types

struct WeatherResponse: Codable {
    let cod: String
    let message: Int
    let cnt: Int
    let list: [ThreeHourWeather]
    let city: CityDescription
}

struct ThreeHourWeather: Codable{
    let dt: Int
    let dt_txt: String
    let main: WeatherMainData
    let weather: [WeatherDescription]
    let clouds: WeatherClouds
    let wind: WindData
    let visibility: Int
    let pop: Float
    let sys: SystemWeather
}
 
struct CityDescription: Codable{
    let id: Int
    let name: String
    let coord: CoordinatesLocal
    let country: String
    let population: Int
    let timezone: Int
    let sunrise: Int
    let sunset: Int
}

struct WeatherMainData: Codable{
    let temp: Float
    let feels_like: Float
    let temp_min: Float
    let temp_max: Float
    let pressure: Int
    let sea_level: Int
    let grnd_level: Int
    let humidity: Int
    let temp_kf: Float
}

struct WeatherDescription: Codable{
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct CoordinatesLocal: Codable{
    let lat: Float
    let lon: Float
}

struct WeatherClouds: Codable{
    let all: Int
}

struct WindData: Codable{
    let speed: Float
    let deg: Int
    let gust: Float
}

struct SystemWeather: Codable{
    let pod: String
}
