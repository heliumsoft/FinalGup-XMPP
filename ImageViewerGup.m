//
//  ImageViewerGup.m
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 2/28/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "ImageViewerGup.h"

@implementation ImageViewerGup
@synthesize ImagePan,activeIndicator,dataSource,delegate,EnableRotation,EnabledTapGeture,EnablePinchGesture,EnablePan;
- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setFrame:frame];

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (void)setDataSource:(id<imageViewDataSource>)_dataSource{
    
if (dataSource != _dataSource){
    dataSource = _dataSource;
    if (dataSource){
        [dataSource ImageViewerWillAppear:self];
        UIImageView *BACKGROU=[dataSource imageViewBackground:self];
        if (BACKGROU!=Nil)
            [self sendSubviewToBack:BACKGROU ];
        else
            [self setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.9]];
        [dataSource ImageViewerDidAppear:self];
        activeIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        ImagePan=[dataSource ImageOfImageViewer:self];//WithFrame:self.frame];
        
        NSLog(@"width =%f  height =%f",ImagePan.image.size.width ,ImagePan.image.size.height);
        [ImagePan setFrame:CGRectMake(0, 0, ImagePan.image.size.width<self.frame.size.width?ImagePan.image.size.width:self.frame.size.width, ImagePan.image.size.height<self.frame.size.height?ImagePan.image.size.height:self.frame.size.height)];
        [ImagePan setCenter:CGPointMake(self.frame.size.width/2 ,self.frame.size.height/2)];
        [ImagePan addSubview:activeIndicator];
        [activeIndicator setCenter:ImagePan.center];
        [self addSubview:ImagePan ];
        if (EnableRotation){
            
            UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateImage:)];
            [self addGestureRecognizer:rotationGesture];
        }
        if (EnablePinchGesture){
            UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleImage:)];
            [self addGestureRecognizer:pinchGesture];
        }
        if (EnabledTapGeture){
            
            singleTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageTapped:)];
            [singleTapRecognizer setNumberOfTapsRequired:1];
            [self addGestureRecognizer:singleTapRecognizer  ];
            doubleTapRecognizer=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resetImage:)];
            [doubleTapRecognizer setNumberOfTapsRequired:2];
            [self addGestureRecognizer:doubleTapRecognizer];
            [singleTapRecognizer requireGestureRecognizerToFail: doubleTapRecognizer];
        }
        if (EnablePan) {
            UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveImage:)];
            [panGesture setMinimumNumberOfTouches:1];
            [panGesture setMaximumNumberOfTouches:1];
            [self addGestureRecognizer:panGesture];
        }
        
    }
}
    
    
}
-(void)setDelegate:(id<imageViewDelegate>)_delegate
{if (delegate != _delegate)
{
    delegate = _delegate;
    if (delegate)
    {
        //[delegate ]
    }
}
    
}
-(void)LoadImage:(NSString*)imageName
{ [activeIndicator startAnimating];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://hotlunchapp.com//BartenderLocator/upload/images/product/%@",imageName]]];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [activeIndicator stopAnimating];
            [activeIndicator removeFromSuperview];
            NSLog(@"data %@",imgData);
            UIImage *downloadImage=[UIImage imageWithData:imgData];
            //[ImagePan setFrame:CGRectMake(0, 0, downloadImage.size.width, downloadImage.size.height)];
            //  [ImagePan setCenter:self.center];
            [ImagePan setImage:downloadImage] ;
            ImagePan.contentMode=UIViewContentModeScaleAspectFit;
        });
        
    });
    
    
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    // Drawing code
    // NSString *ImagePath = [NSString stringWithFormat:@"%@/%@",ImageUrl, ImageName];
    
    
}
- (IBAction)imageTapped:(id)sender {
    
    NSLog(@"Image Tapped.");
    
    //On tap, fade out viewController like the twitter.app
    //[self.navigationController popViewControllerAnimated:YES];
    [self removeFromSuperview];
    [delegate ImageViewerDidEnd:self];
}

- (IBAction)imageDoubleTapped:(id)sender {
    
    NSLog(@"Image Double Tapped.");
    ImagePan.contentMode=UIViewContentModeScaleAspectFit;
    //On double tap zoom into imageView to fill in the screen.
    // [mainScroll setContentMode:UIViewContentModeScaleAspectFill];
    //    CGAffineTransform transform = CGAffineTransformMakeScale(2, 2);
    //  mainScroll.transform = transform;
    //pinchRecognizer.scale = 1;
    
}
- (void)rotateImage:(UIRotationGestureRecognizer *)recognizer
{
    
	if([recognizer state] == UIGestureRecognizerStateEnded) {
        
		previousRotation = 0.0;
		return;
	}
    
	CGFloat newRotation = 0.0 - (previousRotation - [recognizer rotation]);
    
	CGAffineTransform currentTransformation = ImagePan.transform;
	CGAffineTransform newTransform = CGAffineTransformRotate(currentTransformation, newRotation);
    
    ImagePan.transform = newTransform;
    
	previousRotation = [recognizer rotation];
}

- (void)scaleImage:(UIPinchGestureRecognizer *)recognizer
{
    
//	if([recognizer state] == UIGestureRecognizerStateEnded) {
//        
//		previousScale = 1.0;
//		return;
//	}
//    
//	CGFloat newScale = 1.0 - (previousScale - [recognizer scale]);
//    
//	CGAffineTransform currentTransformation = ImagePan.transform;
//	CGAffineTransform newTransform = CGAffineTransformScale(currentTransformation, newScale, newScale);
//    
//    ImagePan.transform = newTransform;
//    
//	previousScale = [recognizer scale];
    
    if([recognizer state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        previousScale = 1.0;
        return;
    }
    
    if ([recognizer state] == UIGestureRecognizerStateBegan ||
        [recognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[ImagePan.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 5.0;
        const CGFloat kMinScale = 1.0;
        
        CGFloat newScale = 1 -  (previousScale - [recognizer scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform currentTransformation = ImagePan.transform;
        CGAffineTransform transform = CGAffineTransformScale(currentTransformation, newScale, newScale);
        ImagePan.transform = transform;
        
        previousScale = [recognizer scale];  // Store the previous scale factor for the next pinch gesture call
    }

}

- (void)resetImage:(UITapGestureRecognizer *)recognizer
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    
    ImagePan.transform = CGAffineTransformIdentity;
    
    [ImagePan setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    
    [UIView commitAnimations];
}

- (void)moveImage:(UIPanGestureRecognizer *)recognizer
{
    CGPoint newCenter = [recognizer translationInView:self];
    
	if([recognizer state] == UIGestureRecognizerStateBegan) {
        
		beginX = ImagePan.center.x;
		beginY = ImagePan.center.y;
	}
    
	newCenter = CGPointMake(beginX + newCenter.x, beginY + newCenter.y);
    
	[ImagePan setCenter:newCenter];
    
}


@end
