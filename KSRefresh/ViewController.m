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
//    
    self.navigationController.navigationBar.barStyle    = UIBarStyleDefault;
    self.navigationController.navigationBar.opaque      = YES;
    self.navigationController.navigationBar.translucent = NO;
    
    self.dataSource               = [NSMutableArray new];
    self.tableView                = [UITableView new];
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    self.tableView.frame          = CGRectMake(0, 0, KS_SCREEN_WIDTH, KS_SCREEN_HEIGHT);
    self.tableView.header         = [[KSDefaultHeadRefreshView alloc] initWithDelegate:self]; //下拉刷新
    self.tableView.footer         = [[KSDefaultFootRefreshView alloc] initWithDelegate:self]; //上拉刷新
//    self.tableView.footer         = [[KSAutoFootRefreshView alloc] initWithDelegate:self]; //尾部自动刷新
    
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.tableView];
//    [self addData];
    [self.tableView.header setState:RefreshViewStateLoading];
}

- (void)addData
{
    for (int i = 0; i < 15; i++) {
        [self.dataSource addObject:@(i + 1)];
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
                if (self.dataSource.count >= 30) {
                    self.tableView.footer.isLastPage = YES;
                } else {
                    self.tableView.footer.isLastPage = NO;
                }
            }
            
            [self.tableView reloadData];
            [self.tableView.header setState:RefreshViewStateDefault];
            [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        });
        
        return;
    }
    
    if ([view isEqual:self.tableView.footer]) {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (self.dataSource.count >= 30) {
                
                [self.tableView.footer setIsLastPage:YES];
                [self.tableView reloadData];
            } else {
                [self addData];
                [self.tableView.footer setState:RefreshViewStateDefault];
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
    
    cell.textLabel.text = [[self.dataSource objectAtIndex:indexPath.row] stringValue];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

@end
