//
//  MapViewController.m
//  Nearby
//
//  Created by Neil Loknath on 2017-10-01.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

#import "MapViewController.h"
#import "NLLocationService.h"
#import "AppDelegate.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
     NLLocationService *locationService = ((AppDelegate*)[UIApplication sharedApplication].delegate).locationService;
    self.mapView.centerCoordinate = locationService.currentLocation;
    self.mapView.region = MKCoordinateRegionMakeWithDistance(self.mapView.centerCoordinate, 1000, 1000);
    [self.mapView addAnnotations:self.placemarks];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:@"CustomPinAnnotationView"];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
    }
    
    return pinView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
