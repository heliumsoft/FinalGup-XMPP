//
//  CategoryList.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/1/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "CategoryList.h"
#import "AppDelegate.h"
#import "GroupTableCell.h"
#import "DatabaseManager.h"
#import "GroupInfo.h"
#import "JSON.h"
#import "CreateGroup.h"
#import "viewPrivateGroup.h"
@interface CategoryList ()

@end

@implementation CategoryList
@synthesize userId,triggeredFrom,distinguishFactor;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        //self.title = @"Category";
    }
    //Dosis-SemiBold
    return self;
}

- (void)viewDidLoad{
    
    [super viewDidLoad];
    lockRow=1;
    
    CategoryListTable.allowsMultipleSelection=NO;
//    
//    UIBarButtonItem*  rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissView:)];
//    [rightButton  setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:254.0/255.0 green:199.0/255.0 blue:16.0/255.0 alpha:1.0], NSFontAttributeName:[UIFont fontWithName:@"Dosis-SemiBold" size:18.0]} forState:UIControlStateNormal];
//    self.navigationItem.rightBarButtonItem = rightButton;
//    
//    
//    
    
    
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
    //categoryImages = [NSArray arrayWithObjects:@"business.png", @"education.png", @"finance.png", @"hospitality.png", @"accounting.png",nil];
    groupId = [[NSMutableArray alloc]init];
    groupName = [[NSMutableArray alloc]init];
    groupDetail = [[NSMutableArray alloc]init];
    groupType = [[NSMutableArray alloc]init];
    groupPic = [[NSMutableArray alloc]init];
    
    if ([distinguishFactor isEqualToString:@"Groups"]){
        CategoryListTable.tag = 1;
        if ([triggeredFrom isEqualToString:@"explore"]){
            
            [self startActivityIndicator];
            [self fetchGroupJoinedList];
        }else{
            
            NSLog(@"user id:%@",userId);
            [groupId removeAllObjects];
            [groupName removeAllObjects];
            [groupDetail removeAllObjects];
            [groupType removeAllObjects];
            [groupPic removeAllObjects];
            
            getData = [[NSMutableArray alloc]init];
            getData = [[DatabaseManager getSharedInstance]getGroupsJoinedByUsers:userId];
            if([getData count]>0){
                for(int i=0;i<[getData count];i++){
                    
                    NSMutableArray *groups = [getData objectAtIndex:i];
                    [groupId addObject:[groups objectAtIndex:0]];
                    [groupName addObject:[groups objectAtIndex:1]];
                    [groupDetail addObject:[groups objectAtIndex:2]];
                    [groupType addObject:[groups objectAtIndex:3]];
                    NSLog(@"group type%@",groupType[i]);
                }
                
            }
            if ([getData count]== 0) {
                NSLog(@"no groups joined");
            }
        }
    }else{
        CategoryListTable.tag =0;
        categoryIds = [[NSMutableArray alloc]init];
        categoryNames = [[NSMutableArray alloc]init];
        NSString *checkIfCategoriesExist;
        checkIfCategoriesExist=[NSString stringWithFormat:@"select * from group_category"];
        BOOL categoriesExist=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfCategoriesExist];
        NSLog(@"bool added %d",categoriesExist);
        if (categoriesExist) {
            NSMutableArray *categoryData = [[NSMutableArray alloc]init];
            categoryData = [[DatabaseManager getSharedInstance]getCategories];
            
            if([categoryData count]>0){
                for(int i=0;i<[categoryData count];i++){
                    
                    NSMutableArray *categories = [categoryData objectAtIndex:i];
                    NSLog(@"getcategory categories %@\n",categories);
                    [categoryIds addObject:[categories objectAtIndex:0]];
                    [categoryNames addObject:[categories objectAtIndex:1]];
                }
            }
            
        }else{
            [self startActivityIndicator];
            [self loadCategories];
            
        }
    }
}
-(void)startActivityIndicator{
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
}
- (void)loadCategories{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *url=[NSString stringWithFormat:@"%@/scripts/fetch_all_cat.php",gupappUrl ];
    NSLog(@"Url final=%@",url);
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPMethod:@"GET"];
    
    fetchCategoryConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchCategoryConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    [fetchCategoryConn start];
    fetchCategoryResponse = [[NSMutableData alloc] init];
    
    
}
#pragma Actions

-(void)dismissView:(UIBarButtonItem*)barButton
{
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}




#pragma mark Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 0) {
        NSLog(@"categ names count == %i",[categoryNames count]);
        return [categoryNames count];
        
    }else
        return [groupId count];
    
    
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section{
    return 1.0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   // UIImageView  *radioSelection;
    
    
    if (tableView.tag == 0) {
        static NSString *CellIdentifier = @"Cell Identifier";
        //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
        }
        
//        radioSelection = [[UIImageView alloc]initWithFrame:CGRectMake(cell.frame.size.width-40.0, cell.center.y-12.50, 25, 25)];
//        radioSelection.image=[UIImage imageNamed:@"radio"];
//        radioSelection.tag=100;
//        cell.selected=NO;
//        [cell.contentView addSubview:radioSelection];
//        
//        if(lasRow.row==indexPath.row && lastSelectedCell)
//            radioSelection.image =[UIImage imageNamed:@"radioselect"];
//        
        
        cell.textLabel.text =[categoryNames objectAtIndex:indexPath.row];
        cell.textLabel.font = [UIFont fontWithName:@"Dosis-Regular" size:17.f];
        return cell;
        
    }else{
        static NSString *groupTableIdentifier = @"GroupTableItem";
        GroupTableCell *cell= (GroupTableCell *)[tableView dequeueReusableCellWithIdentifier:groupTableIdentifier];
        
        if (cell == nil){
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }else{
            cell=nil;
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GroupTableCell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
        }
        UIImageView *iconImage= [[UIImageView alloc]initWithFrame:CGRectMake(8, 8, 18, 18)];
        if([[groupType objectAtIndex:indexPath.row] isEqualToString:@"private#local"]) {
            iconImage.image =[UIImage imageNamed:@"private_local"];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"Created by:%@",[groupDetail objectAtIndex:indexPath.row]];
        }else if([[groupType objectAtIndex:indexPath.row] isEqualToString:@"private#global"]){
            iconImage.image =[UIImage imageNamed:@"private_global"];
            cell.detailTextLabel.text =[NSString stringWithFormat:@"Created by:%@",[groupDetail objectAtIndex:indexPath.row]];
            
        }else if([[groupType objectAtIndex:indexPath.row] isEqualToString:@"public#local"]){
            iconImage.image =[UIImage imageNamed:@"pin15"];
            cell.detailTextLabel.text =[groupDetail objectAtIndex:indexPath.row];
        }else{
            iconImage.image =[UIImage imageNamed:@"globe15"];
            cell.detailTextLabel.text =[groupDetail objectAtIndex:indexPath.row];
        }
        [cell.imageView addSubview:iconImage];
        cell.textLabel.text =[groupName objectAtIndex:indexPath.row];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/media/images/group_pics/%@",gupappUrl,groupPic[indexPath.row]]]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.imageView.image = [UIImage imageWithData:imgData];
                
                
            });
            
        });
        
        
        
        [cell setAccessoryType: UITableViewCellAccessoryDetailButton];
        
        
        
        return cell;
    }
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return tableView.tag == 0 ? 44 : 140;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0)     {
//        NSLog(@"checkmark");
//        //        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
//        //
//        //
//        //
//        
//        
       UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
//        UIImageView *temp =(UIImageView*) [cell.contentView viewWithTag:100];
//        
//        
//                temp.image=[UIImage imageNamed:@"radioselect"];
//                lastSelectedCell=TRUE;
//                lasRow=indexPath;
//                
       
        NSString *categoryID = [categoryIds objectAtIndex:indexPath.row];
        [insta updateCategory:cell.textLabel.text categoryId:categoryID];
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}



-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == 0){
        
    }
    
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    // check whether the user is the admin of the group.
    NSString *appUserId =[[DatabaseManager getSharedInstance]getAppUserID];
    
    NSLog(@"group id check:%@ userid:%@",[groupId objectAtIndex:indexPath.row],userId);
    int is_admin=[[DatabaseManager getSharedInstance]isAdminOrNot:[groupId objectAtIndex:indexPath.row] contactId:appUserId];
    NSLog(@"is_admin%i",is_admin);
    if (is_admin == 1) {
        viewPrivateGroup *viewGroupAsAdmin = [[viewPrivateGroup alloc]init];
        viewGroupAsAdmin.title = [groupName objectAtIndex:indexPath.row];
        viewGroupAsAdmin.groupId = [groupId objectAtIndex:indexPath.row];
        viewGroupAsAdmin.groupType =[groupType objectAtIndex:indexPath.row];
        [self.navigationController pushViewController:viewGroupAsAdmin animated:NO];
    }else{
        GroupInfo *viewGroupPage = [[GroupInfo alloc]init];
        viewGroupPage.title = [groupName objectAtIndex:indexPath.row];
        viewGroupPage.groupId = [groupId objectAtIndex:indexPath.row];
        viewGroupPage.groupType =[groupType objectAtIndex:indexPath.row];
        if (![triggeredFrom isEqualToString:@"explore"]) {
            viewGroupPage.startLoading =@"contacts";
        }
        [self.navigationController pushViewController:viewGroupPage animated:NO];
    }
    
}


- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)fetchGroupJoinedList{
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *postData = [NSString stringWithFormat:@"user_id=%@",userId];
    NSLog(@"$[%@]",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/user_group.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    groupJoinedConn = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [groupJoinedConn scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [groupJoinedConn start];
    groupJoinedResponse = [[NSMutableData alloc] init];
    
}

//NSURL Connection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (connection == groupJoinedConn) {
        [groupJoinedResponse setLength:0];
        
    }
    if (connection == fetchCategoryConn) {
        [fetchCategoryResponse setLength:0];
        
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    NSLog(@"did recieve data");
    
    if (connection == groupJoinedConn) {
        [groupJoinedResponse appendData:data];
        
    }
    if (connection == fetchCategoryConn) {
        
        [fetchCategoryResponse appendData:data];
        
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == groupJoinedConn) {
        
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
    }else{
        [HUD hide:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                        message:[error localizedDescription]
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    NSLog(@" finished loading");
    
    if (connection == groupJoinedConn) {
        
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:groupJoinedResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        NSDictionary *results = res[@"group_list"];
        NSLog(@"results: %@", results);
        NSDictionary *groups=results[@"list"];
        NSLog(@"groups: %@", groups);
        
        if ([groups count]==0 ){
            [HUD hide:YES];
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@""
                                                             message:@"No results found."
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
            alert.tag=11;
            [alert show];
        }else{
            for (NSDictionary *result in groups) {
                
                NSString *resultId = result[@"id"];
                NSString *name = result[@"name"];
                NSString *type = result[@"type"];
                NSString *bottom_display = result[@"bottom_display"];
                NSString *display_pic = result[@"group_pic"];
                //NSString *location = result[@"location_name"];
                
                NSLog(@"resultId: %@",resultId);
                NSLog(@"name: %@",name);
                NSLog(@"type: %@",type);
                NSLog(@"bottomdisplay: %@",bottom_display);
                NSLog(@"display pic: %@",display_pic);
                //NSLog(@"location: %@",location);
                
                [groupId addObject:resultId];
                [groupName addObject:name];
                [groupDetail addObject:bottom_display];
                [groupType addObject:type];
                [groupPic addObject:display_pic];
                
                NSLog(@" id %@",groupId);
                NSLog(@"group names %@",groupName);
                NSLog(@"type array %@",groupType);
                NSLog(@"bottom disp %@",groupDetail);
                
                
            }
            [CategoryListTable reloadData];
            
            [HUD hide:YES];
        }
        groupJoinedConn=nil;
        [groupJoinedConn cancel];
    }
    
    
    if (connection == fetchCategoryConn) {
        
        NSLog(@"====EVENTS");
        
        NSString *response = [[NSMutableString alloc] initWithData:fetchCategoryResponse encoding:NSASCIIStringEncoding];
        
        NSLog(@"categoryResponse:%@",response);
        if (response) {
            NSString *query=[NSString stringWithFormat:@"delete from group_category"];
            NSLog(@"query %@",query);
            [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:query];
        }
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSDictionary *res= [jsonparser objectWithString:response];
        NSDictionary *results = res[@"category_list"];
        NSArray *categories = results[@"list"];
        NSLog(@"====EVENTS==3 %@",res);
        for (NSDictionary *result in categories){
            NSString *checkIfExists=[NSString stringWithFormat:@"select * from group_category where category_id=%@",result[@"category_id"]];
            BOOL existOrNot=[[DatabaseManager getSharedInstance]recordExistOrNot:checkIfExists];
            if (existOrNot) {
                NSString *updateCategory=[NSString stringWithFormat:@"update  group_category set category_id = '%@', category_name = '%@' where category_id = '%@' ",result[@"category_id"],result[@"category_name"],result[@"category_id"]];
                NSLog(@"query %@",updateCategory);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:updateCategory];
            }else{
                NSString *insertCategory=[NSString stringWithFormat:@"insert into group_category (category_id, category_name) values ('%@','%@')",result[@"category_id"],result[@"category_name"]];
                NSLog(@"query %@",insertCategory);
                [[DatabaseManager getSharedInstance]saveDataInTableWithQuery:insertCategory];
            }
            [categoryIds addObject:result[@"category_id"]];
            [categoryNames addObject:result[@"category_name"]];
            
            
        }
        [CategoryListTable reloadData];
        
        [HUD hide:YES];
        fetchCategoryConn=nil;
        
        [fetchCategoryConn cancel];
        
        
    }
    
}

//uialertview delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag==11) {
        if (buttonIndex == 0) {
            [self.navigationController popViewControllerAnimated:NO];
        }
    }
}
-(void)wantToChangeCategoryFrom:(id)instance{
    insta=instance;
}


@end
