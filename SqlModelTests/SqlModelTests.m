//
//  SqlModelTests.m
//  SqlModelTests
//
//  Created by 满艺网 on 2017/11/2.
//  Copyright © 2017年 lvzhenhua. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Student.h"
#import "Person.h"
#import "SqliteModelTool.h"
#import "SqliteTool.h"
@interface SqlModelTests : XCTestCase

@end

@implementation SqlModelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    Class cls = NSClassFromString(@"Student");
    BOOL result = [SqliteModelTool createTable:cls uid:nil];
    XCTAssertEqual(result , true);
}

- (void)testSqliteModelTool {

//    Student *s = [[Student alloc] init];
//    s.name = @"为什么";
//    s.number = 188;
//    s.time = [NSDate date];
//    BOOL result = [SqliteModelTool insertModel:NSClassFromString(@"Student") uid:nil obj:s];
//    XCTAssertEqual(result , true);

//    Class cls = NSClassFromString(@"Student");
//    BOOL result = [SqliteModelTool createTable:cls uid:nil];
//    XCTAssertEqual(result , true);

//    Class cls = NSClassFromString(@"Student");
//    BOOL result = [SqliteModelTool deleteAll:cls uid:nil];
//    XCTAssertEqual(result , true);

    //是否需要更新表
//    [SqliteModelTool isNeededUpdateTable:NSClassFromString(@"Student") uid:nil];
    BOOL result = [SqliteModelTool updateTable:NSClassFromString(@"Student") uid:nil];
    XCTAssertEqual(result , true);
}

- (void)testSqliteTool {
//     //添加新数据
//     NSString *sql = [NSString stringWithFormat:@"INSERT INTO Student (en,number,math,data,name,time) VALUES (0,118,0,'nil','为什么','2017-11-03 03:49:37 +0000')"];
//     [SqliteTool insertSql:sql uid:nil];

     //更新
     NSString *sql = [NSString stringWithFormat:@"UPDATE Student SET en = 99 WHERE ID=2"];
     [SqliteTool updateSql:sql uid:nil];


}
- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
