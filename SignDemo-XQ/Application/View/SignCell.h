//
//  SignCell.h
//  CnovitOffice
//
//  Created by 萧奇 on 2017/8/5.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SignData.h"

@interface SignCell : UITableViewCell

@property(nonatomic,strong)UILabel *currentTime;

@property(nonatomic,strong)UILabel *currentLocation;

@property(nonatomic,strong)UILabel *currentLongitude;

@property(nonatomic,strong)UILabel *currentLatitude;

@property (nonatomic, strong)SignData *signData;

@end
