//
//  NSMyCooperationViewController.m
//  NestSound
//
//  Created by yinchao on 16/10/25.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSMyCooperationViewController.h"
#import "NSMyCooperationTableViewCell.h"
#import "NSMyCooperationListModel.h"
#import "NSCooperationDetailViewController.h"
#import "NSLoginViewController.h"
@interface NSMyCooperationViewController ()<UITableViewDataSource,UITableViewDelegate,NSTipViewDelegate>
{
    UITableView *myCooperationTab;
    UIImageView *emptyImage;
    NSTipView *tipView;
    UIView *maskView;
    NSIndexPath *index;
    int currentPage;
}
@property (nonatomic,strong) NSMutableArray *myCooperationArr;
@end

@implementation NSMyCooperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMyCooperationViewController];
    [self fetchMyCooperationListWithIsLoadingMore:NO];
}

#pragma mark - Network Requests and Data Handling
- (void)fetchMyCooperationListWithIsLoadingMore:(BOOL)isLoadingMore {
    self.requestType = NO;
    if (!isLoadingMore) {
        currentPage = 1;
//        self.requestParams = @{@"page":@(currentPage),@"uid":JUserID,kIsLoadingMore:@(NO),@"token":LoginToken};
    }else{
        ++currentPage;
//        self.requestParams = @{@"page":@(currentPage),@"uid":JUserID,kIsLoadingMore:@(YES),@"token":LoginToken};
    }
    self.requestParams = @{@"page":@(currentPage),@"uid":JUserID,kIsLoadingMore:@(isLoadingMore),@"token":LoginToken};
    self.requestURL = myCooperationListUrl;
    
}
- (void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr {
    if (requestErr) {
        
    } else {
        if ([operation.urlTag isEqualToString:myCooperationListUrl]) {
            NSMyCooperationListModel *model = (NSMyCooperationListModel *)parserObject;
            if (!operation.isLoadingMore) {
                [myCooperationTab.pullToRefreshView stopAnimating];
                self.myCooperationArr = [NSMutableArray arrayWithArray:model.myCooperationList];
                
            }else{
                [myCooperationTab.infiniteScrollingView stopAnimating];
                [self.myCooperationArr addObjectsFromArray:model.myCooperationList];
            }
            if (self.myCooperationArr.count) {
                emptyImage.hidden = YES;
            } else {
                emptyImage.hidden = NO;
            }
            [myCooperationTab reloadData];
        } else if ([operation.urlTag isEqualToString:deleteMyCooperationUrl]) {
            
            [self fetchMyCooperationListWithIsLoadingMore:NO];
        }
    }
}
- (void)setupMyCooperationViewController {
    //我的
    myCooperationTab = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    
    myCooperationTab.delegate = self;
    
    myCooperationTab.dataSource= self;
    
    myCooperationTab.rowHeight = 60;
        
    myCooperationTab.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
    
    //    [lyricTableView registerClass:[NSNewMusicTableViewCell class] forCellReuseIdentifier:lyricCellIdentify];
    self.view = myCooperationTab;
//    [self.contentScrollView addSubview:myCooperationTab];
    
    UIView *noLineView = [[UIView alloc] initWithFrame:CGRectZero];
    
    myCooperationTab.tableFooterView = noLineView;
    
    WS(wSelf);
    //refresh
    [myCooperationTab addDDPullToRefreshWithActionHandler:^{
        if (!wSelf) {
            return ;
        }else{
            [wSelf fetchMyCooperationListWithIsLoadingMore:NO];
        }
    }];
    //loadingMore
    [myCooperationTab addDDInfiniteScrollingWithActionHandler:^{
        if (!wSelf) {
            return ;
        }
        [wSelf fetchMyCooperationListWithIsLoadingMore:YES];
    }];
    
    emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.0_noMyData"]];
    
    emptyImage.hidden = YES;
    
    emptyImage.centerX = ScreenWidth/2;
    
    emptyImage.y = 100;
    
    [myCooperationTab addSubview:emptyImage];
}
#pragma mark - UITableDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _myCooperationArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ID = @"myCooperationCell";
    
    NSMyCooperationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        
        cell = [[NSMyCooperationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
        
    }
    myCooperationModel *model = _myCooperationArr[indexPath.row];
    cell.myCooperation = model;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}
#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    myCooperationModel *model = _myCooperationArr[indexPath.row];
    NSCooperationDetailViewController *cooperationDetailVC = [[NSCooperationDetailViewController alloc] init];
    cooperationDetailVC.cooperationId = model.myCooperationId;
    cooperationDetailVC.detailTitle = model.cooperationTitle;
    cooperationDetailVC.isMyCoWork = YES;
    [self.navigationController pushViewController:cooperationDetailVC animated:YES];
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    myCooperationModel *model = _myCooperationArr[indexPath.row];
    if (editingStyle==UITableViewCellEditingStyleDelete) {
        if (model.status == 1) {
            maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
            
            maskView.backgroundColor = [UIColor lightGrayColor];
            
            maskView.alpha = 0.5;
            
            [self.navigationController.view addSubview:maskView];
            
            CGFloat padding = ScreenWidth *60/375.0;
            CGFloat width = (ScreenWidth - padding * 2);
            CGFloat height = width * 338/256.0f;
            
            tipView = [[NSTipView alloc] initWithFrame:CGRectMake(padding, (ScreenHeight - height)/2.0f, width, height)];
            
            tipView.delegate = self;
            
            tipView.imgName = @"2.3_tipImg_deleteDemand";
            
            tipView.tipText = @"删除后,其他人将无法继续使用该需求进行合作";
            [self.navigationController.view addSubview:tipView];
            
            CAKeyframeAnimation *keyFrame = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
            keyFrame.values = @[@(0.2), @(0.4), @(0.6), @(0.8), @(1.0), @(1.2), @(1.0)];
            keyFrame.duration = 0.3;
            keyFrame.removedOnCompletion = NO;
            [tipView.layer addAnimation:keyFrame forKey:nil];
            index = indexPath;
            
        } else {
            
            self.requestType = NO;
            
            self.requestParams = @{@"did":@(model.myCooperationId),@"token":LoginToken};
            
            self.requestURL = deleteMyCooperationUrl;
        }
    }
}
#pragma mark - NSTipViewDelegate
- (void)cancelBtnClick {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tipView.transform = CGAffineTransformScale(tipView.transform, 0.1, 0.1);
        
    } completion:^(BOOL finished) {
        
        [maskView removeFromSuperview];
        
        [tipView removeFromSuperview];
    }];
}
- (void)ensureBtnClick {
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        tipView.transform = CGAffineTransformScale(tipView.transform, 0.1, 0.1);
        
    } completion:^(BOOL finished) {
        
        [maskView removeFromSuperview];
        
        [tipView removeFromSuperview];
        
        myCooperationModel *model = _myCooperationArr[index.row];
        
        self.requestType = NO;
        
        self.requestParams = @{@"did":@(model.myCooperationId),@"token":LoginToken};
        
        self.requestURL = deleteMyCooperationUrl;
        
    }];
}
- (NSMutableArray *)myCooperationArr {
    if (!_myCooperationArr) {
        self.myCooperationArr = [NSMutableArray arrayWithCapacity:5];
    }
    return _myCooperationArr;
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
