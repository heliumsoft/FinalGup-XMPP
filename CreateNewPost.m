//
//  CreateNewPost.m
//  GUP
//
//  Created by Ram Krishna on 13/12/14.
//  Copyright (c) 2014 genora. All rights reserved.
//

#import "CreateNewPost.h"
#import "CTAssetsPickerController.h"
#import "CTAssetsPageViewController.h"
#import "JSON.h"
#import "AppDelegate.h"
#import "DatabaseManager.h"
#import "AFNetworking.h"

@interface CreateNewPost ()<CTAssetsPickerControllerDelegate, UIPopoverControllerDelegate>{
    UIImagePickerController *imagePicker;
    NSString *val;
    XMPPRoom *xmppRoom;
}
@property (nonatomic, copy) NSArray *assets;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong)UIScrollView *picScrollView;
@property (nonatomic, strong)UIButton *postButton;

@end

@implementation CreateNewPost

- (AppDelegate *)appDelegate

{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

-(void)getProfileData
{
    DatabaseManager *getProfile;   //Get Profile Data From DATABASEMANAGER
    getProfile = [[DatabaseManager alloc] init];
    getData = [[NSMutableArray alloc]init];
    getData=[getProfile getProfileData];
    NSLog(@"profile data: %@",getData);
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title=@"New Topic";
    CGRect frame = self.view.frame;
    frame.size.width = [[UIScreen mainScreen] bounds].size.width;
    frame.size.height = [[UIScreen mainScreen] bounds].size.height;
    self.view.frame = frame;
    UIBarButtonItem *uploadImage = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(addImage)];
    self.navigationItem.rightBarButtonItem = uploadImage;
    
    bgView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width-20, self.view.bounds.size.height-90)];
    bgView.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:248.0/255.0 blue:247.0/255.0 alpha:1];
    bgView.layer.borderColor = [UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1].CGColor;
    bgView.layer.borderWidth = 0.5f;
    bgView.layer.cornerRadius = 5;
    bgView.clearsContextBeforeDrawing = NO;
    [self.view addSubview:bgView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];

    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(60, 10, self.view.bounds.size.width-100, 50)];
    //textView.layer.borderWidth = 1.0f;
    //textView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    textView.text = @"Type your message....";
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont fontWithName:@"Dosis-Regular" size:12];
    textView.textColor = [UIColor colorWithRed:58/255.0 green:56.0/255.0 blue:48.0/255.0 alpha:1];
    textView.delegate=self;
    
    userIcon =[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 40, 40)];
    userIcon.layer.cornerRadius = 20;
    userIcon.clipsToBounds = YES;
    [bgView addSubview:userIcon];
    
    [bgView addSubview:textView];
    self.picScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(10, textView.frame.origin.y+textView.frame.size.height+20, bgView.frame.size.width-20, bgView.frame.size.width-20)];
    self.picScrollView.showsVerticalScrollIndicator=YES;
    self.picScrollView.scrollEnabled=YES;
    //self.picScrollView.contentSize = CGSizeMake(scrollView.frame.size.width * 3, scrollView.frame.size.height);
    self.picScrollView.delegate = self;
    self.picScrollView.userInteractionEnabled=YES;
    self.picScrollView.userInteractionEnabled= YES;
    [bgView addSubview:self.picScrollView];
    
//    
//    post_image = [[UIImageView alloc] init];
//    post_image.backgroundColor = [UIColor clearColor];
//    post_image.opaque = YES;
//    post_image.clearsContextBeforeDrawing = NO;
//    post_image.userInteractionEnabled = YES;
//    [bgView addSubview:post_image];
    
     page = [[UIPageControl alloc] initWithFrame:CGRectMake(0, textView.frame.origin.y+textView.frame.size.height+20+self.picScrollView.frame.size.height+20, self.picScrollView.frame.size.width, 20)];
    page.backgroundColor = [UIColor clearColor];
    page.pageIndicatorTintColor = [UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1];
    page.numberOfPages = 0;
    [page addTarget:self action:@selector(changePage) forControlEvents:UIControlEventValueChanged];
    [bgView addSubview:page];
    
//    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSweepAction:)];
//    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    [post_image addGestureRecognizer:leftSwipe];
//    
//    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(rightSweepAction:)];
//    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//    [post_image addGestureRecognizer:rightSwipe];
    
    menuView = [[UIView alloc] initWithFrame:CGRectMake(11, bgView.frame.size.height-31, bgView.frame.size.width-2, 40)];
    menuView.backgroundColor = [UIColor whiteColor];
    menuView.clearsContextBeforeDrawing = NO;
    menuView.layer.cornerRadius =3.0;
    [self.view addSubview:menuView];
    
    cameraButton = [[UIButton alloc] initWithFrame: CGRectMake(15, 5, 30.0f, 30.0f)];
    [cameraButton setImage:[UIImage imageNamed:@"camera"] forState:UIControlStateNormal];
    [cameraButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
    [menuView addSubview:cameraButton];
    
    _postButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 0, 60.0f, 30.0f)];
    [_postButton setTitle:@"Post" forState:UIControlStateNormal];
    [_postButton setTitleColor:[UIColor colorWithRed:255.0/255.0 green:207.0/255.0 blue:13.0/255.0 alpha:1] forState:UIControlStateNormal];
    [_postButton addTarget:self action:@selector(submitPost) forControlEvents:UIControlEventTouchUpInside];
    _postButton.titleLabel.font = [UIFont fontWithName:@"Dosis-Bold" size:20];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_postButton];
    
    imageArray = [NSMutableArray array];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tap];
    
    imagePicker = [[UIImagePickerController alloc]init];
    imagePicker.delegate = self;
//    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.allowsEditing = NO;
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(streamDisconnected) name:@"streamDisconnect" object:nil];
    
    [self getProfileData];
    // CODE TO RETRIEVE IMAGE FROM THE DOCUMENT DIRECTORY
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *imgPathRetrieve = [[paths objectAtIndex:0]stringByAppendingString:[NSString stringWithFormat:@"/%@",getData[4]]];
    NSLog(@"imgPath_retrieve = %@",imgPathRetrieve);
    NSData *pngData = [NSData dataWithContentsOfFile:imgPathRetrieve];
    UIImage *profilePic = [UIImage imageWithData:pngData];
    if (profilePic) {
        userIcon.image=profilePic;
    }
    else
    {
        userIcon.image=[UIImage imageNamed:@"defaultProfile"];
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.tabBarController.tabBar.hidden = YES;
}

-(void)viewDidAppear:(BOOL)animated{
    
    
}
- (void)changePage {
    CGFloat x = page.currentPage * self.picScrollView.frame.size.width;
    [self.picScrollView setContentOffset:CGPointMake(x, 0) animated:YES];
}
-(void)leftSweepAction:(UIGestureRecognizer*)gesture{
    
    
}

-(void)rightSweepAction:(UIGestureRecognizer*)gesture{
  
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
   
    if(scrollView == self.picScrollView){
//        NSInteger pageNumber = roundf(scrollView.contentOffset.x / (scrollView.frame.size.width));
//        page.currentPage = pageNumber;
        CGFloat pageWidth = self.picScrollView.frame.size.width;
        float fractionalPage = self.picScrollView.contentOffset.x / pageWidth;
        NSInteger pagen = lround(fractionalPage);
        page.currentPage = pagen;
    }
}
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView  {
    
   
}
-(void)viewWillDisappear:(BOOL)animated{
    
    self.tabBarController.tabBar.hidden = NO;
}


-(void)hideKeyBoard{
    [textView resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Delete Image Selection
-(void)deleteImage:(UIButton*)sender{
    [imageArray removeObjectAtIndex:sender.tag];
    for (UIImageView *imageView in self.picScrollView.subviews) {
        [imageView removeFromSuperview];
    }
    int i=0;
    page.numberOfPages = imageArray.count;
    for (UIImage *eachImage in imageArray) {
        
        UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(i* bgView.frame.size.width-20, 10,  bgView.frame.size.width-20, bgView.frame.size.width-20)];
       
        picImage.image = eachImage;
        picImage.userInteractionEnabled=YES;
        picImage.contentMode = UIViewContentModeScaleAspectFill;
        picImage.clipsToBounds = YES;
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake( bgView.frame.size.width-50, 5, 25, 25)];
        cancelButton.tag=i;
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"imgDelete"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [picImage addSubview:cancelButton];
        [self.picScrollView addSubview:picImage];
        self.picScrollView.contentSize = CGSizeMake((i+1)* bgView.frame.size.width, self.picScrollView.contentSize.height);
        i++;
    }
    
    if(imageArray.count>0)
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30+bgView.frame.size.width-20);
    else
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30);
}

- (void) keyboardWillShow:(NSNotification *)notification {
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    NSLog(@"hei %f wi %f",kbSize.height,kbSize.width);
    float keyBdHeight;
    if (kbSize.height<kbSize.width){
        
        keyBdHeight=kbSize.height;
        
    }else{
        keyBdHeight=kbSize.width;
    }
    
    
    bgView.frame = CGRectMake(10, 10, self.view.bounds.size.width-20, self.view.bounds.size.height-keyBdHeight);
    
    menuView.frame = CGRectMake(11, bgView.frame.size.height-40, bgView.frame.size.width-2, 40);
    
    
    
}

- (void)textViewDidBeginEditing:(UITextView *)textViews{
    if([textView.text isEqualToString:@"Type your message...."])
        textView.text =@"";
}
- (void)textViewDidEndEditing:(UITextView *)textViews{
    if(textView.text.length==0)
        textView.text =@"Type your message....";
}
- (void) keyboardWillHide:(NSNotification *)notification {
   
    bgView.frame = CGRectMake(10, 10, self.view.bounds.size.width-20, self.view.bounds.size.height-30);
    
    menuView.frame = CGRectMake(11, bgView.frame.size.height-31, bgView.frame.size.width-2, 40);
    
}
- (void)addImage{
    [self.view endEditing:YES];
    UIActionSheet *imgUpload = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Open Gallery", nil];
    
    [imgUpload showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
        case 0:
            [self performSelector:@selector(openCamera) withObject:nil afterDelay:0.3];
            break;
        case 1:
            [self pickAssets];
            break;
            
        default:
            break;
    }
}


-(void)openCamera{
    if (imageArray.count<5) {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            imagePicker = nil;
            if (!imagePicker) {
                imagePicker = [[UIImagePickerController alloc]init];
                imagePicker.delegate = self;
                imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
                imagePicker.allowsEditing = NO;
            }
            [self presentViewController:imagePicker animated:YES completion:NULL];
        }
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Maximum Limit reached" message:@"You cannot select more than 5 images at a time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)pickAssets{
    
    if (imageArray.count<5) {
        ELCImagePickerController *elcPicker = [[ELCImagePickerController alloc] initImagePicker];
        elcPicker.maximumImagesCount = 5-imageArray.count; //Set the maximum number of images to select, defaults to 4
        elcPicker.returnsOriginalImage = NO; //Only return the fullScreenImage, not the fullResolutionImage
        elcPicker.returnsImage = YES; //Return UIimage if YES. If NO, only return asset location information
        elcPicker.onOrder = YES; //For multiple image selection, display and return selected order of images
        elcPicker.imagePickerDelegate = self;
        
        //Present modally
        [self presentViewController:elcPicker animated:YES completion:nil];
        
    }else{
        [[[UIAlertView alloc] initWithTitle:@"Maximum Limit reached" message:@"You cannot select more than 5 images at a time." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil] show];
    }
}

- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info{
    int i=0;
    if (imageArray.count>0) {
        i=imageArray.count;
    }
    page.numberOfPages = info.count;
    
//    int ind = [[data objectForKey:@"index"] integerValue];
//    NSString *postImagePath ;
//    if(ind == 0)
//        postImagePath = [[data objectForKey:[NSString stringWithFormat:@"image_1"]] objectForKey:@"image_url"];
//    else
//        postImagePath = [[data objectForKey:[NSString stringWithFormat:@"image_%d",ind]] objectForKey:@"image_url"];
//    
    
    for (NSDictionary *eachInfo in info) {
        UIImageView *picImage = [[UIImageView alloc] initWithFrame:CGRectMake(i* bgView.frame.size.width-20, 10,  bgView.frame.size.width-20, bgView.frame.size.width-20)];
        
        picImage.image = [eachInfo objectForKey:UIImagePickerControllerOriginalImage];
        picImage.userInteractionEnabled=YES;
        picImage.contentMode = UIViewContentModeScaleAspectFill;
        picImage.clipsToBounds = YES;
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake( bgView.frame.size.width-50, 5, 25, 25)];
        cancelButton.tag=i;
        [cancelButton setBackgroundImage:[UIImage imageNamed:@"imgDelete"] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(deleteImage:) forControlEvents:UIControlEventTouchUpInside];
        [picImage addSubview:cancelButton];
        [self.picScrollView addSubview:picImage];
        self.picScrollView.contentSize = CGSizeMake((i+1)* bgView.frame.size.width-20, self.picScrollView.contentSize.height);
        [imageArray addObject:[eachInfo objectForKey:UIImagePickerControllerOriginalImage]];
        i++;
    }
   
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30+bgView.frame.size.width-20);
  
    self.picScrollView.contentOffset = CGPointMake(10, 0);
    self.picScrollView.contentInset =UIEdgeInsetsMake(10, 20, 10,10);
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker{
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Popover Controller Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

- (void)textViewDidChange:(UITextView *)textViews{
    
    CGFloat fixedWidth = textView.frame.size.width;
    CGSize newSize = [textView sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
    /*if ((textView.frame.size.height<120.0f || newFrame.size.height<textView.frame.size.height) && (textView.frame.size.height>65.0f || newFrame.size.height>textView.frame.size.height)) {
        */
        textView.frame = newFrame;
        self.picScrollView.frame = CGRectMake(20, textView.frame.origin.y+textView.frame.size.height+20, self.view.bounds.size.width-40, 200);
    
    page.frame =CGRectMake(0, textView.frame.origin.y+textView.frame.size.height+20+self.picScrollView.frame.size.height+20, self.picScrollView.frame.size.width, 20);

   // }
    
    if(imageArray.count>0)
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30+bgView.frame.size.width-20);
    else
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30);
   
//    if(textViews.contentSize.height>140){
//        CGRect newFrame = textView.frame;
//        newFrame.size.height = 126.5f;
//        newFrame.size.width = textView.frame.size.width;
//        textView.frame = newFrame;
//        self.picScrollView.frame = CGRectMake(20, textView.frame.origin.y+textView.frame.size.height+20, self.view.bounds.size.width-40, 200);
//
//    }
   
}

- (BOOL)textView:(UITextView *)textView1 shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    CGFloat fixedWidth = textView1.frame.size.width;
    CGSize newSize = [textView1 sizeThatFits:CGSizeMake(fixedWidth, MAXFLOAT)];
    CGRect newFrame = textView1.frame;
    newFrame.size = CGSizeMake(fmaxf(newSize.width, fixedWidth), newSize.height);
//    if ((textView1.frame.size.height<120.0f || newFrame.size.height<textView.frame.size.height) && (textView.frame.size.height>65.0f || newFrame.size.height>textView.frame.size.height)) {
        textView1.frame = newFrame;
        self.picScrollView.frame = CGRectMake(20, textView1.frame.origin.y+textView1.frame.size.height+20, self.view.bounds.size.width-40, 90);
    
      page.frame =CGRectMake(0, textView.frame.origin.y+textView.frame.size.height+20+self.picScrollView.frame.size.height+20, self.picScrollView.frame.size.width, 20);
   // }
    
    if(imageArray.count>0)
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30+bgView.frame.size.width-20);
    else
        bgView.contentSize = CGSizeMake(bgView.frame.size.width, textView.frame.origin.y+textView.frame.size.height+30);
    return true;

}

-(void)submitPost{
    
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    
    NSString *postDesc= [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([postDesc isEqualToString:@""] && imageArray.count==0) {
        [HUD hide:YES];
        UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"" message:@"Please enter post decription."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [warningAlert show];
        
    }else{
    
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
        AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];

        NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
        [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
        [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        manager.responseSerializer = responseSerializer;
        manager.requestSerializer = requestSerializer;
        manager.requestSerializer.timeoutInterval = 60*4;
//        NSString* appUserId = [[DatabaseManager getSharedInstance]getAppUserID];
        NSMutableDictionary *mainDictonary = [NSMutableDictionary dictionary];
//        NSString *currentDataMiliSecend  = [[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
        
        NSDate *now = [NSDate date];
        NSTimeInterval seconds =  [now timeIntervalSince1970];
        double millisecends = seconds*1000;
        
        NSString *currentDataMiliSecend = [NSString stringWithFormat:@"%.0f",millisecends];
        int j = 1;
        for (UIImage *asset in imageArray){
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            NSData* imageData = UIImageJPEGRepresentation(asset, 0.9);
            NSString *imgname =[NSString stringWithFormat:@"a%d.jpg",j];
            [dic setValue:imgname forKey:@"name"];
            [dic setValue:@"image/png" forKey:@"type"];
            [dic setValue:[NSString stringWithFormat:@"tmp_name%i",j] forKey:@"tmp_name"];
            [dic setValue:@"0" forKey:@"error"];
            [dic setValue:[NSString stringWithFormat:@"%d",imageData.length] forKey:@"size"];
            [mainDictonary setObject:dic forKey:[NSString stringWithFormat:@"post_file%d",j]];
            j++;
            
        }
    NSString *goodValue1 = @" ";
    if(postDesc.length>0){
        goodValue1=[postDesc UTFEncoded];
        [mainDictonary setValue:[goodValue1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""] forKey:@"post_text"];
    }
        [mainDictonary setValue:self.groupID forKey:@"group_id"];
        [mainDictonary setValue:[self appDelegate].myUserID forKey:@"user_id"];
        [mainDictonary setValue:currentDataMiliSecend forKey:@"time"];
        [mainDictonary setValue:[NSString stringWithFormat:@"%d",[imageArray count]] forKey:@"post_file_count"];
    
        NSString *url =[NSString stringWithFormat:@"%@/scripts/post_entity.php",gupappUrl];
        [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:mainDictonary constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            int i=1;
            for (UIImage *asset in imageArray) {
                NSData* imageData = UIImageJPEGRepresentation(asset, 0.9);
                NSString *imgname =[NSString stringWithFormat:@"a%d.jpg",i];
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"post_file%d",i] fileName:imgname mimeType:@"image/jpg"];
                i++;
            }
            
        }  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSData * data = (NSData *)responseObject;
            NSError *error = nil;
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            NSLog(@"error %@",JSON);
            [HUD removeFromSuperview];

            int status = [[JSON objectForKey:@"status"] intValue];
            
            if (status == 1){
                
                [HUD hide:YES];
                UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"" message:[JSON objectForKey:@"error"]  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [failureAlert show];
                
            }else{
                
                NSString* appUserName = [[DatabaseManager getSharedInstance]getAppUserName];
                NSString* appUserImage = [[DatabaseManager getSharedInstance]getAppUserImage];
                NSArray *urls = [NSArray array];
                urls = [JSON objectForKey:@"urls"];
                
                NSLog(@"%@",currentDataMiliSecend);
                NSString *query=[NSString stringWithFormat:@"insert into Post (post_id, group_id, imageCount, description,user_id, user_name,user_image,created,updated,is_fav,total_likes,total_comments,is_like) values ('%@','%@',%d,'%@','%@','%@','%@','%@','%@',1,0,0,0)",[JSON objectForKey:@"post_id"],self.groupID,[urls count],[goodValue1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""],[self appDelegate].myUserID,appUserName,appUserImage,currentDataMiliSecend,currentDataMiliSecend];
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                for (NSDictionary *urlDic in urls) {
                    NSString *query=[NSString stringWithFormat:@"insert into PostImageUrl (post_id,image_url) values ('%@','%@')",[JSON objectForKey:@"post_id"],[urlDic objectForKey:@"icon_full_size_url"]];
                    NSLog(@"query %@",query);
                    [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
                }
                [self updateGroupTime:self.groupID];
                [self tellUserForNewPost:[[JSON objectForKey:@"post_id"] intValue]];
                [self.navigationController popViewControllerAnimated:YES];
//                [self createPostGroup:[JSON valueForKey:@"post_id"]];
            }
//            [HUD removeFromSuperview];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Unable to create posts at this time. Could not connect to the internet" message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
            [alert show];
            [HUD removeFromSuperview];
            
        }];
        
    }
    
}


-(void)updateGroupTime:(NSString*)groupId{
    
    NSArray *privateGroupList = [[DatabaseManager getSharedInstance]retrieveDataFromTableWithQuery:[NSString stringWithFormat:@"SELECT group_name FROM groups_private WHERE group_server_id = %@",groupId]];
     NSString *timeInMiliseconds =[[NSString getCurrentUTCFormateDate] getTimeIntervalFromUTCStringDate];
    if (privateGroupList.count) {
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_private SET updatetime=%@ WHERE group_server_id = %@",timeInMiliseconds,groupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }else{
        NSString *query2=[NSString stringWithFormat:@"UPDATE groups_public SET updatetime=%@ WHERE group_server_id = %@",timeInMiliseconds,groupId];
        [[DatabaseManager getSharedInstance]executeQueryWithQuery:query2];
    }
//    [_chatDelegate newGroupMessageRe];
}

-(void)tellUserForNewPost:(int)postid{
    
    XMPPMessage *msg = [XMPPMessage message];
    [msg addAttributeWithName:@"type" stringValue:@"groupchat"];
    [msg addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"group_%@@%@",self.groupID,groupJabberUrl]];
    [msg addAttributeWithName:@"from" stringValue:[NSString stringWithFormat:@"user_%@@%@",[self appDelegate].myUserID,jabberUrl]];
    NSXMLElement *subject = [NSXMLElement elementWithName:@"subject" stringValue:@"newpost"];
    
    NSXMLElement *body=[NSXMLElement elementWithName:@"body" stringValue:@"newpost"];
    
    NSXMLElement *gup=[NSXMLElement elementWithName:@"gup" xmlns:@"urn:xmpp:gupmessage"];
    NSXMLElement *notification = [NSXMLElement elementWithName:@"newpostnotification" stringValue:@"new Post"];
    NSXMLElement *post_id = [NSXMLElement elementWithName:@"postid" stringValue:[NSString stringWithFormat:@"%d",postid]];
    NSXMLElement *group_id = [NSXMLElement elementWithName:@"groupid" stringValue:[NSString stringWithFormat:@"%@",self.groupID]];
    NSXMLElement *group = [NSXMLElement elementWithName:@"groupname" stringValue:self.groupName];
    NSXMLElement *userid = [NSXMLElement elementWithName:@"userid" stringValue:[self appDelegate].myUserID];
   
    [gup addChild:notification];
    [gup addChild:post_id];
    [gup addChild:userid];
    [gup addChild:group];
    [gup addChild:group_id];
    
    [msg addChild:subject];
    [msg addChild:body];
    [msg addChild:gup];
    
    if ([self appDelegate].hasInet&&[[self appDelegate].xmppStream isDisconnected])
        [[self appDelegate] connect];
    
    [[self appDelegate].xmppStream sendElement:msg];

}

//-(void)createPostGroup:(NSString*)postId{
//
//    XMPPJID *roomJID = [XMPPJID jidWithString:[NSString stringWithFormat:@"post_%@@%@",postId,groupJabberUrl]];
//    XMPPRoomMemoryStorage *roomMemoryStorage = [[XMPPRoomMemoryStorage alloc] init];
//    xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:roomMemoryStorage
//                                                 jid:roomJID
//                                       dispatchQueue:dispatch_get_main_queue()];
//    
//    [xmppRoom activate:[self appDelegate].xmppStream];
//    [xmppRoom addDelegate:self delegateQueue:dispatch_get_main_queue()];
//
//    NSString *nickName = [NSString stringWithFormat:@"user_%@",[self appDelegate].myUserID];
//    [xmppRoom joinRoomUsingNickname:nickName history:nil];
//}


//-(NSXMLElement *)setConfig{
//    
//    NSXMLElement *x = [[NSXMLElement alloc] initWithName:@"x" xmlns:@"jabber:x:data"];
//    NSXMLElement *field = [[NSXMLElement alloc] initWithName:@"field"];
//    [field addAttributeWithName:@"var" stringValue:@"FORM_TYPE"];
//    NSXMLElement *value = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"http://jabber.org/protocol/muc#roomconfig"];
//    [field addChild:value];
//    
////    NSXMLElement *field1 = [[NSXMLElement alloc] initWithName:@"field"];
////    [field1 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomname"];
////    NSXMLElement *value1 = [[NSXMLElement alloc] initWithName:@"value" stringValue:groupName];
////    [field1 addChild:value1];
//    
//    NSXMLElement *field2 = [[NSXMLElement alloc] initWithName:@"field"];
//    [field2 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_membersonly"];
//    NSXMLElement *value2 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"0"];
//    [field2 addChild:value2];
//    
//    NSXMLElement *field3 = [[NSXMLElement alloc] initWithName:@"field"];
//    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
//    NSXMLElement *value3 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
//    [field3 addChild:value3];
//    
//    //    NSXMLElement *field3 = [[NSXMLElement alloc] initWithName:@"field"];
//    //    [field3 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_persistentroom"];
//    //    NSXMLElement *value3 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
//    //    [field3 addChild:value3];
//    
//    
//    NSXMLElement *fieldz = [[NSXMLElement alloc] initWithName:@"field"];
//    [fieldz addAttributeWithName:@"var" stringValue:@"muc#roomconfig_whois"];
//    NSXMLElement *valuez = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"anyone"];
//    [fieldz addChild:valuez];
//    
//    NSXMLElement *field4 = [[NSXMLElement alloc] initWithName:@"field"];
//    [field4 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_publicroom"];
//    
//    NSXMLElement *value4;
////    if([groupType isEqualToString:@"private"])
////        value4 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"0"];
////    else
//        value4 = [[NSXMLElement alloc] initWithName:@"value" stringValue:@"1"];
//    [field4 addChild:value4];
//    
//    NSXMLElement *field5 = [[NSXMLElement alloc] initWithName:@"field"];
//    [field5 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomadmins"];
//    NSXMLElement *value5 = [[NSXMLElement alloc] initWithName:@"value" stringValue:[self appDelegate].myjid];
//    [field5 addChild:value5];
//    
////    NSXMLElement *field6 = [[NSXMLElement alloc] initWithName:@"field"];
////    [field6 addAttributeWithName:@"label" stringValue:@"Short Description of Room"];
////    [field6 addAttributeWithName:@"type" stringValue:@"text-single"];
////    [field6 addAttributeWithName:@"var" stringValue:@"muc#roomconfig_roomdesc"];
////    NSXMLElement *value6 = [[NSXMLElement alloc] initWithName:@"value" stringValue:groupDesc];
////    [field6 addChild:value6];
//    
//    NSXMLElement *field7 = [[NSXMLElement alloc] initWithName:@"field"];
//    [field7 addAttributeWithName:@"label" stringValue:@"Allow Occupants to change nicknames"];
//    [field7 addAttributeWithName:@"var" stringValue:@"x-muc#roomconfig_canchangenick"];
//    NSXMLElement *value7 = [[NSXMLElement alloc] initWithName:@"value" stringValue:val];
//    [field7 addChild:value7];
//    
//    [x addChild:field];
////    [x addChild:field1];
//    [x addChild:field2];
//    [x addChild:field3];
//    //    [x addChild:field4];
//    //    [x addChild:fieldz];
//    //    [x addChild:field5];
////    [x addChild:field6];
//    [x addChild:field7];
//    return x;
//}

//- (void)xmppRoom:(XMPPRoom *)sender didFetchConfigurationForm:(NSXMLElement *)configForm{
//    
//    NSArray *fields = [configForm elementsForName:@"field"];
//    for (NSXMLElement *field in fields) {
//        if([[[field attributeForName:@"label"] stringValue] isEqualToString:@"Allow Occupants to change nicknames"]){
//            NSString *value = [[field elementForName:@"value"] stringValue];
//            if ([value intValue] == 1)
//                val = @"0";
//            else
//                val = @"1";
//            break;
//        }
//        
//    }
//    [sender configureRoomUsingOptions:[self setConfig] from:[self appDelegate].myjid];
//}

//- (void)xmppRoomDidCreate:(XMPPRoom *)sender{
//    
//    NSLog(@"xmppRoomDidCreate - group %@",sender);
//    [sender fetchConfigurationForm];
//    
//}

//- (void)xmppRoomDidJoin:(XMPPRoom *)sender{
//    NSLog(@"xmppRoomDidJoin - group %@",sender);
//}
//
//- (void)xmppRoom:(XMPPRoom *)sender didConfigure:(XMPPIQ *)iqResult{
//    NSLog(@"configer success");
//    [sender joinRoomUsingNickname:[[[self appDelegate].myjid componentsSeparatedByString:@"@"] firstObject] history:nil];
//    [HUD removeFromSuperview];
//    [self.navigationController popViewControllerAnimated:YES];
//
//}
//- (void)xmppRoom:(XMPPRoom *)sender didNotConfigure:(XMPPIQ *)iqResult{
//    NSLog(@"configer success fail");
//}

//-(void)streamDisconnected{
//    [HUD removeFromSuperview];
//    [self.navigationController popViewControllerAnimated:YES];
//}
@end