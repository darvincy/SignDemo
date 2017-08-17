//
//  MAHeaderView.m
//  MAMapKit_static_demo
//
//  Created by songjian on 14-4-28.
//  Copyright (c) 2014年 songjian. All rights reserved.
//

#import "MAHeaderView.h"

/* 间距. */
#define MAHeaderViewMargin 5.f

@interface MAHeaderView ()<UIGestureRecognizerDelegate>

@property (nonatomic, assign, readwrite) BOOL expanded;

@property (nonatomic, strong) UIImageView *expandImageView;

@property (nonatomic, strong) UILabel *label;

@property (nonatomic, strong) UITapGestureRecognizer *singleTapGestureRecognizer;

@end

@implementation MAHeaderView

@synthesize delegate        = _delegate;
@synthesize expanded        = _expanded;
@synthesize section         = _section;

@synthesize expandImageView     = _expandImageView;
@synthesize label               = _label;

@synthesize singleTapGestureRecognizer = _singleTapGestureRecognizer;

#pragma mark - Interface

- (NSString *)text
{
    return self.label.text;
}

- (void)setText:(NSString *)text
{
    self.label.text = text;
}

#pragma mark - Handle Gesture

/* 响应单击手势. */
- (void)singleTapGesture:(UITapGestureRecognizer *)tap
{
    [self toggle];
}

#pragma mark - Utility

/* 切换. */
- (void)toggle
{
    /* 更新数据. */
    self.expanded = !self.expanded;
    
    /* 更新UI. */
    [self updateUI];
    
    [self notifyDelegate];
}

/* 更新图标. */
- (void)updateUI
{
    self.expandImageView.highlighted = self.expanded;
}

/* 通知代理. */
- (void)notifyDelegate
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(headerView:section:expanded:)])
    {
        [self.delegate headerView:self section:self.section expanded:self.expanded];
    }
}

#pragma mark - Initialization

/* 初始化图标. */
- (void)setupExpandImageView
{
    self.expandImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrow_right"]
                                             highlightedImage:[UIImage imageNamed:@"arrow_down"]];
    
    self.expandImageView.center = CGPointMake(MAHeaderViewMargin + CGRectGetWidth(self.expandImageView.bounds) / 2.f, CGRectGetMidY(self.bounds));
    
    /* 根据model初始化UI. */
    self.expandImageView.highlighted = self.expanded;
    
    [self addSubview:self.expandImageView];
}

/* 初始化文本. */
- (void)setupLabel
{
    CGFloat x = CGRectGetMaxX(self.expandImageView.frame) + MAHeaderViewMargin;
    
    CGRect theRect = CGRectMake(x,
                                MAHeaderViewMargin,
                                CGRectGetWidth(self.bounds) - x - MAHeaderViewMargin,
                                CGRectGetHeight(self.bounds) - MAHeaderViewMargin * 2.f);
    
    self.label = [[UILabel alloc] initWithFrame:theRect];
    self.label.backgroundColor  = [UIColor clearColor];
    self.label.textColor        = [UIColor blackColor];
    
    [self addSubview:self.label];
}

- (void)setupBackgroundMaskView
{
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds) - 1)];
    
    maskView.backgroundColor = [UIColor whiteColor];
    
    [self addSubview:maskView];
}

- (void)setupTapGestureRecognizer
{
    self.singleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesture:)];
    self.singleTapGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.singleTapGestureRecognizer];
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame expanded:(BOOL)expanded
{
    if (self = [super initWithFrame:frame])
    {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor lightGrayColor];
        
        self.expanded = expanded;
        
        [self setupBackgroundMaskView];
        
        [self setupExpandImageView];
        
        [self setupLabel];
        
        [self setupTapGestureRecognizer];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame expanded:NO];
}

@end
