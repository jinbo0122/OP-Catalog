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
    //    self.lblGeneralTitle = [UILabel initWithFrame:CGRectMake(10, 64+20, 300, 18)
    //                                   bgColor:[UIColor clearColor]
    //                                 textColor:[UIColor whiteColor]
    //                                      text:@""
    //                             textAlignment:NSTextAlignmentCenter
    //                                      font:[UIFont systemFontOfSize:17]
    //                             numberOfLines:0];
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


- (void)refreshContentView:(NSDictionary *)sources{
  
  //  self.lblGeneralTitle.text = [sources safeStringObjectForKey:@"generalTitle"];
  
  self.lblTitle.text = [sources safeStringObjectForKey:@"title"];
  
  CGRect titleRect = [self.lblTitle.text boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-20, 50)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:@{NSFontAttributeName:self.lblTitle.font}
                                                      context:nil];
  self.lblTitle.frame = CGRectMake(([UIScreen mainScreen].bounds.size.width-titleRect.size.width)/2.0, 10+64,titleRect.size.width, titleRect.size.height);
  
  
  NSString *strEpisodeInfo = [NSString stringWithFormat:@"S%@-E%@",[sources safeNumberObjectForKey:@"season"],[sources safeNumberObjectForKey:@"episode"]];
  
  self.lblEpisodeInfo.text = strEpisodeInfo;
  self.lblEpisodeInfo.frame = CGRectMake(self.lblTitle.left, self.lblTitle.bottom+10, [UIScreen mainScreen].bounds.size.width-20, 16);
  
  
  self.lblPublishTime.text = [@"播出时间:" stringByAppendingString:[NSString timeString:[[sources safeNumberObjectForKey:@"first_aired"] doubleValue]+3600
                                                                             format:MHPrettyDateFormatNoTime]] ;
  self.lblPublishTime.frame = CGRectMake(self.lblTitle.left, self.lblEpisodeInfo.top,self.lblTitle.width, 16);
  
  
  self.imagePreview.frame = CGRectMake(isIPad?234:0, self.lblPublishTime.bottom+15, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width*9/16.0);
  
  NSString *url = [[sources safeDicObjectForKey:@"images"] safeStringObjectForKey:@"screen"];
  
  
  __weak typeof(self) wSelf = self;
  [self.imagePreview setImageWithURL:[NSURL URLWithString:url]
                           completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                             if (!error) {
                               wSelf.imagePreview.height = [UIScreen mainScreen].bounds.size.width * image.size.height/image.size.width;
                               wSelf.lblContent.top = wSelf.imagePreview.bottom+20;
                               wSelf.bgScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
                               wSelf.bgScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, wSelf.lblContent.bottom+10);
                               
                               wSelf.bgScrollView.scrollEnabled = wSelf.bgScrollView.contentSize.height>[UIScreen mainScreen].bounds.size.height;
                             }
  }];
  
  self.lblContent.text = [sources safeStringObjectForKey:@"content"];
  
  NSString *content = [sources safeStringObjectForKey:@"content"];
  self.lblContent.text = content.length==0?[sources safeStringObjectForKey:@"overview"]:content;
  CGRect contentRect = [self.lblContent.text boundingRectWithSize:CGSizeMake(isIPad?648:([UIScreen mainScreen].bounds.size.width-20), 10000)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:@{NSFontAttributeName:self.lblContent.font}
                                                          context:nil];
  
  self.lblContent.frame = CGRectMake(10, self.imagePreview.bottom+20, contentRect.size.width, contentRect.size.height);
  
  
  if (isIPad) {
    UIInterfaceOrientation orientation =  [[UIApplication sharedApplication] statusBarOrientation];
    BOOL isPortrait = (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown);
    CGFloat screenWidth = isPortrait?768:1024;
    
    self.lblTitle.width = screenWidth-20;
    self.lblEpisodeInfo.left = isPortrait?200:328;
    self.lblPublishTime.right = isPortrait?560:688;
    self.imagePreview.left = (screenWidth-300)/2;
    self.lblContent.left = isPortrait?60:128;
  }
  self.bgScrollView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
  self.bgScrollView.contentSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, self.lblContent.bottom+10);
  
  self.bgScrollView.scrollEnabled = self.bgScrollView.contentSize.height>[UIScreen mainScreen].bounds.size.height;
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
