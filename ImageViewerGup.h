//
//  ImageViewerGup.h
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 2/28/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol imageViewDataSource, imageViewDelegate;
@interface ImageViewerGup : UIView<UIGestureRecognizerDelegate>
{
    // id<imageViewDelegate> delegate;
    //   id<imageViewDataSource> dataSource;
    
    CGFloat previousScale;
    CGFloat previousRotation;
    
    CGFloat beginX;
    CGFloat beginY;
    UITapGestureRecognizer *singleTapRecognizer,*doubleTapRecognizer;
    
}
@property (nonatomic,assign) NSInteger section;
@property (strong, nonatomic,readonly) UIImageView *ImagePan;
@property(strong,nonatomic,readonly)UIActivityIndicatorView *activeIndicator;
//@property (strong, nonatomic) NSString *ImageName;
@property (nonatomic, assign) BOOL EnabledTapGeture;
@property(nonatomic,assign)BOOL EnablePinchGesture;
@property(nonatomic,assign)BOOL EnableRotation;
@property(nonatomic,assign)BOOL EnablePan;
@property(nonatomic,assign)BOOL hideActivityIndicator;

@property (nonatomic, strong)  id<imageViewDataSource> dataSource;
@property (nonatomic, strong)  id<imageViewDelegate> delegate;
- (IBAction)imageTapped:(id)sender;
- (IBAction)imageDoubleTapped:(id)sender;
-(void)LoadImage:(NSString*)imageName;
@end
@protocol imageViewDataSource <NSObject>

- (UIImageView*)ImageOfImageViewer:(ImageViewerGup *)imageView;
-(UIImageView*)imageViewBackground:(ImageViewerGup*)imageView;
-(void)ImageViewerWillAppear:(ImageViewerGup*)imageView;
-(void)ImageViewerDidAppear:(ImageViewerGup*)imageView;

@end

@protocol imageViewDelegate <NSObject>

-(void)ImageViewerDidEnd:(ImageViewerGup*)imageView;
-(void)ImageViewerZoomInStarted:(ImageViewerGup*)imageView;
-(void)ImageViewerZoomInStopped:(ImageViewerGup*)imageView;
-(void)ImageViewerZoomOutStarted:(ImageViewerGup*)imageView;
-(void)ImageViewerZoomOutStopped:(ImageViewerGup*)imageView;
-(void)ImageViewerClockWiseRotationStarted:(ImageViewerGup*)imageView;
-(void)ImageViewerClockWiseRotationStopped:(ImageViewerGup*)imageView;
-(void)ImageViewerAntiClockWiseRotationStarted:(ImageViewerGup*)imageView;
-(void)ImageViewerAntiClockWiseRotationStopped:(ImageViewerGup*)imageView;
@end
