//
//  Student.h
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ModelProtocol.h"

@interface Student : NSObject <ModelProtocol>

@property (nonatomic ,copy) NSString *name;//NSString
@property (nonatomic ,strong) NSData *data;//NSData
@property (nonatomic ,assign) int number;//i
@property (nonatomic ,assign) float math;//f
@property (nonatomic ,assign) double en;//d
@property (nonatomic ,assign) long long word;//q
@property (nonatomic ,strong) NSDate *time;//NSDate
@property (nonatomic ,copy) NSString *address;//NSString
@end
