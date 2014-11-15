//
//  MapViewController.swift
//  Timetabler
//
//  Created by Daniel Koehler on 14/11/2014.
//  Copyright (c) 2014 DanielKoehler. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var map:MKMapView?
    
    var routeOverlay:MKPolyline?
    var currentRoute:MKRoute?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "C/2.07"
        self.view.backgroundColor = UIColor.whiteColor()
        
        
        self.map = MKMapView()
        self.map!.frame = self.view.bounds;
        self.map!.autoresizingMask = self.view.autoresizingMask;
        self.map!.delegate = self
        self.view.addSubview(map!)
        
        
        
        var userCoordinate = map?.userLocation.coordinate
        var longitudeDeltaDegrees : CLLocationDegrees = 0.03
        var latitudeDeltaDegrees : CLLocationDegrees = 0.03
        var userSpan = MKCoordinateSpanMake(latitudeDeltaDegrees, longitudeDeltaDegrees)
        var userRegion = MKCoordinateRegionMake(userCoordinate!, userSpan)
        
        map?.setRegion(userRegion, animated: true)

        
        
        
        var directionsRequest = MKDirectionsRequest()
        
        var source = MKMapItem.mapItemForCurrentLocation()
        
        
        // Make the destination
        var destinationCoords = CLLocationCoordinate2DMake(51.484110, -3.169481)
        
        var destinationPlacemark = MKPlacemark(coordinate:destinationCoords, addressDictionary:nil)
        
        var destination = MKMapItem(placemark:destinationPlacemark)
        
        // Set the source and destination on the request
        directionsRequest.setSource(source)
        directionsRequest.setDestination(destination)
        
        var directions = MKDirections(request:directionsRequest)
        
        var point = MKPointAnnotation()
        point.coordinate = destinationPlacemark.coordinate
        point.title = "C/2.07"
        point.subtitle = "Alogorithms and Datastructures"
        
        self.map!.addAnnotation(point)
        
        directions.calculateDirectionsWithCompletionHandler { (response, error) -> Void in
            
            if (error != nil) {
                
                NSLog("There was an error getting your directions");
                return;
                
            }
            
            println("About to show ")
            
            self.currentRoute = response.routes.first as? MKRoute
            
            self.plotRouteOnMap(self.currentRoute!)
        
        }
        
//        MKMapView.

        // Do any additional setup after loading the view.
    }
    
    func plotRouteOnMap(route:MKRoute)
    {
        
        if(routeOverlay != nil) {
            self.map!.removeOverlay(routeOverlay!)
        }
    
        // Update the ivar
        routeOverlay = route.polyline;
    
        // Add it to the map
        self.map!.addOverlay(routeOverlay)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        
        if overlay is MKPolyline {
            var polylineRenderer = MKPolylineRenderer(overlay: overlay)
            polylineRenderer.strokeColor = UIColor.blueColor()
            polylineRenderer.lineWidth = 5
            return polylineRenderer
        }
        
        return nil
        
    }

}
