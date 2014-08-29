//
//  OPTableViewCell.m
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "OPTableViewCell.h"

@implementation OPTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  if (self) {
    // Initialization code
    self.lblIndex = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 60, 60)];
    self.lblIndex.backgroundColor = [UIColor clearColor];
    self.lblIndex.textColor = [UIColor whiteColor];
    self.lblIndex.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:28];
    [self.contentView addSubview:self.lblIndex];
    
    
    self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.lblIndex.right+5, 0,isIPad?630:200, 60)];
    self.lblTitle.backgroundColor = [UIColor clearColor];
    self.lblTitle.textColor = [UIColor whiteColor];
    self.lblTitle.font = [UIFont systemFontOfSize:16];
    self.lblTitle.numberOfLines = 0;
    [self.contentView addSubview:self.lblTitle];
    
    self.btnChecked = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btnChecked.frame = CGRectMake(self.lblTitle.right+2.5, 10, 40, 40);
    self.btnChecked.layer.masksToBounds = YES;
    self.btnChecked.layer.cornerRadius = 20;
    self.btnChecked.layer.borderWidth = 1.0;
    self.btnChecked.layer.borderColor = [[UIColor colorWithRGBHex:0xffffff alpha:0.3] CGColor];
    
    UIImageView *checkMark = [[UIImageView alloc] initWithFrame:CGRectMake(8, 8, 24, 24)];
    checkMark.image = [UIImage imageNamed:@"icon_checkmark"];
    [self.btnChecked addSubview:checkMark];
    
    [self.contentView addSubview:self.btnChecked];
  }
  return self;
}


- (void)refreshOPTableViewCell:(NSDictionary *)sources row:(NSInteger)row{
  NSInteger titleStartIndex = 4;
  
  if (row+1<10) {
    self.lblIndex.text = [NSString stringWithFormat:@"00%d.",(int)row+1];
    titleStartIndex+=0;
  }
  else if (row+1<100){
    self.lblIndex.text = [NSString stringWithFormat:@"0%d.",(int)row+1];
    titleStartIndex+=1;
  }
  else{
    self.lblIndex.text = [NSString stringWithFormat:@"%d.",(int)row+1];
    titleStartIndex+=2;
  }
  
  if ([[[sources safeStringObjectForKey:@"title"] substringToIndex:1] isEqualToString:@"第"]) {
    self.lblTitle.text = [[sources safeStringObjectForKey:@"title"] substringFromIndex:titleStartIndex];
  }
  else{
    self.lblTitle.text = [sources safeStringObjectForKey:@"title"];
  }
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
