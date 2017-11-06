//
//  ModelTool.m
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import "ModelTool.h"
#import <objc/runtime.h>
#import "ModelProtocol.h"
@implementation ModelTool

+ (NSString *)tableName:(Class)cls {
    return NSStringFromClass(cls);
}

+ (NSString *)tempTableName:(Class)cls {
    return [NSStringFromClass(cls) stringByAppendingString:@"_temp"];
}

+ (NSDictionary *)classIvarNameTypeDic:(Class)cls {

    unsigned int outCount = 0;
    Ivar *ivars = class_copyIvarList(cls, &outCount);
    NSArray *ignoreNames = nil;
    if ([cls respondsToSelector:@selector(ignoreColumnNames)]) {
        ignoreNames = [cls ignoreColumnNames];
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (int i = 0; i < outCount; i++) {
         Ivar var = ivars[i];
         const char *name_C = ivar_getName(var);
        NSString *name_OC = [[NSString alloc] initWithUTF8String:name_C];
        if ([name_OC hasPrefix:@"_"]) {
            name_OC = [name_OC substringFromIndex:1];
        }
        if ([ignoreNames containsObject:name_OC]) {
            continue;
        }
        const char *type_C = ivar_getTypeEncoding(var);
        NSString *type_OC = [[NSString alloc] initWithUTF8String:type_C];
        type_OC = [type_OC stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"@\""]];
        //这个需要转化成不带一些特殊符号的字符串
         [dic setValue:type_OC forKey:name_OC];
    }
    return dic;
}

+ (NSDictionary *)classIvarNameSqliteDic:(Class)cls {
    //1.根据类获得当前的属性名和类型
    NSMutableDictionary *classDic = (NSMutableDictionary *)[self classIvarNameTypeDic:cls];
    //1.1 oc类型到sql类型
    NSDictionary *OC_C_TypeDic = [self ocTypeToSqliteTypeDic];
    //2.转化成对应的存储到sqlite中的字段名字和类型
    [classDic enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL * _Nonnull stop) {
        classDic[key] = OC_C_TypeDic[value];
    }];
    return classDic;
}

+ (NSString *)columnNamesAndTypes:(Class)cls {
    NSDictionary *columnDic = [self classIvarNameSqliteDic:cls];
    NSMutableArray *tempArray = [NSMutableArray array];
    [columnDic enumerateKeysAndObjectsUsingBlock:^(NSString *key,NSString *value, BOOL * _Nonnull stop) {
        [tempArray addObject:[NSString stringWithFormat:@"%@ %@",key,value]];
    }];
    return [tempArray componentsJoinedByString:@","];
}

+ (NSDictionary *)columnNamesAndValues:(Class)cls object:(id)obj {
    if (obj == nil){
        NSAssert(obj == nil, @"传入的模型不能为空");
        return nil;
    }
    NSLog(@"%@",[self classIvarNameSqliteDic:cls]);
    NSDictionary *sqlDic = [self classIvarNameSqliteDic:cls];
    NSArray *names = [self classIvarNameSqliteDic:cls].allKeys;
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    for (NSString *name in names) {
        id result = [obj valueForKey:name];
        if (result == nil) {
            result = @" ";
        }
        id value = sqlDic[name];
        if ([value isEqualToString:@"text"]||[value isEqualToString:@"blob"]) {
            result = [NSString stringWithFormat:@"'%@'",result];
        }
//        else if ([value isEqualToString:@"blob"]) {
//
//        }
        [dic setValue:result forKey:name];
    }
    return dic;
}

#pragma mark - 私有方法
+ (NSDictionary *)ocTypeToSqliteTypeDic {
    return @{
             @"d" : @"real",//double
             @"f" : @"real",//float

             @"i" : @"integer",//int
             @"q" : @"integer",//long
             @"Q" : @"integer",//long long
             @"B" : @"integer",//bool

             @"NSData": @"blob",

             @"NSDate" : @"text",
             @"NSString" : @"text",
             @"NSDictionary": @"text",
             @"NSMutableDictionary": @"text",
             @"NSArray": @"text",
             @"NSMutableArray": @"text"
             };
}



@end
