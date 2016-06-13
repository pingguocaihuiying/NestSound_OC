//
//  NSInspirationRecordViewController.m
//  NestSound
//
//  Created by Apple on 16/5/11.
//  Copyright © 2016年 yinchao. All rights reserved.
//

#import "NSInspirationRecordViewController.h"
#import "NSLyricView.h"
#import "NSPictureCollectionView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "XHSoundRecorder.h"

@interface NSInspirationRecordViewController () <UITextViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource> {
    
    UICollectionView *_collection;
    
    UIView *_bottomView;
}

@property (nonatomic, strong) UILabel *placeholderLabel;

@property (nonatomic, weak) UIView *recordView;

@property (nonatomic, weak) UIButton *soundBtn;

@property (nonatomic, weak) UILabel *promptLabel;

@property (nonatomic, weak) UIButton *recordBtn;

@property (nonatomic, weak) UIButton *playSongsBtn;

@property (nonatomic, weak) UIButton *deleteBtn;

@property (nonatomic, strong)  CADisplayLink *link;

@property (nonatomic, assign) CGFloat timeNum;

@property (nonatomic, assign) NSInteger totalTime;

@property (nonatomic, assign) BOOL isPlayer;

@property (nonatomic, weak) UIImageView *volume;

//录音时长
@property (nonatomic, weak) UILabel *recordDuration;

@end
static NSString * const reuseIdentifier  = @"ReuseIdentifier";
@implementation NSInspirationRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = [date datetoLongStringWithDate:[NSDate date]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick:)];
    
    [self setupUI];
    
    //注册键盘通知
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWasShown:)
     
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
     
                                             selector:@selector(keyboardWillBeHidden:)
     
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    
    
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    
    NSDictionary *userInfo = [aNotification userInfo];

    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    WS(wSelf);
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        
        _bottomView.y = keyBoardEndY - _bottomView.height - 64;
        
        if (!(wSelf.recordView.y >= ScreenHeight - 64)) {
            
            wSelf.recordView.y = ScreenHeight - 64;
        }

    }];
    
    
}



-(void)keyboardWillBeHidden:(NSNotification*)aNotification {
    
    NSDictionary *userInfo = [aNotification userInfo];
    
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGFloat keyBoardEndY = value.CGRectValue.origin.y;
    
    NSNumber *duration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    
    NSNumber *curve = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    WS(wSelf);
    
    [UIView animateWithDuration:duration.doubleValue animations:^{
        
        [UIView setAnimationBeginsFromCurrentState:YES];
        [UIView setAnimationCurve:[curve intValue]];
        
        if (wSelf.recordView.y >= ScreenHeight - 64) {
            
            _bottomView.y = keyBoardEndY - _bottomView.height - 64;
        } else {
            
            _bottomView.y = wSelf.recordView.y - _bottomView.height;
        }
        
        
    }];
    
}

- (void)setupUI {
    
    WS(wSelf);
    
    //textView
    NSLyricView *inspiration = [[NSLyricView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - 406)];
    
    inspiration.lyricText.delegate = self;
    
    [self.view addSubview:inspiration];
    
    self.placeholderLabel=[[UILabel alloc]initWithFrame:CGRectMake(4, 5, ScreenHeight, 22)];
    
    self.placeholderLabel.text = @"此时此刻你最想说些什么";
    
    self.placeholderLabel.textColor = [UIColor colorWithRed:186/255.0 green:186/255.0 blue:186/255.0 alpha:1.f];
    
    [inspiration.lyricText addSubview:self.placeholderLabel];
    
    //底部工具条View
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 124, ScreenWidth, 60)];
    
    [self.view addSubview:_bottomView];
    
    
    UIView *line1 = [[UIView alloc] init];//]WithFrame:CGRectMake(0, ScreenHeight - (ScreenHeight - 329), ScreenWidth, 1)];
    
    line1.backgroundColor = [UIColor lightGrayColor];
    
    [_bottomView addSubview:line1];
    
    [line1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.top.equalTo(_bottomView);
        
        make.height.mas_equalTo(1);
        
    }];
    
    //录音View
    UIView *recordView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight - 64, ScreenWidth, 258)];
    
    self.recordView = recordView;
    
    [self.view addSubview:recordView];
    
    
    //收回录音View的按钮
    UIButton *retractBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_record_retract"] forState:UIControlStateNormal];
        
    } action:^(UIButton *btn) {
        
        [UIView animateWithDuration:0.25 animations:^{
            
            recordView.y = ScreenHeight - 64;
            
            _bottomView.y = wSelf.recordView.y - _bottomView.height;
        }];
        
    }];
    
    [recordView addSubview:retractBtn];
    
    [retractBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(wSelf.recordView.mas_top).offset(15);
        
        make.centerX.equalTo(wSelf.recordView.mas_centerX);
        
    }];
    
    
    //遮罩View
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - recordView.height)];
    
    maskView.backgroundColor = [UIColor darkGrayColor];
    
    maskView.alpha = 0.5;
    
    maskView.hidden = YES;
    
    [self.navigationController.view addSubview:maskView];
    
    
    //音量大小的图片
    UIImageView *volume = [[UIImageView alloc] init];
    
    volume.contentMode = UIViewContentModeCenter;
    
    volume.image = [UIImage imageNamed:@"2.0_volume"];
    
    volume.backgroundColor = [UIColor hexColorFloat:@"ffd705"];
    
    volume.layer.cornerRadius = 5;
    
    volume.clipsToBounds = YES;
    
    volume.hidden = YES;
    
    self.volume = volume;
    
    [self.navigationController.view addSubview:volume];
    
    [volume mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(maskView.mas_centerX);
        
        make.centerY.equalTo(maskView.mas_centerY).offset(32);
        
        make.width.mas_equalTo(220);
        
        make.height.mas_equalTo(90);
    }];
    
    //录音时长
    UILabel *recordDuration = [[UILabel alloc] init];
    
    recordDuration.font = [UIFont systemFontOfSize:12];
    
    recordDuration.text = @"00:00";
    
    self.recordDuration = recordDuration;
    
    [volume addSubview:recordDuration];
    
    [recordDuration mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(volume.mas_centerX);
        
        make.centerY.equalTo(volume.mas_centerY);
    }];
    
    
    //提示Label
    UILabel *promptLabel = [[UILabel alloc] init];
    
    promptLabel.textColor = [UIColor hexColorFloat:@"666666"];
    
    promptLabel.text = @"点击录音";
    
    self.promptLabel = promptLabel;
    
    [recordView addSubview:promptLabel];
    
    [promptLabel mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.top.equalTo(retractBtn.mas_bottom).offset(10);
        
        make.centerX.equalTo(retractBtn.mas_centerX);
        
    }];
    
    //录音按钮
    UIButton *recordBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_record_record"] forState:UIControlStateNormal];
        
        [btn setImage:[UIImage imageNamed:@"2.0_record_recording"] forState:UIControlStateSelected];
        
    } action:^(UIButton *btn) {
        
        btn.selected = !btn.selected;
        
        if (btn.selected) {
            
            [self.soundBtn setImage:[UIImage imageNamed:@"2.0_addedSound"] forState:UIControlStateNormal];
            
            [[XHSoundRecorder sharedSoundRecorder] startRecorder:^(NSString *filePath) {
                
                NSLog(@"%@",filePath);
            }];
            
            wSelf.promptLabel.text = @"点击完成";
            
            maskView.hidden = NO;
            
            volume.hidden = NO;
            
            retractBtn.userInteractionEnabled = NO;
            
            [wSelf addLink];
            
             NSLog(@"点击了录音");
        } else {
            
            [[XHSoundRecorder sharedSoundRecorder] stopRecorder];
            
            btn.hidden = YES;
            
            wSelf.playSongsBtn.hidden = NO;
            wSelf.playSongsBtn.selected = NO;
            maskView.hidden = YES;
            
            volume.hidden = YES;
            
            self.deleteBtn.hidden = NO;
            
            retractBtn.userInteractionEnabled = YES;
            
            wSelf.promptLabel.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)self.timeNum / 60, (NSInteger)self.timeNum % 60];
            
            wSelf.totalTime = self.timeNum;
            
            [wSelf removeLink];
            
             NSLog(@"点击了暂停录音");
        }
        
    }];
    
    self.recordBtn = recordBtn;
    
    [recordView addSubview:recordBtn];
    
    [recordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(promptLabel.mas_bottom).offset(50);
        
        make.centerX.equalTo(recordView.mas_centerX);
        
    }];
    
    
    //播放录音按钮
    UIButton *playSongsBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_record_play"] forState:UIControlStateNormal];
        
        [btn setImage:[UIImage imageNamed:@"2.0_record_stop"] forState:UIControlStateSelected];
        
        btn.hidden = YES;
        
    } action:^(UIButton *btn) {
        
        btn.selected = !btn.selected;
        
        if (btn.selected) {
            
            wSelf.isPlayer = YES;
            
            [wSelf addLink];
            
            [[XHSoundRecorder sharedSoundRecorder] playsound:nil withFinishPlaying:^{
                
                btn.selected = NO;
                
                [wSelf removeLink];
            }];
            
            wSelf.promptLabel.text = [NSString stringWithFormat:@"%02ld:%02ld/%02ld:%02ld",(NSInteger)self.timeNum / 60, (NSInteger)self.timeNum % 60, self.totalTime / 60, self.totalTime % 60];
            
            NSLog(@"点击了播放录音");
        } else {
            
            [[XHSoundRecorder sharedSoundRecorder] stopPlaysound];
            
            [wSelf removeLink];
            
            NSLog(@"点击了停止播放录音");
        }
        
        
    }];
    
    self.playSongsBtn = playSongsBtn;
    
    [recordView addSubview:playSongsBtn];
    
    [playSongsBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(promptLabel.mas_bottom).offset(50);
        
        make.centerX.equalTo(recordView.mas_centerX);
        
    }];
    
    
    //删除录音按钮
    UIButton *deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
       
        [btn setImage:[UIImage imageNamed:@"2.0_record_delete"] forState:UIControlStateNormal];
        
        btn.hidden = YES;
        
    } action:^(UIButton *btn) {
        
        [wSelf.soundBtn setImage:[UIImage imageNamed:@"2.0_addSound"] forState:UIControlStateNormal];
        
        wSelf.recordBtn.hidden = NO;
        
        wSelf.playSongsBtn.hidden = YES;
        
        [[XHSoundRecorder sharedSoundRecorder] stopPlaysound];
        
        [[XHSoundRecorder sharedSoundRecorder] removeSoundRecorder];
        
        wSelf.promptLabel.text = @"点击录音";
        
        [wSelf removeLink];
        
        wSelf.isPlayer = NO;
        
        btn.hidden = YES;
        
        NSLog(@"点击了删除录音");
    }];
    
    self.deleteBtn = deleteBtn;
    
    [recordView addSubview:deleteBtn];
    
    [deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
       
        make.left.equalTo(recordBtn.mas_right).offset(35);
        
        make.centerY.equalTo(recordBtn.mas_centerY);
        
    }];
    
    
    //添加照片
    UIButton *pictureBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_addPicture"] forState:UIControlStateNormal];
        
    } action:^(UIButton *btn) {
        
        NSLog(@"点击了添加照片");
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        
        layout.minimumLineSpacing = 10;
        
        layout.minimumInteritemSpacing = 20;
        
        layout.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        
        CGFloat W = (inspiration.lyricText.width - 60) / 3;
        
        layout.itemSize = CGSizeMake(W, W);
        
        _collection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 100, inspiration.lyricText.width, W + 10) collectionViewLayout:layout];
        
        _collection.delegate = self;
        
        _collection.dataSource = self;
        
        _collection.backgroundColor = [UIColor hexColorFloat:@"f8f8f8"];
        
        [_collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
        
        [inspiration.lyricText addSubview:_collection];
        
        
    }];
    
    [_bottomView addSubview:pictureBtn];
    
    [pictureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line1.mas_bottom).offset(15);
        
        make.left.equalTo(_bottomView.mas_left).offset(15);
        
        make.width.height.mas_equalTo(30);
        
    }];
    
    //添加录音
    UIButton *soundBtn = [UIButton buttonWithType:UIButtonTypeCustom configure:^(UIButton *btn) {
        
        [btn setImage:[UIImage imageNamed:@"2.0_addSound"] forState:UIControlStateNormal];
        
    } action:^(UIButton *btn) {
        
        [inspiration.lyricText resignFirstResponder];
        
        [UIView animateWithDuration:0.25 animations:^{
            
            if (wSelf.recordView.y >= ScreenHeight - 64) {
                
                wSelf.recordView.y = ScreenHeight - 258 - 64;
                
                _bottomView.y = wSelf.recordView.y - _bottomView.height;
            } else {
                
                wSelf.recordView.y = ScreenHeight - 64;
                
                _bottomView.y = wSelf.recordView.y - _bottomView.height;
            }
            
        }];
        
        NSLog(@"点击了添加录音");
        
    }];
    
    self.soundBtn = soundBtn;
    
    [_bottomView addSubview:soundBtn];
    
    [soundBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(line1.mas_bottom).offset(15);
        
        make.left.equalTo(pictureBtn.mas_right).offset(15);
        
        make.width.height.mas_equalTo(30);
        
    }];
    
    
    UIView *line2 = [[UIView alloc] init];//]WithFrame:CGRectMake(0, ScreenHeight - (ScreenHeight - 329), ScreenWidth, 1)];
    
    line2.backgroundColor = [UIColor lightGrayColor];
    
    [self.view addSubview:line2];
    
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.right.bottom.equalTo(_bottomView);
        
        make.height.mas_equalTo(1);
        
    }];
    
    
}


-(void)textViewDidChange:(UITextView *)textView {
    
    if ([textView.text length] == 0) {
        
        self.placeholderLabel.hidden = NO;
        
    }else{
        
        self.placeholderLabel.hidden = YES;
    }
    
}

/**
 *  添加定时器
 */
- (void)addLink {
    
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(actionTiming)];
    
    [self.link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

/**
 *  移除定时器
 */
- (void)removeLink {
    
    self.timeNum = 0;
    
    self.recordDuration.text = @"00:00";
    
    [self.link invalidate];
    
    self.link = nil;
}

- (void)actionTiming {
    
    self.timeNum += 1/60.0;
    
    if (self.deleteBtn.hidden) {
        
        CGFloat count = [[XHSoundRecorder sharedSoundRecorder] decibels];
        
        if (count <= -35) {
            
            self.volume.image = [UIImage imageNamed:@"2.0_volume"];
            
        } else if (count <= -25 && count >= -35) {
            
            self.volume.image = [UIImage imageNamed:@"2.0_volume1"];
            
        } else if (count <= -15 && count >= -25) {
            
            self.volume.image = [UIImage imageNamed:@"2.0_volume2"];
            
        } else if (count <= 5 && count >= 15) {
            
            self.volume.image = [UIImage imageNamed:@"2.0_volume3"];
            
        } else {
            
            self.volume.image = [UIImage imageNamed:@"2.0_volume4"];
        }
        
    }
    
    
    self.recordDuration.text = [NSString stringWithFormat:@"%02ld:%02ld",(NSInteger)self.timeNum / 60, (NSInteger)self.timeNum % 60];
    
    if (self.isPlayer) {
        
        self.promptLabel.text = [NSString stringWithFormat:@"%02ld:%02ld/%02ld:%02ld",(NSInteger)self.timeNum / 60, (NSInteger)self.timeNum % 60, self.totalTime / 60, self.totalTime % 60];
    }
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return 9;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor colorWithRed:((float)arc4random_uniform(256) / 255.0) green:((float)arc4random_uniform(256) / 255.0) blue:((float)arc4random_uniform(256) / 255.0) alpha:1.0];
    
    return cell;
}


- (void)rightItemClick:(UIBarButtonItem *)rightItem {
    
    NSLog(@"点击了发布");
}


- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end








