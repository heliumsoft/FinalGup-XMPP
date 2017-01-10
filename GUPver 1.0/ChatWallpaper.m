//
//  ChatWallpaper.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/6/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "ChatWallpaper.h"
#import "ChooseWallpaper.h"
#import "DatabaseManager.h"

@interface ChatWallpaper ()

@end

@implementation ChatWallpaper

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"Chat Wallpaper";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    
    
}
#pragma mark Table View Data Source Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"Choose Wallpaper";
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];                }
                    break;
              
            }
            
            break;
        case 1:
            switch(indexPath.row) {
                case 0:
                {
                    cell.textLabel.text = @"Photo Gallery";
                    cell.textLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:17.f];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];                }
                    break;
              
            }
            break;
        default:
            break;
    }
    
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    switch (indexPath.section) {
        case 0:
            switch(indexPath.row) {
                case 0:
                {
                    ChooseWallpaper *chooseWallpaper = [[ChooseWallpaper alloc]init];
                    [self.navigationController pushViewController:chooseWallpaper animated:YES];

                }
                    break;
                    
            }
            
            break;
        case 1:
            switch(indexPath.row) {
                case 0:
                {
                    iPicker = [[UIImagePickerController alloc] init];
                    [iPicker setDelegate:self];
                    iPicker.allowsEditing = YES;
                    iPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    [iPicker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
                    [self presentViewController:iPicker animated:YES completion:NULL];
                   
                }
                    break;
                    
            }
            break;
        default:
            break;
    }

}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenWallpaper=[[UIImage alloc]init];
    chosenWallpaper= info[UIImagePickerControllerEditedImage];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *chatWallpaperPath = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",@"wallpaper.jpg"]];
    NSData *imageData=UIImageJPEGRepresentation(chosenWallpaper,1);
    [imageData writeToFile:chatWallpaperPath atomically:YES];
    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:[NSString stringWithFormat:@"UPDATE master_table SET chat_wall_paper='%@' WHERE id=1 ",@"wallpaper.jpg" ]];
    [iPicker dismissViewControllerAnimated:YES completion:NULL];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:@"Wallpaper has been set."   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    
    NSLog(@"imagePickerDidCancel");
    [iPicker dismissViewControllerAnimated:YES completion:NULL];
    
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
