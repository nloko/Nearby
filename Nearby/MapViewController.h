//
//  MapViewController.h
//  Nearby
//
//  Created by Neil Loknath on 2017-10-01.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

#import <UIKit/UIKit.h>
@import MapKit;

@interface MapViewController : UIViewController<MKMapViewDelegate>
@property (nonatomic) NSArray *placemarks;
@property (nonatomic) IBOutlet MKMapView *mapView;
@end
