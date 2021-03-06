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
    self.bgScrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
    self.bgScrollView.alwaysBounceVertical = YES;
    [self.contentView addSubview:self.bgScrollView];
    
    
    self.lblTitle = [UILabel initWithFrame:CGRectZero
                                   bgColor:[UIColor clearColor]
                                 textColor:[UIColor whiteColor]
                                      text:@""
                             textAlignment:NSTextAlignmentCenter
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
    self.imagePreview.layer.masksToBounds = YES;
    self.imagePreview.layer.borderWidth = 0.5;
    self.imagePreview.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.tapGesture = [[UITapGestureRecognizer alloc] init];
    [self.imagePreview addGestureRecognizer:self.tapGesture];
    self.imagePreview.userInteractionEnabled = YES;
    [self.bgScrollView addSubview:self.lblContent];
    [self.bgScrollView addSubview:self.lblTitle];
    [self.bgScrollView addSubview:self.lblEpisodeInfo];
    [self.bgScrollView addSubview:self.lblPublishTime];
    [self.bgScrollView addSubview:self.imagePreview];
  }
  return self;
}


- (void)refreshContentView:(NSDictionary *)sources index:(NSInteger)index{
  
  //  self.lblGeneralTitle.text = [sources safeStringObjectForKey:@"generalTitle"];
  
  self.lblTitle.text = [sources safeStringObjectForKey:@"title"];
  
  CGRect titleRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake(UIScreenWidth-20, 50)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                      context:nil];
  self.lblTitle.frame = CGRectMake((UIScreenWidth-titleRect.size.width)/2.0, 10+64,titleRect.size.width, titleRect.size.height);
  
  
  NSString *strEpisodeInfo = [NSString stringWithFormat:@"S%@-E%@ ~ No.%d",[sources safeNumberObjectForKey:@"season"],
                              [sources safeNumberObjectForKey:@"episode"],(int)(index+1)];
  
  self.lblEpisodeInfo.text = strEpisodeInfo;
  
  CGSize infoSize = [strEpisodeInfo sizeWithAttributes:@{NSFontAttributeName:self.lblEpisodeInfo.font}];
  self.lblEpisodeInfo.frame = CGRectMake(15, self.lblTitle.bottom+10,infoSize.width, 16);
  
  
  self.lblPublishTime.text = [@"播出时间:" stringByAppendingString:[NSString timeString:[[sources safeNumberObjectForKey:@"first_aired"] doubleValue]+3600
                                                                             format:MHPrettyDateFormatNoTime]];
  CGSize timeSize = [self.lblPublishTime.text sizeWithAttributes:@{NSFontAttributeName:self.lblPublishTime.font}];
  self.lblPublishTime.frame = CGRectMake(UIScreenWidth-timeSize.width-15, self.lblEpisodeInfo.top,timeSize.width, 16);
  
  
  CGFloat imageWidth = MIN(UIScreenWidth-20, UIScreenHeight-20);
  
  self.imagePreview.frame = CGRectMake((UIScreenWidth-imageWidth)/2.0, self.lblPublishTime.bottom+15, imageWidth, imageWidth*9/16.0);
  
  __weak typeof(self) wSelf = self;
  NSString *url = [sources safeStringObjectForKey:@"screen"];
  [self.imagePreview setImageWithURL:[NSURL URLWithString:url]
                    placeholderImage:nil
                             options:SDWebImageRetryFailed
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             if (!error) {
                               wSelf.imagePreview.height = imageWidth * image.size.height/image.size.width;
                               wSelf.lblContent.top = wSelf.imagePreview.bottom+20;
                               wSelf.bgScrollView.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
                               wSelf.bgScrollView.contentSize = CGSizeMake(UIScreenWidth, wSelf.lblContent.bottom+10);
                               
                               wSelf.bgScrollView.scrollEnabled = wSelf.bgScrollView.contentSize.height>UIScreenHeight;
                             }
                           }];
  
  self.imagePreview.hidden = url.length==0;
  
  self.lblContent.text = [sources safeStringObjectForKey:@"content"];
  
  NSString *content = [sources safeStringObjectForKey:@"content"];
  self.lblContent.text = content.length==0?[sources safeStringObjectForKey:@"overview"]:content;
  CGRect contentRect = [self.lblContent.text boundingRectWithSize:CGSizeMake(UIScreenWidth-20, 10000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblContent.font}
                                                          context:nil];
  
  self.lblContent.frame = CGRectMake(10, self.imagePreview.bottom+20, contentRect.size.width, contentRect.size.height);
  
  self.bgScrollView.frame = CGRectMake(0, 0, UIScreenWidth, UIScreenHeight);
  self.bgScrollView.contentSize = CGSizeMake(UIScreenWidth, self.lblContent.bottom+10);
  
  self.bgScrollView.scrollEnabled = self.bgScrollView.contentSize.height>UIScreenHeight;
}

- (BOOL)gestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UISwipeGestureRecognizer *)otherGestureRecognizer
{
  BOOL result = [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]
  &&([otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]);
  
  if (result) {
    DDLogVerbose(@"simulated");
  }
  return result;
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
