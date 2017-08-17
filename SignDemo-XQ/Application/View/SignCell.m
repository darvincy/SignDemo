//
//  SignCell.m
//  CnovitOffice
//
//  Created by 萧奇 on 2017/8/5.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "SignCell.h"

#define Ksize_x 10
#define Ksize_y 5
#define Khight  60
#define Kweight 260

@implementation SignCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //时间
        self.currentTime = [[UILabel alloc ] init];
        self.currentTime.frame = CGRectMake(Ksize_x,Ksize_y,Kweight,25);
        self.currentTime.font = [UIFont systemFontOfSize:14];
        self.currentTime.textColor = kUIColorFromRGB(0x808080);
        [self.contentView addSubview:self.currentTime];
        
        //位置
        self.currentLocation = [[UILabel alloc ] init];
        self.currentLocation.frame = CGRectMake(Ksize_x,Ksize_y+25,Kweight,25);
        self.currentLocation.font = [UIFont systemFontOfSize:14];
        self.currentLocation.textColor = kUIColorFromRGB(0x808080);
        [self.contentView addSubview:self.currentLocation];
        
        // 经度 Longitude
        self.currentLongitude = [[UILabel alloc ] init];
        self.currentLongitude.font = [UIFont systemFontOfSize:14];
        self.currentLongitude.textColor = kUIColorFromRGB(0x808080);
        [self.contentView addSubview:self.currentLongitude];
        
        // 纬度 Latitude
        self.currentLatitude = [[UILabel alloc ] init];
        self.currentLatitude.font = [UIFont systemFontOfSize:14];
        self.currentLatitude.textColor = kUIColorFromRGB(0x808080);
        [self.contentView addSubview:self.currentLatitude];
    }
    return self;
}

- (void)setSignData:(SignData *)signData {
    
    self.currentTime.text = [NSString stringWithFormat:@"时间:%@", signData.createdTime];
    self.currentLocation.text = [NSString stringWithFormat:@"位置:%@", signData.name];
    // 根据文本长度确定label的宽高
    NSString *currentLongitude = [NSString stringWithFormat:@"经度:%@",signData.longitude];
    CGRect tempRectLongitude = [currentLongitude boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40,2000) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
    self.currentLongitude.frame = CGRectMake(SCREEN_WIDTH - tempRectLongitude.size.width - 20, self.currentTime.top + 5, tempRectLongitude.size.width, tempRectLongitude.size.height);
    self.currentLongitude.text = currentLongitude;
    // 根据文本长度确定label的宽高
    NSString *currentLatitude = [NSString stringWithFormat:@"纬度:%@",signData.latitude];
    CGRect tempRectLatitude = [currentLatitude boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-40,2000) options:NSStringDrawingUsesLineFragmentOrigin  attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]} context:nil];
    self.currentLatitude.frame = CGRectMake(SCREEN_WIDTH - tempRectLatitude.size.width - 20, self.currentLocation.top + 5, tempRectLatitude.size.width, tempRectLatitude.size.height);
    self.currentLatitude.text = currentLatitude;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
