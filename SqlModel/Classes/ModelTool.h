//
//  ModelTool.h
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//
/*********          操作模型的工具类           *********/
#import <Foundation/Foundation.h>

@interface ModelTool : NSObject
/**
 *  创建表名
 */
+ (NSString *)tableName:(Class)cls ;
/**
 *  临时表名 更新表时需要
 */
+ (NSString *)tempTableName:(Class)cls ;
/**
 *  获得当前类型类的名字和类型
 */
+ (NSDictionary *)classIvarNameTypeDic:(Class)cls ;
/**
 *  保存到数据库中的字段名字和类型
 */
+ (NSDictionary *)classIvarNameSqliteDic:(Class)cls;
/**
 *  返回对应的字段的名字和类型 例如：age integer,name text等 方便写对应的sql语句查询对应的字段和修改对应的字段
 */
+ (NSString *)columnNamesAndTypes:(Class)cls ;
/**
 * 获得当前的类的名字和值
 */
+ (NSDictionary *)columnNamesAndValues:(Class)cls object:(id)obj;
@end
