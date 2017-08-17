//
//  Macros.h
//  Moblie officing
//
//  Created by 萧奇 on 2017/5/11.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

// 屏幕宽度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
// 屏幕高度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
// 颜色
#define RGB(x,y,z,a) [UIColor colorWithRed:(x/255.0) green:(y/255.0) blue:(z/255.0) alpha:a]
// TabBar高度
#define TABBAR_HEIGHT 49
// Nav高度
#define NAVIGATIONBAR_HEIGHT 64


#define kUIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kUIColorFromRGBAlpha(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:0.4]

/** DEBUG模式下打印日志,当前行*/
#ifdef DEBUG
#define Log(FORMAT, ...) fprintf(stderr, "[%s:%d行] %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:FORMAT, ##__VA_ARGS__] UTF8String]);
#else
#define Log(...)
#endif


#endif /* Macros_h */


