//
//  OPTableViewController.m
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "OPTableViewController.h"
#import "OPContentViewController.h"
#import "OPTableViewCell.h"
#import <iAd/iAd.h>
@interface OPTableViewController ()<OPContentModelDelegate,DMAdViewDelegate>
@property(nonatomic, strong)DMAdView *bannerView;
@end

@implementation OPTableViewController
- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    self.model = [[OPContentModel alloc] init];
    self.model.delegate = self;
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
  }
  return self;
}

- (void)viewWillAppear:(BOOL)animated{
  [self.tableView reloadData];
  [self leftBarItem];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRGBHex:0x273552]];
  self.title = @"";
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.text = @"海贼王追番";
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.font = [UIFont boldSystemFontOfSize:18];
  [titleLabel sizeToFit];
  
  self.navigationItem.titleView = titleLabel;
  
  UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedNoCache:@"bg"]];
  [tempImageView setFrame:self.tableView.frame];
  self.tableView.backgroundView = tempImageView;
  self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, UIScreenWidth, 50)];
  [self leftBarItem];
  [self rightBarItem];
  [self scrollToCurrentEpisode];
  [self.model requestEpisodes];
  [self adSetup];
}

- (void)adSetup{
  self.bannerView = [[DMAdView alloc]initWithPublisherId:@"56OJxro4uN5ekXo8a1" placementId:@"16TLeYHlApZ7wNUO7R9s7Djz"];
  self.bannerView.frame = CGRectMake(0, UIScreenHeight-64, UIScreenWidth, 50);
  [self.bannerView setBackgroundColor:[UIColor clearColor]];
  self.bannerView.delegate = self;
  self.bannerView.rootViewController = self;
  [self.bannerView loadAd];
  [self.tableView addSubview: self.bannerView];
}

- (void)scrollToCurrentEpisode{
  NSInteger maxCheckIndex = 0;
  for (NSInteger i=self.model.checkArray.count-1; i>=0; i--) {
    if ([[self.model.checkArray safeNumberObjectAtIndex:i] boolValue]) {
      maxCheckIndex = i;
      break;
    }
  }
  if ([self.tableView numberOfRowsInSection:0]>maxCheckIndex) {
    __weak typeof(self)wSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
      [wSelf.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:maxCheckIndex inSection:0]
                             atScrollPosition:UITableViewScrollPositionTop animated:NO];
    });
  }
}

- (void)leftBarItem{
  __weak typeof(self)wSelf=self;
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    NSInteger checkNum = 0;
    for (NSNumber *number in wSelf.model.checkArray) {
      if ([number boolValue]) {
        checkNum++;
      }
    }
    NSInteger leftNum = wSelf.model.contentArray.count-checkNum;
    
    for (NSInteger i=wSelf.model.contentArray.count-1; i>wSelf.model.contentArray.count-50;i--) {
      NSDictionary *dict = [wSelf.model.contentArray safeDicObjectAtIndex:i];
      if ([[dict safeNumberObjectForKey:@"first_aired"] doubleValue]+3600>[[NSDate date] timeIntervalSince1970]) {
        leftNum--;
      }
    }
    NSString *left = [NSString stringWithFormat:@"余%d集",(int)leftNum];
    dispatch_async(dispatch_get_main_queue(), ^{
      UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:nil action:nil];
      negativeSpacer.width = -35;
      self.navigationItem.leftBarButtonItems = @[negativeSpacer, [UIBarButtonItem loadBarButtonItemWithTitle:left
                                                                                                       color:[UIColor colorWithWhite:1 alpha:0.6]
                                                                                                        font:[UIFont systemFontOfSize:14]
                                                                                                      target:self
                                                                                                      action:@selector(scrollToCurrentEpisode)]];
    });
  });
}


- (void)rightBarItem{
  UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                     target:nil action:nil];
  negativeSpacer.width = -10;
  UIBarButtonItem *item =[UIBarButtonItem loadBarButtonItemWithTitle:@"当前"
                                                               color:[UIColor colorWithWhite:1 alpha:0.6]
                                                                font:[UIFont systemFontOfSize:14]
                                                              target:self  action:@selector(scrollToCurrentEpisode)];
  self.navigationItem.rightBarButtonItems = @[negativeSpacer,item];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)onCheckClicked:(UIButton *)button{
  BOOL isAired = [[[self.model.contentArray safeDicObjectAtIndex:button.tag] safeNumberObjectForKey:@"first_aired"] doubleValue]+3600<[[NSDate date] timeIntervalSince1970];
  
  if(!isAired){
    return;
  }
  
  BOOL checked = [[self.model.checkArray safeNumberObjectAtIndex:button.tag] boolValue];
  checked = !checked;
  
  if (checked) {
    [MobClick event:@"op-check-in-home"];
  }
  [self.model.checkArray replaceObjectAtIndex:button.tag withObject:[NSNumber numberWithBool:checked]];
  
  [button setBackgroundImage:[UIImage imageWithColor:checked?[UIColor whiteColor]:[UIColor clearColor] size:button.frame.size]
                    forState:UIControlStateNormal];
  [button setImage:[UIImage imageNamed:checked?@"icon_checkmark_on":@"icon_checkmark_off"]
          forState:UIControlStateNormal];
  
  NSMutableArray *checkArray = [[NSArray readFromPlistFile:OPCheckArray] mutableCopy];
  
  if (checked) {
    if (!checkArray) {
      checkArray = [@[[NSNumber numberWithInteger:button.tag]] mutableCopy];
    }
    else{
      if (![checkArray containsObject:[NSNumber numberWithInteger:button.tag]]) {
        [checkArray addObject:[NSNumber numberWithInteger:button.tag]];
      }
    }
    [checkArray writeToPlistFileSync:OPCheckArray];
    
    __weak typeof(self)wSelf = self;
    for (NSInteger i=0;i<button.tag;i++) {
      if (![[self.model.checkArray safeNumberObjectAtIndex:i] boolValue]) {
        [[[UIActionSheet alloc] initWithTitle:@"是否需要将之前的未看剧集设置为已看？"
                             cancelButtonItem:[RIButtonItem itemWithLabel:@"取消"]
                        destructiveButtonItem:[RIButtonItem itemWithLabel:@"确定" action:^{
          for (NSInteger i=0; i<button.tag; i++) {
            if (![checkArray containsObject:[NSNumber numberWithInteger:i]]) {
              [checkArray addObject:[NSNumber numberWithInteger:i]];
              [wSelf.model.checkArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
            }
          }
          [checkArray writeToPlistFileSync:OPCheckArray];
          [wSelf leftBarItem];
          [wSelf.tableView reloadData];
        }]
                             otherButtonItems:nil] showInView:self.view];
        break;
      }
    }
  }
  else{
    [checkArray removeObject:[NSNumber numberWithInteger:button.tag]];
    [checkArray writeToPlistFileSync:OPCheckArray];
    
  }
  [self leftBarItem];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  // Return the number of sections.
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
  return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  // Return the number of rows in the section.
  return [self.model.contentArray count];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
  [cell setBackgroundColor:[UIColor clearColor]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *identifier = @"OPTableViewIdentifier";
  OPTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
  if (!cell) {
    cell = [[OPTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
  }
  BOOL isChecked = [[self.model.checkArray safeNumberObjectAtIndex:indexPath.row] boolValue];
  [cell refreshOPTableViewCell:[self.model.contentArray safeDicObjectAtIndex:indexPath.row] isChecked:isChecked row:indexPath.row];
  [cell.btnChecked addTarget:self action:@selector(onCheckClicked:) forControlEvents:UIControlEventTouchUpInside];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  OPContentViewController *vc = [[OPContentViewController alloc] initWithSource:[self.model.contentArray safeDicObjectAtIndex:indexPath.row]
                                                                          index:indexPath.row];
  vc.delegate = self;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
  NSArray* visibleCells = [self.tableView visibleCells];
  for (OPTableViewCell *cell in visibleCells) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    BOOL isChecked = [[self.model.checkArray safeNumberObjectAtIndex:indexPath.row] boolValue];
    [cell refreshOPTableViewCell:[self.model.contentArray safeDicObjectAtIndex:indexPath.row] isChecked:isChecked row:indexPath.row];
  }
  [self.bannerView orientationChanged];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
  self.bannerView.top = self.tableView.contentOffset.y+self.tableView.height-50;
}

#pragma mark Model Delegate
- (void)contentModelDidLoadData:(OPContentModel *)model{
  [self.tableView reloadData];
  [self leftBarItem];
}

#pragma mark - AdViewDelegates
- (void)dmAdViewSuccessToLoadAd:(DMAdView *)adView{
  NSLog(@"Ad loaded");
}
// 加载广告失败后，回调该方法
- (void)dmAdViewFailToLoadAd:(DMAdView *)adView withError:(NSError *)error{
  NSLog(@"Error loading");
}

// 当将要呈现出 Modal View 时，回调该方法。如打开内置浏览器。
- (void)dmWillPresentModalViewFromAd:(DMAdView *)adView{

}
// 当呈现的 Modal View 被关闭后，回调该方法。如内置浏览器被关闭。
- (void)dmDidDismissModalViewFromAd:(DMAdView *)adView{

}
// 当因用户的操作（如点击下载类广告，需要跳转到Store），需要离开当前应用时，回调该方法
- (void)dmApplicationWillEnterBackgroundFromAd:(DMAdView *)adView{

}
@end
