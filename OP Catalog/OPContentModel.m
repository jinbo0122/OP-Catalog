//
//  OPContentModel.m
//  OP Catalog
//
//  Created by Albert Lee on 1/21/15.
//  Copyright (c) 2015 Albert Lee. All rights reserved.
//

#import "OPContentModel.h"
@interface OPContentModel()
@property(nonatomic, assign)NSInteger season;
@property(nonatomic, assign)NSInteger updateEpisode;

@end
@implementation OPContentModel
- (id)init{
  self = [super init];
  if (self) {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"plist"];
    self.contentArray = [[NSMutableArray alloc] initWithContentsOfFile:plistPath];
    
    NSArray *array = [NSArray readFromPlistFile:@"content"];
    if (array) {
      self.contentArray = [array mutableCopy];
    }
    
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
    
    self.season = 17;
  }
  return self;
}

- (void)requestEpisodes{
  __weak typeof(self)wSelf = self;
  [[OPNetworkEngine shareInstance]
   requestOPSeason:self.season
   CompleteHandle:
   ^(NSDictionary *resultDic) {
     NSArray *array = (NSArray *)resultDic;
     if (array.count>0) {
       NSMutableArray *mutaArray = [wSelf.contentArray mutableCopy];
       [mutaArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(636, wSelf.contentArray.count-636)]];
       [mutaArray addObjectsFromArray:[array subarrayWithRange:NSMakeRange(8, array.count-8)]];
       wSelf.contentArray = [NSMutableArray arrayWithArray:mutaArray];
       for (NSInteger i=636; i<wSelf.contentArray.count; i++) {
         NSMutableDictionary *dict = [[wSelf.contentArray safeDicObjectAtIndex:i] mutableCopy];
         NSString *generalTitle = wSelf.season==17?@"德雷斯罗萨篇":@"new";
         [dict setSafeObject:generalTitle forKey:@"generalTitle"];
         [wSelf.contentArray safeReplaceObjectAtIndex:i withObject:dict];
       }
       wSelf.season++;
       [wSelf.contentArray writeToPlistFileSync:@"content"];
       [wSelf requestEpisodes];
     }
     if (wSelf.delegate &&[wSelf.delegate respondsToSelector:@selector(contentModelDidLoadData:)]) {
       [wSelf.delegate contentModelDidLoadData:wSelf];
     }
   }
   errorHandler:
   ^(NSError *error) {
     wSelf.season = 1;
     wSelf.updateEpisode = 0;
     [wSelf updateEpisodeImages];
   }];
}

- (void)updateEpisodeImages{
  __weak typeof(self)wSelf = self;
  [[OPNetworkEngine shareInstance]
   requestOPSeason:self.season
   CompleteHandle:
   ^(NSDictionary *resultDic) {
     NSMutableArray *array = [(NSArray *)resultDic mutableCopy];
     if (array.count>0) {
       if (wSelf.season==16) {
         [array insertObject:@{@"screen":@""} atIndex:11];
       }
       for (NSInteger i = wSelf.updateEpisode; i<wSelf.updateEpisode+[array count]; i++) {
         NSMutableDictionary *episodeInfo = [[wSelf.contentArray safeDicObjectAtIndex:i] mutableCopy];
         NSDictionary *freshInfo = [array safeDicObjectAtIndex:i-wSelf.updateEpisode];
         [episodeInfo setObject:[[[freshInfo safeStringObjectForKey:@"screen"] componentsSeparatedByString:@"?"] safeObjectAtIndex:0] forKey:@"screen"];
         NSLog(@"%@",[episodeInfo safeStringObjectForKey:@"screen"]);
         [wSelf.contentArray safeReplaceObjectAtIndex:i withObject:episodeInfo];
       }
       wSelf.updateEpisode+=array.count;
       wSelf.season++;
       [wSelf updateEpisodeImages];
     }
   }
   errorHandler:
   ^(NSError *error) {
     [wSelf.contentArray writeToPlistFileSync:@"content"];
     if (wSelf.delegate &&[wSelf.delegate respondsToSelector:@selector(contentModelDidLoadData:)]) {
       [wSelf.delegate contentModelDidLoadData:wSelf];
     }
   }];
}

- (NSString *)localFilePath{
  NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory,NSUserDomainMask,YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  NSString * path = [[documentsDirectory stringByAppendingPathComponent:@"Caches"] stringByAppendingPathComponent:@"content"];
  return path;
}
@end
