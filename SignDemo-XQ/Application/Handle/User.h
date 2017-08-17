//
//  User.h
//  MoblieOffice
//
//  Created by 萧奇 on 2017/5/12.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject


+ (instancetype _Nullable )shareUser;

NS_ASSUME_NONNULL_BEGIN

@property (nonatomic, assign)BOOL isLogin;// 是否登录
@property (nonatomic, assign)BOOL netState;// 是否有网

NS_ASSUME_NONNULL_END


@end
