//
//  ChooseWallpaper.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/21/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ChooseWallpaper.h"
#import "DatabaseManager.h"

@interface ChooseWallpaper ()

@end

@implementation ChooseWallpaper

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Choose Wallpaper";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    wallPapers=[[NSArray alloc]initWithObjects:@"default_bg",@"wallpaper1",@"wallpaper2",@"wallpaper3",@"wallpaper4",@"wallpaper5",@"wallpaper6",@"wallpaper7",@"wallpaper8",@"wallpaper9",@"wallpaper10",@"wallpaper11", nil];
    [wallpaperGallery registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
    [wallpaperGallery setScrollEnabled: TRUE];
    [wallpaperGallery setFrame:CGRectMake(15,0,self.view.frame.size.width-30, self.view.frame.size.height)];
}

#pragma mark - UICollectionView Datasource

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    //NSString *searchTerm = self.searches[section];
    //return [self.searchResults[searchTerm] count];
    return wallPapers.count;
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    //return [self.searches count];
    return 1;
}
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(90, 90);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
  
    static NSString *identifier = @"Cell";
  
    UICollectionViewCell *cell = [wallpaperGallery dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:wallPapers[indexPath.row]]];
    cell.layer.borderWidth = 1.0;
    if (indexPath.row == 0) {
        cell.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else
    {
        cell.layer.borderColor = [UIColor colorWithRed:135/255.0 green:206/255.0 blue:250/255.0 alpha:1].CGColor;
    }

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake(360, 20);
}


#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
   NSLog(@"selected image name %@",wallPapers[indexPath.row]);
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *chatWallpaperPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",@"wallpaper.jpg"]];
    UIImage *image=[UIImage imageNamed:wallPapers[indexPath.row]];
    NSData *imageData=UIImageJPEGRepresentation(image,1);
    [imageData writeToFile:chatWallpaperPath atomically:YES];
    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"UPDATE master_table SET chat_wall_paper='%@' WHERE id=1 ",@"wallpaper.jpg" ]];
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Wallpaper has been set."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
