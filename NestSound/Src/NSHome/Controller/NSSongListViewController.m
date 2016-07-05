//
//  NSSongListViewController.m
//  NestSound
//
//  Created by 谢豪杰 on 16/5/4.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSSongListViewController.h"
#import "NSSongViewController.h"
#import "NSSingListModel.h"
#import "NSSongMenuCollectionViewCell.h"
@interface NSSongListViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout
>{

    NSMutableArray * SongLists;
    
    UICollectionView * SongListColl;

    NSSongViewController * songVC;
    
    NSString * itemId;
    int currentPage;
    NSString * url;
}



@end

@implementation NSSongListViewController
 static NSString * cellId = @"SongListCell";

-(instancetype)initWithItemID:(NSString *)itemId_
{
    if (self = [super init]) {
        itemId = itemId_;
    }
    return self;


}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureUIAperance];
    

}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self fetchSongList];
}

#pragma mark -configureUIAppearance
-(void)configureUIAperance
{
    //title
    self.title = @"歌单";
//    LocalizedStr(@"promot_song");
    self.view.backgroundColor = [UIColor whiteColor];
    //collection
    UICollectionViewFlowLayout * SongListCollLayOut = [[UICollectionViewFlowLayout alloc] init];
    SongListColl = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:SongListCollLayOut];
    SongListColl.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    SongListColl.backgroundColor = [UIColor whiteColor];
    SongListColl.showsHorizontalScrollIndicator = NO;
    SongListColl.showsVerticalScrollIndicator = NO;
    SongListColl.delegate = self;
    SongListColl.dataSource = self;
    [SongListColl registerClass:[NSSongMenuCollectionViewCell class] forCellWithReuseIdentifier:cellId];
//    SongListColl.bounces = NO;
    
    [self.view addSubview:SongListColl];
    
    WS(wSelf);
    //refresh
    [SongListColl addDDPullToRefreshWithActionHandler:^{
        if (!wSelf) {
            return ;
        }else{
            [wSelf fetchSongListWithIsLoadingMore:NO];
        }
        
    }];
    //loadingMore
    [SongListColl addDDInfiniteScrollingWithActionHandler:^{
        if (!wSelf) {
            return ;
        }else{
            [wSelf fetchSongListWithIsLoadingMore:YES];
        }
    }];
    
    //hide infiniteView
    SongListColl.showsInfiniteScrolling = NO;

}

#pragma mark -fetchData
-(void)fetchSongList
{
    
        [SongListColl setContentOffset:CGPointMake(0 , -60) animated:YES];
        [SongListColl performSelector:@selector(triggerPullToRefresh) withObject:self afterDelay:0.5];
    

}

#pragma mark -fetchSongListIsLoadingMore
-(void)fetchSongListWithIsLoadingMore:(BOOL)isLoadingMore
{
    if (!isLoadingMore) {
        currentPage = 1;
        
    }else{
        ++currentPage;
    }
    NSDictionary * dic = @{@"page":[NSString stringWithFormat:@"%d",currentPage]};
    NSString * str = [NSTool encrytWithDic:dic];
    url = [songListURL  stringByAppendingString:str];
    self.requestType = YES;
    self.requestURL = url;
    

}


#pragma mark -actionFetchData
-(void)actionFetchRequest:(NSURLSessionDataTask *)operation result:(NSBaseModel *)parserObject error:(NSError *)requestErr
{
    
    if ([operation.urlTag isEqualToString:url]) {
    
        if (!parserObject.success) {
           NSSingListModel  * songListModel = (NSSingListModel *)parserObject;
            if (!operation.isLoadingMore) {
                SongLists = [NSMutableArray  arrayWithArray:songListModel.singList];
            }else{
            
                if (songListModel.singList.count == 0) {
                    
                }else{
                    [SongLists addObjectsFromArray:songListModel.singList];
                }
                
            }
            [SongListColl reloadData];
            
            if (!operation.isLoadingMore) {
                [SongListColl.pullToRefreshView stopAnimating];
            }else{
                [SongListColl.infiniteScrollingView stopAnimating];
            }
            
        }
    }
}

#pragma mark collectionView dataSource

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return SongLists.count;

}


-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSSongMenuCollectionViewCell * SongListCell = (NSSongMenuCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    NSInteger row = indexPath.row;
    singListModel * sing = SongLists[row];
    SongListCell.singList = sing;
   
    
    return SongListCell;
}

#pragma mark collectionView delegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSInteger row = indexPath.row;
    singListModel * sing = SongLists[row];
    songVC = [[NSSongViewController alloc] initWithSongListId:sing.itemId];
    [self.navigationController pushViewController: songVC animated:YES];
    
}

#pragma mark collectionViewDelegateLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake((ScreenWidth -40)/2, (ScreenWidth - 40)/2*0.66);
    
}



-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(10, 15, 0,15);
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10;
}

@end
