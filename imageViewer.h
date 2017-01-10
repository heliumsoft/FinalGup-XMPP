//
//  imageView.h
//  chat
//
//  Created by Deepesh_Genora on 2/5/14.
//  Copyright (c) 2014 Deepesh_Genora. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol imageViewDataSource, imageViewDelegate;
@interface imageViewer : UIView<UIGestureRecognizerDelegate>
{
   // id<imageViewDelegate> delegate;
 //   id<imageViewDataSource> dataSource;

    CGFloat previousScale;
    CGFloat previousRotation;
    
    CGFloat beginX;
    CGFloat beginY;
    UITapGestureRecognizer *singleTapRecognizer,*doubleTapRecognizer;
    
}
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
- (IBAction)imageTapped:(id)sender ;
- (IBAction)imageDoubleTapped:(id)sender ;
-(void)LoadImage:(NSString*)imageName
;
@end
@protocol imageViewDataSource <NSObject>

- (UIImageView*)ImageOfImageViewer:(imageView *)imageView;
-(UIImageView*)imageViewBackground:(imageView*)imageView;
-(void)ImageViewerWillAppear:(imageView*)imageView;
-(void)ImageViewerDidAppear:(imageView*)imageView;

@end

@protocol imageViewDelegate <NSObject>

-(void)ImageViewerDidEnd:(imageView*)imageView;
-(void)ImageViewerZoomInStarted:(imageView*)imageView;
-(void)ImageViewerZoomInStopped:(imageView*)imageView;
-(void)ImageViewerZoomOutStarted:(imageView*)imageView;
-(void)ImageViewerZoomOutStopped:(imageView*)imageView;
-(void)ImageViewerClockWiseRotationStarted:(imageView*)imageView;
-(void)ImageViewerClockWiseRotationStopped:(imageView*)imageView;
-(void)ImageViewerAntiClockWiseRotationStarted:(imageView*)imageView;
-(void)ImageViewerAntiClockWiseRotationStopped:(imageView*)imageView;
@end
