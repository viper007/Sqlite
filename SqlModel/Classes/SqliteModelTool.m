
#import "SqliteModelTool.h"
#import "SqliteTool.h"
#import "ModelTool.h"
#import "ModelProtocol.h"
@implementation SqliteModelTool

#pragma mark - 表的操作
+ (BOOL)createTable:(Class)cls uid:(NSString *)uid {
    //创建表
    NSString *createTableSql = [self createTableSql:cls uid:uid];
    return [SqliteTool dealSql:createTableSql uid:uid];
}

+ (BOOL)isTableExist:(Class)cls uid:(NSString *)uid {
    //select * from sqlite_master
    NSString *tableName = [ModelTool tableName:cls];
    NSString *tableSql = [NSString stringWithFormat:@"SELECT * FROM SQLITE_MASTER WHERE type = 'table' and name = %@",tableName];
    NSMutableArray *sqls = [SqliteTool querySql:tableSql uid:uid];
    if (sqls.count == 0) {
        return [self createTable:cls uid:uid];
    }
    return YES;
}
+ (BOOL)isNeededUpdateTable:(Class)cls uid:(NSString *)uid {
    NSString *tableName = [ModelTool tableName:cls];
    //得到现在要创建的表的数据与以前创建的表的数据之间的差别跟原来创建表的sql语句
    NSString *createTableSql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    NSDictionary *createSqlDic = [SqliteTool querySql:createTableSql uid:uid].firstObject;
    NSString *oldCreateSql = createSqlDic[@"sql"];
    if (oldCreateSql.length == 0) {
        return true;
    }
    //
    NSArray *oldArray = [self sortedColumnCreateSql:oldCreateSql];
    //
    NSString *newString = [self createTableSql:cls uid:uid];
    NSArray *newArray = [self sortedColumnCreateSql:newString];
    return ![newArray isEqualToArray:oldArray];
}

/**
 *   创建一个临时的表，把原来的数据迁移过去，在将临时表名修改为对应的表名
 */
+ (BOOL)updateTable:(Class)cls uid:(NSString *)uid {
    BOOL result = [self isNeededUpdateTable:cls uid:uid];
    if (!result) return YES;
    NSString *tableName = [ModelTool tableName:cls];
    NSString *tempTableName = [ModelTool tempTableName:cls];
    //1.主键
    NSString *primaryKey = nil;
    NSString *primaryKeyWithType = nil;
    if (![cls respondsToSelector:@selector(primaryKey)]) {//主键为ID
         primaryKey = @"ID";
         primaryKeyWithType = @"ID integer,";
    }else {
         primaryKey = [cls primaryKey];
         primaryKeyWithType = [NSString stringWithFormat:@"%@ integer,",primaryKey];
    }
    NSMutableArray *execSqls = [NSMutableArray array];
    //创建临时的数据
    NSString *createTempTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@%@,primary key(%@))",tempTableName,primaryKeyWithType,[ModelTool columnNamesAndTypes:cls],primaryKey];
    [execSqls addObject:createTempTableSql];
    //先插入主键,迁移过去
    NSString *insertKeySql = [NSString stringWithFormat:@"INSERT INTO %@(%@) SELECT %@ FROM %@",tempTableName,primaryKey,primaryKey,tableName];
    [execSqls addObject:insertKeySql];
    //对应的数据进行更新或者添加操作
    //得到现在要创建的表的数据与以前创建的表的数据之间的差别跟原来创建表的sql语句
    NSString *createTableSql = [NSString stringWithFormat:@"select sql from sqlite_master where type = 'table' and name = '%@'",tableName];
    NSDictionary *createSqlDic = [SqliteTool querySql:createTableSql uid:uid].firstObject;
    NSString *oldCreateSql = createSqlDic[@"sql"];
    //
    NSArray *oldArray = [self returnDataBaseColumnNames:[self sortedColumnCreateSql:oldCreateSql]];
    //现在得到的对应的columnName
    NSArray *newArray = [ModelTool classIvarNameSqliteDic:cls].allKeys;
    for (NSString *columnName in newArray) {
        if (![oldArray containsObject:columnName]) {
            continue;
        }
      //在这里判断对应的主键或者直接在制作对应的oldArray的时候去清除
      NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET %@ = (SELECT %@ FROM %@ WHERE %@.%@ = %@.%@)",tempTableName,columnName,columnName,tableName,tempTableName,primaryKey,tableName,primaryKey];
      [execSqls addObject:updateSql];
    }
    //删除原来的表
    NSString *deleteTableSql = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",tableName];
    [execSqls addObject:deleteTableSql];
    NSString *renameTableSql = [NSString stringWithFormat:@"ALTER TABLE %@ RENAME TO %@",tempTableName,tableName];
    [execSqls addObject:renameTableSql];
    return [SqliteTool dealSqls:execSqls uid:uid];
}

+ (BOOL)isExistPrimaryKey:(Class)cls uid:(NSString *)uid value:(NSString *)value {
    NSString *tableName = [ModelTool tableName:cls];
    NSString *primaryKey;
    if ([cls respondsToSelector:@selector(primaryKey)]) {
        primaryKey = [cls primaryKey];
    }else {
        primaryKey = @"ID";
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ where %@ = '%@'",tableName,primaryKey,value];
    NSArray *tempArray = [SqliteTool querySql:sql uid:uid];
    return tempArray.count;
}

#pragma mark - 数据库操作
+ (NSMutableArray *)queryTable:(Class)cls uid:(NSString *)uid {
    NSString *tableName = [ModelTool tableName:cls];
    //得到对应的列名字
    NSDictionary *sqlDic = [ModelTool classIvarNameSqliteDic:cls];
    NSArray *columnNames = sqlDic.allKeys;
    //SELECT column1, column2, columnN FROM table_name
    NSString *columnsSql = [columnNames componentsJoinedByString:@","];
    NSString *createSql = [NSString stringWithFormat:@"SELECT %@ FROM %@",columnsSql,tableName];
    return [SqliteTool querySql:createSql uid:uid];
}

+ (BOOL)insertModel:(Class)cls uid:(NSString *)uid obj:(id)obj{
    BOOL isExistTable = [self isTableExist:cls uid:uid];
    if (!isExistTable) {
        BOOL createTableSuccess = [self createTable:cls uid:uid];
        if (!createTableSuccess) {
            NSLog(@"创建表失败");
            return NO;
        }
    }
    NSString *tableName = [ModelTool tableName:cls];
    NSDictionary *names_values_dic = [ModelTool columnNamesAndValues:cls object:obj];
    NSArray *names = names_values_dic.allKeys;
    NSArray *values = names_values_dic.allValues;
    //insert into tableName (col1,col2) values ('value1','value2')
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@);",tableName,[names componentsJoinedByString:@","],[values componentsJoinedByString:@","]];
    return [SqliteTool dealSql:sql uid:uid];
}

+ (BOOL)deleteModel:(Class)cls uid:(NSString *)uid obj:(NSString *)sql {
    //先判断对应的表是否创建
    NSString *tableName = [ModelTool tableName:cls];
    //
    sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,sql];
    return [SqliteTool dealSql:sql uid:uid];
}

+ (BOOL)deleteAll:(Class)cls uid:(NSString *)uid {
    NSString *tableName = [ModelTool tableName:cls];
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    return [SqliteTool dealSql:sql uid:uid];
}



#pragma mark - 私有方法
/**
 *  得到对应的创建的sql语句
 */
+ (NSString *)createTableSql:(Class)cls uid:(NSString *)uid {
    NSString *tableName = [ModelTool tableName:cls];
    if (![cls respondsToSelector:@selector(primaryKey)]) {//自己添加对应的ID为主键
        NSString *primaryKey = @"ID";
        //create table if not exists tableName(sqli语句,primary key(primaryKey))
        NSString *primaryKeyWithType = @"ID integer,";
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@%@,primary key(%@))",tableName,primaryKeyWithType,[ModelTool columnNamesAndTypes:cls],primaryKey];
        return createTableSql;
    }else {
        NSString *primaryKey = [cls primaryKey];
        //create table if not exists tableName(sqli语句,primary key(primaryKey))
        NSString *createTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@,primary key(%@))",tableName,[ModelTool columnNamesAndTypes:cls],primaryKey];
        return createTableSql;
    }
}

/**
 *  根据创建的表的语句返回排好序的 columnName和type
 */
+ (NSArray *)sortedColumnCreateSql:(NSString *)sql {
    sql = [sql stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\""]];
    sql = [sql stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    sql = [sql stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    sql = [sql stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    NSString *createString = [sql componentsSeparatedByString:@"("][1];
    NSArray *nameTypeArray = [createString componentsSeparatedByString:@","];
    NSMutableArray *names = [NSMutableArray array];
    for (NSString *nameType in nameTypeArray) {
        if ([nameType containsString:@"primary"]) {
            continue;
        }
        NSString *tempNameType = [nameType stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@" "]];
        [names addObject:tempNameType];
    }
    [names sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    return names;
}

/**
 *  ID integer,
 *  data blob,
 *  en real,
 *  math real,
 *  name text,
 *  number integer,
 *  time text
 */
+ (NSArray *)returnDataBaseColumnNames:(NSArray *)sqlColumnNames {
      //
      NSMutableArray *returnValues = [NSMutableArray array];
    for (NSString *columnTypeName in sqlColumnNames) {
         NSString *columnName = [columnTypeName componentsSeparatedByString:@" "].firstObject;
        [returnValues addObject:columnName];
    }
    return returnValues;
}


@end
