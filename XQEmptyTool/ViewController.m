//
//  ViewController.m
//  XQEmptyTool
//
//  Created by 王家强 on 17/7/23.
//  Copyright © 2017年 Qiang. All rights reserved.
//

#import "ViewController.h"
#import "UITableView+Empty.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;


@property(nonatomic,assign) BOOL showData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self.view addSubview:self.tableView];
    
    self.showData = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.showData = YES;
        [self.tableView reloadData];
    });
    

    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"有数据" style:UIBarButtonItemStylePlain target:self action:@selector(hasData)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"无数据" style:UIBarButtonItemStylePlain target:self action:@selector(noData)];
    
    UIButton *errorBtn = [[UIButton alloc] init];
    [errorBtn setTitle:@"出错啦" forState:UIControlStateNormal];
    [errorBtn setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
    [errorBtn setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.4] forState:UIControlStateHighlighted];
    [errorBtn addTarget:self action:@selector(showError) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = errorBtn;
}

- (void)hasData
{
    self.showData = YES;
    [self.tableView reloadData];
}

- (void)noData
{
    self.showData = NO;
    [self.tableView reloadData];
}

- (void)showError
{
    [self.tableView errorWithRefreshBlock:^{
        NSLog(@"-----我要刷新");
        [self.tableView reloadData];
    }];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.showData?10:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = @"册书";
    return cell;
}



- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
        _tableView.tableFooterView = [UIView new];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        // 设置tableView无数据显示
//        _tableView.emptyDesc = @"啊哈。。我是白的";
        _tableView.errorDesc = @"我就是试试优先级";
    }
    return _tableView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
