//
//  NLLocationService.m
//  Nearby
//
//  Created by Neil Loknath on 2017-09-30.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

#import "NLLocationService.h"

NSString * const kNLLocationServiceDidStartMonitoring = @"kNLLocationServiceDidStartMonitoring";
NSString * const kNLLocationServiceDidUpdatePointsOfInterest = @"kNLLocationServiceDidUpdatePointsOfInterest";
NSString * const kNLLocationServiceDidUpdatePointsOfInterestKey = @"mapItems";


@interface NLLocationService()
@property (nonatomic) NSDate *lastSearchTime;
@end

@implementation NLLocationService

- (void)startLocationMonitoring {
    // Create the location manager if this object does not
    // already have one.
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
        self.locationManager.allowsBackgroundLocationUpdates = YES;
        self.locationManager.activityType = CLActivityTypeOther;
        self.locationManager.delegate = self;
    }
    
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        return;
    }
    
    if (!self.locationManager.locationServicesEnabled) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNLLocationServiceDidStartMonitoring object:nil];
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    self.currentLocation = self.locationManager.location.coordinate;
}

- (void)searchWithCriteria:(NSString *)criteria completion:(void (^)(NSArray<MKMapItem*>*))completion {
    if (!CLLocationCoordinate2DIsValid(self.currentLocation)) {
        return;
    }
    
    if (!completion) {
        return;
    }
    
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.region = MKCoordinateRegionMake(self.currentLocation, MKCoordinateSpanMake(0.1, 0.1));
    request.naturalLanguageQuery = criteria;
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        if (error) {
            NSLog(@"%@ - searchWithCriteria error: %@", NSStringFromClass([self class]), error);
            completion(@[]);
            return;
        }
        
        completion(response.mapItems);
    }];
}

- (void)searchWithCompletion:(void (^)(NSArray<CLPlacemark *> *))completion {
    NSDate *searchTime = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval fiveMinutes = 60 * 5;
    if (self.lastSearchTime && [searchTime timeIntervalSinceDate:self.lastSearchTime] <= fiveMinutes) {
        return;
    }
    self.lastSearchTime = searchTime;
    
    id categories = @[@"electronics", @"clothing", @"restaurants", @"movies"];

    __block NSInteger totalRequests = [categories count];
    NSMutableArray<CLPlacemark *> *allMapItems  = [NSMutableArray array];
    
    void(^done)(NSArray<MKMapItem *> *) = ^(NSArray<MKMapItem *> *items) {
        totalRequests--;
        for (MKMapItem *item in items) {
            [allMapItems addObject:item.placemark];
        }
        if (!totalRequests) {
            completion(allMapItems);
        }
    };
    
    // TODO can we make just 1 request?
    for (id category in categories) {
        [self searchWithCriteria:category completion:^(NSArray<MKMapItem *> *items) {
            done(items);
        }];
    }
}

- (NSArray *)placemarks:(NSArray<CLPlacemark *> *)items withDistanceFromCurrentLocation:(NSInteger)meters {
    if (!CLLocationCoordinate2DIsValid(self.currentLocation)) {
        return items;
    }
    
    CLLocation *currentLocation = [[CLLocation alloc] initWithLatitude:self.currentLocation.latitude longitude:self.currentLocation.longitude];
    
    return [items filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(CLPlacemark*  _Nullable item, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [item.location distanceFromLocation:currentLocation] <= meters;
    }]];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self.currentLocation = locations.lastObject.coordinate;
    NSLog(@"%@ - locationManager didUpdateLocations with locations: %@", NSStringFromClass([self class]), locations);
    
    [self searchWithCompletion:^(NSArray<MKMapItem *> *items) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNLLocationServiceDidUpdatePointsOfInterest object:nil userInfo:@{kNLLocationServiceDidUpdatePointsOfInterestKey: items}];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@ - locationManager didFailWithError: %@", NSStringFromClass([self class]), error);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status != kCLAuthorizationStatusAuthorizedAlways) {
        return;
    }
    
    [self startLocationMonitoring];
}

@end
