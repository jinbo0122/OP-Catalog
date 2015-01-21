//
//  OPContentModel.h
//  OP Catalog
//
//  Created by Albert Lee on 1/21/15.
//  Copyright (c) 2015 Albert Lee. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol OPContentModelDelegate;
@interface OPContentModel : NSObject
@property (nonatomic, strong)NSMutableArray *contentArray;
@property (nonatomic, strong)NSMutableArray *checkArray;
@property (nonatomic,   weak)id<OPContentModelDelegate>delegate;
- (void)requestEpisodes;
@end

@protocol OPContentModelDelegate <NSObject>
- (void)contentModelDidLoadData:(OPContentModel *)model;
@end
