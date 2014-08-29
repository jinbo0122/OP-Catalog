//
//  OPEpisodePlayerVC.h
//  OP Catalog
//
//  Created by Albert Lee on 8/29/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface OPEpisodePlayerVC : MPMoviePlayerViewController
+ (OPEpisodePlayerVC *)sharedMPVC;
@end
