//
//  ViewController.m
//  TestScrollBanner
//
//  Created by 柴勇峰 on 15/7/14.
//  Copyright (c) 2015年 Brave. All rights reserved.
//

#import "ViewController.h"
#import "YFBannerView.h"

#define kBannerHeight 175.0/568*Screen_height
#define Screen_Width [UIScreen mainScreen].bounds.size.width
#define Screen_height [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>{
    
    UITableView *_tableview;
    
    YFBannerView *_bannerView;
    
    NSArray *_bannerArray;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    _tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableview.delegate = self;
    _tableview.dataSource = self;
    [self.view addSubview:_tableview];
    
    NSDictionary *dic1 = @{@"pic":@"http://pubimg.xingren.com/7430fe96-1fbf-4aec-88ad-c71b77605cb7", @"url":@"chaiyongfeng.com"};
    NSDictionary *dic2 = @{@"pic":@"http://pubimg.xingren.com/e9f5d1a8-d65c-40c1-a702-4337f48ccf06", @"url":@"chaiyongfeng.com"};
    NSDictionary *dic3 = @{@"pic":@"http://pubimg.xingren.com/a3115056-0a07-46b5-8b1d-cc808cacb2ea", @"url":@"chaiyongfeng.com"};
    
    _bannerArray = @[dic1, dic2, dic3];
    
//    http://pubimg.xingren.com/e91b497d-d098-4184-9aab-80697185b5e5
//    http://pubimg.xingren.com/d63ebd7a-b294-4cbf-8039-9a52e6c17b85
    
    _bannerView = [[YFBannerView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, kBannerHeight)];
    
    _bannerView.isLoop = YES;
    
    _bannerView.springAttachScrollView = _tableview;
    
    _bannerView.springWithScroll = YES;
    
    _bannerView.itemArray = ({
        
        NSMutableArray *array = [NSMutableArray array];
        
        for (NSDictionary *dic in _bannerArray) {
            
            YFBannerItem *item = [[YFBannerItem alloc] init];
            
            item.imageUrlString = dic[@"pic"];
            
            item.urlString = dic[@"url"];
            
            item.itemTarget = self;
            
            item.itemSelector = @selector(tappedBannerItem:);
            
            [array addObject:item];
        }
        
        array;
    });
    
    [self.view addSubview:_bannerView];
    
    _tableview.contentInset = UIEdgeInsetsMake(175, 0, 0, 0);

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [_bannerView startAutoScroll];
}

- (void)tappedBannerItem:(NSString *)urlString {
    
    NSLog(@"%@", urlString);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *str = @"bannerCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:str];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:str];
    }
    return cell;
}

@end
