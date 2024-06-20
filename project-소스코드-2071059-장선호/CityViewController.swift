//
//  CityViewController.swift
//  ch12-jangseonho-sharedPlan
//
//  Created by Mac on 2023/06/18.
//

import Foundation
import UIKit

class CityViewController: UIViewController {
    
    @IBOutlet weak var cityPickerView: UIPickerView!
    
    var cities: [String: [String:Double]] = [
        "Seoul" : ["lon":126.9778,"lat":37.5683], "Gyeongju" : ["lon":129.2247477, "lat": 35.8561719],
        "Daegu" : ["lon":128.601445,"lat":35.8714354], "jinju" : ["lon":128.1076213, "lat":35.1799817],
        "Jeju" : ["lon":126.5311884, "lat":33.4996213], "Incheon" : ["lon":126.7052062, "lat":37.4562557],
        "Daejeon" : ["lon":127.3845475, "lat":36.3504119], "Jeonju" : ["lon":127.1479532, "lat":35.8242238],
        "Gwangju" : ["lon":126.8526012, "lat":35.1595454], "Busan" : ["lon":129.0756416, "lat":35.1795543],
        "Gangneung" : ["lon":128.8760574, "lat":37.751853], "Ulsan" : ["lon":129.3113596, "lat":35.5383773]
    ]

}

extension CityViewController: UIPickerViewDataSource, UIPickerViewDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let cityNames = Array(cities.keys)
        return cityNames.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var cityNames = Array(cities.keys)
        cityNames.sort()

        return cityNames[row]
    }
}

extension CityViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        cityPickerView.dataSource = self
        cityPickerView.delegate = self
    }
}

extension CityViewController{
    func getCurrentLonLat() -> (String, Double?, Double?){
        
        var cityNames = Array(cities.keys)
        cityNames.sort()
        let selectedCity = cityNames[cityPickerView.selectedRow(inComponent: 0)]
        let city = cities[selectedCity]
        return (selectedCity, city!["lon"], city!["lat"])
    }
}

