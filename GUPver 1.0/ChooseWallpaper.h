//
//  ChooseWallpaper.h
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/21/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChooseWallpaper : UIViewController<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    IBOutlet UICollectionView *wallpaperGallery;
    NSArray *wallPapers;
}

@end
