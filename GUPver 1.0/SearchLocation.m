//
//  SearchLocation.m
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/26/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import "SearchLocation.h"
#import "SignUp.h"
#import "JSON.h"
#import "CreateProfile.h"

@interface SearchLocation ()

@end

@implementation SearchLocation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title=@"Select your City";
        loactionArray=[[NSMutableArray alloc]init];
        
    }
    return self;
}
-(void)setinitialContent:(NSArray*)passedArray :(id)instace
{  insta=instace;
   [loactionArray addObjectsFromArray:passedArray];
    initiallocation=[[NSMutableArray alloc]init];
    [initiallocation addObjectsFromArray:passedArray];
      NSLog(@"array %@ and %@",loactionArray,initiallocation);
}
/*-(void)wontToChangeLocation
{ locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}*/
-(void)wontToChangeLocationFrom:(id)instance
{
    insta=instance;
    HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    HUD.delegate = self;
    HUD.dimBackground = YES;
    HUD.labelText = @"Please Wait";
    
   
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];

}


#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
     [HUD hide:YES];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    NSLog(@"Resolving the Address");
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
        if (error == nil && [placemarks count] > 0) {
            placemark = [placemarks lastObject];
           
            Longitude=newLocation.coordinate.longitude;
            Latitude=newLocation.coordinate.latitude;
            
            NSLog(@"CCLOC LONGI =%f Lati =%f ",Longitude,Latitude);
            [locationManager stopUpdatingLocation];
            NSString *latitudeL=[NSString stringWithFormat:@"%f",Latitude];
            NSString *longitudeL=[NSString stringWithFormat:@"%f",Longitude];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            
            //  NSString *url=[NSURL URLWithString:@"http://198.154.98.11/~gup/scripts/add_user.php"];
            
            NSString *postData = [NSString stringWithFormat:@"latitude=%@&longitude=%@&type=1",latitudeL,longitudeL];
            NSLog(@"request %@",postData);
            
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/check_location.php",gupappUrl]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            //set post data of request
            [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
            //initialize a connection from request
            fetchLocation = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
            [fetchLocation scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
            [fetchLocation start];
            locationResponse = [[NSMutableData alloc] init];
            
            
        } else {
            NSLog(@"%@", error.debugDescription);
        }
    } ];
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    search.backgroundColor = [UIColor whiteColor];
   // [self.navigationController.navigationBar setUserInteractionEnabled:FALSE];
    // Do any additional setup after loading the view from its nib.
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [tap setDelegate:self];
    [self.view addGestureRecognizer:tap];
    CGSize deviceSize=[UIScreen mainScreen].bounds.size;
    NSLog(@"size w=%f h=%f ",deviceSize.width,deviceSize.height);
    //search.textInputMode.layer.borderColor = [[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1] CGColor];
    UITextField *txfSearchField = [search valueForKey:@"_searchField"];
    txfSearchField.layer.cornerRadius =10.0;
    txfSearchField.layer.borderWidth =1.0f;
    txfSearchField.layer.borderColor =  [[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1] CGColor];
    txfSearchField.background = [UIImage new];
    [search setTranslucent:YES];
    //ios 7
    for(UIView *subView in [search subviews]) {
        if([subView conformsToProtocol:@protocol(UITextInputTraits)]) {
            [(UITextField *)subView setReturnKeyType: UIReturnKeyDone];
        } else {
            for(UIView *subSubView in [subView subviews]) {
                if([subSubView conformsToProtocol:@protocol(UITextInputTraits)]) {
                    [(UITextField *)subSubView setReturnKeyType: UIReturnKeyDone];
                    subSubView.backgroundColor = [UIColor whiteColor];
                }
            }      
        }
    
    }
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
}
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Table View Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [loactionArray count];
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([touch.view isDescendantOfView:listing]) {
        
        // Don't let selections of auto-complete entries fire the
        // gesture recognizer
        return NO;
    }
    
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton=FALSE;
   [search resignFirstResponder];
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    searchBar.showsCancelButton=TRUE;
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [search resignFirstResponder];
}
-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.0;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell Identifier";
    //[tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"Dosis-SemiBold" size:17.f];
    cell.textLabel.textColor =[UIColor colorWithRed:58/255.0 green:56/255.0 blue:48/255.0 alpha:1];
    NSDictionary *location=[loactionArray objectAtIndex:indexPath.row];
   // for (  NSDictionary *tempdict in loactionArray)
   // {
   //     if ([tempdict[@"id"] integerValue]==indexPath.row)
      //  {
         cell.textLabel.text=location[@"location_name"];
       //     break;
       // }
   // }
    
    return cell;
    
    
    
    
}
-(void)viewWillDisappear:(BOOL)animated
{[search resignFirstResponder];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [search resignFirstResponder];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSDictionary *tempDict= [loactionArray objectAtIndex:indexPath.row];
    NSInteger LocID=[tempDict[@"id"] integerValue];
    [insta updateLocationLable:cell.textLabel.text locationID:LocID];
    [self.navigationController popViewControllerAnimated:YES];
    
}


-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{


}
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{// NSString *latitudeL=[NSString stringWithFormat:@"%d",45];
 //   NSString *longitudeL=[NSString stringWithFormat:@"%d",52];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  NSString *url=[NSURL URLWithString:@"http://198.154.98.11/~gup/scripts/add_user.php"];
    NSString *locationName=[NSString stringWithFormat:@"%@",searchText];
    NSString *postData = [NSString stringWithFormat:@"location_name=%@&type=2",locationName];
    NSLog(@"request %@",postData);
    NSLog(@"search TEXT %@",locationName);
   // NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    //  NSString *url=[NSURL URLWithString:@"http://198.154.98.11/~gup/scripts/add_user.php"];
   //  NSString *postData = [NSString stringWithFormat:@"location_name=%@&type=2",locationName];
    NSLog(@"request %@",postData);
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/scripts/check_location.php",gupappUrl]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    //set post data of request
    [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    //initialize a connection from request
    fetchLocation = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [fetchLocation scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    [fetchLocation start];
    locationResponse = [[NSMutableData alloc] init];

}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"did recieve response");
    
    if (connection == fetchLocation) {
        [locationResponse setLength:0];
    }
    }

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSLog(@"did recieve data");
    
    if (connection == fetchLocation) {
        [locationResponse appendData:data];
    }
   
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@" finished loading");
    if (connection == fetchLocation) {
        NSLog(@"====EVENTS");
        NSString *str = [[NSMutableString alloc] initWithData:locationResponse encoding:NSASCIIStringEncoding];
        NSLog(@"Response:%@",str);
        
        SBJSON *jsonparser=[[SBJSON alloc]init];
        NSLog(@"====EVENTS==1");
        NSDictionary *res= [jsonparser objectWithString:str];
        NSLog(@"====EVENTS==2");
        
        NSLog(@"====EVENTS==3 result %@",res);
        
        loactionArray= res[@"response"];
        if (initiallocation==Nil)
        {
            initiallocation=[[NSMutableArray alloc]init];
            [initiallocation addObjectsFromArray:loactionArray];
        }
        if ([loactionArray count]==0&&[search.text length]==0)
        {
            [loactionArray addObjectsFromArray:initiallocation];
        }
        NSLog(@"arr %@",res[@"response"]);
        NSLog(@"array %@ and %@",loactionArray,initiallocation);
        [listing reloadData];
            
        fetchLocation=nil;
        [fetchLocation cancel];
        [HUD hide:YES];

    }
}
@end
