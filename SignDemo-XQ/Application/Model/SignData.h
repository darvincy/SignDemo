//
//  SignData.h
//  FMDBTest
//
//  Created by 萧奇 on 2017/8/5.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SignData : NSObject


//@property (nonatomic, strong)NSNumber *ID;
//@property (nonatomic, copy)NSString *currentTime;
//@property (nonatomic, copy)NSString *userLongitude;
//@property (nonatomic, copy)NSString *userLatitude;
//@property (nonatomic, copy)NSString *location;

@property (nonatomic, strong)NSNumber *id;
@property (nonatomic, assign)NSInteger appId;
@property (nonatomic, copy)NSString *address;
@property (nonatomic, copy)NSString *longitude;
@property (nonatomic, copy)NSString *createdTime;
@property (nonatomic, copy)NSString *latitude;
@property (nonatomic, copy)NSString *name;


@end
