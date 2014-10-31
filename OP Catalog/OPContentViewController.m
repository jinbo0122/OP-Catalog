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
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithRGBHex:0x273552];
  
  [self setTitleView];
  
  self.bgImageView = [[UIImageView alloc] initWithFrame:UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)?self.view.bounds:
                      CGRectMake(0, 0, 1024, 768)];
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
  self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

  
  [self.view addSubview:self.bgImageView];
  [self.view addSubview:self.collectionView];
  
  
  [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0]
                              atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
  
  [self setRightNavigationBarButton];
  
  
  __block typeof(self)wSelf = self;
  [[NSNotificationCenter defaultCenter] addObserverForName:MPMoviePlayerDidExitFullscreenNotification
                                                    object:nil
                                                     queue:[NSOperationQueue mainQueue]
                                                usingBlock:^(NSNotification *note) {
                                                  [wSelf mpDoneButtonClick:note];
                                                }];
}

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
  [collectionCell refreshContentView:[self.delegate.contentArray safeDicObjectAtIndex:indexPath.row] index:indexPath.row];
  [collectionCell.tapGesture addTarget:self action:@selector(onPlayTapped:)];
  return collectionCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
  return CGSizeMake(UIScreenWidth-10, UIScreenHeight);
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
  NSTimeInterval currentPlaybackTime = [[OPEpisodePlayerVC sharedMPVC].moviePlayer currentPlaybackTime];
  if (currentPlaybackTime>0) {
    NSMutableDictionary *playbacTimeDic = [[NSMutableDictionary readFromPlistFile:@"PlaybackTimeDic"] mutableCopy];
    if (!playbacTimeDic) {
      playbacTimeDic = [NSMutableDictionary dictionary];
    }
    
    currentPlaybackTime-=3;
    if (currentPlaybackTime<=0) {
      currentPlaybackTime = 0;
    }
    
    [playbacTimeDic setSafeObject:[NSNumber numberWithDouble:currentPlaybackTime] forKey:[[NSNumber numberWithInteger:self.index] stringValue]];
    [playbacTimeDic writeToPlistFileSync:@"PlaybackTimeDic"];
    
  }
  [self dismissMoviePlayerViewControllerAnimated];
}

- (void)playEpisodeByStarndard:(NSString *)standard{
  NSNumber *vid = [[NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"vid" ofType:@"plist"]]
                   safeNumberObjectAtIndex:self.index];
  [[NSNotificationCenter defaultCenter] removeObserver:[OPEpisodePlayerVC sharedMPVC]
                                                  name:MPMoviePlayerPlaybackDidFinishNotification object:[OPEpisodePlayerVC sharedMPVC].moviePlayer];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(mpDoneButtonClick:)
                                               name:MPMoviePlayerPlaybackDidFinishNotification
                                             object:[OPEpisodePlayerVC sharedMPVC].moviePlayer];
  
  [[OPEpisodePlayerVC sharedMPVC].moviePlayer setContentURL:[NSURL URLWithString:[self getM3U8ByVid:vid byStandrad:standard]]];
  [[OPEpisodePlayerVC sharedMPVC].moviePlayer prepareToPlay];
  NSDictionary *dic = [NSDictionary readFromPlistFile:@"PlaybackTimeDic"];
  if (!dic) {
    dic = [NSDictionary dictionary];
  }
  
  NSTimeInterval initialPlaybackTime = [[dic safeNumberObjectForKey:[[NSNumber numberWithInteger:self.index] stringValue]] doubleValue];
  
  if (initialPlaybackTime>0) {
    [[[UIActionSheet alloc] initWithTitle:@"是否继续播放"
                         cancelButtonItem:[RIButtonItem itemWithLabel:@"取消播放"]
                    destructiveButtonItem:nil
                         otherButtonItems:
      [RIButtonItem itemWithLabel:@"继续播放" action:^{
      [[OPEpisodePlayerVC sharedMPVC].moviePlayer play];
      [[OPEpisodePlayerVC sharedMPVC].moviePlayer setCurrentPlaybackTime:initialPlaybackTime];
      [self presentMoviePlayerViewControllerAnimated:[OPEpisodePlayerVC sharedMPVC]];
    }],
      [RIButtonItem itemWithLabel:@"从头播放" action:^{
      [[OPEpisodePlayerVC sharedMPVC].moviePlayer play];
      [self presentMoviePlayerViewControllerAnimated:[OPEpisodePlayerVC sharedMPVC]];
    }],nil] showInView:self.view];
  }
  else{
    [[OPEpisodePlayerVC sharedMPVC].moviePlayer play];
    [self presentMoviePlayerViewControllerAnimated:[OPEpisodePlayerVC sharedMPVC]];
  }
}

- (NSString *)getM3U8ByVid:(NSNumber *)vid byStandrad:(NSString *)standard{

  return @"";
}

- (void)dealloc{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
  self.bgImageView.frame = self.view.bounds;
  NSArray* visibleCells = [self.collectionView visibleCells];
  
  for (OPContentCell *cell in visibleCells) {
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    [cell refreshContentView:[self.delegate.contentArray safeDicObjectAtIndex:indexPath.row] index:indexPath.row];
  }
  
  [self.collectionView reloadData];
  [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.index inSection:0]
                              atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
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
