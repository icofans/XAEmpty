//
//  UITableView+Empty.m
//  XQEmptyTool
//
//  Created by 王家强 on 17/7/23.
//  Copyright © 2017年 Qiang. All rights reserved.
//

#import "UITableView+Empty.h"
#import <objc/runtime.h>

static char ShowErrorViewKey;
static char ShowLoadViewKey;
static char RefreshBlockKey;

static char WXErrorImageKey;
static char WXErrorDescKey;
static char WXEmptyImageKey;
static char WXEmptyDescKey;


@implementation UITableView (Empty)


- (void)setErrorImage:(UIImage *)errorImage
{
    
    objc_setAssociatedObject(self, &WXErrorImageKey, errorImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)errorImage
{
    if (objc_getAssociatedObject(self, &WXErrorImageKey)) {
        return objc_getAssociatedObject(self, &WXErrorImageKey);
    } else if ([UITableView appearance].errorImage) {
        return [UITableView appearance].errorImage;
    } else {
        return nil;
    }
}

- (void)setErrorDesc:(NSString *)errorDesc
{
    objc_setAssociatedObject(self, &WXErrorDescKey, errorDesc, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)errorDesc
{
    if (objc_getAssociatedObject(self, &WXErrorDescKey)) {
        return objc_getAssociatedObject(self, &WXErrorDescKey);
    } else if ([UITableView appearance].errorDesc) {
        return [UITableView appearance].errorDesc;
    } else {
        return @"轻触屏幕重新加载";
    }
}


- (void)setEmptyImage:(UIImage *)emptyImage
{
    
    objc_setAssociatedObject(self, &WXEmptyImageKey, emptyImage, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)emptyImage
{
    if (objc_getAssociatedObject(self, &WXEmptyImageKey)) {
        return objc_getAssociatedObject(self, &WXEmptyImageKey);
    } else if ([UITableView appearance].emptyImage) {
        return [UITableView appearance].emptyImage;
    } else {
        return nil;
    }
}

- (void)setEmptyDesc:(NSString *)emptyDesc {
    objc_setAssociatedObject(self, &WXEmptyDescKey, emptyDesc, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)emptyDesc {
    if (objc_getAssociatedObject(self, &WXEmptyDescKey)) {
        return objc_getAssociatedObject(self, &WXEmptyDescKey);
    } else if ([UITableView appearance].emptyDesc) {
        return [UITableView appearance].emptyDesc;
    } else {
        return nil;
    }
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
    BOOL showError = [objc_getAssociatedObject(self, &ShowErrorViewKey) boolValue];
    if (showError) {
        // 当前是错误视图
    } else if (self.emptyDesc) {
        NSInteger numberOfRows = [self numberOfRows];
        // 显示空白视图
        if (numberOfRows > 0) {
            // 有数据 移除
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
                UIView *customView = [self viewWithImage:self.emptyImage title:self.emptyDesc];
                self.backgroundView = customView;
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
        self.backgroundView = nil;
        return;
    }
    if (block) {
        objc_setAssociatedObject(self, &RefreshBlockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    objc_setAssociatedObject(self, &ShowErrorViewKey, @(YES), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    UIView *bgView = [self viewWithImage:self.errorImage title:self.errorDesc];
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

- (UIView *)viewWithImage:(UIImage *)image title:(NSString *)title
{
    UIView *bgView = [[UIView alloc] init];
    bgView.frame = self.bounds;
    
    UIImageView *imageView;
    if (image) {
        imageView = [[UIImageView alloc] init];
        imageView.image = image;
        [bgView addSubview:imageView];
        imageView.frame = CGRectMake((self.frame.size.width-80)/2, self.frame.size.height/2-80, 80, 80);
    }
    
    UILabel *freshLabel = [[UILabel alloc] init];
    freshLabel.text = title;
    freshLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    freshLabel.textAlignment = NSTextAlignmentCenter;
    freshLabel.textColor = [UIColor lightGrayColor];
    [bgView addSubview:freshLabel];
    
    CGFloat maxY = imageView? (CGRectGetMaxY(imageView.frame) + 8) : self.frame.size.height/2-10;
    freshLabel.frame = CGRectMake(0, maxY, self.frame.size.width, 20);
    
    return bgView;
}

@end
