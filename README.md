# XQEmptyTool
优雅的控制tableView显示无数据和错误视图

###说明:
利用运行时来显示和隐藏空白视图

###要点：
1.利用运行时Swizzling对reloadData进行方法交换，然后在reloadData调用时获取DataSource的数据来判断是否有数据要显示。如果没有就显示无数据空视图。
2.tableView设置DataSource的委托人会走一次reloadData，这个时候数据是空的，我们可以利用这个先显示一个加载视图。
3.这里无数据只是简单的显示一个label，如果想定制请自己动手
4.访问出错视图只在无数据的状态显示


###使用方法：

在tableView初始化的时候，设置空白视图

    // 设置tableView无数据显示
    _tableView.showEmptyView = YES;
    _tableView.emptyDesc = @"啊哈。。我是白的";

在访问数据出错的时候

	[self.tableView errorWithRefreshBlock:^{
        NSLog(@"-----我要刷新");
        [self.tableView reloadData];
    }];
