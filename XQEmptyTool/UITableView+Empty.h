//
//  UITableView+Empty.h
//  XQEmptyTool
//
//  Created by 王家强 on 17/7/23.
//  Copyright © 2017年 Qiang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (Empty)

/**
 无数据视图。
 1. 通过运行时交换reloadData而检测是否有数据源，默认不显示，如果需要全局使用，导入头文件，在Appdelegate中设置
 [UITableView appearance].emptyDesc = @"xxxxxxx";
 2. 建议通过单个VC根据场景设置。无视图是否显示是根据是否设置emptyDesc。
 3. 可设置占位图样式，同上在appdelegate中设置，本类不提供图片。
 4. VC设置的属性优先级高于全局
**/


/**
 无数据描述 [当不设置文字，默认不显示] - 需单独设置
 */
@property(nonatomic,copy) NSString *emptyDesc;

/**
 空白提示图片
 */
@property(nonatomic,strong) UIImage *emptyImage;


/**
  出错视图。
  1.需要手动调用和设置刷新的回调。默认只显示文字
  2.建议全局设置样式
  3. VC设置的属性优先级高于全局
**/

/**
 错误描述 - 默认为"轻触屏幕重新加载"
 */
@property(nonatomic,copy) NSString *errorDesc;

/**
 错误图片
 */
@property(nonatomic,strong) UIImage *errorImage;

/**
 出错视图点击回调

 @param block block
 */
- (void)errorWithRefreshBlock:(void(^)(void))block;

@end
