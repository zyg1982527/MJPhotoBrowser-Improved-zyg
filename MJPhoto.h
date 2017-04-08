//
//  MJPhoto.h
//
//  Created by mj on 13-3-4.
//  Copyright (c) 2013年 itcast. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MJPhoto : NSObject
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *image; // 完整的图片
@property (nonatomic, strong) NSMutableDictionary *detailProductInfo;

@property (nonatomic, strong) UIImageView *srcImageView; // 来源view
@property (nonatomic, strong) UIImage *placeholder;
@property (nonatomic, strong, readonly) UIImage *capture;

@property (nonatomic, assign) BOOL firstShow;

// 是否已经保存到相册
@property (nonatomic, assign) BOOL save;
@property (nonatomic, assign) int index; // 索引
@property (nonatomic)float y;
// 图片描述
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *type; //new新房 ，second 二手房
@end
