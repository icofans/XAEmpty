//
//  UITableView+Empty.h
//  XQEmptyTool
//
//  Created by 王家强 on 17/7/23.
//  Copyright © 2017年 Qiang. All rights reserved.
//

#import <UIKit/UIKit.h>

// 图片名称
#define ERROR_IMAGE  @"ic_page_reload"

@interface UITableView (Empty)

/**-------无数据视图-------**/

// 是否显示无数据视图
@property(nonatomic,assign) BOOL showEmptyView;

// 无数据描述
@property(nonatomic,copy) NSString *emptyDesc;

/**-------出错视图-------**/
- (void)errorWithRefreshBlock:(void(^)(void))block;

@end
