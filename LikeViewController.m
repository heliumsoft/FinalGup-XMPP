//
//  LikeViewController.m
//  GUP
//
//  Created by Unicode Systems on 06/01/15.
//  Copyright (c) 2015 genora. All rights reserved.
//

#import "LikeViewController.h"
#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"
#import "SDWebImage/UIImageView+WebCache.h"

@interface LikeViewController ()

@end

@implementation LikeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.frame = [[UIScreen mainScreen] bounds];
    likeTable = [[UITableView alloc] initWithFrame:CGRectMake(0,0, self.view.frame.size.width,  self.view.frame.size.height-120) style:UITableViewStylePlain];
    likeTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    likeTable.delegate = self;
    likeTable.dataSource = self;
    [self.view addSubview:likeTable];
    likeData = [NSMutableArray array];
//    for (int i=1;i<=10; i++) {
//        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
//        [dic setValue:[NSString stringWithFormat:@"User %d",i] forKey:@"name"];
//        [dic setValue:@"test1" forKey:@"image"];
//        [likeData addObject:dic];
//    }
    [self loadLikeUsers];
    
}


-(void)loadLikeUsers{
    
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestSerializer * requestSerializer = [AFHTTPRequestSerializer serializer];
    AFHTTPResponseSerializer *responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *ua = @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_0 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10A5376e Safari/8536.25";
    
    [requestSerializer setValue:ua forHTTPHeaderField:@"User-Agent"];
    [requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    manager.responseSerializer = responseSerializer;
    manager.requestSerializer = requestSerializer;
    manager.requestSerializer.timeoutInterval = 60*4;
    
    NSMutableDictionary *postdata = [NSMutableDictionary dictionary];
    [postdata setObject:self.postid forKey:@"post_id"];
//    [postdata setObject:self.postid forKey:@"user_id"];
    
    NSString *url =[NSString stringWithFormat:@"%@/scripts/post_like_data.php",gupappUrl];
    [manager POST:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] parameters:postdata success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData * data = (NSData*)responseObject;
        NSError *error = nil;
        NSArray *JSON = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        NSLog(@"error %@",JSON);
        for(NSDictionary *dic in JSON){
            NSMutableDictionary *data = [NSMutableDictionary dictionary];
            [data setValue:[dic objectForKey:@"display_name"] forKey:@"name"];
            [data setValue:[dic objectForKey:@"user_image"] forKey:@"image"];
            [likeData addObject:data];
        }
        [likeTable reloadData];
        [HUD removeFromSuperview];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:error.localizedDescription message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:@"ok", nil];
        [alert show];
        [HUD removeFromSuperview];
        
        
    }];
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // Return the number of sections.
    return 1;
    
}
//-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
//    return 25.0;
//}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
           return [likeData count];
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//        return @"Status";
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
        static NSString *simpleTableIdentifier = @"SimpleTableItem";
        HomeTableCell *cell= (HomeTableCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"HomeTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
      cell.nameLabel.text = [[likeData objectAtIndex:indexPath.row] objectForKey:@"name"];
      NSString *imageUrl = [[likeData objectAtIndex:indexPath.row] objectForKey:@"image"];
      [cell.profileImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"defaultProfile"] completed:^(UIImage *image , NSError *error, SDImageCacheType cacheType, NSURL *imageURL){
        if (image) {
            cell.profileImageView.image = image;
        }else{
            cell.profileImageView.image = [UIImage imageNamed:@"defaultProfile"];
        }
        
    }];
    
          return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 61;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
}

@end
