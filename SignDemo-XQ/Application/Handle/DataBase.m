//
//  DataBase.m
//  FMDBTest
//
//  Created by 萧奇 on 2017/8/5.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "DataBase.h"

static DataBase *_dataBase = nil;

@interface DataBase ()<NSCopying,NSMutableCopying>{
    
    FMDatabase *_db;
}
@end

@implementation DataBase

+ (instancetype)shareDataBase {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataBase = [[DataBase alloc] init];
        [_dataBase initWithDataBase];
    });
    return _dataBase;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    
    if (_dataBase == nil) {
        _dataBase = [super allocWithZone:zone];
    }
    return _dataBase;
}

- (id)copy {
    return self;
}

- (id)mutableCopy {
    return self;
}

-(id)copyWithZone:(NSZone *)zone{
    return self;
}

-(id)mutableCopyWithZone:(NSZone *)zone{
    return self;
}

- (void)initWithDataBase {

    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];

    NSString *filePath = [documentsPath stringByAppendingPathComponent:@"SignDataBase.sqlite"];
    
    _db = [FMDatabase databaseWithPath:filePath];
    [_db open];
    
    NSString *signDataSql = @"CREATE TABLE 'signData' ('id' INTEGER PRIMARY KEY AUTOINCREMENT  NOT NULL ,'signData_id' VARCHAR(255),'signData_time' VARCHAR(255),'signData_longitude' VARCHAR(255),'signData_latitude' VARCHAR(255),'signData_location' VARCHAR(255))";
    
    [_db executeUpdate:signDataSql];
    [_db close];
}

// 添加signData
- (void)addSignData:(SignData *)signData {
    
    [_db open];
    NSNumber *maxID = @(0);
    
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM signData"];
    while ([res next]) {
        if ([maxID integerValue] < [[res stringForColumn:@"signData_id"] integerValue]) {
            maxID = @([[res stringForColumn:@"signData_id"] integerValue] ) ;
        }
    }
    maxID = @([maxID integerValue] + 1);
    [_db executeUpdate:@"INSERT INTO signData(signData_id,signData_time,signData_longitude,signData_latitude,signData_location)VALUES(?,?,?,?,?)",maxID,signData.createdTime,signData.longitude,signData.latitude,signData.name];
    [_db close];
}

// 删除signData
- (void)deleteSignData:(SignData *)signData {
    [_db open];
    [_db executeUpdate:@"DELETE FROM signData WHERE signData_id = ?",signData.id];
    [_db close];
}

// 更新signData
- (void)updateSignData:(SignData *)signData{
    
    [_db open];
    [_db executeUpdate:@"UPDATE 'signData' SET signData_time = ?  WHERE signData_id = ? ",signData.createdTime,signData.id];
    [_db executeUpdate:@"UPDATE 'signData' SET signData_longitude = ?  WHERE signData_id = ? ",signData.longitude,signData.id];
    [_db executeUpdate:@"UPDATE 'signData' SET signData_latitude = ?  WHERE signData_id = ? ",signData.latitude,signData.id];
    [_db executeUpdate:@"UPDATE 'signData' SET signData_location = ?  WHERE signData_id = ? ",signData.name,signData.id];
    [_db close];
}

// 得到所有signData
- (NSMutableArray *)getAllSignData{
    [_db open];
    
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    FMResultSet *res = [_db executeQuery:@"SELECT * FROM signData"];
    while ([res next]) {
        SignData *signData = [[SignData alloc] init];
        signData.id = @([[res stringForColumn:@"signData_id"] integerValue]);
        signData.createdTime = [res stringForColumn:@"signData_time"];
        signData.longitude = [res stringForColumn:@"signData_longitude"];
        signData.latitude = [res stringForColumn:@"signData_latitude"];
        signData.name = [res stringForColumn:@"signData_location"];
        [dataArray addObject:signData];
    }
    
    [_db close];
    return dataArray;
}

- (void)deleteAllSignData{
    [_db open];
    [_db executeUpdate:@"DELETE FROM signData"];
    [_db close];
}



@end
