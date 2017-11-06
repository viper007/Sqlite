//
//  ModelProtocol.h
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModelProtocol <NSObject>

@optional
+ (NSString *)primaryKey;

+ (NSArray *)ignoreColumnNames;
@end
