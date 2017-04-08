//
//  MJZoomingScrollView.m
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoView.h"
#import "MJPhoto.h"
#import "MJPhotoLoadingView.h"
#import "UIImageView+WebCache.h"
#import <QuartzCore/QuartzCore.h>
#import "CONST.h"
#import "BaseViewController.h"


@interface MJPhotoView ()
{
    BOOL _doubleTap;
    UIImageView *_imageView;
    MJPhotoLoadingView *_photoLoadingView;
}
@end

@implementation MJPhotoView
- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.delegate=self;
        self.clipsToBounds = YES;
		// 图片
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
        
        // 进度条
        _photoLoadingView = [[MJPhotoLoadingView alloc] init];
		
		// 属性
		self.backgroundColor = [UIColor clearColor];
		self.delegate = self;
		self.showsHorizontalScrollIndicator = NO;
		self.showsVerticalScrollIndicator = NO;
		self.decelerationRate = UIScrollViewDecelerationRateFast;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // 监听点击
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        singleTap.delaysTouchesBegan = YES;
        singleTap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        // 关键在这一行，如果双击确定偵測失败才會触发单击
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(setPhoto1:)
                                                     name:@"setPhoto1" object:nil];
        
    }
    return self;
}

#pragma mark - photoSetter
- (void)setPhoto:(MJPhoto *)photo {
    _photo = photo;
    
    [self showImage];
}

//- (void)setPhoto1:(MJPhoto *)photo {
//    _photo = photo;
//    
//    [self showImage];
//}

-(void)setPhoto1:(NSNotification *)notification{
    MJPhoto *photo=[[notification object]objectForKey:@"photo"];
    _photo = photo;
    [self showImage];
}


// /var/mobile/Containers/Data/Application/D93F5325-F014-43BA-94D3-47E53A427E0C/Library/Caches/KuaiQiang/EGOCache/EGOImageLoader-1498893286.jpg
//501719687180000.jpg

//EGOImageLoader-2744637941
//http://house.dl.goufang.com/_UsingData/2255/482355169500791.jpg
//http://house.dl.goufang.com/_UsingData/2255/482355169500791.jpg
#pragma mark 显示图片
- (void)showImage
{

    if (_photo.firstShow) { // 首次显示
        _imageView.image = _photo.placeholder; // 占位图片
        _photo.srcImageView.image = nil;
        // 不是gif，就马上开始下载
        //if (![_photo.url.absoluteString hasSuffix:@"gif"]) { //0919 注释
        //以下 0414 ZHANGYG加
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        docDir=[docDir stringByAppendingPathComponent:@"KuaiQiang/EGOCache/"];
        NSString *egoImageTitle=[NSString stringWithFormat:@"EGOImageLoader-%u", [[_photo.url description] hash]];
        egoImageTitle=[egoImageTitle stringByAppendingPathComponent:@".jpg"];
        egoImageTitle=[egoImageTitle stringByReplacingOccurrencesOfString:@"/.jpg" withString:@".jpg"];
        NSString *downloadPath = [NSString stringWithFormat:@"%@/%@", docDir,egoImageTitle];
        NSData *data = [NSData dataWithContentsOfFile:downloadPath];
        //如果已经下载
        if (data!=nil)
        {
            UIImage *avatarImage = [UIImage imageWithData:data];
            float actualHeight = avatarImage.size.height;
            float actualWidth = avatarImage.size.width;
            if(actualHeight>1){
                //[_photoLoadingView removeFromSuperview];
                //_photo.firstShow=NO;
                if(_photo.firstShow){
                    _imageView.image=avatarImage;
                    _photo.image=avatarImage;
                    
                     __unsafe_unretained MJPhotoView *photoView = self;
                    // 调整frame参数
                    [photoView adjustFrame];
                    return;
                }
            }
        }
        else{
            
            
        }
        
            //以上 0414 ZHANGYG加
            __unsafe_unretained MJPhotoView *photoView = self;
            __unsafe_unretained MJPhoto *photo = _photo;
            // 直接显示进度条
            [_photoLoadingView removeFromSuperview];
            [_photoLoadingView showLoading];
            //            [_imageView setImageWithURL:_photo.url placeholderImage:_photo.placeholder options:SDWebImageRetryFailed|SDWebImageLowPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            //                photo.image = image;
            //
            //                // 调整frame参数
            //[photoView adjustFrame];
            //            }];
        
                        [self addSubview:_photoLoadingView];
            //__unsafe_unretained MJPhotoLoadingView *loading = _photoLoadingView;  0504
             MJPhotoLoadingView *loading = _photoLoadingView;
            [_imageView setImageWithURL:_photo.url placeholderImage:_photo.srcImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSUInteger receivedSize, long long expectedSize) {
                if (receivedSize > kMinProgress) {
                    loading.progress = (float)receivedSize/expectedSize;
                }
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
                if(image!=nil){
                    [photoView photoDidFinishLoadWithImage:image];
                    // 调整frame参数
                    [photoView adjustFrame];
                }
            }];
            //}  //0919 //0919 注释

        
        } else {
        [self photoStartLoad];
    }

    // 调整frame参数
    [self adjustFrame];
}

#pragma mark 开始加载图片
- (void)photoStartLoad
{
    if (_photo.image) {
        self.scrollEnabled = YES;
        _imageView.image = _photo.image;
        [_photoLoadingView removeFromSuperview];
        
    } else {
        self.scrollEnabled = NO;
        // 直接显示进度条
        [_photoLoadingView removeFromSuperview];
        [_photoLoadingView showLoading];
        [self addSubview:_photoLoadingView];
        
        __unsafe_unretained MJPhotoView *photoView = self;
        //__unsafe_unretained MJPhotoLoadingView *loading = _photoLoadingView;  0504
         MJPhotoLoadingView *loading = _photoLoadingView;
        [_imageView setImageWithURL:_photo.url placeholderImage:_photo.srcImageView.image options:SDWebImageRetryFailed|SDWebImageLowPriority progress:^(NSUInteger receivedSize, long long expectedSize) {
            if (receivedSize > kMinProgress) {
                loading.progress = (float)receivedSize/expectedSize;
            }
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
            if(image!=nil){
            [photoView photoDidFinishLoadWithImage:image];
            }
        }];
    }
}

#pragma mark 加载完毕
- (void)photoDidFinishLoadWithImage:(UIImage *)image
{
    if (image) {
        self.scrollEnabled = YES;
        _photo.image = image;
        [_photoLoadingView removeFromSuperview];
        
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewImageFinishLoad:)]) {
            [self.photoViewDelegate photoViewImageFinishLoad:self];
        }
    } else {
        [self addSubview:_photoLoadingView];
        [_photoLoadingView showFailure];
    }
    
    // 设置缩放比例
    [self adjustFrame];
}
#pragma mark 调整frame
- (void)adjustFrame
{
	if (_imageView.image == nil) return;
    
    // 基本尺寸参数
    CGSize boundsSize = self.bounds.size;
    CGFloat boundsWidth = boundsSize.width;
    CGFloat boundsHeight = boundsSize.height;
    
    CGSize imageSize = _imageView.image.size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;
	
	// 设置伸缩比例
    CGFloat minScale = boundsWidth / imageWidth;
	if (minScale > 1) {
		minScale = 1.0;
	}
	CGFloat maxScale = 2.0; 
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		maxScale = maxScale / [[UIScreen mainScreen] scale];
	}
	self.maximumZoomScale = maxScale;
	self.minimumZoomScale = minScale;
	self.zoomScale = minScale;
    
    CGRect imageFrame = CGRectMake(0, 0, boundsWidth, imageHeight * boundsWidth / imageWidth);
    // 内容尺寸
    self.contentSize = CGSizeMake(0, imageFrame.size.height);
    
    // y值
    if (imageFrame.size.height < boundsHeight) {
        imageFrame.origin.y = floorf((boundsHeight - imageFrame.size.height) / 2.0);
	} else {
        imageFrame.origin.y = 0;
	}
    
    if (_photo.firstShow) { // 第一次显示的图片
        _photo.firstShow = NO; // 已经显示过了
        _imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil];
        
        _imageView.frame=CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH*3/4);  //zhangyg 0403+
        if(_photo.y!=0){
            _imageView.frame=CGRectMake(0, _photo.y, SCREEN_WIDTH, SCREEN_WIDTH*3/4);
        }
        [UIView animateWithDuration:0.3 animations:^{
            _imageView.frame = imageFrame;
        } completion:^(BOOL finished) {
            // 设置底部的小图片
            _photo.srcImageView.image = _photo.placeholder;
            [self photoStartLoad];
        }];
    } else {
        _imageView.frame = imageFrame;
    }
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return _imageView;
}

#pragma mark - 手势处理
- (void)handleSingleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = NO;
    [self performSelector:@selector(hide) withObject:nil afterDelay:0.2];
}
- (void)hide
{
    if (_doubleTap) return;
    
    // 移除进度条
    [_photoLoadingView removeFromSuperview];
    self.contentOffset = CGPointZero;
    
    // 清空底部的小图
    _photo.srcImageView.image = nil;
    
    CGFloat duration = 0.15;
    if (_photo.srcImageView.clipsToBounds) {
        [self performSelector:@selector(reset) withObject:nil afterDelay:duration];
    }
    
    [UIView animateWithDuration:duration + 0.3 animations:^{
        //_imageView.frame = [_photo.srcImageView convertRect:_photo.srcImageView.bounds toView:nil]; //zhangyg 0403
        _imageView.frame=CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH*3/4);  //zhangyg 0403+
        if(_photo.y!=0){
            _imageView.frame=CGRectMake(0, _photo.y, SCREEN_WIDTH, SCREEN_WIDTH*3/4);
        }
//        _imageView.frame = CGRectMake(100, 200, 0, 0);
        // gif图片仅显示第0张
        if (_imageView.image.images) {
            _imageView.image = _imageView.image.images[0];
        }
        
        _imageView.frame=CGRectMake(SCREEN_WIDTH/2, 100, 0, 0);
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewSingleTap:)]) {
            [self.photoViewDelegate photoViewSingleTap:self];
        }
    } completion:^(BOOL finished) {
        // 设置底部的小图片
        _photo.srcImageView.image = _photo.placeholder;
        
        // 通知代理
        if ([self.photoViewDelegate respondsToSelector:@selector(photoViewDidEndZoom:)]) {
            [self.photoViewDelegate photoViewDidEndZoom:self];
        }
    }];
}

- (void)reset
{
    _imageView.image = _photo.capture;
    _imageView.contentMode = UIViewContentModeScaleToFill;
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)tap {
    _doubleTap = YES;
    
    CGPoint touchPoint = [tap locationInView:self];
	if (self.zoomScale == self.maximumZoomScale) {
		[self setZoomScale:self.minimumZoomScale animated:YES];
	} else {
		[self zoomToRect:CGRectMake(touchPoint.x, touchPoint.y, 1, 1) animated:YES];
	}
}

- (void)dealloc
{
    // 取消请求
    [_imageView setImageWithURL:[NSURL URLWithString:@"file:///abc"]];
}
@end
