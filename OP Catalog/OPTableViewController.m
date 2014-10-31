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

#define OPCheckArray @"OPCheckArray"

@interface OPTableViewController (){
  NSInteger _season;
}
@end

@implementation OPTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"plist"];
    self.contentArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    self.checkArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<1000; i++) {
      [self.checkArray addObject:[NSNumber numberWithBool:NO]];
    }
    
    NSArray *checkArray = [NSArray readFromPlistFile:OPCheckArray];
    if (checkArray) {
      for (NSNumber *index in checkArray) {
        [self.checkArray replaceObjectAtIndex:index.integerValue withObject:[NSNumber numberWithBool:YES]];
      }
    }
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
  titleLabel.text = @"One Piece目录";
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.font = [UIFont boldSystemFontOfSize:18];
  [titleLabel sizeToFit];
  
  self.navigationItem.titleView = titleLabel;
  
  UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedNoCache:@"bg"]];
  [tempImageView setFrame:self.tableView.frame];
  self.tableView.backgroundView = tempImageView;
  
  
  [self leftBarItem];
  [self rightBarItem];
  
  [self scrollToCurrentEpisode];
  
  
  for (NSInteger i=589; i<self.contentArray.count; i++) {
    NSMutableDictionary *dict = [[self.contentArray safeDicObjectAtIndex:i] mutableCopy];
    NSString *generalTitle = @"";
    if (i==589) {
      generalTitle = @"美食的俘虏×海贼王×七龙珠";
    }
    else if (i>589&& i<625){
      generalTitle = @"庞克哈萨德篇";
    }
    else if (i>=625 &&i<628){
      generalTitle = @"宠物果实能力者篇";
    }
    else{
      generalTitle = @"德雷斯罗萨篇";
    }
    [dict setSafeObject:generalTitle forKey:@"generalTitle"];
    [self.contentArray safeReplaceObjectAtIndex:i withObject:dict];
  }
  
  _season = 17;
  [self requestEpisodes];
}

- (void)requestEpisodes{
  
  __weak typeof(self)wSelf = self;
  
  [[OPNetworkEngine shareInstance]
   requestOPSeason:_season
   CompleteHandle:
   ^(NSDictionary *resultDic) {
     NSArray *array = (NSArray *)resultDic;
     if (array.count>0) {
       NSMutableArray *mutaArray = [_contentArray mutableCopy];
       
       NSInteger location = 39;
       NSArray *addArray = [array subarrayWithRange:NSMakeRange(location, array.count-location)];
       
       [mutaArray addObjectsFromArray:addArray];
       _contentArray = [NSMutableArray arrayWithArray:mutaArray];
       _season++;
       
       for (NSInteger i=666; i<self.contentArray.count; i++) {
         NSMutableDictionary *dict = [[self.contentArray safeDicObjectAtIndex:i] mutableCopy];
         NSString *generalTitle = _season==17?@"德雷斯罗萨篇":@"new";
         [dict setSafeObject:generalTitle forKey:@"generalTitle"];
         [wSelf.contentArray safeReplaceObjectAtIndex:i withObject:dict];
       }
       
       NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
       NSString *plistPath1 = [paths objectAtIndex:0];
       NSString *filename=[plistPath1 stringByAppendingPathComponent:@"content.plist"];
       [_contentArray writeToFile:filename atomically:YES];
       
       [wSelf.tableView reloadData];
       [wSelf requestEpisodes];
     }
     [wSelf leftBarItem];
   }
   errorHandler:
   ^(NSError *error) {
     
   }];
}

- (void)scrollToCurrentEpisode{
  NSInteger maxCheckIndex = 0;
  for (NSInteger i=self.checkArray.count-1; i>=0; i--) {
    if ([[self.checkArray safeNumberObjectAtIndex:i] boolValue]) {
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
    for (NSNumber *number in wSelf.checkArray) {
      if ([number boolValue]) {
        checkNum++;
      }
    }
    NSInteger leftNum = wSelf.contentArray.count-checkNum;
    
    for (NSInteger i=wSelf.contentArray.count-1; i>wSelf.contentArray.count-50;i--) {
      NSDictionary *dict = [wSelf.contentArray safeDicObjectAtIndex:i];
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
  BOOL checked = [[self.checkArray safeNumberObjectAtIndex:button.tag] boolValue];
  checked = !checked;
  
  [self.checkArray replaceObjectAtIndex:button.tag withObject:[NSNumber numberWithBool:checked]];
  
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
    
    for (NSInteger i=0;i<button.tag;i++) {
      if (![[self.checkArray safeNumberObjectAtIndex:i] boolValue]) {
        [[[UIActionSheet alloc] initWithTitle:@"是否需要将之前的未看剧集设置为已看？"
                             cancelButtonItem:[RIButtonItem itemWithLabel:@"取消"]
                        destructiveButtonItem:[RIButtonItem itemWithLabel:@"确定" action:^{
          for (NSInteger i=0; i<button.tag; i++) {
            if (![checkArray containsObject:[NSNumber numberWithInteger:i]]) {
              [checkArray addObject:[NSNumber numberWithInteger:i]];
              [self.checkArray replaceObjectAtIndex:i withObject:[NSNumber numberWithBool:YES]];
            }
          }
          [checkArray writeToPlistFileSync:OPCheckArray];
          [self.tableView reloadData];
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
  return [self.contentArray count];
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
  // Configure the cell...
  [cell refreshOPTableViewCell:[self.contentArray safeDicObjectAtIndex:indexPath.row] row:indexPath.row];
  
  [cell.btnChecked setBackgroundImage:[UIImage imageWithColor:[[self.checkArray safeNumberObjectAtIndex:indexPath.row] boolValue]?[UIColor whiteColor]:[UIColor clearColor] size:cell.btnChecked.frame.size] forState:UIControlStateNormal];
  
  [cell.btnChecked setImage:[UIImage imageNamed:[[self.checkArray safeNumberObjectAtIndex:indexPath.row] boolValue]?@"icon_checkmark_on":@"icon_checkmark_off"]
                   forState:UIControlStateNormal];
  cell.btnChecked.tag = indexPath.row;
  [cell.btnChecked addTarget:self action:@selector(onCheckClicked:) forControlEvents:UIControlEventTouchUpInside];
  
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  OPContentViewController *vc = [[OPContentViewController alloc] initWithSource:[self.contentArray safeDicObjectAtIndex:indexPath.row]
                                                                          index:indexPath.row];
  vc.delegate = self;
  [self.navigationController pushViewController:vc animated:YES];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration{
  NSArray* visibleCells = [self.tableView visibleCells];
  for (OPTableViewCell *cell in visibleCells) {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [cell refreshOPTableViewCell:[self.contentArray safeDicObjectAtIndex:indexPath.row] row:indexPath.row];
  }
}
@end
