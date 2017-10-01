//
//  ViewController.h
//  Nearby
//
//  Created by Neil Loknath on 2017-09-30.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) IBOutlet UIButton *refreshButton;
@property (nonatomic) IBOutlet UILabel *locationLabel;
@property (nonatomic) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)didTapRefreshButton:(id)sender;

@end

