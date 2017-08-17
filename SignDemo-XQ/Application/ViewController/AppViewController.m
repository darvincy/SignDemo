//
//  AppViewController.m
//  SignDemo-XQ
//
//  Created by 萧奇 on 2017/8/14.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "AppViewController.h"

@interface AppViewController ()

@end

@implementation AppViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [[UIButton alloc] init];
    [button setBackgroundImage:[UIImage imageNamed:@"332"] forState:UIControlStateNormal];
    [button sizeToFit];
    button.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    [button addTarget:self action:@selector(signClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = kUIColorFromRGB(0x3cb2e0);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
}

- (void)signClick {
    
    UIViewController *signViewController = [NSClassFromString(@"SignViewController") new];
    signViewController.title = @"移动签到";
    [self.navigationController pushViewController:signViewController animated:YES];
}


@end
