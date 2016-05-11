//
//  NSDiscoverViewController.m
//  NestSound
//
//  Created by Apple on 16/5/7.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSDiscoverViewController.h"
#import "NSMusicViewController.h"

@interface NSDiscoverViewController () <UIScrollViewDelegate> {
    
    UIScrollView *_topScrollView;
    
    UIScrollView *_scrollView;
    
    UIView *_lineView;
}

@end

@implementation NSDiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    [self setupUI];
    
}


- (void)setupUI {
    
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 33)];
    
    _topScrollView.contentSize = CGSizeZero;
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _scrollView.showsVerticalScrollIndicator = NO;
    
    [self.view addSubview:_topScrollView];
    
    NSArray *titleArray = @[@"活动",@"歌曲",@"歌词",@"榜单"];
    
    CGFloat W = ScreenWidth / titleArray.count;
    
    CGFloat H = _topScrollView.height;
    
    for (int i = 0; i < titleArray.count; i++) {
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(W * i, 0, W, H)];
        
        [titleBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        
        [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        titleBtn.tag = i;
        
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topScrollView addSubview:titleBtn];
    }
    
    
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _topScrollView.height - 3, ScreenWidth / titleArray.count, 3)];
    
    _lineView.backgroundColor = [UIColor orangeColor];
    
    [_topScrollView addSubview:_lineView];
    
    
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topScrollView.height, ScreenWidth, ScreenHeight - _topScrollView.height - 108)];
    
    _scrollView.contentSize = CGSizeMake(ScreenWidth * titleArray.count, 0);
    
    _scrollView.showsHorizontalScrollIndicator = NO;
    
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _scrollView.pagingEnabled = YES;
    
    _scrollView.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    
    _scrollView.delegate = self;
    
    [self.view addSubview:_scrollView];
    
    [self setupContent];
    
}

- (void)setupContent {
    
    NSMusicViewController *music = [[NSMusicViewController alloc] init];
    
    music.view.frame = CGRectMake(ScreenWidth, 0, ScreenWidth, _scrollView.height);
    
    [self addChildViewController:music];
    
    [_scrollView addSubview:music.view];
}



- (void)titleBtnClick:(UIButton *)titleBtn {
    
    if (titleBtn.tag == 0) {
        
        NSLog(@"点击了活动");
    } else if(titleBtn.tag == 1) {
        
        NSLog(@"点击了歌曲");
    } else if (titleBtn.tag == 2) {
        
        NSLog(@"点击了歌词");
    } else {
        
        NSLog(@"点击了榜单");
    }
    
    [_scrollView setContentOffset:CGPointMake(ScreenWidth * titleBtn.tag, 0) animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _lineView.x = titleBtn.width * titleBtn.tag;
    }];
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    _lineView.x = scrollView.contentOffset.x / ScreenWidth * _lineView.width;
}


@end









