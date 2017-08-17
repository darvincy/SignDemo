//
//  DataBase.h
//  FMDBTest
//
//  Created by 萧奇 on 2017/8/5.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignData.h"
#import <FMDB/FMDB.h>

@interface DataBase : NSObject

/**
 *  添加SignData
 *
 */
- (void)addSignData:(SignData *)signData;
/**
 *  删除SignData
 *
 */
- (void)deleteSignData:(SignData *)signData;
/**
 *  更新SignData
 *
 */
- (void)updateSignData:(SignData *)signData;

/**
 *  获取所有数据
 *
 */
- (NSMutableArray *)getAllSignData;

/**
 *  删除所有数据
 *
 */
- (void)deleteAllSignData;


+ (instancetype)shareDataBase;


@end



