//
//  NSPreserveListViewController.m
//  NestSound
//
//  Created by yinchao on 16/9/12.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSPreserveListViewController.h"
#import "NSPreserveTableViewCell.h"
#import "NSPreserveDetailViewController.h"
#import "NSPreserveSelectViewController.h"
#import "NSPreserveListModel.h"
@interface NSPreserveListViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *preserveTab;
    UIImageView *emptyImage;
    int currentPage;
}
@property (nonatomic,strong) NSMutableArray *preserveListArr;
@end
static NSString * const preserveCellIdentifier = @"preserveCellIdentifier";
@implementation NSPreserveListViewController
- (NSMutableArray *)preserveListArr {
    if (!_preserveListArr) {
        self.preserveListArr = [NSMutableArray arrayWithCapacity:1];
    }
    return _preserveListArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self configurePreserveListView];
    [self fetchPreserveListDataWithIsLoadingMore:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.needRefresh) {
        [preserveTab.pullToRefreshView triggerRefresh];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.needRefresh = NO;
}

- (void)fetchPreserveListDataWithIsLoadingMore:(BOOL)isLoadingMore {
    self.requestType = NO;
    if (!isLoadingMore) {
        currentPage = 1;
    }else{
        ++currentPage;
    }
    self.requestParams = @{@"uid":JUserID,@"token":LoginToken,@"page":[NSNumber numberWithInt:currentPage]};
    self.requestURL = preserveListUrl;
}
- (void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr {
    if (requestErr) {
        
    } else {
        if ([operation.urlTag isEqualToString:preserveListUrl]) {
            NSPreserveListModel *preserveListModel = (NSPreserveListModel*)parserObject;
            if (!operation.isLoadingMore) {
                [preserveTab.pullToRefreshView stopAnimating];
                self.preserveListArr = [NSMutableArray arrayWithArray:preserveListModel.preserveList];
            }else{
                [preserveTab.infiniteScrollingView stopAnimating];
                    [self.preserveListArr addObjectsFromArray:preserveListModel.preserveList];
                
            }
            if (self.preserveListArr.count) {
                emptyImage.hidden = YES;
            } else {
                emptyImage.hidden = NO;
            }
        }
        [preserveTab reloadData];
    }
}
- (void)configurePreserveListView {
    
    self.title = @"保全列表";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"添加" style:UIBarButtonItemStylePlain target:self action:@selector(rightClick)];
    preserveTab = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    
    preserveTab.dataSource = self;
    
    preserveTab.delegate = self;
    
    preserveTab.rowHeight = 50;
    
    preserveTab.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
    
    [self.view addSubview:preserveTab];
    
    [preserveTab mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.left.bottom.right.equalTo(self.view);
    }];
    
    WS(wSelf);
    [preserveTab addDDPullToRefreshWithActionHandler:^{
        if (!wSelf) {
            return ;
        }else{
            [wSelf fetchPreserveListDataWithIsLoadingMore:NO];
        }
    }];
    
    [preserveTab addDDInfiniteScrollingWithActionHandler:^{
        if (!wSelf) {
            return ;
        }else{
            [wSelf fetchPreserveListDataWithIsLoadingMore:YES];
        }
    }];
    
    preserveTab.showsInfiniteScrolling = NO;
    
    emptyImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"2.0_noMyData"]];
    
    emptyImage.hidden = YES;
    
    emptyImage.centerX = ScreenWidth/2;
    
    emptyImage.y = 100;
    
    [self.view addSubview:emptyImage];
}
- (void)rightClick {
    NSPreserveSelectViewController *preserveSelectVC = [[NSPreserveSelectViewController alloc] init];
    [self.navigationController pushViewController:preserveSelectVC animated:YES];
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.preserveListArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSPreserveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:preserveCellIdentifier];
    if (!cell) {
        cell = [[NSPreserveTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:preserveCellIdentifier];
    }
    cell.preserveModel = self.preserveListArr[indexPath.row];
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSPreserveModel *model = self.preserveListArr[indexPath.row];
    NSPreserveDetailViewController *preserveDetailVC = [[NSPreserveDetailViewController alloc] initWithPreserveID:model.preserveId sortID:model.sortId];
    [self.navigationController pushViewController:preserveDetailVC animated:YES];
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
