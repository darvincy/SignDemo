//
//  SignInquireController.m
//  SignDemo-XQ
//
//  Created by 萧奇 on 2017/8/15.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "SignInquireController.h"

@interface SignInquireController ()

@end

@implementation SignInquireController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UILabel *aletLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,300,40)];
    aletLabel.center = self.view.center;
    aletLabel.text = @"请求后台所得到的数据";
    aletLabel.textAlignment = NSTextAlignmentCenter;
    aletLabel.textColor = kUIColorFromRGB(0x3cb2e0);
    aletLabel.font = [UIFont systemFontOfSize:16];
    aletLabel.backgroundColor = [UIColor clearColor];
    [self.view addSubview:aletLabel];
    
    self.view.backgroundColor = [UIColor whiteColor];
}
@end
