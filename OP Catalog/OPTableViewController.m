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

@interface OPTableViewController ()
@end

@implementation OPTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
  self = [super initWithStyle:style];
  if (self) {
    // Custom initialization
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"plist"];
    self.contentArray = [[NSArray alloc] initWithContentsOfFile:plistPath];
    
    self.checkArray = [NSMutableArray array];
    
    for (NSInteger i=0; i<[self.contentArray count]; i++) {
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
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRGBHex:0x273552]];
  self.title = @"";
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.text = @"One Piece剧情目录";
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.font = [UIFont boldSystemFontOfSize:18];
  [titleLabel sizeToFit];
  
  self.navigationItem.titleView = titleLabel;
  
  UIImageView *tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamedNoCache:@"bg"]];
  [tempImageView setFrame:self.tableView.frame];
  self.tableView.backgroundView = tempImageView;
  
  
  UIBarButtonItem *item =[[UIBarButtonItem alloc] initWithTitle:@"当前"
                                                          style:UIBarButtonItemStylePlain
                                                         target:self action:@selector(scrollToCurrentEpisode)];
  self.navigationItem.rightBarButtonItem = item;

  
  [self scrollToCurrentEpisode];
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
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:maxCheckIndex inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop animated:NO];
  }
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
