//
//  part1AppDelegate.h
//  iOSassignmant_part1
//
//  Created by Lion User on 15/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "sqlite3.h"
//#import "selectRoute.h"
#import "calculateSOS.h"
#import "FBConnect.h"



@class selectRoute;

@interface part1AppDelegate : UIResponder <UIApplicationDelegate,FBSessionDelegate>{
    UINavigationController *navController;
    UITabBarController *tabBarController;
    UINavigationController *navController2;
    sqlite3 *db;
    Facebook *facebook;
    NSString *SOSMessage;
}

@property (nonatomic,retain)  Facebook *facebook;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) selectRoute *viewController;
@property (strong, nonatomic) NSString *pathText;
@property (strong, nonatomic) NSString *checkpointText;
@property (strong, nonatomic) NSString *routeTitle;
@property (strong, nonatomic) NSMutableArray *HkDistancePosts;
@property (strong, nonatomic) NSString *SOSMessage;
@property (strong, nonatomic) CLLocation *location;
@property bool displayHDP;
@property bool showEditSuccessMessage;
@property bool showDeleteSuccessMessage;

//Setting bundle
@property int preference_gps_interval;



@property (readwrite) sqlite3 *db;

- (NSString *)filePath:(NSString *) filename;
- (void)openDB;
- (void)createTable:(NSString *) tableName;

@end