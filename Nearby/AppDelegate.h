//
//  AppDelegate.h
//  Nearby
//
//  Created by Neil Loknath on 2017-09-30.
//  Copyright © 2017 Neil Loknath. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NLLocationService.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) NLLocationService *locationService;

@end

