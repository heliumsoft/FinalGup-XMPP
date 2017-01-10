//
//  AboutUs.m
//  GUPver 1.0
//
//  Created by Milind Prabhu on 11/6/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "AboutUs.h"
#import "WebView.h"

@interface AboutUs ()

@end

@implementation AboutUs

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.title = @"About";
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
  
    
    table = [[UITableView alloc]initWithFrame:CGRectMake(5.0, [[UIScreen mainScreen] bounds].size.height-215.0, [[UIScreen mainScreen] bounds].size.width, 100) style:UITableViewStylePlain];
    table.delegate=self;
    table.dataSource=self;
    table.scrollEnabled=NO;
    table.separatorStyle=0;
   
   // [self.view addSubview:table];
    [TEXTview setScrollEnabled:YES];
    [TEXTview setTextColor:[UIColor grayColor]];
    [TEXTview setUserInteractionEnabled:YES];
    [TEXTview setBackgroundColor:[UIColor clearColor]];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithRed:247.0/255.0 green:247.0/255.0 blue:247.0/255.0 alpha:1.0];
}
-(IBAction)openTerms:(id)sender
{
    WebView *webview = [[WebView alloc]init];
    webview.fromView=@"terms";
    [self.navigationController pushViewController:webview animated:YES];
    
}

-(IBAction)openPrivacyPolicy:(id)sender
{
    WebView *webview = [[WebView alloc]init];
    webview.fromView=@"privacypolicy";
    [self.navigationController pushViewController:webview animated:YES];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --tableview Delegates 

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"cell"];
            UIView *line;
    
    if(!cell)
    {
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.textLabel.font=[UIFont fontWithName:@"Dosis-Regular" size:17.0];
        cell.selectionStyle=0;

        line=[[UIView alloc]init];
        line.backgroundColor=[UIColor colorWithRed:138.0/255.0 green:155.0/255.0 blue:160.0/255.0 alpha:1.0];
        
        if(indexPath.row==0)
        {
            [line setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, 0.50)];
            UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(cell.frame.origin.x+13.0, cell.frame.origin.y+cell.frame.size.height-1, cell.frame.size.width, 2)];
            line2.backgroundColor=[UIColor colorWithRed:225.0/255.0 green:228.0/255.0 blue:226.0/255.0 alpha:1.0];
            [cell addSubview:line2];
           cell.textLabel.text=@"Terms";
        }
        else if(indexPath.row==1)
        { [line setFrame:CGRectMake(cell.frame.origin.x, cell.frame.origin.y+cell.frame.size.height-1, cell.frame.size.width, 0.50)];
         cell.textLabel.text=@"Privacy Policy";
        }
        
        
        [cell addSubview:line];

        
        
        
        
        
    }
    
    return cell;
    
   
    
    
}

    
    
    
    


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 2;
}





@end
