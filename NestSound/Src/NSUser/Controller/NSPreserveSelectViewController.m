//
//  NSPreserveSelectViewController.m
//  NestSound
//
//  Created by yinchao on 16/9/20.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSPreserveSelectViewController.h"
#import "NSPreserveApplyController.h"
@interface NSPreserveSelectViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    UIScrollView *_topScrollView;
    UITableView *musicTableView;
    UITableView *lyricTableView;
    UIView *_lineView;
}
@property (nonatomic, strong) UIScrollView *contentScrollView;
@end
static NSString * const productCellIdentifier = @"productCellIdentifier";
@implementation NSPreserveSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configurePreserveSelectView];
}
- (void)configurePreserveSelectView {
    
    self.title = @"作品列表";
    self.view.backgroundColor = KBackgroundColor;
    _topScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 33)];
    _topScrollView.backgroundColor = KBackgroundColor;
    _topScrollView.contentSize = CGSizeZero;
    
    [self.view addSubview:_topScrollView];
    
    NSArray *titleArray = @[@"歌词",@"歌曲"];
    
    CGFloat W = ScreenWidth / titleArray.count;
    
    CGFloat H = _topScrollView.height;
    
    for (int i = 0; i < titleArray.count; i++) {
        
        UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake((W + 1) * i, 1, W, H-2)];
        
        titleBtn.backgroundColor = [UIColor whiteColor];
        
        [titleBtn setTitle:titleArray[i] forState:UIControlStateNormal];
        
        [titleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        
        titleBtn.tag = i + 100;
        
        [titleBtn addTarget:self action:@selector(titleBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [_topScrollView addSubview:titleBtn];
    }
    _lineView = [[UIView alloc] initWithFrame:CGRectMake(0, _topScrollView.height - 3, ScreenWidth / titleArray.count, 3)];
    
    _lineView.backgroundColor = [UIColor hexColorFloat:@"ffd705"];
    
    [_topScrollView addSubview:_lineView];
    
    self.contentScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topScrollView.height, ScreenWidth, self.view.height - _topScrollView.height - 64)];
    
    self.contentScrollView.contentSize = CGSizeMake(ScreenWidth * titleArray.count, 0);
    
    self.contentScrollView.showsHorizontalScrollIndicator = NO;
    
    self.contentScrollView.showsVerticalScrollIndicator = NO;
    
    self.contentScrollView.pagingEnabled = YES;
    
    self.contentScrollView.delegate = self;
    
    [self.view addSubview:self.contentScrollView];
    
    musicTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, CGRectGetHeight(self.contentScrollView.frame)) style:UITableViewStylePlain];
    
    musicTableView.delegate = self;
    
    musicTableView.dataSource = self;
    
//    musicTableView.rowHeight = 80;
    
    musicTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    musicTableView.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
    
//    [musicTableView registerClass:[NSNewMusicTableViewCell class] forCellReuseIdentifier:musicCellIdentify];
    
    [self.contentScrollView addSubview:musicTableView];
    
    WS(Wself);
    //refresh
    [musicTableView addDDPullToRefreshWithActionHandler:^{
        if (!Wself) {
            return ;
        }else{
//            [Wself fetchDataWithType:1 andIsLoadingMore:NO];
        }
    }];
    //loadingMore
    [musicTableView addDDInfiniteScrollingWithActionHandler:^{
        if (!Wself) {
            return ;
        }
//        [Wself fetchDataWithType:1 andIsLoadingMore:YES];
    }];
    //歌词
    lyricTableView = [[UITableView alloc] initWithFrame:CGRectMake(ScreenWidth, 0, ScreenWidth, CGRectGetHeight(self.contentScrollView.frame)) style:UITableViewStylePlain];
    
    lyricTableView.delegate = self;
    
    lyricTableView.dataSource= self;
    
//    lyricTableView.rowHeight = 80;
    
    lyricTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    lyricTableView.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
    
//    [lyricTableView registerClass:[NSNewMusicTableViewCell class] forCellReuseIdentifier:lyricCellIdentify];
    
    [self.contentScrollView addSubview:lyricTableView];
    //refresh
    [lyricTableView addDDPullToRefreshWithActionHandler:^{
        if (!Wself) {
            return ;
        }else{
//            [Wself fetchDataWithType:2 andIsLoadingMore:NO];
        }
    }];
    //loadingMore
    [lyricTableView addDDInfiniteScrollingWithActionHandler:^{
        if (!Wself) {
            return ;
        }
//        [Wself fetchDataWithType:2 andIsLoadingMore:YES];
    }];
}
- (void)titleBtnClick:(UIButton *)titleBtn {
    
    [self.contentScrollView setContentOffset:CGPointMake(ScreenWidth * (titleBtn.tag-100), 0) animated:YES];
    
    [UIView animateWithDuration:0.25 animations:^{
        
        _lineView.x = titleBtn.width * (titleBtn.tag-100);
    }];
//    searchType = titleBtn.tag - 99;
    
//    if (titleBtn.tag == 100) {
//        if (musicDataAry.count) {
//            [musicTableView reloadData];
//        } else {
//            [self fetchDataWithType:1 andIsLoadingMore:NO];
//        }
//    } else if (titleBtn.tag == 101) {
//        if (lyricDataAry.count) {
//            [lyricTableView reloadData];
//        } else {
//            [self fetchDataWithType:2 andIsLoadingMore:NO];
//        }
//    }
//    }
    
}

#pragma mark UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.contentScrollView) {
        _lineView.x = scrollView.contentOffset.x / ScreenWidth * _lineView.width;
    }
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:productCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:productCellIdentifier];
    }
    cell.textLabel.text = @"南方姑娘";
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    cell.detailTextLabel.text = @"2016.09.20 14:00";
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSPreserveApplyController *preserveController = [[NSPreserveApplyController alloc] init];
//    preserveController.itemUid = self.itemUid;
    [self.navigationController pushViewController:preserveController animated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
