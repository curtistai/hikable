//
//  selectRoute.h
//  iOSassignmant_part1
//
//  Created by Lion User on 15/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "part1AppDelegate.h"

@interface selectRoute : UITableViewController{
    NSMutableArray *firstArray;
    NSMutableArray *secondArray;
    NSArray *tableArray;
    NSMutableArray *firstDataArray;
    NSMutableArray *secondDataArray;
    NSMutableArray *firstCheckpointArray;
    NSMutableArray *secondCheckpointArray;
    NSMutableArray *firstIdArray;
    NSMutableArray *secondIdArray;
}

- (NSString *)itemForIndexPath:(NSIndexPath *)indexPath;
- (void)getRoute:(NSString *)tableName;

@end
