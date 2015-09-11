//
//  ViewController.m
//  KSRefresh
//
//  Created by bing.hao on 15/4/4.
//  Copyright (c) 2015年 bing.hao. All rights reserved.
//

#import "ViewController.h"
#import "UIScrollView+KS.h"

@interface ViewController ()
<
    UITableViewDataSource,
    UITableViewDelegate,
    KSRefreshViewDelegate
>

@property (nonatomic, strong) NSMutableArray * dataSource;
@property (nonatomic, strong) UITableView    * tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.title = @"上拉刷新与下拉刷新";
    
    self.navigationController.navigationBar.barStyle    = UIBarStyleDefault;
    self.navigationController.navigationBar.opaque      = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.dataSource               = [NSMutableArray new];
    self.tableView                = [UITableView new];
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    self.tableView.frame          = CGRectMake(0, 0, KS_SCREEN_WIDTH, KS_SCREEN_HEIGHT);
    
    //默认提供三种刷新方式
    //KSDefaultHeadRefreshView 下拉刷新
    //KSDefaultFootRefreshView 上拉刷新
    //KSAutoFootRefreshView 底部自动刷新
    //如果觉得这三种刷新视图不够用可以继承KSHeadRefreshView或KSFootRefreshView自行实现刷新试图
    
    self.tableView.header         = [[KSDefaultHeadRefreshView alloc] initWithDelegate:self];
//    self.tableView.footer         = [[KSDefaultFootRefreshView alloc] initWithDelegate:self];
    self.tableView.footer         = [[KSAutoFootRefreshView alloc] initWithDelegate:self];
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];
    //首次加载数据
    [self.tableView.header setState:KSRefreshViewStateLoading];
}

- (void)addData
{
    for (int i = 0; i < 15; i++) {
        [self.dataSource addObject:[NSString stringWithFormat:@"测试数据%@", @(self.dataSource.count + 1)]];
    }
    
    [self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)refreshViewDidLoading:(id)view
{
    if ([view isEqual:self.tableView.header]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [self.dataSource removeAllObjects];
            [self addData];
            
            if (self.tableView.footer) {
                //如果没有可加载的数据,需要将footer的isLastPage属性设置为YES,这样就不会出发底部刷新了
                if (self.dataSource.count >= 30) {
                    self.tableView.footer.isLastPage = YES;
                } else {
                    self.tableView.footer.isLastPage = NO;
                }
            }
            [self.tableView headerFinishedLoading];
            [self.tableView reloadData];
        });
        
        return;
    }
    
    if ([view isEqual:self.tableView.footer]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.dataSource.count >= 30) {
                //如果没有可加载的数据,需要将footer的isLastPage属性设置为YES,这样就不会出发底部刷新了
                [self.tableView.footer setIsLastPage:YES];
                [self.tableView reloadData];
            } else {
                [self addData];
                [self.tableView footerFinishedLoading];
                [self.tableView reloadData];
            }
        });
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 54.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * identifier = @"Cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    cell.textLabel.text = [self.dataSource objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.1f;
}

@end
