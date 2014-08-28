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
    self.lblTitle = [UILabel initWithFrame:CGRectZero
                                   bgColor:[UIColor clearColor]
                                 textColor:[UIColor whiteColor]
                                      text:@""
                             textAlignment:NSTextAlignmentLeft
                                      font:[UIFont systemFontOfSize:20]
                             numberOfLines:0];
    
    self.lblContent = [UILabel initWithFrame:CGRectZero
                                     bgColor:[UIColor clearColor]
                                   textColor:[UIColor whiteColor]
                                        text:@""
                               textAlignment:NSTextAlignmentLeft
                                        font:[UIFont systemFontOfSize:15]
                               numberOfLines:0];
    
    self.lblEpisodeInfo = [UILabel initWithFrame:CGRectZero
                                         bgColor:[UIColor clearColor]
                                       textColor:[UIColor colorWithRGBHex:0xadadad]
                                            text:@""
                                   textAlignment:NSTextAlignmentLeft
                                            font:[UIFont systemFontOfSize:15]
                                   numberOfLines:1];
    
    self.lblPublishTime = [UILabel initWithFrame:CGRectZero
                                         bgColor:[UIColor clearColor]
                                       textColor:[UIColor colorWithRGBHex:0xadadad]
                                            text:@""
                                   textAlignment:NSTextAlignmentRight
                                            font:[UIFont systemFontOfSize:15]
                                   numberOfLines:1];
    
    self.imagePreview = [[UIImageView alloc] initWithFrame:CGRectZero];
    
    [self.contentView addSubview:self.lblContent];
    [self.contentView addSubview:self.lblTitle];
    [self.contentView addSubview:self.lblEpisodeInfo];
    [self.contentView addSubview:self.lblPublishTime];
    [self.contentView addSubview:self.imagePreview];
  }
  return self;
}


- (void)refreshContentView:(NSDictionary *)sources{
  self.lblTitle.text = [sources safeStringObjectForKey:@"title"];
  
  CGRect titleRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake(300, 50)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                                context:nil];
  self.lblTitle.frame = CGRectMake(10, 20+64, titleRect.size.width, titleRect.size.height);
  
  
  NSString *strEpisodeInfo = [NSString stringWithFormat:@"S%@-E%@",[sources safeNumberObjectForKey:@"season"],[sources safeNumberObjectForKey:@"episode"]];
  
  self.lblEpisodeInfo.text = strEpisodeInfo;
  self.lblEpisodeInfo.frame = CGRectMake(10, self.lblTitle.bottom+5, 300, 16);
  
  
  self.lblPublishTime.text = [@"播出时间:" stringByAppendingString:[NSString timeString:[[sources safeNumberObjectForKey:@"first_aired"] doubleValue]+3600
                                                                             format:MHPrettyDateFormatNoTime]] ;
  self.lblPublishTime.frame = CGRectMake(10, self.lblTitle.bottom+5, 300, 16);

  
  self.imagePreview.frame = CGRectMake(10, self.lblPublishTime.bottom+10, 300, 225);
  
  NSString *url = [[sources safeDicObjectForKey:@"images"] safeStringObjectForKey:@"screen"];
  
  [self.imagePreview setImageWithURL:[NSURL URLWithString:url]];
  
  self.lblContent.text = [sources safeStringObjectForKey:@"content"];
  CGRect contentRect = [self.lblContent.text boundingRectWithSize:CGSizeMake(300, 10000)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:self.lblContent.font}
                                                                    context:nil];
  
  self.lblContent.frame = CGRectMake(10, self.imagePreview.bottom+20, contentRect.size.width, contentRect.size.height);
  
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
