//
//  PDAppDelegate.h
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPTableViewController.h"
@interface OPAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) OPTableViewController  *opTBC;
@property (strong, nonatomic) OPNavigationViewController *nav;
@end
