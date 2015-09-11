# KSRefresh

这是一个下拉刷新、上拉刷新以及底部自动刷新组件,使用方便简单。

初始化刷新组件

    self.tableView                = [UITableView new];
    self.tableView.delegate       = self;
    self.tableView.dataSource     = self;
    self.tableView.frame          = CGRectMake(0, 0, KS_SCREEN_WIDTH, KS_SCREEN_HEIGHT);
    self.tableView.header         = [[KSDefaultHeadRefreshView alloc] initWithDelegate:self]; //下拉刷新
    self.tableView.footer         = [[KSDefaultFootRefreshView alloc] initWithDelegate:self]; //上拉刷新
    
    
    
    
触发刷新状态回调方法
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

pod 'KSRefresh', '~> 0.3'
