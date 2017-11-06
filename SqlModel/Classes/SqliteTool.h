//
//  SqliteTool.h
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

//现在是对应的一个数据库对应的单张表，单词查询。

#import <Foundation/Foundation.h>

@interface SqliteTool : NSObject

/**
 *  根据uid处理sql语句，
 *  uid == nil,common.sqlite;
 *  uid != nil,uid.sqlite
 */
+ (BOOL)dealSql:(NSString *)sql uid:(NSString *)uid ;

+ (BOOL)dealSqls:(NSArray <NSString *>*)sqls uid:(NSString *)uid ;
/**
 *  查询数据
 */
+ (NSMutableArray <NSMutableDictionary *>*)querySql:(NSString *)sql uid:(NSString *)uid ;
/**
 *  插入
 */
+ (BOOL)insertSql:(NSString *)sql cls:(Class)cls uid:(NSString *)uid ;
/**
 *  删除
 */
+ (BOOL)deleteSql:(NSString *)sql cls:(Class)cls uid:(NSString *)uid ;
/**
 *  删除uid对应的所有的收藏
 */
+ (BOOL)deleteAll:(NSString *)sql cls:(Class)cls uid:(NSString *)uid ;
/**
 *  更新对应的数据,
 *  sql:这个需要写对应的sql语句
 *  uid:对应的数据库名称
 */
+ (BOOL)updateSql:(NSString *)sql cls:(Class)cls uid:(NSString *)uid ;

@end
