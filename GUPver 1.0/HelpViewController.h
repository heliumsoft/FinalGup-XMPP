//
//  HelpViewController.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/18/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HelpViewController : UIViewController<UIScrollViewDelegate>
{
  //  IBOutlet UIView *subView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet UIPageControl *pageControl;
    BOOL pageControlBeingUsed;
    NSArray *images,*details,*heading;
    int lastSlide;
    IBOutlet UIButton *button;
    
}
- (IBAction)changePage;
-(IBAction)buttonAction:(id)sender;

@end
