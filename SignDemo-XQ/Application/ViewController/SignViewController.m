//
//  SignViewController.m
//  SignDemo-XQ
//
//  Created by 萧奇 on 2017/8/14.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "User.h"
#import "SignData.h"
#import "DataBase.h"
#import "SignViewController.h"
#import "OfflineMapController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

// 设置公司经纬度
#define kLatitude 30.480672
#define kLongitude 114.542898

@interface SignViewController ()<MAMapViewDelegate>{
    BOOL isSelect;
    UIImageView *selectImg;
}

// 高德地图
@property (nonatomic, strong)MAMapView *mapView;
// 有多少个打卡范围(可拓展不同地方打卡)
@property (nonatomic, copy)NSArray *circles;
// 经纬度
@property (nonatomic,strong)NSString *userLongitude;
@property (nonatomic,strong)NSString *userLatitude;
// 公司或者nil(在公司或者不在公司字段,无影响)
@property (nonatomic,strong)NSString *location;
// 用户
@property (nonatomic, strong)User *user;

@end

@implementation SignViewController


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    // 进入界面就以定位点为地图中心
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.userLatitude floatValue], [self.userLongitude floatValue]) animated:NO];
    // 将绘制的图形添加到地图上
    [self.mapView addOverlays:self.circles];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // 创建导航项
    [self initNavigationItem];
    // 初始化地图
    [self initMapView];
    // 初始化 MAUserLocationRepresentation 对象
    [self initUserLocationRepresentation];
    // 创建按钮
    [self initMapButton];
}

- (void)initNavigationItem {
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"more_btn02"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStyleDone target:self action:@selector(selectPressed)];
}

- (void)initMapView {
    // https配置
    [AMapServices sharedServices].enableHTTPS = YES;
    // 初始化地图
    self.mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, NAVIGATIONBAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATIONBAR_HEIGHT)];
    self.mapView.delegate = self;
    // 显示定位小蓝点
    self.mapView.showsUserLocation = YES;
    self.mapView.showsCompass = NO;
    // 追踪用户的location更新
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    // 放大等级
    [self.mapView setZoomLevel:16 animated:YES];
    [self.view addSubview:self.mapView];
}

- (void)initUserLocationRepresentation {
    // 初始化小蓝点
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    r.showsAccuracyRing = YES;// 精度圈是否显示，默认YES
    r.enablePulseAnnimation = YES;// 内部蓝色圆点是否使用律动效果, 默认YES
    r.lineWidth = 2;// 精度圈 边线宽度，默认0
    [self.mapView updateUserLocationRepresentation:r];
}

- (void)initMapButton {
    
    UIButton *signBtn = [[UIButton alloc ] initWithFrame:CGRectMake(20,SCREEN_HEIGHT - 80,SCREEN_WIDTH - 20*2,44)];
    [signBtn setBackgroundImage:[UIImage imageNamed:@"sign"] forState:UIControlStateNormal];
    [signBtn setBackgroundImage:[UIImage imageNamed:@"sign_select"] forState:UIControlStateHighlighted];
    [signBtn setTitle:@"签 到" forState:UIControlStateNormal];
    [signBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [signBtn addTarget:self action:@selector(signWork) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signBtn];
    // 定位按钮
    UIButton *searchBtn = [[UIButton alloc ] initWithFrame:CGRectMake(SCREEN_WIDTH - 20 - 37, NAVIGATIONBAR_HEIGHT + 20, 37, 37)];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"locationPoint"] forState:UIControlStateNormal];
    [searchBtn setBackgroundImage:[UIImage imageNamed:@"locationPoint_select"] forState:UIControlStateHighlighted];
    [searchBtn addTarget:self action:@selector(locationClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:searchBtn];
    
    UIButton *zoomUpBtn = [[UIButton alloc] initWithFrame:CGRectMake(signBtn.right - 37, signBtn.top - 67 - 30, 37, 37)];
    [zoomUpBtn setBackgroundImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal];
    [zoomUpBtn setBackgroundImage:[UIImage imageNamed:@"up_select"] forState:UIControlStateHighlighted];
    [zoomUpBtn addTarget:self action:@selector(zoomUp) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomUpBtn];
    
    UIButton *zoomDownBtn = [[UIButton alloc ] initWithFrame:CGRectMake(signBtn.right - 37, signBtn.top - 30 - 30, 37, 37)];
    [zoomDownBtn setBackgroundImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal];
    [zoomDownBtn setBackgroundImage:[UIImage imageNamed:@"down_select"] forState:UIControlStateHighlighted];
    [zoomDownBtn addTarget:self action:@selector(zoomDown) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:zoomDownBtn];
    
    BOOL isOnline = self.user.netState;
    // 判断是否离线
    if (isOnline) {
        // 绘制打卡范围
        [self setAddress];
    }else {
        [self setAddress];
    }
}

- (void)setAddress {
    
    NSMutableArray *arr = [NSMutableArray array];
    MACircle *circle1 = [MACircle circleWithCenterCoordinate:CLLocationCoordinate2DMake(kLatitude, kLongitude) radius:500];
    [arr addObject:circle1];
    self.circles = [NSArray arrayWithArray:arr];
}

// 放大
- (void)zoomUp {
    [self.mapView setZoomLevel:(self.mapView.zoomLevel + 1) animated:YES];
}

// 缩小
- (void)zoomDown {
    [self.mapView setZoomLevel:(self.mapView.zoomLevel - 1) animated:YES];
}

- (void)selectPressed {
    
    if(isSelect == NO) {
        isSelect = YES;
        if(selectImg != nil) {
            [selectImg removeFromSuperview];
            selectImg = nil;
        }
        selectImg = [[UIImageView alloc ] initWithFrame:CGRectMake(SCREEN_WIDTH - 110, NAVIGATIONBAR_HEIGHT, 90, 140)];
        selectImg.image = [UIImage imageNamed:@"popBtn"];
        selectImg.userInteractionEnabled = YES;
        [self.view addSubview:selectImg];
        
        [self initIndex];
    }else {
        isSelect = NO;
        if(selectImg != nil){
            [selectImg removeFromSuperview];
            selectImg = nil;
        }
    }
}

- (void)initIndex {
    
    UIButton *btn1 = [[UIButton alloc ] init];
    btn1.frame = CGRectMake(10,8,70,(selectImg.height-8)/3);
    [btn1 setTitle:@"签到查询" forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:14];
    btn1.tag = 100;
    [btn1 addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectImg addSubview:btn1];
    
    UIButton *btn2 = [[UIButton alloc ] init];
    btn2.frame = CGRectMake(10,btn1.bottom,70,(selectImg.height-8)/3);
    [btn2 setTitle:@"离线地图" forState:UIControlStateNormal];
    btn2.titleLabel.font = [UIFont systemFontOfSize:14];
    btn2.tag = 101;
    [btn2 addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectImg addSubview:btn2];
    
    UIButton *btn3 = [[UIButton alloc ] init];
    btn3.frame = CGRectMake(10,btn2.bottom,70,(selectImg.height-8)/3);
    [btn3 setTitle:@"离线记录" forState:UIControlStateNormal];
    btn3.titleLabel.font = [UIFont systemFontOfSize:14];
    btn3.tag = 102;
    [btn3 addTarget:self action:@selector(selectBtn:) forControlEvents:UIControlEventTouchUpInside];
    [selectImg addSubview:btn3];
}

// 签到
- (void)signWork {
    
    self.user = [User shareUser];
    BOOL isOnline = self.user.netState;
    // 判断是否离线
    /// 在线
    if (isOnline) {
        // 半径在500米以内就在范围内
        double r = 500;
        double distance = [self distanceBetweenCenterLatitude:kLatitude centerLongitude:kLongitude userLatitude:[self.userLatitude doubleValue]  userLongitude:[self.userLongitude doubleValue]];
        if (distance <= r) {
            // 在范围内的提示
        }else {
            // 不在范围内的提示
        }
        // 接口名称
        NSString *url = @"www.baidu.com";
        // 用户名, 密码以及其他参数
        // 后台配置参数(根据自己公司后台配置)
        NSMutableDictionary *parameters  = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"用户名", @"loginName", @"密码", @"password", nil];
        [parameters setObject:@([self.userLongitude doubleValue]) forKey:@"longitude"];
        [parameters setObject:@([self.userLatitude doubleValue]) forKey:@"latitude"];
        [parameters setObject:@(0) forKey:@"type"];//0高德，1百度
        // 签到请求
        [HttpTool postWithPath:url params:parameters success:^(id responseObject) {
            Log(@"提交成功,签到成功");
        } failure:^(NSError *error) {
            Log(@"%@",error);
        }];
        // 仅作Demo演示(直接签到成功)
        // 签到成功
        [self presentAlertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"签到成功"] cancelTitle:@"好的"];
        
        /// 离线
    }else{
        // 半径在500米以内就在范围内
        double r = 500;
        double distance = [self distanceBetweenCenterLatitude:kLatitude centerLongitude:kLongitude userLatitude:[self.userLatitude doubleValue]  userLongitude:[self.userLongitude doubleValue]];
        if (distance <= r) {
            [self presentAlertControllerWithTitle:@"提示" message:@"离线签到,在公司范围内,请注意提交" cancelTitle:@"好的"];
            self.location = @"公司";
        }else {
            [self presentAlertControllerWithTitle:@"提示" message:@"离线签到,不在公司范围内" cancelTitle:@"好的"];
            self.location = @"不在公司";
        }
        // FMDB储存
        [self addData];
    }
}

- (void)addData {
    
    SignData *signData = [SignData new];
    signData.createdTime = [self getCurrentTime];
    signData.longitude = self.userLongitude;
    signData.latitude = self.userLatitude;
    signData.name = self.location;
    [[DataBase shareDataBase] addSignData:signData];
}

- (NSString *)getCurrentTime {
    // 获取当前时间
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter new];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

// 选择按钮
-(void)selectBtn:(UIButton *)sender {
    
    switch (sender.tag) {
        case 100:
        {
            // 签到查询
            UIViewController *signInquireController = [NSClassFromString(@"SignInquireController") new];
            signInquireController.hidesBottomBarWhenPushed = YES;
            signInquireController.title = @"我的打卡记录";
            [self.navigationController pushViewController:signInquireController animated:YES];
        }
            break;
            
        case 101:
        {
            // 版本控制
            if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
                // 离线地图
                OfflineMapController *offlineViewController = [OfflineMapController new];
                offlineViewController.mapView = self.mapView;
                offlineViewController.title = @"离线数据下载";
                offlineViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
                UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:offlineViewController];
                [self presentViewController:navigationController animated:YES completion:nil];
            }else {
                [self presentAlertControllerWithTitle:@"提示" message:@"系统版本过低，不支持离线地图" cancelTitle:@"好的"];
            }
        }
            break;
            
        case 102:
        {
            // 离线签到记录
            UIViewController *signInquireController = [NSClassFromString(@"OfflineSignController") new];
            signInquireController.hidesBottomBarWhenPushed = YES;
            signInquireController.title = @"离线记录";
            [self.navigationController pushViewController:signInquireController animated:YES];
        }
            break;
            
        default:
            break;
    }
    
    isSelect = NO;
    if(selectImg != nil) {
        [selectImg removeFromSuperview];
        selectImg = nil;
    }
}


// 定位按钮
-(void)locationClick {
    // 设置地图中心位置
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.userLatitude floatValue], [self.userLongitude floatValue]) animated:YES];
    [self.mapView setZoomLevel:18 animated:YES];
}

- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation {
    // 获取用户位置的经纬度
    self.userLongitude = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    self.userLatitude = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
}

// 高德地图delegate
#pragma mark - MAMapViewDelegate

- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay{
    
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer *circleRenderer = [[MACircleRenderer alloc] initWithCircle:overlay];
        circleRenderer.lineWidth    = 1.f;
        circleRenderer.strokeColor = [UIColor blueColor];
        circleRenderer.lineDash     = NO;
        
        NSInteger index = [self.circles indexOfObject:overlay];
        if(index == 0) {
            circleRenderer.fillColor    = kUIColorFromRGBAlpha(0x24b7eb);
        } else if(index == 1) {
            circleRenderer.fillColor   = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        } else if(index == 2) {
            circleRenderer.fillColor   = [[UIColor blueColor] colorWithAlphaComponent:0.3];
        } else {
            circleRenderer.fillColor   = [[UIColor yellowColor] colorWithAlphaComponent:0.3];
        }
        return circleRenderer;
    }
    
    return nil;
}

// 计算两个经纬度点的距离
- (double)distanceBetweenCenterLatitude:(double)centerLatitude centerLongitude:(double)centerLongitude userLatitude:(double)userLatitude  userLongitude:(double)userLongitude{
    
    double dd = M_PI/180;
    double x1=centerLatitude*dd,x2=userLatitude*dd;
    double y1=centerLongitude*dd,y2=userLongitude*dd;
    double R = 6371004;
    double distance = (2*R*asin(sqrt(2-2*cos(x1)*cos(x2)*cos(y1-y2) - 2*sin(x1)*sin(x2))/2));
    //返回 m
    return  distance;
}

// 警告弹框
- (void)presentAlertControllerWithTitle:(NSString *)title message:(NSString *)message cancelTitle:(NSString *)cancelTitle {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


@end
