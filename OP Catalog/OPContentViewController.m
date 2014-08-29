//
//  OPContentViewController.m
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "OPContentViewController.h"
#import "OPContentCell.h"
@interface OPContentViewController ()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong)NSDictionary *source;
@property (nonatomic, assign)NSInteger     index;
@property (nonatomic, strong)UIImageView  *bgImageView;
@property (nonatomic, strong)UICollectionView *collectionView;
@property (nonatomic, strong)MPMoviePlayerController *moviePlayer;
@end

@implementation OPContentViewController

- (id)initWithSource:(NSDictionary *)source index:(NSInteger)index
{
  self = [super init];
  if (self) {
    // Custom initialization
    self.source = [source copy];
    self.index = index;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mpDoneButtonClick:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithRGBHex:0x273552];
  
  [self setTitleView];
  
  self.bgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
  self.bgImageView.image = [UIImage imageNamedNoCache:@"bg"];
  
  UICollectionViewFlowLayout *layout=[[UICollectionViewFlowLayout alloc] init];
  
  self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                           collectionViewLayout:layout];
  [layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
  
  self.collectionView.dataSource = self;
  self.collectionView.delegate   = self;
  [self.collectionView registerClass:[OPContentCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
  [self.collectionView setBackgroundColor:[UIColor clearColor]];
  self.collectionView.pagingEnabled = YES;
  
  [self.view addSubview:self.bgImageView];
  [self.view addSubview:self.collectionView];
  
  
  [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0]
                              atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
  
  [self setRightNavigationBarButton];
}

//- (void)requestEpisodes{
//  if (_season>17) {
//    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString * documentsDirectory = [paths objectAtIndex:0];
//    NSString * path = [documentsDirectory stringByAppendingPathComponent:@"episodes.plist"];
//    [_episodesArray writeToFile:path atomically:YES];
//    return;
//  }
//
//  [[OPNetworkEngine shareInstance]
//   requestOPSeason:_season
//   CompleteHandle:
//   ^(NSDictionary *resultDic) {
//     [_episodesArray addObjectsFromArray:(NSArray *)resultDic];
//     _season++;
//     [self requestEpisodes];
//   }
//   errorHandler:
//   ^(NSError *error) {
//
//   }];
//}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
  return self.delegate.contentArray.count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
  OPContentCell *collectionCell;
  collectionCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
  if (!collectionCell) {
    collectionCell = [[OPContentCell alloc] initWithFrame:self.view.frame];
  }
  [collectionCell refreshContentView:[self.delegate.contentArray safeDicObjectAtIndex:indexPath.row]];
  [collectionCell.tapGesture addTarget:self action:@selector(onPlayTapped:)];
  return collectionCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  if (isIPad) {
    return CGSizeMake(758, self.view.height);
  }
  else{
    return CGSizeMake(310, self.view.height);
  }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
  self.index = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
  
  [self setRightNavigationBarButton];
  [self setTitleView];
}

- (void)setTitleView{
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.text = [[self.delegate.contentArray safeDicObjectAtIndex:self.index] safeStringObjectForKey:@"generalTitle"];
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.font = [UIFont boldSystemFontOfSize:18];
  [titleLabel sizeToFit];
  self.navigationItem.titleView = titleLabel;
}

- (void)setRightNavigationBarButton{
  BOOL checked = [[self.delegate.checkArray safeNumberObjectAtIndex:self.index] boolValue];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:checked?@"icon_page_check_on":@"icon_page_check_off"]
                                                                            style:UIBarButtonItemStylePlain target:self action:@selector(onCheckClicked:)];
  
}

- (void)onCheckClicked:(UIBarButtonItem *)item{
  BOOL checked = [[self.delegate.checkArray safeNumberObjectAtIndex:self.index] boolValue];
  checked = !checked;
  
  [self.delegate.checkArray replaceObjectAtIndex:self.index withObject:[NSNumber numberWithBool:checked]];
  
  [self setRightNavigationBarButton];
  
  NSMutableArray *checkArray = [[NSArray readFromPlistFile:@"OPCheckArray"] mutableCopy];
  
  if (checked) {
    if (!checkArray) {
      checkArray = [@[[NSNumber numberWithInteger:self.index]] mutableCopy];
    }
    else{
      if (![checkArray containsObject:[NSNumber numberWithInteger:self.index]]) {
        [checkArray addObject:[NSNumber numberWithInteger:self.index]];
      }
    }
    [self.delegate.tableView reloadData];
    [checkArray writeToPlistFileSync:@"OPCheckArray"];
    
    for (NSInteger i=0;i<self.index;i++) {
      if (![[self.delegate.checkArray safeNumberObjectAtIndex:i] boolValue]) {
        [[[UIActionSheet alloc] initWithTitle:@"是否需要将之前的未看剧集设置为已看？"
                             cancelButtonItem:[RIButtonItem itemWithLabel:@"取消"]
                        destructiveButtonItem:[RIButtonItem itemWithLabel:@"确定" action:^{
          for (NSInteger i=0; i<self.index; i++) {
            if (![checkArray containsObject:[NSNumber numberWithInteger:i]]) {
              [checkArray addObject:[NSNumber numberWithInteger:i]];
              [self.delegate.checkArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
            }
          }
          [checkArray writeToPlistFileSync:@"OPCheckArray"];
          [self.delegate.tableView reloadData];
        }]
                             otherButtonItems:nil] showInView:self.view];
        break;
      }
    }
  }
  else{
    [checkArray removeObject:[NSNumber numberWithInteger:self.index]];
    [checkArray writeToPlistFileSync:@"OPCheckArray"];
    [self.delegate.tableView reloadData];
  }
  
}


- (void)onPlayTapped:(UITapGestureRecognizer*)tapGesture{
  [[[UIActionSheet alloc] initWithTitle:@"请选择画质"
                       cancelButtonItem:[RIButtonItem itemWithLabel:@"取消"]
                  destructiveButtonItem:nil
                       otherButtonItems:
    [RIButtonItem itemWithLabel:@"超清"
                         action:^{
                           [self playEpisodeByStarndard:@"superVid"];
                         }],
    [RIButtonItem itemWithLabel:@"高清"
                         action:^{
                           [self playEpisodeByStarndard:@"highVid"];
                         }],
    [RIButtonItem itemWithLabel:@"标清"
                         action:^{
                           [self playEpisodeByStarndard:@"norVid"];
                         }], nil] showInView:self.view];
  
}


-(void)mpDoneButtonClick:(NSNotification*)aNotification{
  [self dismissMoviePlayerViewControllerAnimated];
}

- (void)playEpisodeByStarndard:(NSString *)standard{
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.removeFromSuperViewOnHide = YES;
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSString *movieURL = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"url" ofType:@"plist"]]
                          safeStringObjectAtIndex:self.index];
    NSString *m3u8 = [self getM3U8ByUrl:movieURL byStandrad:standard];//@"superVid",@"highVid",@"norVid"
    
    dispatch_async(dispatch_get_main_queue(), ^{
      [hud hide:YES];
      [[OPEpisodePlayerVC sharedMPVC].moviePlayer setContentURL:[NSURL URLWithString:m3u8]];
      [self presentMoviePlayerViewControllerAnimated:[OPEpisodePlayerVC sharedMPVC]];
      [[OPEpisodePlayerVC sharedMPVC].moviePlayer play];
    });
  });
}

- (NSString *)getM3U8ByUrl:(NSString *)movieURL byStandrad:(NSString *)standard{
  NSMutableString *movieUrlNew = [movieURL mutableCopy];
  [movieUrlNew insertString:@"pad." atIndex:7];
  NSURL *url = [NSURL URLWithString:movieUrlNew];
  
  NSString *html = [NSString stringWithContentsOfURL:url
                                            encoding:NSUTF8StringEncoding error:nil];
  NSRange range = [html rangeOfString:standard];
  
  NSString *vidURL = [html substringWithRange:NSMakeRange(range.location, 80)];
  
  NSRange m3u8Range = [vidURL rangeOfString:@"m3u8"];
  
  NSString *finalURL = [vidURL substringWithRange:NSMakeRange(standard.length+3, m3u8Range.location+m3u8Range.length-standard.length-3)];
  return finalURL;
}

- (void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
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
