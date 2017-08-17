//
//  User.m
//  MoblieOffice
//
//  Created by 萧奇 on 2017/5/12.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "User.h"

@implementation User

+ (instancetype)shareUser{
    
    static User *_user;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _user = [[User alloc]init];
    });

    return _user;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key{

}

@end
