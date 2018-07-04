//
//  ViewController.swift
//  MapApp
//
//  Created by Thanh Quach on 7/4/18.
//  Copyright © 2018 Sea Group Limited. All rights reserved.
//

import UIKit
import CoreLocation
import GoogleMaps
import SVProgressHUD

class ViewController: UIViewController {

    var distances: [Double] = [1000, 2000, 3000, 4000 , 5000 , 6000, 7000, 8000, 9000] // meter
    var selectedIndex: Int = 0 {
        didSet {
            let oldSelectedIndex = oldValue + 1

            self.tableView.reloadRows(at: [IndexPath(row: self.selectedIndex + 1, section: 0), IndexPath(row: oldSelectedIndex, section: 0)], with: .fade)
            // Handle map circle
            circleMarker?.radius = distances[selectedIndex]
            let cameraUpdate = GMSCameraUpdate.fit(circleMarker!.bounds())
            self.mapView.animate(with: cameraUpdate)
        }
    }
    let locationManager = CLLocationManager()
    var circleMarker: GMSCircle?

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Info.plist
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
        mapView.isMyLocationEnabled = true
    }

    @IBAction func didTapRefreshBtn(_ sender: Any) {
        SVProgressHUD.show()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SVProgressHUD.dismiss()
            self.selectedIndex = 0
        }
    }

}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let myLocation = locations.first?.coordinate else {
            return
        }

        mapView.animate(to: GMSCameraPosition.camera(withTarget: myLocation, zoom: 14))

        let circleMarker = GMSCircle(position: myLocation, radius: distances[selectedIndex])
        circleMarker.fillColor = UIColor.blue.withAlphaComponent(0.3)
        circleMarker.strokeColor = .black
        circleMarker.map = self.mapView

        // Clean cai cũ đi
        self.circleMarker?.map = nil
        // Gán cái mới vào
        self.circleMarker = circleMarker
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return distances.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DistanceTableViewCell
        // Header
        if indexPath.row == 0 {
            cell.bindingUI(text: "Km", type: .header)
            return cell
        }

        let text = "\(self.distances[indexPath.row-1]/1000)"
        if indexPath.row - 1 == self.selectedIndex {
            cell.bindingUI(text: text, type: .selected)
        } else {
            cell.bindingUI(text: text, type: .normal)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 {
            return nil
        }


        self.selectedIndex = indexPath.row - 1
        return nil
    }
}

extension GMSCircle {
    func bounds () -> GMSCoordinateBounds {
        func locationMinMax(positive : Bool) -> CLLocationCoordinate2D {
            let sign:Double = positive ? 1 : -1
            let dx  = sign * self.radius  / 6378000 * (180/Double.pi)
            let lat = position.latitude + dx
            let lon = position.longitude + dx / cos(position.latitude * .pi/180)
            return CLLocationCoordinate2D(latitude: lat, longitude: lon)
        }
        return GMSCoordinateBounds(coordinate: locationMinMax(positive: true),
                                   coordinate: locationMinMax(positive: false))
    }
}

