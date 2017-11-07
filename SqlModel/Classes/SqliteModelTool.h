//
//  SqliteModelTool.h
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

/*********          根据模型产生对应的sql语句去执行           *********/

#import <Foundation/Foundation.h>

@interface SqliteModelTool : NSObject

#pragma mark - 表的操作
/**
 *   创建用户表
 */
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid ;
/**
 *   表是否存在
 */
+ (BOOL)isTableExist:(Class)cls uid:(NSString *)uid ;
/**
 *   用户表是否需要更新
 *   //判断创建的sql语句
 *    returnValue : 返回为真两种情况:1.没有创建表
 *                                2.需要更新
 *                  0时:不需要
 */
+ (BOOL)isNeededUpdateTable:(Class)cls uid:(NSString *)uid ;
/**
 *  更新表单
 */
+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid ;
/**
 *   判断对应的primaryKey的值是否存在
 */
+ (BOOL)isExistPrimaryKey:(Class)cls uid:(NSString *)uid value:(NSString *)value ;
#pragma mark - 数据库操作
/**
 * 查询数据库中的数据
 */
+ (NSMutableArray *)queryTable:(Class)cls uid:(NSString *)uid ;
/**
 *  添加一个对应的模型
 */
+ (BOOL)insertModel:(Class)cls uid:(NSString *)uid obj:(id)obj;
/**
 * 删除对应的模型，根据某个sql是限定条件，比如:sql = (ID = 7)
 */
+ (BOOL)deleteModel:(Class)cls uid:(NSString *)uid obj:(NSString *)sql;
/**
 * 删除所有
 */
+ (BOOL)deleteAll:(Class)cls uid:(NSString *)uid ;

@end
