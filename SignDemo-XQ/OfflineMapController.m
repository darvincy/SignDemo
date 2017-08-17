//
//  OfflineMapController.m
//  CnovitOffice
//
//  Created by 萧奇 on 2017/8/4.
//  Copyright © 2017年 萧奇. All rights reserved.
//

// -----------------------------------------------------代码为高德地图里面的示例代码,直接拷贝过来即可----------------------------------------------------------------------
#import "OfflineMapController.h"
#import <MAMapKit/MAMapKit.h>
#import "MAHeaderView.h"

#define kDefaultSearchkey       @"bj"
#define kSectionHeaderMargin    15.f
#define kSectionHeaderHeight    22.f
#define kTableCellHeight        42.f
#define kTagDownloadButton 0
#define kTagPauseButton 1
#define kTagDeleteButton 2
#define kButtonSize 30.f
#define kButtonCount 3


NSString const *DownloadStageIsRunningKey2 = @"DownloadStageIsRunningKey";
NSString const *DownloadStageStatusKey2    = @"DownloadStageStatusKey";
NSString const *DownloadStageInfoKey2      = @"DownloadStageInfoKey";

@interface OfflineMapController (SearchCity)

/* Returns a new array consisted of MAOfflineCity object for which match the key. */
- (NSArray *)citiesFilterWithKey:(NSString *)key;

@end

@interface OfflineMapController ()<UITableViewDataSource, UITableViewDelegate, MAHeaderViewDelegate>
{
    char *_expandedSections;
    UIImage *_download;
    UIImage *_pause;
    UIImage *_delete;
}

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *cities;
@property (nonatomic, strong) NSPredicate *predicate;

@property (nonatomic, strong) NSArray *sectionTitles;
@property (nonatomic, strong) NSArray *provinces;
@property (nonatomic, strong) NSArray *municipalities;

@property (nonatomic, strong) NSMutableSet *downloadingItems;
@property (nonatomic, strong) NSMutableDictionary *downloadStages;

@property (nonatomic, assign) BOOL needReloadWhenDisappear;

@end

@implementation OfflineMapController

@synthesize mapView   = _mapView;
@synthesize tableView = _tableView;
@synthesize cities = _cities;
@synthesize predicate = _predicate;

@synthesize sectionTitles = _sectionTitles;
@synthesize provinces = _provinces;
@synthesize municipalities = _municipalities;
@synthesize downloadingItems = _downloadingItems;
@synthesize downloadStages = _downloadStages;

@synthesize needReloadWhenDisappear = _needReloadWhenDisappear;


- (void)back {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility

- (void)checkNewestVersionAction
{
    [[MAOfflineMap sharedOfflineMap] checkNewestVersion:^(BOOL hasNewestVersion) {
        
        if (!hasNewestVersion)
        {
            return;
        }
        
        /* Manipulations to your application's user interface must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self setupTitle];
            
            [self setupCities];
            
            [self.tableView reloadData];
        });
    }];
}

- (NSIndexPath *)indexPathForSender:(id)sender event:(UIEvent *)event
{
    UIButton *button = (UIButton*)sender;
    
    UITouch *touch = [[event allTouches] anyObject];
    
    if (![button pointInside:[touch locationInView:button] withEvent:event])
    {
        return nil;
    }
    
    CGPoint touchPosition = [touch locationInView:self.tableView];
    
    return [self.tableView indexPathForRowAtPoint:touchPosition];
}

- (NSString *)cellLabelTextForItem:(MAOfflineItem *)item
{
    NSString *labelText = nil;
    
    if (item.itemStatus == MAOfflineItemStatusInstalled)
    {
        labelText = [item.name stringByAppendingString:@"(已安装)"];
    }
    else if (item.itemStatus == MAOfflineItemStatusExpired)
    {
        labelText = [item.name stringByAppendingString:@"(有更新)"];
    }
    else if (item.itemStatus == MAOfflineItemStatusCached)
    {
        labelText = [item.name stringByAppendingString:@"(缓存)"];
    }
    else
    {
        labelText = item.name;
    }
    
    return labelText;
}

- (NSString *)cellDetailTextForItem:(MAOfflineItem *)item
{
    NSString *detailText = nil;
    
    if (![self.downloadingItems containsObject:item])
    {
        if (item.itemStatus == MAOfflineItemStatusCached)
        {
            detailText = [NSString stringWithFormat:@"%lld/%lld", item.downloadedSize, item.size];
        }
        else
        {
            detailText = [NSString stringWithFormat:@"大小:%0.2f M", (float)item.size/(1014*1024)];
        }
    }
    else
    {
        NSMutableDictionary *stage  = [self.downloadStages objectForKey:item.adcode];
        
        MAOfflineMapDownloadStatus status = [[stage objectForKey:DownloadStageStatusKey2] intValue];
        
        switch (status)
        {
            case MAOfflineMapDownloadStatusWaiting:
            {
                detailText = @"等待";
                
                break;
            }
            case MAOfflineMapDownloadStatusStart:
            {
                detailText = @"开始";
                
                break;
            }
            case MAOfflineMapDownloadStatusProgress:
            {
                NSDictionary *progressDict = [stage objectForKey:DownloadStageInfoKey2];
                
                long long recieved = [[progressDict objectForKey:MAOfflineMapDownloadReceivedSizeKey] longLongValue];
                long long expected = [[progressDict objectForKey:MAOfflineMapDownloadExpectedSizeKey] longLongValue];
                
                detailText = [NSString stringWithFormat:@"%lld/%lld(%.1f%%)", recieved, expected, recieved/(float)expected*100];
                break;
            }
            case MAOfflineMapDownloadStatusCompleted:
            {
                detailText = @"下载完成";
                break;
            }
            case MAOfflineMapDownloadStatusCancelled:
            {
                detailText = @"取消";
                break;
            }
            case MAOfflineMapDownloadStatusUnzip:
            {
                detailText = @"解压中";
                break;
            }
            case MAOfflineMapDownloadStatusFinished:
            {
                detailText = @"结束";
                
                break;
            }
            default:
            {
                detailText = @"错误";
                
                break;
            }
        } // end switch
        
    }
    
    return detailText;
}

- (void)updateAccessoryViewForCell:(UITableViewCell *)cell item:(MAOfflineItem *)item
{
    UIButton *delete = nil;
    UIButton *download = nil;
    UIButton *pause = nil;
    for (UIButton * but in cell.accessoryView.subviews)
    {
        switch (but.tag)
        {
            case kTagDeleteButton:
                delete = but;
                break;
            case kTagPauseButton:
                pause = but;
                break;
            case kTagDownloadButton:
                download = but;
                break;
                
            default:
                break;
        }
    }
    
    CGPoint right = CGPointMake(kButtonSize * (kButtonCount - 0.5), kButtonSize * 0.5);
    CGFloat leftMove = -kButtonSize;
    CGPoint center = right;
    if (item.itemStatus == MAOfflineItemStatusInstalled || item.itemStatus ==MAOfflineItemStatusCached)
    {
        delete.hidden = NO;
        delete.center = center;
        center.x += leftMove;
    }
    else
    {
        delete.hidden = YES;
        delete.center = right;
    }
    
    if ([[MAOfflineMap sharedOfflineMap] isDownloadingForItem:item])
    {
        pause.hidden = NO;
        pause.center = center;
        center.x += leftMove;
        
        download.hidden = YES;
        download.center = right;
    }
    else
    {
        pause.hidden = YES;
        pause.center = right;
        
        if (item.itemStatus != MAOfflineItemStatusInstalled)
        {
            download.hidden = NO;
            download.center = center;
        }
        else
        {
            download.hidden = YES;
            download.center = right;
        }
    }
    
}

- (void)updateUIForItem:(MAOfflineItem *)item atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (cell != nil)
    {
        [self updateCell:cell forItem:item];
    }
    
    if ([item isKindOfClass:[MAOfflineItemCommonCity class]])
    {
        UITableViewCell * provinceCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:indexPath.section]];
        if (provinceCell != nil)
        {
            [self updateCell:provinceCell forItem:((MAOfflineItemCommonCity *)item).province];
        }
        return;
    }
    
    if ([item isKindOfClass:[MAOfflineProvince class]])
    {
        MAOfflineProvince * province = (MAOfflineProvince *)item;
        [province.cities enumerateObjectsUsingBlock:^(MAOfflineItemCommonCity * obj, NSUInteger idx, BOOL *  stop) {
            UITableViewCell * cityCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:idx+1 inSection:indexPath.section]];
            [self updateCell:cityCell forItem:obj];
        }];
        return;
    }
}

- (void)updateCell:(UITableViewCell *)cell forItem:(MAOfflineItem *)item
{
    [self updateAccessoryViewForCell:cell item:item];
    
    cell.textLabel.text = [self cellLabelTextForItem:item];
    
    cell.detailTextLabel.text = [self cellDetailTextForItem:item];
}

- (void)download:(MAOfflineItem *)item atIndexPath:(NSIndexPath *)indexPath
{
    if (item == nil || item.itemStatus == MAOfflineItemStatusInstalled)
    {
        return;
    }
    
    NSLog(@"download :%@", item.name);
    
    [[MAOfflineMap sharedOfflineMap] downloadItem:item shouldContinueWhenAppEntersBackground:YES downloadBlock:^(MAOfflineItem * downloadItem, MAOfflineMapDownloadStatus downloadStatus, id info) {
        
        if (![self.downloadingItems containsObject:downloadItem])
        {
            [self.downloadingItems addObject:downloadItem];
            [self.downloadStages setObject:[NSMutableDictionary dictionary] forKey:downloadItem.adcode];
        }
        
        /* Manipulations to your application’s user interface must occur on the main thread. */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableDictionary *stage  = [self.downloadStages objectForKey:downloadItem.adcode];
            
            if (downloadStatus == MAOfflineMapDownloadStatusWaiting)
            {
                [stage setObject:[NSNumber numberWithBool:YES] forKey:DownloadStageIsRunningKey2];
            }
            else if(downloadStatus == MAOfflineMapDownloadStatusProgress)
            {
                [stage setObject:info forKey:DownloadStageInfoKey2];
            }
            else if(downloadStatus == MAOfflineMapDownloadStatusCancelled
                    || downloadStatus == MAOfflineMapDownloadStatusError
                    || downloadStatus == MAOfflineMapDownloadStatusFinished)
            {
                [stage setObject:[NSNumber numberWithBool:NO] forKey:DownloadStageIsRunningKey2];
                
                // clear
                [self.downloadingItems removeObject:downloadItem];
                [self.downloadStages removeObjectForKey:downloadItem.adcode];
            }
            
            [stage setObject:[NSNumber numberWithInt:downloadStatus] forKey:DownloadStageStatusKey2];
            
            /* Update UI. */
            //更新触发下载操作的item涉及到的UI
            [self updateUIForItem:item atIndexPath:indexPath];
            
            if (downloadStatus == MAOfflineMapDownloadStatusFinished)
            {
                self.needReloadWhenDisappear = YES;
            }
        });
    }];
}

- (void)pause:(MAOfflineItem *)item
{
    NSLog(@"pause :%@", item.name);
    
    [[MAOfflineMap sharedOfflineMap] pauseItem:item];
}

- (void)delete:(MAOfflineItem *)item
{
    NSLog(@"delete :%@", item.name);
    
    [[MAOfflineMap sharedOfflineMap] deleteItem:item];
}

- (MAOfflineItem *)itemForIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath == nil)
    {
        return nil;
    }
    
    MAOfflineItem *item = nil;
    
    switch (indexPath.section)
    {
        case 0:
        {
            item = [MAOfflineMap sharedOfflineMap].nationWide;
            break;
        }
        case 1:
        {
            item = self.municipalities[indexPath.row];
            break;
        }
        case 2:
        {
            item = nil;
            break;
        }
        default:
        {
            MAOfflineProvince *pro = self.provinces[indexPath.section - self.sectionTitles.count];
            
            if (indexPath.row == 0)
            {
                item = pro; // 添加整个省
            }
            else
            {
                item = pro.cities[indexPath.row - 1]; // 添加市
            }
            
            break;
        }
    }
    
    return item;
}

- (UIButton *)buttonWithImage:(UIImage *)image tag:(NSUInteger)tag
{
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kButtonSize, kButtonSize)];
    [button setImage:image forState:UIControlStateNormal];
    button.tag = tag;
    button.center = CGPointMake((kButtonCount - tag + 0.5) * kButtonSize, kButtonSize * 0.5);
    
    [button addTarget:self action:@selector(checkButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)accessoryView
{
    UIView * accessory = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kButtonSize * kButtonCount, kButtonSize)];
    UIButton * downloadButton = [self buttonWithImage:[self downloadImage] tag:kTagDownloadButton];
    UIButton * pauseButton = [self buttonWithImage:[self pauseImage] tag:kTagPauseButton];
    UIButton * deleteButton = [self buttonWithImage:[self deleteImage] tag:kTagDeleteButton];
    
    [accessory addSubview:downloadButton];
    [accessory addSubview:pauseButton];
    [accessory addSubview:deleteButton];
    
    return accessory;
}



#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section < self.sectionTitles.count ? kSectionHeaderHeight : kTableCellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sectionTitles.count + self.provinces.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    
    switch (section)
    {
        case 0:
        {
            number = 1;
            break;
        }
        case 1:
        {
            number = self.municipalities.count;
            break;
        }
        default:
        {
            if (_expandedSections[section])
            {
                MAOfflineProvince *pro = self.provinces[section - self.sectionTitles.count];
                
                // 加1用以下载整个省份的数据
                number = pro.cities.count + 1;
            }
            break;
        }
    }
    
    return number;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *theTitle = nil;
    
    if (section < self.sectionTitles.count)
    {
        theTitle = self.sectionTitles[section];
        
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kSectionHeaderHeight)];
        headerView.backgroundColor = [UIColor lightGrayColor];
        
        UILabel *lb = [[UILabel alloc] initWithFrame:CGRectMake(kSectionHeaderMargin, 0, CGRectGetWidth(headerView.bounds), CGRectGetHeight(headerView.bounds))];
        lb.backgroundColor = [UIColor clearColor];
        lb.text = theTitle;
        lb.textColor = [UIColor whiteColor];
        
        [headerView addSubview:lb];
        
        return headerView;
    }
    else
    {
        MAOfflineProvince *pro = self.provinces[section - self.sectionTitles.count];
        theTitle = pro.name;
        
        MAHeaderView *headerView = [[MAHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), kTableCellHeight) expanded:_expandedSections[section]];
        
        headerView.section = section;
        headerView.text = theTitle;
        headerView.delegate = self;
        
        return headerView;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cityCellIdentifier = @"cityCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cityCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cityCellIdentifier];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.accessoryView = [self accessoryView];
    }
    
    MAOfflineItem *item = [self itemForIndexPath:indexPath];
    [self updateCell:cell forItem:item];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < self.sectionTitles.count)
    {
        cell.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}

#pragma mark - ImageResource
- (UIImage *)downloadImage
{
    if (_download == nil)
    {
        _download = [UIImage imageNamed:@"download"];
    }
    return _download;
}

- (UIImage *)pauseImage
{
    if (_pause == nil)
    {
        _pause = [UIImage imageNamed:@"pause"];
    }
    return _pause;
}

- (UIImage *)deleteImage
{
    if (_delete == nil)
    {
        _delete = [UIImage imageNamed:@"delete"];
    }
    return _delete;
}

#pragma mark - MAHeaderViewDelegate

- (void)headerView:(MAHeaderView *)headerView section:(NSInteger)section expanded:(BOOL)expanded
{
    _expandedSections[section] = expanded;
    
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark - Handle Action

- (void)checkButtonTapped:(id)sender event:(id)event
{
    NSIndexPath *indexPath = [self indexPathForSender:sender event:event];
    
    MAOfflineItem *item = [self itemForIndexPath:indexPath];
    
    if (item == nil)
    {
        return;
    }
    
    UIButton * button = sender;
    switch (button.tag)
    {
        case kTagDeleteButton:
            [self delete:item];
            
            [self updateUIForItem:item atIndexPath:indexPath];
            
            break;
        case kTagPauseButton:
            [self pause:item];
            
            break;
        case kTagDownloadButton:
            [self download:item atIndexPath:indexPath];
            break;
            
            
        default:
            break;
    }
}

- (void)backAction
{
    [self cancelAllAction];
    
    //    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancelAllAction
{
    [[MAOfflineMap sharedOfflineMap] cancelAll];
}

- (void)searchAction
{
    /* 搜索关键字支持 {城市中文名称, 拼音(不区分大小写), 拼音简写, cityCode, adCode}五种类型. */
    NSString *key = kDefaultSearchkey;
    
    NSArray *result = [self citiesFilterWithKey:key];
    
    NSLog(@"key = %@, result count = %d", key, (int)result.count);
    [result enumerateObjectsUsingBlock:^(MAOfflineCity *obj, NSUInteger idx, BOOL *stop) {
        NSLog(@"idx = %d, cityName = %@, cityCode = %@, adCode = %@, pinyin = %@, jianpin = %@, size = %lld", (int)idx, obj.name, obj.cityCode,obj.adcode, obj.pinyin, obj.jianpin, obj.size);
    }];
}

#pragma mark - Initialization

- (void)initNavigationBar
{
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(backAction)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全部"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(cancelAllAction)];
}

/*
- (void)initToolBar
{
    UIBarButtonItem *flexbleItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                 target:self
                                                                                 action:nil];
    
    UILabel *prompts = [[UILabel alloc] init];
    prompts.text            = [NSString stringWithFormat:@"默认关键字是\"%@\", 结果在console打印", kDefaultSearchkey];
    //    prompts.textAlignment   = UITextAlignmentCenter;
    prompts.textAlignment =  NSTextAlignmentCenter;
    prompts.backgroundColor = [UIColor clearColor];
    prompts.textColor       = [UIColor whiteColor];
    prompts.font            = [UIFont systemFontOfSize:15];
    [prompts sizeToFit];
    
    UIBarButtonItem *promptsItem = [[UIBarButtonItem alloc] initWithCustomView:prompts];
    
    UIBarButtonItem *searchItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                                                target:self
                                                                                action:@selector(searchAction)];
    
    self.toolbarItems = [NSArray arrayWithObjects:flexbleItem, promptsItem, flexbleItem, searchItem,flexbleItem, nil];
}
 */

- (void)initTableView
{
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.tableView.delegate   = self;
    self.tableView.dataSource = self;
    
    [self.view addSubview:self.tableView];
}

- (void)setupCities
{
    self.sectionTitles = @[@"全国", @"直辖市", @"省份"];
    
    self.cities = [MAOfflineMap sharedOfflineMap].cities;
    self.provinces = [MAOfflineMap sharedOfflineMap].provinces;
    self.municipalities = [MAOfflineMap sharedOfflineMap].municipalities;
    
    self.downloadingItems = [NSMutableSet set];
    self.downloadStages = [NSMutableDictionary dictionary];
    
    
    if (_expandedSections != NULL)
    {
        free(_expandedSections);
        _expandedSections = NULL;
    }
    
    _expandedSections = (char *)malloc((self.sectionTitles.count + self.provinces.count) * sizeof(char));
    memset(_expandedSections, 0, (self.sectionTitles.count + self.provinces.count) * sizeof(char));
    
}

- (void)setupTitle
{
    self.navigationItem.title = [MAOfflineMap sharedOfflineMap].version;
}

- (void)setupPredicate
{
    self.predicate = [NSPredicate predicateWithFormat:@"name CONTAINS[cd] $KEY OR cityCode CONTAINS[cd] $KEY OR jianpin CONTAINS[cd] $KEY OR pinyin CONTAINS[cd] $KEY OR adcode CONTAINS[cd] $KEY"];
}

#pragma mark - Life Cycle

- (id)init
{
    self = [super init];
    if (self)
    {
        [self setupCities];
        
        [self setupPredicate];
        
        [self setupTitle];
        
        [self checkNewestVersionAction];
    }
    
    return self;
}

- (void)dealloc
{
    free(_expandedSections);
    _expandedSections = NULL;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigationBar];
    
    [self initTableView];
    
//    [self initToolBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.barStyle    = UIBarStyleBlack;
    self.navigationController.navigationBar.translucent = NO;
    
//    self.navigationController.toolbar.barStyle      = UIBarStyleBlack;
//    self.navigationController.toolbar.translucent   = NO;
//    [self.navigationController setToolbarHidden:NO animated:animated];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:@"完成" forState:UIControlStateNormal];
    button.size = CGSizeMake(70, 30);
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.needReloadWhenDisappear)
    {
        [self.mapView reloadMap];
        
        self.needReloadWhenDisappear = NO;
    }
}

@end

@implementation OfflineMapController (SearchCity)

/* Returns a new array consisted of MAOfflineCity object for which match the key. */
- (NSArray *)citiesFilterWithKey:(NSString *)key
{
    if (key.length == 0)
    {
        return nil;
    }
    
    NSPredicate *keyPredicate = [self.predicate predicateWithSubstitutionVariables:[NSDictionary dictionaryWithObject:key forKey:@"KEY"]];
    
    return [self.cities filteredArrayUsingPredicate:keyPredicate];
}

@end

