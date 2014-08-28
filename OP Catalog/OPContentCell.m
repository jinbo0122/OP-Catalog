//
//  OPContentCell.m
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "OPContentCell.h"

@implementation OPContentCell

- (id)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  if (self) {
    // Initialization code
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblTitle.backgroundColor = [UIColor clearColor];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.font = [UIFont systemFontOfSize:20];
    self.lblTitle.numberOfLines = 0;
        
    self.lblContent = [[UILabel alloc] initWithFrame:CGRectZero];
    self.lblContent.backgroundColor = [UIColor clearColor];
    self.lblContent.textColor = [UIColor whiteColor];
    self.lblContent.font = [UIFont systemFontOfSize:15];
    self.lblContent.numberOfLines = 0;
    
    self.imagePreview = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:self.lblContent];
    [self.contentView addSubview:self.lblTitle];
    [self.contentView addSubview:self.imagePreview];
  }
  return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
