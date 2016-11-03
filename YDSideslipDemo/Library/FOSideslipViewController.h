//
//  FOSideslipViewController.h
//  YDSideslipDemo
//
//  Created by 罗义德 on 15/6/19.
//  Copyright (c) 2015年 lyd. All rights reserved.
//

#import <UIKit/UIKit.h>

#define FOSystemVersionGreaterOrEqualThan(version) ([[[UIDevice currentDevice] systemVersion] floatValue] >= version)

typedef enum {
    /** 左边 */
    FORevealSideDirectionLeft = 1,
    /** 右边 */
    FORevealSideDirectionRight,
    /** 中间 */
    FORevealSideDirectionCenter,
    
}FORevealSideDirection;

@interface FOSideslipViewController : UIViewController

//中间控制器
@property(nonatomic, strong)UIViewController *centerViewController;

//左边控制器
@property(nonatomic, strong)UIViewController *leftViewController;

//右边控制器
@property(nonatomic, strong)UIViewController *rightViewController;

/**
 左滑偏移量 --- 中间视图离屏幕左边框的距离
 */
@property(nonatomic, assign)CGFloat leftOffset;

/**
 右滑偏移量 --- 中间视图离屏幕右边框的距离
 */
@property(nonatomic, assign)CGFloat rightOffset;

/**
 是否开启手动侧滑 --- 默认开启
 */
@property(nonatomic, assign)BOOL isHandSlide;

/**
 是否允许手动侧滑直接从左边滑到右边或者右边滑到左边 --- 默认不允许
 */
@property(nonatomic, assign)BOOL isLeftToRight;

/**
 滑动之后是否显示阴影 --- 默认显示
 */
@property(nonatomic, assign)BOOL isShowShadow;

/**
 是否开启滑动时中间视图缩放 --- 默认开启
 */
@property(nonatomic, assign)BOOL isCenterScaleGradient;

/**
 是否开启滑动时左右分栏透明度渐变 --- 默认开启
 */
@property(nonatomic, assign)BOOL isVagueGradient;

//抽屉切换时动画的时间
@property(nonatomic, assign)NSTimeInterval animationDuration;

//中间视图缩放的倍数

//当前动画完成后抽屉所显示的方向
@property(nonatomic, readonly, assign)FORevealSideDirection sideDirection;

//当前动画过程中抽屉的方向
@property(nonatomic, readonly, assign)FORevealSideDirection currentDirection;

/**
 初始化方法
 */
- (instancetype)initWithCenterViewController:(UIViewController *)viewController;

/**
 显示中间控制器
 */
- (void)revealCenterViewController;
//- (void)revealCenterPushViewController:(UIViewController *)viewController toViewController) isAnimation:(BOOL)animation;

/**
 显示左边控制器
 */
- (void)revealLeftViewController;
- (void)revealLeftPushViewController:(UIViewController *)viewController isAnimation:(BOOL)animation;

/**
 显示右边控制器
 */
- (void)revealRightViewController;
- (void)revealRightPushViewController:(UIViewController *)viewController isAnimation:(BOOL)animation;

/**
 控制器跳转
 */
- (void)pushViewController:(UIViewController *)controller onDirection:(FORevealSideDirection)direction animated:(BOOL)animated;

@end


@interface UIViewController (FOSideslipViewController)
/**
 抽屉控制器
 */
@property (nonatomic, assign) FOSideslipViewController *sideslipViewController;
@end

