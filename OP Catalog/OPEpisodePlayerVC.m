//
//  OPEpisodePlayerVC.m
//  OP Catalog
//
//  Created by Albert Lee on 8/29/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "OPEpisodePlayerVC.h"

@interface OPEpisodePlayerVC ()

@end

@implementation OPEpisodePlayerVC

+ (OPEpisodePlayerVC *)sharedMPVC{
  static dispatch_once_t pred;
  
  static OPEpisodePlayerVC *sharedMPVC = nil;
  dispatch_once(&pred, ^{
    sharedMPVC = [[OPEpisodePlayerVC alloc] initWithContentURL:nil];
  });
  return sharedMPVC;
}

- (id)initWithContentURL:(NSURL *)contentURL
{
  self = [super initWithContentURL:contentURL];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
