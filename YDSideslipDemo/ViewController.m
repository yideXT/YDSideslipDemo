//
//  ViewController.m
//  YDSideslipDemo
//
//  Created by 罗义德 on 15/6/19.
//  Copyright (c) 2015年 lyd. All rights reserved.
//

#import "ViewController.h"
#import "FOSideslipViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)btnClick:(UIBarButtonItem *)btn {
    NSLog(@"点击");
    
    if (btn.tag == 1) {
        [self.sideslipViewController revealLeftViewController];
    }else{
        [self.sideslipViewController revealRightViewController];
    }
    
}

- (void)setupUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.navigationItem.title = @"抽屉效果实现";
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:@"左边控制器" style:UIBarButtonItemStyleDone target:self action:@selector(btnClick:)];
    left.tag = 1;
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:@"右边控制器" style:UIBarButtonItemStyleDone target:self action:@selector(btnClick:)];
    right.tag = 2;
    self.navigationItem.rightBarButtonItem = right;
    
    NSArray *array = [[NSArray alloc] initWithObjects:@"手动侧滑",@"从左到右",@"显示阴影",@"滑动缩放",@"透明渐变", nil];
    
    CGRect rect = CGRectMake(10, 100, CGRectGetWidth(self.view.frame)/2-10, 60);
    int i=0;
    for (NSString *title in array) {
        
        BOOL isOn = NO;
        if (i==0) {
            isOn = self.sideslipViewController.isHandSlide;
        }else if (i==1) {
            isOn = self.sideslipViewController.isLeftToRight;
        }else if (i==2) {
            isOn = self.sideslipViewController.isShowShadow;
        }else if (i==3) {
            isOn = self.sideslipViewController.isCenterScaleGradient;
        }else{
            isOn = self.sideslipViewController.isVagueGradient;
        }
        
        [self makeSwitch:title andFrame:rect andTag:i isOn:isOn];
        
        if (rect.origin.x+CGRectGetWidth(self.view.frame)-10>CGRectGetWidth(self.view.frame)) {
            rect.origin.x = 10;
            rect.origin.y += 60;
        }else{
            rect.origin.x += rect.size.width;
        }
        i++;
    }
}

- (void)makeSwitch:(NSString *)title andFrame:(CGRect)rect andTag:(int)tag isOn:(BOOL)on {
    UIView *baseView = [[UIView alloc] initWithFrame:rect];
    
    //标题
    UILabel *lab = [[UILabel alloc] initWithFrame:CGRectMake(rect.size.width/2-40, 0, 80, rect.size.height/2)];
    lab.textAlignment = NSTextAlignmentCenter;
    lab.font = [UIFont systemFontOfSize:15];
    lab.text = title;
    [baseView addSubview:lab];
    
    //开关
    UISwitch *switchView = [[UISwitch alloc] initWithFrame:CGRectMake(rect.size.width/2-20, rect.size.height/2, 40, rect.size.height/2)];
    [switchView addTarget:self action:@selector(onAndOff:) forControlEvents:UIControlEventValueChanged];
    switchView.on = on;
    switchView.tag = tag;
    [baseView addSubview:switchView];
    [self.view addSubview:baseView];
}

- (void)onAndOff:(UISwitch *)switchView {
    
    switch (switchView.tag) {
        case 0:{
            self.sideslipViewController.isHandSlide = switchView.on;
            break;
        }
        case 1:{
            self.sideslipViewController.isLeftToRight = switchView.on;
            break;
        }
        case 2:{
            self.sideslipViewController.isShowShadow = switchView.on;
            break;
        }
        case 3:{
            self.sideslipViewController.isCenterScaleGradient = switchView.on;
            break;
        }
        case 4:{
            self.sideslipViewController.isVagueGradient = switchView.on;
            break;
        }
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
