//
//  CurrentData.swift
//  MyWeather
//
//  Created by Luana Mendonça on 21/07/2021.
//

import Foundation

// ------------------ Structs ------------------

// To define the weather data types

struct _WeatherResponse: Codable{
    let coord: _CoordinatesLocal
    let weather: [_WeatherDescription]
    let base: String
    let main: _WeatherMainData
    let visibility: Int
    let wind: _WindData
    let clouds: _WeatherClouds
    let dt: Int
    let sys: _SystemWeather
    let timezone: Int
    let id: Int
    let name: String
    let cod: Int
}

struct _CoordinatesLocal: Codable{
    let lon: Float
    let lat: Float
}

struct _WeatherDescription: Codable{
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct _WeatherMainData: Codable{
    let temp: Float
    let feels_like: Float
    let temp_min: Float
    let temp_max: Float
    let pressure: Int
    let humidity: Int
}

struct _WindData: Codable{
    let speed: Float
    let deg: Int
}

struct _WeatherClouds: Codable{
    let all: Int
}

struct _SystemWeather: Codable{
    let type: Int
    let id: Int
    let country: String
    let sunrise: Int
    let sunset: Int
}
