//
//  SqliteTool.m
//  SqlModel
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import "SqliteTool.h"
#import <sqlite3.h>

#define KCachePath @"/Users/manyiwang/Desktop"

@implementation SqliteTool

sqlite3 *qqdb = nil;
#pragma mark -
#pragma mark - 处理sql语句
+ (BOOL)dealSql:(NSString *)sql uid:(NSString *)uid {
    if (![self openDB:uid]) {
        NSLog(@"数据库打开失败");
        return false;
    }
    //执行sql语句
    BOOL result = sqlite3_exec(qqdb, sql.UTF8String, nil, nil, nil) == SQLITE_OK;
    [self closeDB:uid];
    return result;
}

+ (BOOL)dealSqls:(NSArray<NSString *> *)sqls uid:(NSString *)uid {
    [self beginTranasction:uid];
    for (NSString *sql in sqls) {
        BOOL result = [self dealSql:sql uid:uid];
        if (!result) {
            [self rollBackTranscation:uid];
        }
    }
    [self commitTranscation:uid];
    return YES;
}


+ (void)beginTranasction:(NSString *)uid {
    [self dealSql:@"begin transaction" uid:uid];
}

+ (void)rollBackTranscation:(NSString *)uid {
    [self dealSql:@"rollback transaction" uid:uid];
}

+ (void)commitTranscation:(NSString *)uid {
    [self dealSql:@"commit transaction" uid:uid];
}
#pragma mark - 数据库查询
/**
 *   1.创建准备语句
 *   2.0 绑定数据
 *   2.执行
 */
+ (NSMutableArray<NSMutableDictionary *> *)querySql:(NSString *)sql uid:(NSString *)uid {
    [self openDB:uid];
    sqlite3_stmt *ppStmt = nil;
    if(sqlite3_prepare_v2(qqdb, sql.UTF8String, -1, &ppStmt, nil) != SQLITE_OK){
        NSLog(@"查询准备语句失败");
        return nil;
    }
    NSMutableArray *rowDicArray = [NSMutableArray array];
    while (sqlite3_step(ppStmt) == SQLITE_ROW) {
       int count = sqlite3_column_count(ppStmt);
        NSMutableDictionary *rowDic = [NSMutableDictionary dictionary];
        [rowDicArray addObject:rowDic];
        //一行一行的去读取数据
        for (int i = 0; i < count; i++) {
            const char *columnName_C = sqlite3_column_name(ppStmt, i);
            NSString *columnName_OC = [[NSString alloc] initWithUTF8String:columnName_C];
            int type = sqlite3_column_type(ppStmt, i);
            id value = nil;
            //SQLITE_INTEGER
            //SQLITE_FLOAT
            //SQLITE_BLOB
            //SQLITE_NULL
            //SQLITE3_TEXT
            switch (type) {
                case SQLITE_INTEGER:
                    value = @(sqlite3_column_int(ppStmt, i));
                    break;
                case SQLITE3_TEXT:{
                    const unsigned char* text = sqlite3_column_text(ppStmt, i);
                    value = [[NSString alloc] initWithUTF8String:(const char*)text];
                }break;
                case SQLITE_FLOAT:
                    value = @(sqlite3_column_double(ppStmt, i));
                    break;
                case SQLITE_BLOB:{
                    value = (__bridge id)(sqlite3_column_blob(ppStmt, i));
                }break;
                case SQLITE_NULL:
                    value = @"";
                break;
            }
            [rowDic setValue:value forKey:columnName_OC];
        }
    }
    sqlite3_finalize(ppStmt);
    [self closeDB:uid];
    return rowDicArray;
}

+ (BOOL)insertSql:(NSString *)sql cls:(Class)cls uid:(NSString *)uid {
    return [SqliteTool dealSql:sql uid:uid];
}

+ (BOOL)deleteSql:(NSString *)sql cls:(Class)cls uid:(NSString *)uid {
    return [SqliteTool dealSql:sql uid:uid];
}

+ (BOOL)deleteAll:(NSString *)sql cls:(Class)cls uid:(NSString *)uid {
    return [SqliteTool dealSql:sql uid:uid];
}

+ (BOOL)updateSql:(NSString *)sql cls:(Class)cls uid:(NSString *)uid {
    return [SqliteTool dealSql:sql uid:uid];
}
#pragma mark - private method
#pragma mark - 打开数据库
+ (BOOL)openDB:(NSString *)uid {
    NSString *dbName = @"common.sqlite";
    if (uid.length != 0) {
        dbName = [NSString stringWithFormat:@"%@.sqlite",uid];
    }
    NSString *dbPath = [KCachePath stringByAppendingPathComponent:dbName];
    return sqlite3_open(dbPath.UTF8String, &qqdb) == SQLITE_OK;
}
#pragma mark - 关闭数据库
+ (void)closeDB:(NSString *)uid {
    sqlite3_close(qqdb);
}
@end
