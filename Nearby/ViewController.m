//
//  ViewController.m
//  Nearby
//
//  Created by Neil Loknath on 2017-09-30.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

@import MapKit;
@import CoreLocation;
@import Contacts;

#import "AppDelegate.h"
#import "ViewController.h"
#import "NLLocationService.h"

@interface ViewController ()
@property (nonatomic) NSMutableArray<CLPlacemark*> *pointsOfInterest;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshLocation];
    self.tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didStartMonitoringLocation:) name:kNLLocationServiceDidStartMonitoring object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pointsOfInterestDidUpdate:) name:kNLLocationServiceDidUpdatePointsOfInterest object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showLoading {
    [self.spinner startAnimating];
    self.spinner.hidden = NO;
    [self.pointsOfInterest removeAllObjects];
    [self.tableView reloadData];
}

- (void)hideLoading {
    [self.spinner stopAnimating];
    self.spinner.hidden = YES;
    [self.tableView reloadData];
}

- (void)refreshLocation {
    [self showLoading];
    
    NLLocationService *locationService = ((AppDelegate*)[UIApplication sharedApplication].delegate).locationService;

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        [self hideLoading];
        [locationService.locationManager requestAlwaysAuthorization];
        return;
    }
    
    [locationService.locationManager requestLocation];
}

- (void)updateViewsForLocations:(NSArray *)locations {
    NLLocationService *locationService = ((AppDelegate*)[UIApplication sharedApplication].delegate).locationService;
    locations = [locationService placemarks:locations withDistanceFromCurrentLocation:1000];
    self.pointsOfInterest = [NSMutableArray arrayWithArray:locations];
    
    self.locationLabel.text = [NSString stringWithFormat:@"Current location: %f %f", locationService.currentLocation.latitude, locationService.currentLocation.longitude];
    
    [self hideLoading];
}

- (void)didTapRefreshButton:(id)sender {
    [self refreshLocation];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.pointsOfInterest.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 125;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        cell.detailTextLabel.numberOfLines = 0;
    }
    
    cell.textLabel.text = [self cellLabelForIndex:indexPath.row];
    cell.detailTextLabel.text = [self cellDetailLabelForIndex:indexPath.row];
    return cell;
}

- (NSString *)cellLabelForIndex:(NSInteger)index {
    if (index < 0 || index >= self.pointsOfInterest.count) {
        return @"";
    }
    
    CLPlacemark *placemark = self.pointsOfInterest[index];
    return placemark.name;
}


- (NSString *)cellDetailLabelForIndex:(NSInteger)index {
    if (index < 0 || index >= self.pointsOfInterest.count) {
        return @"";
    }
    
    CLPlacemark *placemark = self.pointsOfInterest[index];
    NSMutableString *string = [NSMutableString string];
    [string appendString:[CNPostalAddressFormatter stringFromPostalAddress:placemark.postalAddress style:CNPostalAddressFormatterStyleMailingAddress]];
    [string appendString:@"\n"];
    [string appendString:[NSString stringWithFormat:@"%@", placemark.location]];
    
    return string;
}

- (void)didStartMonitoringLocation:(NSNotification *)notification {
    [self refreshLocation];
}

- (void)pointsOfInterestDidUpdate:(NSNotification *)notification {
    NSArray *locations = notification.userInfo[kNLLocationServiceDidUpdatePointsOfInterestKey];
    [self updateViewsForLocations:locations];
}

@end
