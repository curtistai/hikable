//
//  part1AppDelegate.m
//  iOSassignmant_part1
//
//  Created by Lion User on 15/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "part1AppDelegate.h"
#import "selectRoute.h"
#import "WeatherViewController.h"

@implementation part1AppDelegate

@synthesize facebook; 
@synthesize SOSMessage;

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize pathText = _pathText;
@synthesize checkpointText = _checkpointText;
@synthesize routeTitle = _routeTitle;
@synthesize HkDistancePosts = _HkDistancePosts;
@synthesize db;
@synthesize displayHDP = _displayHDP;
@synthesize showEditSuccessMessage = _showEditSuccessMessage;
@synthesize showDeleteSuccessMessage = _showDeleteSuccessMessage;
@synthesize location = _location;
//Setting bundle
@synthesize preference_gps_interval = _preference_gps_interval;

//Read setting bundle
-(NSDictionary *)settingsBundleDefaultValues{
    NSMutableDictionary *defaultDic_ = [[NSMutableDictionary alloc] init];
    NSURL *settingUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Root" ofType:@"plist" inDirectory:@"Settings.bundle"] isDirectory:YES];
    NSDictionary *settingBundle = [NSDictionary dictionaryWithContentsOfURL:settingUrl];
    NSArray *preference_ = [settingBundle objectForKey:@"PreferenceSpecifiers"];
    for(NSDictionary *component_ in preference_){
        NSString *key = [component_ objectForKey:@"Key"];
        NSString *defaultValue = [component_ objectForKey:@"DefaultValue"];
        if(!key || !defaultValue){
            continue;
        }
        if(![component_ objectForKey:key]){
            [defaultDic_ setObject:[component_ objectForKey:@"DefaultValue"] forKey:key];
        }
    }
    return defaultDic_;
}

- (NSString *)filePath:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    NSLog(@"%@", fileDirectory);
    return fileDirectory;
}

- (void)openDB
{
    if (sqlite3_open([[self filePath:@"db.sql"] UTF8String], &db) != SQLITE_OK){
        sqlite3_close(db);
        NSAssert(0, @"Database failed to open.");
    }
}

- (void)createTable:(NSString *)tableName
{
    char *error;
    NSString *sql;
    
    if([tableName isEqualToString:@"route_userdefine"]){
        sql = @"CREATE TABLE IF NOT EXISTS 'route_userdefine' ('id' INTEGER PRIMARY KEY, 'title' TEXT, 'path' TEXT, 'checkpoint' TEXT);";
    }else if([tableName isEqualToString:@"route_buildin"]){
        sql = @"CREATE TABLE IF NOT EXISTS 'route_buildin' ('id' INTEGER PRIMARY KEY, 'title' TEXT, 'path' TEXT, 'checkpoint' TEXT);";
    }
    
    if (sqlite3_exec(db, [sql UTF8String], NULL, NULL, &error) != SQLITE_OK){
        sqlite3_close(db);
        NSAssert(0, @"Table failed to create.");
    }
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [_pathText release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    SOSMessage = @"";
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.viewController = [[[selectRoute alloc] initWithNibName:@"selectRoute" bundle:nil] autorelease];
    
    [self openDB];
    [self createTable:@"route_userdefine"];
    [self createTable:@"route_buildin"];
    
    self.viewController.title = @"Select route";
    navController = [[UINavigationController alloc] init];
    [navController pushViewController:self.viewController animated:NO];
    
    calculateSOS *aView = [[calculateSOS alloc]init];
    
    aView.title = @"SOS";
    navController2 = [[UINavigationController alloc] init];
    [navController2 pushViewController:aView animated:NO];

    
    WeatherViewController *bView = [[WeatherViewController alloc]init];
    bView.title = @"Weather Forecast";
    
    tabBarController = [[UITabBarController alloc]init];
    tabBarController.viewControllers = [NSArray arrayWithObjects:navController,navController2,bView, nil];
    [self.window addSubview:tabBarController.view];


    //self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    [aView release];
    [navController release];
    [navController2 release];
    //Read setting bundle
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault registerDefaults:[self settingsBundleDefaultValues]];
    _preference_gps_interval = [userDefault integerForKey:@"preference_gps_interval"];
    
    //FaceBook Permission
    // FB Change here
    facebook=[[Facebook alloc]initWithAppId:@"386913861360420" andDelegate:self];
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![facebook isSessionValid]){
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes", 
                                @"read_stream",
                                @"publish_stream",
                                nil];
        [facebook authorize:permissions];
        [permissions release];
        
    }

    return YES;
}
// Pre iOS 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [facebook handleOpenURL:url]; 
}

// For iOS 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [facebook handleOpenURL:url]; 
}
- (void)fbDidLogin {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    sqlite3_close(db);
}

@end
