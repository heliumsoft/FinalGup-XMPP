//
//  DatabaseManager.h
//  GUPver 1.0
//
//  Created by Deepesh_Genora on 11/12/13.
//  Copyright (c) 2013 genora. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <sqlite3.h>
@interface DatabaseManager : NSObject
{
       NSString *databasePath;
      // sqlite3 *database;
       bool success;
    
}
+(DatabaseManager*)getSharedInstance;
//-(BOOL)createDB;
-(BOOL)executeQueryWithQuery:(NSString*)Query;
- (BOOL) saveDataInTableWithQuery:(NSString*)Query;
- (NSArray*) retrieveDataFromTableWithQuery:(NSString*)Query;
-(NSDictionary*)DatabaseOutputParserRetrieveRowFromRowIndex:(NSInteger)index FromOutput:(NSArray*)output;
-(NSString*)DatabaseRowParserRetrieveColumnFromColumnName:(NSString*)columnname givenRow:(NSDictionary*)row;
-(NSString*)DatabaseRowParserRetrieveColumnFromColumnName:(NSString*)columnname ForRowIndex:(NSInteger)index givenOutput:(NSArray*)output;

- (BOOL) deleteDataWithQuery:(NSString*)Query;

//-(BOOL)insertQueryForTable:(NSString*)tableName WithData:(NSArray*)DataArray;
//-(NSArray*)retrieveDataFromTable:(NSString*)tableName WithCondition:(NSString*)condition;
//-(BOOL)checkForConditionIfExistsWithQuery:(NSString*)Query;
-(NSArray*) getProfileData;
//-(void)profileUpdate:(NSString*)userName userLoggedInId:(NSString*)logged_in_user_id;
-(void)initialiseDatabase;
//-(void)updatePassword:(NSString*)newPassword userLoggedInId:(NSString*)logged_in_user_id;
-(void)updateLocation:(NSString*)location locationId:(int)locID userLoggedInId:(NSString*)logged_in_user_id;
-(void)setUpdateProfileVariable:(int)profileUpdate userLoggedInId:(NSString*)logged_in_user_id;
-(NSMutableArray*) getUsersData;
-(NSArray*) getContactMuteAndBlockStatus:(NSString*)user_id;
-(NSArray*) getViewProfileData:(NSString*)user_id;
-(NSMutableArray*) getGroupsJoinedByUsers:(NSString*)user_id;
-(NSArray*) getPrivateGroupInfo:(NSString*)group_id;
-(NSArray*) getPublicGroupInfo:(NSString*)group_id;
-(NSMutableArray*) getMembersOfGroup:(NSString*)group_id;
-(BOOL)recordExistOrNot:(NSString *)query;
-(NSString*)getAppUserID;
-(NSMutableArray*) getCategories;
-(NSString*)getAppUserName;
-(NSString*)getAppUserLocationId;
-(NSString*)getAppUserLocationName;
-(NSMutableArray*)getContactList;
//-(BOOL)recordExistOrNot:(NSString *)query;
-(int)countGroupMembers:(NSString*)group_id;
-(int)isAdminOrNot:(NSString*)groupId contactId:(NSString*)contactId;
-(NSMutableArray*)getGroupMembersList:(NSString*)groupId;
-(int)countGroupAdmins:(NSString*)group_id;
-(NSMutableArray*) getGroupsData;
-(int)countNoOfUnreadMsgs:(NSString *)sentId contactOrGroup:(NSString*)contactOrGroup;
-(NSString*)getAppUserImage;
-(int)groupAdminId:(NSString*)group_id;
-(int)fetchGroupJoinRequestCount:(NSString*)group_id;
-(NSMutableArray*) getBlockedUsers;
-(int)fetchBlockedUsersCount;
-(NSArray*)fetchFileNamesToBeDeleted;
-(NSString*)getAdminList:(NSString*)group_id;


@end
