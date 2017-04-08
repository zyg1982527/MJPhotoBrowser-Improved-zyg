//
//  MJPhotoToolbar.m
//  FingerNews
//
//  Created by mj on 13-9-24.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MJPhotoToolbar.h"
#import "MJPhoto.h"
#import "MBProgressHUD+Add.h"
#import "iToast.h"
#import "CONST.h"

@interface MJPhotoToolbar()
{
    // 显示页码
    UILabel *_indexLabel;
    UILabel *_descLabel;
    UIButton *_saveImageBtn;
    UIScrollView *_myScroll;
    NSMutableArray *typeBarList;
    id<MJPhotoToolbarDelegate> photoToolBarDelegate;
    BOOL isfirst;
}
@end

@implementation MJPhotoToolbar
@synthesize desc;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setPhotos:(NSArray *)photos
{
    isfirst=YES;
    _photos = photos;
    typeBarList=[[NSMutableArray alloc]init];
    NSMutableArray *paramList=[[NSMutableArray alloc]initWithObjects:@"厅",@"卧室",@"室内图", @"户型", @"厨房", @"卫生间", @"小区",  nil];
    NSMutableArray *list1=[[NSMutableArray alloc]init];
    NSMutableArray *list2=[[NSMutableArray alloc]init];
    NSMutableArray *list3=[[NSMutableArray alloc]init];
    NSMutableArray *list4=[[NSMutableArray alloc]init];
    NSMutableArray *list5=[[NSMutableArray alloc]init];
    NSMutableArray *list6=[[NSMutableArray alloc]init];
    NSMutableArray *list7=[[NSMutableArray alloc]init];
    NSMutableArray *houseList=[[NSMutableArray alloc]initWithObjects:list1,list2,list3,list4,list5,list6,list7, nil];
    
    BOOL issecondhouse=NO; //是否是二手房
    
    if(_photos.count > 0){
        for(int i=0;i<_photos.count;i++){
            MJPhoto *photo = [_photos objectAtIndex:i];
            NSMutableDictionary *dic=photo.detailProductInfo;
            NSString *tag=[dic objectForKey:@"tag"];
            NSString *type=photo.type;
            if([type isEqualToString:@"second"]){
                issecondhouse=YES;
            }
            for(int j=0;j<paramList.count;j++){
                NSString *tag1=[paramList objectAtIndex:j];
                if([tag isEqualToString:tag1]){
                    NSMutableArray *list=[houseList objectAtIndex:j];
                    [list addObject:dic];
                }
            }
        }
    }
    
    _myScroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    _myScroll.delegate=self;
    [self addSubview:_myScroll];
    
    float width=0;
    for(int i=0;i<houseList.count;i++){
        NSMutableArray *list=[houseList objectAtIndex:i];
        if(list.count>0){
            NSString *name=[paramList objectAtIndex:i];
            UILabel *nameL=[[UILabel alloc]initWithFrame:CGRectMake(width, 0, 60, 30)];
            nameL.text=[NSString stringWithFormat:@"%@(%ld)",name,list.count];
            nameL.backgroundColor=[UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:100];
            nameL.alpha=1;
            nameL.textColor=[UIColor colorWithRed:167/255.0 green:167/255.0 blue:167/255.0 alpha:100];
            nameL.font=[UIFont systemFontOfSize:12];
            nameL.textAlignment=1;
            nameL.layer.cornerRadius=2;
            nameL.layer.masksToBounds=YES;
            [_myScroll addSubview:nameL];
            width=width+70;
            
            UIButton *nameBtn=[[UIButton alloc]initWithFrame:nameL.frame];
            [nameBtn addTarget:self action:@selector(gotoTag:) forControlEvents:UIControlEventTouchUpInside];
            nameBtn.tag=typeBarList.count;
            [_myScroll addSubview:nameBtn];
            
            [typeBarList addObject:nameL];
        }
    }
    
    _myScroll.frame=CGRectMake(15, 0, SCREEN_WIDTH, 30);
    
    
    if (_photos.count > 1) {
        _indexLabel = [[UILabel alloc] init];
        _indexLabel.font = [UIFont boldSystemFontOfSize:20];
        _indexLabel.frame = self.bounds;
        _indexLabel.backgroundColor = [UIColor clearColor];
        _indexLabel.textColor = [UIColor whiteColor];
        _indexLabel.textAlignment = NSTextAlignmentCenter;
        _indexLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_indexLabel];
    }
    
    if(desc.length>0){
        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont boldSystemFontOfSize:20];
        _descLabel.frame = CGRectMake(0, self.bounds.origin.y, SCREEN_WIDTH, self.bounds.size.height);
        _descLabel.backgroundColor = [UIColor clearColor];
        _descLabel.textColor = [UIColor whiteColor];
        _descLabel.textAlignment = 2;
        _descLabel.text=desc;
        _descLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self addSubview:_descLabel];
    }
    
    // 保存图片按钮
    CGFloat btnWidth = self.bounds.size.height;
    _saveImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _saveImageBtn.frame = CGRectMake(20, 0, btnWidth, btnWidth);
    _saveImageBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon.png"] forState:UIControlStateNormal];
    [_saveImageBtn setImage:[UIImage imageNamed:@"MJPhotoBrowser.bundle/save_icon_highlighted.png"] forState:UIControlStateHighlighted];
    [_saveImageBtn addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_saveImageBtn];
    
    if(issecondhouse){
        _indexLabel.hidden=YES;
        _descLabel.hidden=YES;
        _saveImageBtn.hidden=YES;
    }
}

-(IBAction)gotoTag:(id)sender{
    return;
    isfirst=YES;
    UIButton *btn=sender;
    int tag=btn.tag;
    UILabel *nameL=[typeBarList objectAtIndex:tag];
    NSString *tag1=nameL.text;
    for(int i=0;i<_photos.count;i++){
        MJPhoto *photo = [_photos objectAtIndex:i];
        NSMutableDictionary *dic=photo.detailProductInfo;
        NSString *tag=[dic objectForKey:@"tag"];
        if([tag1 rangeOfString:tag].location!=NSNotFound){
            [self setCurrentPhotoIndex:i];
            
            NSMutableDictionary *notificationData1=[[NSMutableDictionary alloc]initWithCapacity:0];
            [notificationData1 setObject:photo forKey:@"photo"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"setPhoto1" object:notificationData1];
            
            return;
            
        }
    }
    
}

- (void)saveImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MJPhoto *photo = _photos[_currentPhotoIndex];
        UIImageWriteToSavedPhotosAlbum(photo.image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    });

}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        [[iToast makeText:@"保存失败"]show];
    } else {
        MJPhoto *photo = _photos[_currentPhotoIndex];
        photo.save = YES;
        _saveImageBtn.enabled = NO;
        [[iToast makeText:@"成功保存到相册"]show];
    }
}

- (void)setCurrentPhotoIndex:(NSUInteger)currentPhotoIndex
{
    if(isfirst){
        isfirst=NO;
    }else{
        if(currentPhotoIndex==0){
//            return;
        }
    }
    _currentPhotoIndex = currentPhotoIndex;
    
    // 更新页码
    _indexLabel.text = [NSString stringWithFormat:@"%d / %d", _currentPhotoIndex + 1, _photos.count];
    _descLabel.text = [NSString stringWithFormat:@"%@", desc];
    
    MJPhoto *photo = _photos[_currentPhotoIndex];
    NSMutableDictionary *dic=photo.detailProductInfo;
    // 按钮
    _saveImageBtn.enabled = photo.image != nil && !photo.save;
    
    NSString *tag=[dic objectForKey:@"tag"];
    
    
    //对应的类型高亮
    for(int i=0;i<typeBarList.count;i++){
        UILabel *nameL=[typeBarList objectAtIndex:i];
        nameL.textColor=[UIColor colorWithRed:167/255.0 green:167/255.0 blue:167/255.0 alpha:100];
        NSString *tag1=nameL.text;
        if([tag1 rangeOfString:tag].location!=NSNotFound){
            nameL.textColor=WHITEBACKCOLOR;
            float x=nameL.frame.origin.x;
            if((x+70)>SCREEN_WIDTH){
                [_myScroll setContentOffset:CGPointMake(x+80-SCREEN_WIDTH,0) animated:NO];
            }
            if(x<100){
                [_myScroll setContentOffset:CGPointMake(0,0) animated:NO];
            }
        }
        
    }
    
    // 通知代理
//    if ([self.photoToolBarDelegate respondsToSelector:@selector(setPhoto1:)]) {
//        [self.photoToolBarDelegate setPhoto1:photo];
//    }
//    
    
}

@end
