//
//  OPContentCell.h
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OPContentCell : UICollectionViewCell
@property(nonatomic, strong)UILabel *lblGeneralTitle;
@property(nonatomic, strong)UILabel *lblTitle;
@property(nonatomic, strong)UILabel *lblPublishTime;
@property(nonatomic, strong)UILabel *lblEpisodeInfo;
@property(nonatomic, strong)UILabel *lblContent;
@property(nonatomic, strong)UIImageView *imagePreview;

- (void)refreshContentView:(NSDictionary *)sources;
@end
