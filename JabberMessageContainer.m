//
//  JabberMessageContainer.m
//  GUPver 1.1
//
//  Created by Deepesh_Genora on 4/25/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "JabberMessageContainer.h"


@implementation JabberMessageContainer

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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
-(BOOL)canBecomeFirstResponder
{
    //[self.superview becomeFirstResponder];
    return NO;
}
/*
-(void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{NSLog(@"gesture %@",gestureRecognizer);
    //Prevent zooming but not panning
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]])
    {UILongPressGestureRecognizer *lg=(UILongPressGestureRecognizer*)gestureRecognizer;
    
        gestureRecognizer.enabled = NO;
    }
    [super addGestureRecognizer:gestureRecognizer];
    return;
}*/
@end
