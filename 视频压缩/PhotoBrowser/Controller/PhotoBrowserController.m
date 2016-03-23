//
//  PhotoBrowserController.m
//  LoginAndRegister
//
//  Created by qian on 15/11/20.
//  Copyright © 2015年 topsci. All rights reserved.
//

#import "PhotoBrowserController.h"

@interface PhotoBrowserController ()<UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *imageViewArray;
@property (nonatomic, strong) UILabel * titleLabel;
@property (nonatomic, strong) UICollectionView *photoCollectionView;

@end

@implementation PhotoBrowserController

#define screenW ([UIScreen mainScreen].bounds.size.width)
#define screenH ([UIScreen mainScreen].bounds.size.height)

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initPhotoCollectionView];

    [self addTitleLabel];

    // Do any additional setup after loading the view.
}

-(void)addTitleLabel
{
    self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 20, 200, 40)];
    self.titleLabel.text = [NSString stringWithFormat:@"%zd/%zd",self.currentIndex+1,self.photos.count];
    self.title = self.titleLabel.text;
    self.titleLabel.textColor = [UIColor lightGrayColor];

    [self.view addSubview:self.titleLabel];
}

-(void)updateTitleLabelWith:(NSInteger)index
{
    self.title = [NSString stringWithFormat:@"%zd/%zd",index+1,self.photos.count];
    [self.titleLabel setText:self.title];
}

-(void)initPhotoCollectionView
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc]init];
    flow.itemSize = CGSizeMake(screenW, screenH-64);
    flow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flow.minimumInteritemSpacing = 0;
    flow.minimumLineSpacing = 0;
    self.photoCollectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:flow];
    self.photoCollectionView.showsHorizontalScrollIndicator = NO;
    self.photoCollectionView.showsVerticalScrollIndicator = NO;
    self.photoCollectionView.pagingEnabled = YES;
    self.automaticallyAdjustsScrollViewInsets =NO;
    self.photoCollectionView.delegate = self;
    self.photoCollectionView.dataSource = self;
    
    [self.photoCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:NSStringFromClass([self class])];
    [self.view addSubview:self.photoCollectionView];
    
    [self.photoCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
    
    UIScrollView *scroll = [[UIScrollView alloc]initWithFrame:cell.contentView.bounds];
    scroll.maximumZoomScale = 8.0;
    scroll.minimumZoomScale = 1;
    scroll.showsHorizontalScrollIndicator = NO;
    scroll.showsVerticalScrollIndicator = NO;
    scroll.bounces = NO;
    scroll.delegate = self;
    
    CGRect frame = [self getImageframeWith:self.photos[indexPath.item]];
    UIImageView *imageView =[[UIImageView alloc]initWithFrame:frame];
    imageView.userInteractionEnabled = YES;
    imageView.image = self.photos[indexPath.item];
    [scroll addSubview:imageView];
    
    for (UIView * view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    [cell.contentView addSubview:scroll];
    [self.imageViewArray addObject:imageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGest)];
    [imageView addGestureRecognizer:tap];
    
    [self updateTitleLabelWith:indexPath.item];

    return cell;
}

-(void)tapGest
{
    [UIView animateWithDuration:0.2 animations:^{
        self.navigationController.navigationBarHidden = !self.navigationController.navigationBarHidden;
    }];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.photos.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return scrollView.subviews[0];
}

#pragma mark - 让需要缩放的image中心保持在scrollView的中心
-(void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    UIView * view = scrollView.subviews[0];
    
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    view.center = CGPointMake(xcenter, ycenter);
}

-(CGRect)getImageframeWith:(UIImage *)image
{
    CGRect frame;
    CGFloat imageViewH;
    CGFloat imageViewW;
    CGFloat imageViewY;
    CGFloat imageViewX;
    
    if (image.size.width>image.size.height) {
        imageViewW = screenW;
        imageViewH = image.size.height/(image.size.width/screenW);
        imageViewX = 0;
        imageViewY = (screenH-imageViewH)/2;
    } else {
        imageViewH = screenH;
        imageViewW = image.size.width*(screenH/image.size.height);
        if (imageViewW>screenW) {
            imageViewH = imageViewH*(screenW/imageViewW);
            imageViewW = screenW;
            imageViewX = 0;
            imageViewY = (screenH-imageViewH)/2;
        } else {
            imageViewY = 0;
            imageViewX = (screenW-imageViewW)/2;
        }
    }
    
    frame = CGRectMake(imageViewX, imageViewY, imageViewW, imageViewH);
    return frame;
}

-(void)dealloc
{
    self.photoCollectionView.delegate = nil;
    self.photoCollectionView.dataSource = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
