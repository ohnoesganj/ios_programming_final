//
//  MapViewController.swift
//  ch12-jangseonho-sharedPlan
//
//  Created by Mac on 2023/06/18.
//

import Foundation
import UIKit
import MapKit

class MapViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    let baseURLString = "https://api.openweathermap.org/data/2.5/weather"
    let apikey = "981a23e2f0b25f8ed91307b872126dc2"
    
    @IBAction func sgcValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            mapView.mapType = .standard
        case 1:
            mapView.mapType = .hybrid
        case 2:
            mapView.mapType = .satellite
        default:
            mapView.mapType = .standard
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

extension MapViewController {
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        let parent = self.parent as! UITabBarController
        let cityViewController = parent.viewControllers![1] as! CityViewController
        let (city, longitute, latitute) = cityViewController.getCurrentLonLat()
        
        getWeatherData(cityName: city)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
    }
}

extension MapViewController {
    func updateMap(title: String, longitude: Double?, latitute: Double?) {
        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var center = mapView.centerCoordinate
        if let longitude = longitude, let latitute = latitute {
            center = CLLocationCoordinate2D(latitude: latitute, longitude: longitude)
        }
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
}

extension MapViewController {
    func getWeatherData(cityName city: String) {
        var urlStr = baseURLString+"?"+"q="+city+"&"+"appid="+apikey
        urlStr = urlStr.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let session = URLSession(configuration: .default)
        let url = URL(string: urlStr)
        let request = URLRequest(url: url!)
        
        let dataTask = session.dataTask(with: request) {
            (data, response, error) in
            guard let jsonData = data else {print(error!); return}
            if let jsonStr = String(data: jsonData, encoding: .utf8) {
                print(jsonStr)
            }
            let (temperature, longitude, latitute) = self.extractWeatherData(jsonData: jsonData)
            var title = city
            if let temperature = temperature{
                title += String.init(format: ": %.2f◦C", temperature)
            }
            self.updateMap(title: title, longitude: longitude, latitute: latitute)
        }
        dataTask.resume()
    }
}

extension MapViewController {
    func extractWeatherData(jsonData: Data) -> (Double?, Double?, Double?) {
        let json = try! JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        
        if let code = json["cod"] {
            if code is String, code as! String == "404" {
                return (nil, nil, nil)
            }
        }
        
        let latitute = (json["coord"] as! [String: Double])["lat"]
        let longitude = (json["coord"] as! [String: Double])["lon"]
        
        guard var temperature = (json["main"] as! [String: Double])["temp"] else{
            return (nil, longitude, latitute)
        }
        
        temperature = temperature - 273.0
        return (temperature, longitude, latitute)
    }
}



extension MapViewController{
    func updateMap(title: String, longitute: Double?, latitute: Double?){

        let span = MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
        var center = mapView.centerCoordinate // 일단 기존의 중심을 저장
        if let longitute = longitute, let latitute = latitute{
            center = CLLocationCoordinate2D(latitude: latitute, longitude: longitute) // 새로운 중심 설정
        }
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true) // 주어진 영역으로 지도를 설정
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = center    // 센터에 annotation을 설치
        annotation.title = title
        mapView.addAnnotation(annotation)
    }
}
