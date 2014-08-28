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
  
  UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  titleLabel.backgroundColor = [UIColor clearColor];
  titleLabel.textColor = [UIColor whiteColor];
  titleLabel.text = @"One Piece分集介绍";
  titleLabel.textAlignment = NSTextAlignmentCenter;
  titleLabel.font = [UIFont boldSystemFontOfSize:18];
  [titleLabel sizeToFit];
  
  self.navigationItem.titleView = titleLabel;
  
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
  collectionCell.lblTitle.text = [[self.delegate.contentArray safeDicObjectAtIndex:indexPath.row] safeStringObjectForKey:@"title"];
  
  CGRect titleRect = [collectionCell.lblTitle.text boundingRectWithSize:CGSizeMake(300, 50)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:@{NSFontAttributeName:collectionCell.lblTitle.font}
                                                                context:nil];
  collectionCell.lblTitle.frame = CGRectMake(10, 20+64, titleRect.size.width, titleRect.size.height);
  
  collectionCell.imagePreview.frame = CGRectMake(10, collectionCell.lblTitle.bottom+20, 300, 225);
  
  NSString *url = [[[self.delegate.contentArray safeDicObjectAtIndex:indexPath.row] safeDicObjectForKey:@"images"] safeStringObjectForKey:@"screen"];
  
  [collectionCell.imagePreview setImageWithURL:[NSURL URLWithString:url]];
  
  collectionCell.lblContent.text = [[self.delegate.contentArray safeDicObjectAtIndex:indexPath.row] safeStringObjectForKey:@"content"];
  CGRect contentRect = [collectionCell.lblContent.text boundingRectWithSize:CGSizeMake(300, 10000)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:@{NSFontAttributeName:collectionCell.lblContent.font}
                                                                    context:nil];
  
  collectionCell.lblContent.frame = CGRectMake(10, collectionCell.imagePreview.bottom+30, contentRect.size.width, contentRect.size.height);
  
  
  return collectionCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
  return CGSizeMake(310, self.view.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
  self.index = self.collectionView.contentOffset.x / self.collectionView.frame.size.width;
  
  [self setRightNavigationBarButton];
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
