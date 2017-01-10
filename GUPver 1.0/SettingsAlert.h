//
//  SettingsAlert.h
//  GUPver 1.0
//
//  Created by genora on 11/5/13.
//  Copyright (c) 2013 genora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface SettingsAlert : UIViewController<UITableViewDataSource,UITableViewDelegate,MBProgressHUDDelegate>
{
    IBOutlet UITableView *alertTable;
    UISwitch *groupChat,*personalChat,*vibration,*sound;
    NSURLConnection *alertGroupSetting,*alertPersonalSetting,*alertViberationSetting,*alertSoundSetting;
    NSMutableData *alertGroupSettingData,*alertPersonalSettingData,*alertViberationGroupSettingData,*alertSoundSettingData;
     MBProgressHUD *HUD;
}
- (IBAction)switchAction:(id)sender;
@end
