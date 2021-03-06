//
//  NSLyricPosterViewController.m
//  NestSound
//
//  Created by 李龙飞 on 16/8/10.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSLyricPosterViewController.h"
#import "NSShareView.h"
#import "NSImagePicker.h"
@interface NSLyricPosterViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate,NSImagePickerDelegate>
{
    NSString *lyric;
    
    UIImage *posterImg;
    
    CGFloat height;
    
    NSShareView *shareView;
    
    UIView *maskView;
    
    UIImage *finalImg;
    
}
@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) NSArray *shareArr;
@end

@implementation NSLyricPosterViewController

@synthesize posterImg = _posterImg;
- (NSArray *)shareArr {
    if (!_shareArr) {
        self.shareArr = [NSArray array];
    }
    return _shareArr;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    lyric = [self.lyricsArr componentsJoinedByString:@"\n"];
    
    posterImg = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.posterImg]]];
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:15]};
    
    height = [lyric boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:dic context:nil].size.height;
    
    [self setupLyricPoster];
    
}
- (void)setupLyricPoster {
    
    self.navigationController.navigationBar.hidden = NO;
    
    self.title = @"歌词海报";
    
    UIScrollView *backScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight-104)];
    
    backScrollView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight - 104 + height);
    
    backScrollView.showsHorizontalScrollIndicator = NO;
    
    backScrollView.showsVerticalScrollIndicator = NO;
    
    backScrollView.delegate = self;
    
    [self.view addSubview:backScrollView];
    
    self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 104 + height)];
    
    self.imgView.userInteractionEnabled = YES;
    
    [_imgView setContentScaleFactor:[[UIScreen mainScreen] scale]];
    
    _imgView.contentMode = UIViewContentModeScaleAspectFill;
    
    _imgView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    _imgView.clipsToBounds = YES;
    
    self.imgView.image = [self drawRectImage:posterImg withContent:lyric title:[NSString stringWithFormat:@"%@",self.lyricTitle] author:[NSString stringWithFormat:@"作词:『%@』",self.lyricAuthor]];
    
    [backScrollView addSubview:_imgView];
    
    UIButton *picBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    picBtn.frame = CGRectMake(ScreenWidth - 50, ScreenHeight/2 - 60 , 40, 40);
    
    [picBtn setBackgroundImage:[UIImage imageNamed:@"2.0_changePic_icon"] forState:UIControlStateNormal];
    
    [picBtn addTarget:self action:@selector(selectPicFromAlbum) forControlEvents:UIControlEventTouchUpInside];
    
    [self.imgView addSubview:picBtn];
    
    UIView *bottomView = [UIView new];
    
    bottomView.backgroundColor = [UIColor hexColorFloat:@"ffd00b"];
    
    [self.view addSubview:bottomView];
    
    [bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(self.view).offset(0);
        
        make.height.mas_offset(40);
        
    }];
    
    //分享
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [shareBtn setImage:[UIImage imageNamed:@"2.0_share_icon"] forState:UIControlStateNormal];
    
    [shareBtn setTitle:@"  分享" forState:UIControlStateNormal];
    
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    shareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [shareBtn addTarget:self action:@selector(handleShareAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:shareBtn];
    
    [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.bottom.equalTo(bottomView).offset(0);
        
        make.size.mas_equalTo(CGSizeMake(ScreenWidth/2-0.5, 40));
        
    }];
    
    //保存
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [saveBtn setImage:[UIImage imageNamed:@"2.0_save_icon"] forState:UIControlStateNormal];
    
    [saveBtn setTitle:@"  保存" forState:UIControlStateNormal];
    
    [saveBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    
    [saveBtn addTarget:self action:@selector(saveThePosterImgToLoacl) forControlEvents:UIControlEventTouchUpInside];
    
    [bottomView addSubview:saveBtn];
    
    [saveBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.right.bottom.equalTo(bottomView).offset(0);
        
        make.size.mas_equalTo(CGSizeMake(ScreenWidth/2 - 0.5, 40));
        
    }];
    
    UIView *midView = [UIView new];
    
    midView.backgroundColor = [UIColor blackColor];
    
    [bottomView addSubview:midView];
    
    [midView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(shareBtn.mas_right).offset(0);
        
        make.right.equalTo(saveBtn.mas_left).offset(0);
        
        make.top.equalTo(bottomView).offset(5);
        
        make.bottom.equalTo(bottomView).offset(-5);
        
    }];
    maskView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    
    maskView.backgroundColor = [UIColor lightGrayColor];
    
    maskView.alpha = 0.5;
    
    [self.navigationController.view addSubview:maskView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    
    maskView.hidden = YES;
    
    [maskView addGestureRecognizer:tap];
    
    // 分享弹框
    shareView = [[NSShareView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 100) withType:@"poster"];
    
    self.shareArr = shareView.shareArr;
    
    shareView.backgroundColor = [UIColor whiteColor];
    
    for (int i = 0; i < 5; i++) {
        UIButton *shareBtn = (UIButton *)[shareView viewWithTag:250+i];
        [shareBtn addTarget:self action:@selector(handleShareViewButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.navigationController.view addSubview:shareView];
}

- (void)selectPicFromAlbum {
    
    
    NSImagePicker *imagePicker = [NSImagePicker sharedInstance];
    imagePicker.delegate = self;
    [imagePicker showImagePickerWithType:1 InViewController:self Scale:(ScreenHeight/2)/ScreenWidth];
    /**
    
    UIImagePickerController *imgController = [[UIImagePickerController alloc] init];
    
    imgController.delegate = self;
    
    imgController.editing = YES;
    
    imgController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:imgController animated:YES completion:^{
        
    }];
     */
}
- (void)tapClick:(UIGestureRecognizer *)tap {
    
    maskView.hidden = YES;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        shareView.y = ScreenHeight;
        
    }];
}
- (void)handleShareAction:(UIButton *)sender {
    
    maskView.hidden = NO;
    [UIView animateWithDuration:0.4 animations:^{
        shareView.y = ScreenHeight - shareView.height;
    }];
    
}
- (void)handleShareViewButton:(UIButton *)sender {
    
    
    NSDictionary *dic = self.shareArr[sender.tag-250];
    UMSocialUrlResource * urlResource  = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:nil];
    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeImage;

    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[dic[@"type"]] content:nil image:finalImg location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *response) {
        if (response.responseCode == UMSResponseCodeSuccess) {
            [self tapClick:nil];
            [[NSToastManager manager] showtoast:@"分享成功"];
        }
    }];
}
- (void)saveThePosterImgToLoacl {
    
    if (finalImg) {
        [self saveImageToPhotos:finalImg];
    }else{
    [self saveImageToPhotos:[self drawRectImage:posterImg withContent:lyric title:[NSString stringWithFormat:@"%@",self.lyricTitle] author:[NSString stringWithFormat:@"作词:『%@』",self.lyricAuthor]]];
    }
}
/**
#pragma mark - UIImageViewDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage * img = [info objectForKey:UIImagePickerControllerEditedImage];
    
    self.imgView.image = [self drawRectImage:img withContent:lyric title:[NSString stringWithFormat:@"%@",self.lyricTitle] author:[NSString stringWithFormat:@"作词:『%@』",self.lyricAuthor]];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
 */

#pragma mark - NSImagePickerDelegate

- (void)imagePickerDidCancel:(NSImagePicker *)imagePicker{
    
}
- (void)imagePicker:(NSImagePicker *)imagePicker didFinished:(UIImage *)editedImage{
    self.imgView.image = [self drawRectImage:editedImage withContent:lyric title:[NSString stringWithFormat:@"%@",self.lyricTitle] author:[NSString stringWithFormat:@"作词:『%@』",self.lyricAuthor]];

}
-(UIImage *)drawRectImage:(UIImage *)img withContent:(NSString *)content title:(NSString *)title author:(NSString *)author;
{
    //获得一个位图图形上下文
    CGSize size=CGSizeMake(ScreenWidth, ScreenHeight - 104 + height);//画布大小
    UIGraphicsBeginImageContextWithOptions(size, NO, 2.0);
//    UIGraphicsBeginImageContextWithOptions(CGSizeMake(ScreenWidth, ScreenHeight - 104 + height), NO,[UIScreen mainScreen].scale);//换一下这句就行了。
//    UIGraphicsBeginImageContext(size);
    
    [img drawInRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight/2)];//注意绘图的位置是相对于画布顶点而言，不是屏幕
    //添加水印
    NSDictionary *fontDic1 = @{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:15.f]};
    
    CGFloat height0 = [title boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:fontDic1 context:nil].size.height;
    [title drawInRect:CGRectMake(10, ScreenHeight/2 + 20, ScreenWidth, height0 + 10) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:15.f],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    CGFloat height1 = [author boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:fontDic1 context:nil].size.height;
    [author drawInRect:CGRectMake(10, ScreenHeight/2 + 30 + height0, ScreenWidth, height1+ 10) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:15.f],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    CGFloat height2 = [content boundingRectWithSize:CGSizeMake(ScreenWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:fontDic1 context:nil].size.height;
    
    [content drawInRect:CGRectMake(10, ScreenHeight/2 + 40 + height0 + height1, ScreenWidth, height2) withAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"STHeitiSC-Light" size:15.f],NSForegroundColorAttributeName:[UIColor blackColor]}];
    
    UIImage *logoImg = [UIImage imageNamed:@"2.0_poster_logo"];
    
    [logoImg drawInRect:CGRectMake(10, ScreenHeight/2 + 30 + height0 + height1 + height2, 0.48 * ScreenWidth, ScreenWidth/15)];
    
    //返回绘制的新图形
    UIImage *newImage=UIGraphicsGetImageFromCurrentImageContext();
    
    //最后一定不要忘记关闭对应的上下文
    UIGraphicsEndImageContext();
    
    finalImg = newImage;
    return newImage;
}
- (void)saveImageToPhotos:(UIImage*)savedImage
{
    
    UIImageWriteToSavedPhotosAlbum(savedImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    
}

// 指定回调方法

- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    
    NSString *msg = nil ;
    
    if(error != NULL){
        
        msg = @"保存图片失败" ;
        
    }else{
        
        msg = @"保存图片成功" ;
        
    }
    
    [[NSToastManager manager] showtoast:msg];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
    //
    //                                                    message:msg
    //
    //                                                   delegate:self
    //
    //                                          cancelButtonTitle:@"确定"
    //
    //                                          otherButtonTitles:nil];
    //
    //    [alert show];
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
