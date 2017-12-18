//
//  UITableView+Empty.m
//  XQEmptyTool
//
//  Created by 王家强 on 17/7/23.
//  Copyright © 2017年 Qiang. All rights reserved.
//

#import "UITableView+Empty.h"
#import <objc/runtime.h>

static char EmptyDescKey;
static char ShowEmptyViewKey;
static char ShowErrorViewKey;
static char ShowLoadViewKey;
static char RefreshBlockKey;

@implementation UITableView (Empty)

- (void)setShowEmptyView:(BOOL)showEmptyView
{
    objc_setAssociatedObject(self, &ShowEmptyViewKey, @(showEmptyView), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)showEmptyView
{
    return objc_getAssociatedObject(self, &ShowEmptyViewKey);
}

- (void)setEmptyDesc:(NSString *)emptyDesc {
    objc_setAssociatedObject(self, &EmptyDescKey, emptyDesc, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)emptyDesc {
    return objc_getAssociatedObject(self, &EmptyDescKey);
}

+ (void)load
{
    // class_getInstanceMethod()
    Method fromMethod = class_getInstanceMethod([self class], @selector(reloadData));
    Method toMethod = class_getInstanceMethod([self class], @selector(tt_reloadData));
    
    // class_addMethod()
    if (!class_addMethod([self class], @selector(reloadData), method_getImplementation(toMethod), method_getTypeEncoding(toMethod))) {
        method_exchangeImplementations(fromMethod, toMethod);
    }
}

- (void)tt_reloadData
{
    BOOL showError = objc_getAssociatedObject(self, &ShowErrorViewKey);
    
    if (showError) {
        // 当前是错误视图
    } else if (self.showEmptyView) {
        NSInteger numberOfRows = [self numberOfRows];
        // 显示空白视图
        if (numberOfRows > 0) {
            // 有数据
            self.backgroundView = nil;
        } else {
            self.backgroundView = nil;
            
            BOOL showLoad = objc_getAssociatedObject(self, &ShowLoadViewKey);
            if (!showLoad) {
                // 显示加载视图
                UIView *bgView = [[UIView alloc] init];
                bgView.frame = self.bounds;
                
                UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                indicatorView.hidesWhenStopped = YES;
                [bgView addSubview:indicatorView];
                
                UILabel *freshLabel = [[UILabel alloc] init];
                freshLabel.text = @"加载中...";
                freshLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                freshLabel.textAlignment = NSTextAlignmentCenter;
                freshLabel.textColor = [UIColor lightGrayColor];
                [bgView addSubview:freshLabel];
                
                
                indicatorView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2-40);
                freshLabel.frame = CGRectMake(0, CGRectGetMaxY(indicatorView.frame)+10, self.frame.size.width, 20);
                indicatorView.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
                [indicatorView startAnimating];
                self.backgroundView = bgView;
            } else {
                // 无数据
                UILabel *hitLabel = [[UILabel alloc] init];
                hitLabel.text = self.emptyDesc?:@"无数据";
                hitLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
                hitLabel.textAlignment = NSTextAlignmentCenter;
                hitLabel.textColor = [UIColor lightGrayColor];
                self.backgroundView = hitLabel;
            }
            objc_setAssociatedObject(self, &ShowLoadViewKey, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
        }
    }
    [self tt_reloadData];
}

- (NSInteger)numberOfRows
{
    NSInteger sections = 0; // 此处一定要给初始值
    if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
        sections = [self.dataSource numberOfSectionsInTableView:self];
    } else {
        sections = self.numberOfSections;
    }
    if ([self.dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)]) {
        // 获取有多少个数据
        NSInteger numberOfRows = 0; // 此处一定要给初始值
        for (int i = 0; i<sections; i++) {
            NSInteger rows = [self.dataSource tableView:self numberOfRowsInSection:i];
            numberOfRows += rows;
        }
        return numberOfRows;
    } else {
        return 0;
    }
}

- (void)errorWithRefreshBlock:(void (^)(void))block
{
    NSInteger numberOfRows = [self numberOfRows];
    // 如果当期有数据。不显示错误视图
    if (numberOfRows > 0) {
        return;
    }
    if (block) {
        objc_setAssociatedObject(self, &RefreshBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    objc_setAssociatedObject(self, &ShowErrorViewKey, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = self.bounds;
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:ERROR_IMAGE];
    [bgView addSubview:imageView];
    
    UILabel *freshLabel = [[UILabel alloc] init];
    freshLabel.text = @"轻触屏幕重新加载";
    freshLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    freshLabel.textAlignment = NSTextAlignmentCenter;
    freshLabel.textColor = [UIColor lightGrayColor];
    [bgView addSubview:freshLabel];
    
    imageView.frame = CGRectMake((self.frame.size.width-80)/2, self.frame.size.height/2-80, 80, 80);
    freshLabel.frame = CGRectMake(0, self.frame.size.height/2+10, self.frame.size.width, 20);
    
    self.backgroundView = bgView;
    
    // 添加点击事件
    UITapGestureRecognizer *tapG = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRefresh)];
    [bgView addGestureRecognizer:tapG];
}

- (void)clickRefresh
{
    void(^block)(void) = objc_getAssociatedObject(self, &RefreshBlockKey);
    objc_setAssociatedObject(self, &ShowErrorViewKey, nil, OBJC_ASSOCIATION_COPY_NONATOMIC);
    block();
}



@end
