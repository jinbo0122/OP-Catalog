//
//  OPContentViewController.h
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPTableViewController.h"
@interface OPContentViewController : UIViewController
@property(nonatomic, weak)OPTableViewController *delegate;
- (id)initWithSource:(NSDictionary *)source index:(NSInteger)index;
@end
