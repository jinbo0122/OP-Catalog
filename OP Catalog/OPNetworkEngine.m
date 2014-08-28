//
//  OPNetworkEngine.m
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

#import "OPNetworkEngine.h"

@implementation OPNetworkEngine
static OPNetworkEngine * _opInstance;
#pragma mark Singleton
+ (OPNetworkEngine *)shareInstance{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _opInstance = [[OPNetworkEngine alloc] initWithHostName:[OPNetworkEngine serverHost]
                                                    apiPath:@""
                                         customHeaderFields:nil];
  });
  
  return _opInstance;
}
+ (NSString*)serverHost{
  return @"api.trakt.tv";
}

#pragma mark - 请求新消息操作
- (MKNetworkOperation *)requestOPSeason:(NSInteger)season
                         CompleteHandle:(ReturnDictionaryBlock)completionHandler
                           errorHandler:(MKNKErrorBlock)errorHandler{
  
  MKNetworkOperation *op = [self operationWithPath:[NSString stringWithFormat:@"show/season.json/0d5b8b9c7eae89cc8e29b7b01fb28f07/one-piece/%d",(int)season]
                                            params:@{}
                                        httpMethod:@"GET"];
  [op addCompletionHandler:^(MKNetworkOperation *completedOperation) {
    NSDictionary *dict = [completedOperation responseJSON];
    completionHandler(dict);
  } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
    errorHandler(error);
  }];
  [self enqueueOperation:op];
  return op;
}
@end
