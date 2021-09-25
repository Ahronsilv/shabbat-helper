//
//  ViewController.swift
//  shabbat-helper
//
//  Created by Haim Aharon Zilberman on 25/09/2021.
//

import UIKit
import CoreLocation

class ViewController:
    
    UIViewController {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var lblHebrew: UILabel!
    
    let locationManager = CLLocationManager()
    
    var stm = ShabbatTimesMind()
    var si = [ShabbatItem]()
    
    let spinner = SpinnerViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblDate.text = ""
        lblTime.text = ""
        lblHebrew.text = ""
        
        createSpinnerView()
        
        cardView.layer.cornerRadius = 5
        cardView.layer.masksToBounds = true;
        
        locationManager.delegate = self
        stm.delegate = self
        locationManager.requestLocation()
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func createSpinnerView() {
        // add the spinner view controller
        addChild(spinner)
        spinner.view.frame = view.frame
        view.addSubview(spinner.view)
        spinner.didMove(toParent: self)
    }

    func removeSpinnerView()
    {
        spinner.willMove(toParent: nil)
        spinner.view.removeFromSuperview()
        spinner.removeFromParent()
    }
    
}

extension ViewController : ShabbatTimesDelegate {
    func didReceiveResults(with st: ShabbatTimes) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        si = st.items
        for item in si {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = dateFormatter.date(from:item.date) {
                if date >= Date() {
                    dateFormatter.dateFormat = "dd/MM/yyyy"
                    lblDate.text = dateFormatter.string(from: date)
                    dateFormatter.dateFormat = "HH:mm"
                    lblTime.text = dateFormatter.string(from: date)
                    lblHebrew.text = item.hebrew
                    removeSpinnerView()
                    break
                }
            }
        }
    }
}

extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            locationManager.stopUpdatingLocation()
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            stm.updateData(lat: Float(latitude), long: Float(longitude), timesoneId: TimeZone.current.identifier)
        }
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        print("Unable to get location")
    }
}
