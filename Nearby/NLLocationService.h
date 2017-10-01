//
//  NLLocationService.h
//  Nearby
//
//  Created by Neil Loknath on 2017-09-30.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

#import <Foundation/Foundation.h>
@import MapKit;
@import CoreLocation;

extern NSString * const kNLLocationServiceDidStartMonitoring;
extern NSString * const kNLLocationServiceDidUpdatePointsOfInterest;
extern NSString * const kNLLocationServiceDidUpdatePointsOfInterestKey;

@interface NLLocationService : NSObject <CLLocationManagerDelegate>

- (void)searchWithCriteria:(NSString *)criteria completion:(void (^)(NSArray<MKMapItem*>*))completion;
- (void)searchWithCompletion:(void (^)(NSArray<CLPlacemark*>*))completion;
- (NSArray *)placemarks:(NSArray<CLPlacemark *> *)items withDistanceFromCurrentLocation:(NSInteger)meters;
- (void)startLocationMonitoring;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) CLLocationCoordinate2D currentLocation;

@end
