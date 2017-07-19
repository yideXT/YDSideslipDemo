//
//  FOSideslipViewController.m
//  YDSideslipDemo
//
//  Created by 罗义德 on 15/6/19.
//  Copyright (c) 2015年 lyd. All rights reserved.
//

#import "FOSideslipViewController.h"
#import <objc/runtime.h>

/** 抽屉位置发生改变通知 */
NSString *const FOSideslipViewDirectionChangedNotification = @"FOSideslipViewDirectionChangedNotification";

@implementation FOSideslipViewController {
    //中间视图显示完毕，私有block
    void (^_centerAnimationFinish_block)(void);
    //是否正在显示左边分栏中
    BOOL _isDirectionChange;
    //抽屉滑动时中间视图缩放的比例
    CGFloat _scaleRate;
    //当程序进入后台时，记住抽屉所在的方向
    FORevealSideDirection _toBackDirection;
    
    //显示当前左边控制器时中间视图的缩放比例
    CGFloat _showLeftCenterCurrentScale;
    //左边控制器滑动时中间控制器最小的缩放比
    CGFloat _showLeftCenterMinScale;
    
    //显示当前右边控制器时中间视图的缩放比例
    CGFloat _showRightCenterCurrentScale;
    //右边控制器滑动时中间控制器最小的缩放比
    CGFloat _showRightCenterMinScale;
    
    //中间视图的点击手势
    UITapGestureRecognizer *_centerVCtapRecognizer;
    //中间视图拖动手势
    UIPanGestureRecognizer *_centerVCPanRecognizer;
}

#pragma system method
- (instancetype)initWithCenterViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor whiteColor];
        
        [self setCenterViewController:viewController];
        
        //设置默认参数
        _isHandSlide = YES;
        _isLeftToRight = NO;
        _leftOffset = 200;
        _rightOffset = 200;
        //不能直接在里面设置为YES
        _isShowShadow = NO;
        _isCenterScaleGradient = YES;
        _isVagueGradient = YES;
        _animationDuration = 0.3;
        _sideDirection = FORevealSideDirectionCenter;
        //缩放比例
        _scaleRate = 2.5;
        
        //显示左边控制器时中间视图的缩放比例
        _showLeftCenterCurrentScale = 1.0;
        _showLeftCenterMinScale = 0.8;
        
        //显示右边控制器时中间视图的缩放比例
        _showRightCenterCurrentScale = 1.0;
        _showRightCenterMinScale = 0.8;
    }
    return self;
}

#pragma mark private method
//设置滑动之后是否显示阴影
- (void)setIsShowShadow:(BOOL)isShowShadow {
    _isShowShadow = isShowShadow;
    if (isShowShadow) {//显示阴影
        _centerViewController.view.layer.shadowOffset = CGSizeZero;
        _centerViewController.view.layer.shadowOpacity = 0.20f;
        _centerViewController.view.layer.shadowRadius = 10.0f;
        _centerViewController.view.layer.shadowColor = [UIColor blackColor].CGColor;
        _centerViewController.view.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.view.layer.bounds].CGPath;
        _centerViewController.view.clipsToBounds = NO;
        
    }else{//不显示阴影
        _centerViewController.view.layer.shadowPath = nil;
        _centerViewController.view.layer.shadowOpacity = 0.0f;
        _centerViewController.view.layer.shadowRadius = 0.0;
        _centerViewController.view.layer.shadowColor = nil;
    }
}

- (void)setIsHandSlide:(BOOL)isHandSlide {
    _isHandSlide = isHandSlide;
    if (_isHandSlide) {
        [_centerViewController.view addGestureRecognizer:_centerVCPanRecognizer];
        
    }else {
        [_centerViewController.view removeGestureRecognizer:_centerVCPanRecognizer];
        
    }
}

- (void)setIsVagueGradient:(BOOL)isVagueGradient {
    _isVagueGradient = isVagueGradient;
    if (!_isVagueGradient) {
        _leftViewController.view.alpha = 1.0;
        _rightViewController.view.alpha = 1.0;
    }
}

- (void)setIsCenterScaleGradient:(BOOL)isCenterScaleGradient {
    _isCenterScaleGradient = isCenterScaleGradient;
    if (!_isCenterScaleGradient) {
        _centerViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
    }
}

//设置中间控制器
- (void)setCenterViewController:(UIViewController *)centerViewController {
    
    if (_centerViewController!=centerViewController) {
        
        if (_centerViewController) {
            [_centerViewController willMoveToParentViewController:nil];
            [_centerViewController.view removeFromSuperview];
            [_centerViewController removeFromParentViewController];
        }
        
        _centerViewController = centerViewController;
        _centerViewController.sideslipViewController = self;
        
        [self addChildViewController:_centerViewController];
        [self.view addSubview:_centerViewController.view];
        [_centerViewController didMoveToParentViewController:self];
        
        //加一个拖动手势
        _centerVCPanRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(slideDragCenter:)];
        if (_isHandSlide) {
            [_centerViewController.view addGestureRecognizer:_centerVCPanRecognizer];
        }
        
    }
}

//设置左边控制器
- (void)setLeftViewController:(UIViewController *)leftViewController {
    if (_leftViewController != leftViewController) {
        
        if (_leftViewController) {
            [_leftViewController willMoveToParentViewController:nil];
            [_leftViewController.view removeFromSuperview];
            [_leftViewController removeFromParentViewController];
        }
        
        _leftViewController = leftViewController;
        _leftViewController.sideslipViewController = self;
        
        [self addChildViewController:_leftViewController];
        [self.view insertSubview:_leftViewController.view belowSubview:_centerViewController.view];
        [_leftViewController didMoveToParentViewController:self];
    }
}

//设置右边控制器
- (void)setRightViewController:(UIViewController *)rightViewController {
    if (_rightViewController != rightViewController) {
        
        if (_rightViewController) {
            [_rightViewController willMoveToParentViewController:nil];
            [_rightViewController.view removeFromSuperview];
            [_rightViewController removeFromParentViewController];
        }
        
        _rightViewController = rightViewController;
        _rightViewController.sideslipViewController = self;
        
        [self addChildViewController:_rightViewController];
        [self.view insertSubview:_rightViewController.view belowSubview:_centerViewController.view];
        [_rightViewController didMoveToParentViewController:self];
    }
}

//设置左边偏移量
- (void)setLeftOffset:(CGFloat)leftOffset {
    _leftOffset = leftOffset<40?40:leftOffset;
}

//设置右边偏移量
- (void)setRightOffset:(CGFloat)rightOffset {
    _rightOffset = rightOffset<40?40:rightOffset;
}

//给中间视图添加一个点击手势
- (void)centerViewControllerAddTapGestureRecognizer {
    
    if ([_centerViewController.view.gestureRecognizers containsObject:_centerVCtapRecognizer]) {
        return;
    }
    
    //添加一个点击手势
    if (!_centerVCtapRecognizer) {
        _centerVCtapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(centerViewControllerTapClick:)];
    }
    
    //如果首页是导航控制器
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        [[[(UINavigationController *)(_centerViewController) viewControllers] lastObject] view].userInteractionEnabled = NO;
    }
    
    [_centerViewController.view addGestureRecognizer:_centerVCtapRecognizer];
}

//给中间视图删除点击手势
- (void)centerViewControllerRemoveTapGestureRecognizer {
    
    if (![_centerViewController.view.gestureRecognizers containsObject:_centerVCtapRecognizer]) {
        return;
    }
    
    //如果首页是导航控制器
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        [[[(UINavigationController *)(_centerViewController) viewControllers] lastObject] view].userInteractionEnabled = YES;
    }
    
    [_centerViewController.view removeGestureRecognizer:_centerVCtapRecognizer];
}

#pragma mark 响应事件
//滑动中间控制器的响应
- (void)slideDragCenter:(UIPanGestureRecognizer *)pan {
    
    if (pan.state == UIGestureRecognizerStateEnded) {//手势结束
        NSLog(@"手势结束!");
        CGFloat x;
        int direction = 0;//1.显示左边，2.显示中间，3.显示右边
        if (pan.view.frame.origin.x>0) {//显示左边分栏中
            
            if (pan.view.frame.origin.x>(_leftOffset/2)) {//显示左边分栏
                x = _leftOffset;
                direction = 1;
            }else{//显示中间页面
                x = 0;
                direction = 2;
            }
            
        }else if(pan.view.frame.origin.x<0) {//显示右边分栏中
            
            if ([UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(pan.view.frame)>(_rightOffset/2)) {//显示右边分栏
                x = [UIScreen mainScreen].bounds.size.width-_rightOffset-CGRectGetWidth(pan.view.frame);
                direction = 3;
            }else{//显示中间页面
                x = 0;
                direction = 2;
            }
            
        }else{//显示中间
            x = 0;
            direction = 2;
        }
        
        //动画
        [UIView animateWithDuration:(double)_animationDuration/2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            
            if (direction == 1) {//显示左边
                _leftViewController.view.alpha = 1.0;
                _currentDirection = FORevealSideDirectionLeft;
                
                if (_isCenterScaleGradient) {
                    _centerViewController.view.transform = CGAffineTransformMakeScale(_showLeftCenterMinScale, _showLeftCenterMinScale);
                    _showLeftCenterCurrentScale = _showLeftCenterMinScale;
                }
                
                CGRect rect = pan.view.frame;
                rect.origin.x = x;
                pan.view.frame = rect;
                
                //给中间控制器添加手势
                [self centerViewControllerAddTapGestureRecognizer];
                
            }else if (direction == 2) {//显示中间
                
                if (_isVagueGradient) {
                    _rightViewController.view.alpha = 0.0;
                    _leftViewController.view.alpha = 0.0;
                }
                _currentDirection = FORevealSideDirectionCenter;
                
                _centerViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
                _showLeftCenterCurrentScale = 1.0;
                _showRightCenterCurrentScale = 1.0;
                
                CGRect rect = pan.view.frame;
                rect.origin.x = x;
                pan.view.frame = rect;
                
                //删除中间点击手势
                [self centerViewControllerRemoveTapGestureRecognizer];
                
            }else if (direction == 3) {
                _rightViewController.view.alpha = 1.0;
                _currentDirection = FORevealSideDirectionRight;
                
                if (_isCenterScaleGradient) {
                    _centerViewController.view.transform = CGAffineTransformMakeScale(_showRightCenterMinScale, _showRightCenterMinScale);
                    _showRightCenterCurrentScale = _showRightCenterMinScale;
                }
                
                CGRect rect = pan.view.frame;
                rect.origin.x = [UIScreen mainScreen].bounds.size.width-_rightOffset-CGRectGetWidth(pan.view.frame);
                pan.view.frame = rect;
                
                //给中间控制器添加手势
                [self centerViewControllerAddTapGestureRecognizer];
            }
            
        } completion:^(BOOL finished) {
            
            CGFloat center = _centerViewController.view.center.x;
            if (center>(CGFloat)[UIScreen mainScreen].bounds.size.width/2) {//显示左边
                _sideDirection = FORevealSideDirectionLeft;
            }else if (center<(CGFloat)[UIScreen mainScreen].bounds.size.width/2) {//显示右边
                _sideDirection = FORevealSideDirectionRight;
            }else{//显示中间
                _sideDirection = FORevealSideDirectionCenter;
            }
            
            //动画完成,发出通知
            if (finished) {
                [[NSNotificationCenter defaultCenter] postNotificationName:FOSideslipViewDirectionChangedNotification object:[NSNumber numberWithInteger:_sideDirection]];
            }
            
        }];
        return;
    }

    CGPoint point = [pan translationInView:self.view];
    
    if ((pan.view.frame.origin.x + point.x)>0) {//即将显示左边控制器
        
        if (!_leftViewController) {//如果左边控制器不存在
            return;
            
        }else if (!_isLeftToRight && _sideDirection == FORevealSideDirectionRight) {//不允许直接从右边到左边
            NSLog(@"滑动失败11");
            
        }else if (!_isLeftToRight && _currentDirection == FORevealSideDirectionRight) {//在动画过程中直接由右边到左边
            NSLog(@"滑动失败12");
            
        }else{
            if ([UIScreen mainScreen].bounds.size.width-CGRectGetMinX(pan.view.frame)-point.x>40) {//设置滑动范围
                
                pan.view.center = CGPointMake(pan.view.center.x + point.x, pan.view.center.y);
                
                if (_isCenterScaleGradient) {//是否允许centerView的frame一起变化
                    
                    _showLeftCenterCurrentScale = 1.0-(1.0-_showLeftCenterMinScale)*(CGRectGetMinX(pan.view.frame)/_leftOffset);
                    pan.view.transform = CGAffineTransformMakeScale(_showLeftCenterCurrentScale, _showLeftCenterCurrentScale);
                }
                
                if (_isVagueGradient) {//是否允许模糊渐变
                    _leftViewController.view.alpha = (double)(CGRectGetMinX(pan.view.frame)/_leftOffset);
                }
                
                [self willShowLeftViewController];
                _currentDirection = FORevealSideDirectionLeft;
            }
        }
        
    }else if((pan.view.frame.origin.x + point.x)<0){//即将显示右边控制器
        
        if (!_rightViewController) {//如果右边控制器不存在
            return;
            
        }else if (!_isLeftToRight &&  _sideDirection == FORevealSideDirectionLeft) {//不允许直接由左边到右边
            NSLog(@"滑动失败21");
        }else if (!_isLeftToRight && _currentDirection == FORevealSideDirectionLeft) {//在动画过程中直接由左边到右边
            NSLog(@"滑动失败22");
        }else{
            if (CGRectGetMaxX(pan.view.frame)-point.x>40) {//设置滑动范围
                
                if (_isCenterScaleGradient) {//是否允许centerView的frame一起变化
                    _showRightCenterCurrentScale = 1.0-(1.0-_showRightCenterMinScale)*(([UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(pan.view.frame))/_rightOffset);
                    pan.view.transform = CGAffineTransformMakeScale(_showRightCenterCurrentScale, _showRightCenterCurrentScale);
                }
                
                pan.view.center = CGPointMake(pan.view.center.x + point.x, pan.view.center.y);
                
                if (_isVagueGradient) {//是否允许模糊渐变
                    _rightViewController.view.alpha = (double)(([UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(pan.view.frame))/_rightOffset);
                }
                
                [self willShowRightViewController];
                _currentDirection = FORevealSideDirectionRight;
            }
        }
    }
    
//    NSLog(@"pan.state结束1 ============================================ %ld",pan.state);
    
    [pan setTranslation:CGPointMake(0, 0) inView:self.view];
    
//    if (pan.state == UIGestureRecognizerStateEnded) {//手势结束
////        NSLog(@"手势结束!");
//        
//        CGFloat x;
//        int direction = 0;//1.显示左边，2.显示中间，3.显示右边
//        if (pan.view.frame.origin.x>0) {//显示左边分栏中
//            
//            if (pan.view.frame.origin.x>(_leftOffset/2)) {//显示左边分栏
//                x = _leftOffset;
//                direction = 1;
//            }else{//显示中间页面
//                x = 0;
//                direction = 2;
//            }
//            
//        }else if(pan.view.frame.origin.x<0) {//显示右边分栏中
//            
//            if ([UIScreen mainScreen].bounds.size.width-CGRectGetMaxX(pan.view.frame)>(_rightOffset/2)) {//显示右边分栏
//                x = [UIScreen mainScreen].bounds.size.width-_rightOffset-CGRectGetWidth(pan.view.frame);
//                direction = 3;
//            }else{//显示中间页面
//                x = 0;
//                direction = 2;
//            }
//            
//        }else{//显示中间
//            x = 0;
//            direction = 2;
//            return;
//        }
//        
//        //动画
//        [UIView animateWithDuration:(double)_animationDuration/2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
//            
//            if (direction == 1) {//显示左边
//                _leftViewController.view.alpha = 1.0;
//                _currentDirection = FORevealSideDirectionLeft;
//                
//                if (_isCenterScaleGradient) {
//                    _centerViewController.view.transform = CGAffineTransformMakeScale(_showLeftCenterMinScale, _showLeftCenterMinScale);
//                    _showLeftCenterCurrentScale = _showLeftCenterMinScale;
//                }
//                
//                CGRect rect = pan.view.frame;
//                rect.origin.x = x;
//                pan.view.frame = rect;
//                
//                //给中间控制器添加手势
//                [self centerViewControllerAddTapGestureRecognizer];
//                
//            }else if (direction == 2) {//显示中间
//                
//                if (_isVagueGradient) {
//                    _rightViewController.view.alpha = 0.0;
//                    _leftViewController.view.alpha = 0.0;
//                }
//                _currentDirection = FORevealSideDirectionCenter;
//                
//                _centerViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
//                _showLeftCenterCurrentScale = 1.0;
//                _showRightCenterCurrentScale = 1.0;
//                
//                CGRect rect = pan.view.frame;
//                rect.origin.x = x;
//                pan.view.frame = rect;
//                
//                //删除中间点击手势
//                [self centerViewControllerRemoveTapGestureRecognizer];
//
//            }else if (direction == 3) {
//                _rightViewController.view.alpha = 1.0;
//                _currentDirection = FORevealSideDirectionRight;
//                
//                if (_isCenterScaleGradient) {
//                    _centerViewController.view.transform = CGAffineTransformMakeScale(_showRightCenterMinScale, _showRightCenterMinScale);
//                    _showRightCenterCurrentScale = _showRightCenterMinScale;
//                }
//                
//                CGRect rect = pan.view.frame;
//                rect.origin.x = [UIScreen mainScreen].bounds.size.width-_rightOffset-CGRectGetWidth(pan.view.frame);
//                pan.view.frame = rect;
//                
//                //给中间控制器添加手势
//                [self centerViewControllerAddTapGestureRecognizer];
//            }
//            
//        } completion:^(BOOL finished) {
//            
//            CGFloat center = _centerViewController.view.center.x;
//            if (center>(CGFloat)[UIScreen mainScreen].bounds.size.width/2) {//显示左边
//                _sideDirection = FORevealSideDirectionLeft;
//            }else if (center<(CGFloat)[UIScreen mainScreen].bounds.size.width/2) {//显示右边
//                _sideDirection = FORevealSideDirectionRight;
//            }else{//显示中间
//                _sideDirection = FORevealSideDirectionCenter;
//            }
//        }];
//    }
}

//中间控制器点击响应事件
- (void)centerViewControllerTapClick:(UITapGestureRecognizer *)tap {
    [self revealCenterViewControllerIsAnimation:YES];
    
}


- (void)willShowLeftViewController {
    if (!_rightViewController.view.hidden) {
        _leftViewController.view.hidden = NO;
        _rightViewController.view.hidden = YES;
        NSLog(@"即将显示左边分栏");
    }
    
    //添加点击手势
    [self centerViewControllerAddTapGestureRecognizer];
}

- (void)willShowRightViewController {
    if (!_leftViewController.view.hidden) {
        _rightViewController.view.hidden = NO;
        _leftViewController.view.hidden = YES;
        NSLog(@"即将显示右边分栏");
    }
    
    //添加点击手势
    [self centerViewControllerAddTapGestureRecognizer];
}

#pragma mark public method
/** 显示中间控制器 */
- (void)revealCenterViewControllerIsAnimation:(BOOL)animation {
    
    if (_sideDirection == FORevealSideDirectionCenter) {
        return;
    }
    
    NSTimeInterval tempDuration = _animationDuration;
    if (!animation) {//不允许动画
        _animationDuration = 0;
    }
    
    [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        _centerViewController.view.transform = CGAffineTransformMakeScale(1.0, 1.0);
        
        CGRect rect = _centerViewController.view.frame;
        rect.origin.x = 0;
        _centerViewController.view.frame = rect;
        
        if (_isVagueGradient) {//允许模糊渐变
            _leftViewController.view.alpha = 0.0;
            _rightViewController.view.alpha = 0.0;
        }
        
    } completion:^(BOOL finished) {//显示中间视图完毕
        _sideDirection = FORevealSideDirectionCenter;
        _currentDirection = FORevealSideDirectionCenter;
        if (_centerAnimationFinish_block && finished) {
            _centerAnimationFinish_block();
            _centerAnimationFinish_block = nil;
        }
        
        //删除点击手势
        [self centerViewControllerRemoveTapGestureRecognizer];
        
        //抽屉位置变化完成,发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:FOSideslipViewDirectionChangedNotification object:[NSNumber numberWithInteger:_sideDirection]];
    }];
    
    _animationDuration = tempDuration;
    
}

/** 显示中间控制器的主页面 */
- (void)revealCenterRootViewControllerIsAnimation:(BOOL)animation {
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationVC = (UINavigationController *)_centerViewController;
        //退出主控制器栈的当前控制器
        [navigationVC popToRootViewControllerAnimated:YES];
        [self revealCenterViewControllerIsAnimation:animation];
    }
}

/** 显示中间视图同时跳转到新的控制器 */
- (void)revealCenterPushViewController:(UIViewController *)viewController isAnimation:(BOOL)animation {
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationVC = (UINavigationController *)_centerViewController;
        //先退出主控制器栈的当前控制器
        [navigationVC popToRootViewControllerAnimated:NO];
        [navigationVC pushViewController:viewController animated:NO];
        
        [self revealCenterViewControllerIsAnimation:animation];
    }
}

/** 由中间控制器的导航控制器的主控制器push到某个控制器组，按顺序push */
- (void)revealCenterPushViewControllers:(NSArray *)viewControllers isAnimation:(BOOL)animation {
    if ([_centerViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationVC = (UINavigationController *)_centerViewController;
        //先退出主控制器栈的当前控制器
        [navigationVC popToRootViewControllerAnimated:NO];
        
        for (UIViewController *subVC in viewControllers) {
            [navigationVC pushViewController:subVC animated:NO];
        }
        
        [self revealCenterViewControllerIsAnimation:animation];
    }
}

/**
 显示左边控制器
 */
- (void)revealLeftViewControllerIsAnimation:(BOOL)animation {
    if (!_leftViewController || _sideDirection == FORevealSideDirectionLeft) {
        return;
    }
    
    if (_sideDirection == FORevealSideDirectionRight) {//先显示中间，再显示右边
        __weak typeof(self)mySelf = self;
        //设置中间视图控制器动画完成回调
        _centerAnimationFinish_block = ^{
            [mySelf willShowLeftViewController];
            [mySelf showLeftViewCenterViewScaleAndTranslation];
        };
        //先显示中间视图控制器
        [self revealCenterViewControllerIsAnimation:animation];
        
    }else {//直接显示左边
        [self willShowLeftViewController];
        [self showLeftViewCenterViewScaleAndTranslation];
        
    }
}

//显示左控制器时，中间控制器的缩放和平移
- (void)showLeftViewCenterViewScaleAndTranslation {
    
    [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if (_isCenterScaleGradient) {//允许缩放
            _centerViewController.view.transform = CGAffineTransformMakeScale(_showLeftCenterMinScale, _showLeftCenterMinScale);
        }

        CGRect rect = _centerViewController.view.frame;
        rect.origin.x = _leftOffset;
        _centerViewController.view.frame = rect;
        
        _leftViewController.view.alpha = 1.0;

    } completion:^(BOOL finished){
        _sideDirection = FORevealSideDirectionLeft;
        
        //抽屉位置变化完成,发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:FOSideslipViewDirectionChangedNotification object:[NSNumber numberWithInteger:_sideDirection]];
        
    }];
}

/**
 显示右边控制器
 */
- (void)revealRightViewControllerIsAnimation:(BOOL)animation {
    if (!_rightViewController || _sideDirection == FORevealSideDirectionRight) {
        return;
    }
    
    if (_sideDirection == FORevealSideDirectionLeft) {//先显示中间，再显示右边
        __weak typeof(self)mySelf = self;
        //设置中间视图控制器动画完成回调
        _centerAnimationFinish_block = ^{
            [mySelf willShowRightViewController];
            [mySelf showRightViewCenterViewScaleAndTranslation];
        };
        //先显示中间视图控制器
        [self revealCenterViewControllerIsAnimation:animation];
        
    }else {//直接显示右边
        [self willShowRightViewController];
        [self showRightViewCenterViewScaleAndTranslation];
        
    }
}

//显示右控制器时，中间控制器的缩放和平移
- (void)showRightViewCenterViewScaleAndTranslation {
    
    [UIView animateWithDuration:_animationDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if (_isCenterScaleGradient) {//允许缩放
            _centerViewController.view.transform = CGAffineTransformMakeScale(_showRightCenterMinScale, _showRightCenterMinScale);
        }
        
        CGRect rect = _centerViewController.view.frame;
        rect.origin.x = [UIScreen mainScreen].bounds.size.width-_rightOffset-CGRectGetWidth(_centerViewController.view.frame);
        _centerViewController.view.frame = rect;
        
        _rightViewController.view.alpha = 1.0;
        
    } completion:^(BOOL finished){
        _sideDirection = FORevealSideDirectionRight;
        
        //抽屉位置变化完成,发出通知
        [[NSNotificationCenter defaultCenter] postNotificationName:FOSideslipViewDirectionChangedNotification object:[NSNumber numberWithInteger:_sideDirection]];
        
    }];
}

@end

@implementation UIViewController (FOSideslipViewController)

//关联关键字
static char kSideslipViewControllerKey;

- (void)setSideslipViewController:(FOSideslipViewController *)sideslipViewController {
    [self willChangeValueForKey:@"sideslipViewController"];
    objc_setAssociatedObject(self, &kSideslipViewControllerKey, sideslipViewController, OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"sideslipViewController"];
}

- (FOSideslipViewController *)sideslipViewController {
    id controller = objc_getAssociatedObject(self, &kSideslipViewControllerKey);
    
    if (!controller && self.navigationController) {
        controller = self.navigationController.sideslipViewController;
    }
    
    if (!controller && self.tabBarController) {
        controller = self.tabBarController.sideslipViewController;
    }
    return controller;
}

@end

