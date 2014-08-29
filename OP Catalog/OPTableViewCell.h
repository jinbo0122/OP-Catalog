//
//  OPTableViewCell.h
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPTableViewCell : UITableViewCell
@property(nonatomic, strong)UILabel *lblIndex;
@property(nonatomic, strong)UILabel *lblTitle;
@property(nonatomic, strong)UIButton *btnChecked;

- (void)refreshOPTableViewCell:(NSDictionary *)sources row:(NSInteger)row;
@end
