//
//  MJPhotoToolbar.h
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MJPhotoToolbar,MJPhoto;
@protocol MJPhotoToolbarDelegate <NSObject>
- (void)setPhoto1:(MJPhoto *)photo;
@end

@interface MJPhotoToolbar : UIView
// 所有的图片对象
@property (nonatomic, strong) NSArray *photos;
// 当前展示的图片索引
@property (nonatomic, assign) NSUInteger currentPhotoIndex;
// 图片描述
@property (nonatomic, copy) NSString *desc;

// 代理
@property (nonatomic, weak) id<MJPhotoToolbarDelegate> photoToolBarDelegate;

@end
