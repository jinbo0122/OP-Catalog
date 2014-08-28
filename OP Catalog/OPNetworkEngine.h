//
//  OPNetworkEngine.h
//  OP Catalog
//
//  Created by Albert Lee on 8/27/14.
//  Copyright (c) 2014 Albert Lee. All rights reserved.
//

typedef void (^ReturnDictionaryBlock)(NSDictionary *resultDic);


@interface OPNetworkEngine : MKNetworkEngine

#pragma mark Singleton
+ (OPNetworkEngine *)shareInstance;
+ (NSString*)serverHost;

#pragma mark - 请求OPSeason
- (MKNetworkOperation *)requestOPSeason:(NSInteger)season
                         CompleteHandle:(ReturnDictionaryBlock)completionHandler
                           errorHandler:(MKNKErrorBlock)errorHandler;
@end
