//
//  OfflineSignController.m
//  CnovitOffice
//
//  Created by 萧奇 on 2017/8/5.
//  Copyright © 2017年 萧奇. All rights reserved.
//

#import "OfflineSignController.h"
#import "DataBase.h"
#import "SignCell.h"

static NSString *identifier = @"SignCell";

@interface OfflineSignController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong)UITableView *signTableView;

@property (nonatomic, strong)NSMutableArray *signArray;

@end

@implementation OfflineSignController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    
    // 从数据库读取数据
    [self loadData];
}

- (void)initUI {
    
    self.signTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.signTableView.delegate = self;
    self.signTableView.dataSource = self;
    [self.signTableView registerClass:[SignCell class] forCellReuseIdentifier:identifier];
    [self.view addSubview:self.signTableView];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)loadData {
    
    self.signArray = [[DataBase shareDataBase] getAllSignData];
    [self.signTableView reloadData];
    if (self.signArray.count == 0) {
        self.signTableView.hidden = YES;
        UILabel *aletLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,100,40)];
        aletLabel.center = self.view.center;
        aletLabel.text = @"暂无数据";
        aletLabel.textAlignment = NSTextAlignmentCenter;
        aletLabel.textColor = kUIColorFromRGB(0x3cb2e0);
        aletLabel.font = [UIFont systemFontOfSize:16];
        aletLabel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:aletLabel];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.signArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SignCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.signData = self.signArray[indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 65;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewRowAction *action0 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"上传" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        NSLog(@"点击了上传");
        // 收回左滑出现的按钮(退出编辑模式)
        tableView.editing = NO;
    }];
    
    UITableViewRowAction *action1 = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [[DataBase shareDataBase] deleteSignData:self.signArray[indexPath.row]];
        [self.signArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.signTableView reloadData];
    }];
    
    return @[action1, action0];
}


@end
