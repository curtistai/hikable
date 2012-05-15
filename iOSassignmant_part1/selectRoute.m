//
//  selectRoute.m
//  iOSassignmant_part1
//
//  Created by Lion User on 15/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

//#define frameHeightFix -50    //Fix the tab bar height problem
#define frameHeightFix 0

#import "selectRoute.h"
#import "viewRoute.h"
#import "createRoute.h"
#import "part1AppDelegate.h"
#import "sqlite3.h"
#import "Toast+UIView.h"


@implementation selectRoute

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Create route" style:UIBarButtonItemStyleBordered target:self action:@selector(goCreateRouteView)];
    self.navigationItem.rightBarButtonItem = barButtonItem;
    [barButtonItem release];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)viewDidAppear:(BOOL)animated{
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    if(delegate.showDeleteSuccessMessage){
        [self.view makeToast:@"Success to delete route!" 
                    duration:2.0 
                    position:[NSValue valueWithCGPoint:CGPointMake(165, 340+frameHeightFix)]];
        delegate.showDeleteSuccessMessage = false;
    }
    [super viewDidAppear:animated];
}

- (void)getRoute:(NSString *)tableName
{
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSString *sql;
    
    if([tableName isEqualToString:@"route_userdefine"]){
        sql = @"SELECT id, title, path, checkpoint FROM route_userdefine ORDER BY id";
    }else if([tableName isEqualToString:@"route_buildin"]){
        sql = @"SELECT id, title, path, checkpoint FROM route_buildin ORDER BY id";
    }
    
    sqlite3_stmt *statement;
    bool haveData = false;
    if (sqlite3_prepare_v2(delegate.db, [sql UTF8String], -1, &statement, nil) == SQLITE_OK){
        while (sqlite3_step(statement) == SQLITE_ROW){
            haveData = true;
            NSString *routeid = [[NSString alloc] initWithUTF8String:(char*) sqlite3_column_text(statement, 0)];
            NSString *title = [[NSString alloc] initWithUTF8String:(char*) sqlite3_column_text(statement, 1)];
            NSString *path = [[NSString alloc] initWithUTF8String:(char*) sqlite3_column_text(statement, 2)];
            NSString *checkpoint = [[NSString alloc] initWithUTF8String:(char*) sqlite3_column_text(statement, 3)];
            if([tableName isEqualToString:@"route_userdefine"]){
                [firstArray addObject:title];
                [firstDataArray addObject:path];
                [firstCheckpointArray addObject:checkpoint];
                [firstIdArray addObject:routeid];
            }else if([tableName isEqualToString:@"route_buildin"]){
                [secondArray addObject:title];
                [secondDataArray addObject:path];
                [secondCheckpointArray addObject:checkpoint];
                [secondIdArray addObject:routeid];
            }
            [title release];
            [path release];
        }
        sqlite3_finalize(statement);
    }
    if(!haveData){
        if([tableName isEqualToString:@"route_userdefine"]){
            [firstArray addObject:@"No any route!"];
        }else if([tableName isEqualToString:@"route_buildin"]){
            [secondArray addObject:@"No any route!"];
        }
    }
}

- (void)goCreateRouteView
{
    createRoute *create_route = [[createRoute alloc] init];
    create_route.title = @"New route";
    create_route.edit_route_id = 0;
    [self.navigationController pushViewController:create_route animated:YES];
    [create_route release];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    /*
     firstArray = [[NSMutableArray alloc] initWithObjects:@"Route A", @"Route B", @"Route C", nil];
     secondArray = [[NSMutableArray alloc] initWithObjects:@"Route D", @"Route E", @"Route F", nil];
     firstDataArray = [[NSMutableArray alloc] initWithObjects:
     @"41.33677,-79.126046\n42.336845,-71.126239\n43.336953,-75.12639",
     @"44.33677,-78.126046\n45.336845,-72.126239\n46.336953,-77.12639",
     @"47.33677,-77.126046\n48.336845,-73.126239\n49.336953,-79.12639"
     , nil];
     secondDataArray = [[NSMutableArray alloc] initWithObjects:
     @"51.33677,-77.126046\n52.336845,-71.126239\n53.336953,-73.12639",
     @"54.33677,-79.126046\n55.336845,-74.126239\n56.336953,-74.12639",
     @"57.33677,-76.126046\n58.336845,-72.126239\n59.336953,-71.12639"
     , nil];
     */
    
    //reset the array
    firstArray = [[NSMutableArray alloc] init];
    firstDataArray = [[NSMutableArray alloc] init];
    firstCheckpointArray = [[NSMutableArray alloc] init];
    firstIdArray = [[NSMutableArray alloc] init];
    secondArray = [[NSMutableArray alloc] init];
    secondDataArray = [[NSMutableArray alloc] init];
    secondCheckpointArray = [[NSMutableArray alloc] init];
    secondIdArray = [[NSMutableArray alloc] init];
    tableArray = [[NSArray alloc] initWithObjects:firstArray, secondArray, nil];
    
    [self getRoute:@"route_userdefine"];
    [self getRoute:@"route_buildin"];
    [self.tableView reloadData];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSString *)itemForIndexPath:(NSIndexPath *)indexPath
{
    return [[tableArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [[tableArray objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"User-defined route";
            break;
        case 1:
            return @"Build-in route";
            break;
        default:
            return nil;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    if(indexPath.section == 0){
        if([[firstArray objectAtIndex:indexPath.row] isEqualToString:@"No any route!"]){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }else{
        if([[secondArray objectAtIndex:indexPath.row] isEqualToString:@"No any route!"]){
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    
    // Assign value to the cell
    NSString *cellValue = [self itemForIndexPath:indexPath];
    cell.textLabel.text = cellValue;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSString* routeid;
    if(indexPath.section == 0){
        if([[firstArray objectAtIndex:indexPath.row] isEqualToString:@"No any route!"]){
            return;
        }
        delegate.routeTitle = [firstArray objectAtIndex:indexPath.row];
        delegate.pathText = [firstDataArray objectAtIndex:indexPath.row];
        delegate.checkpointText = [firstCheckpointArray objectAtIndex:indexPath.row];
        routeid = [firstIdArray objectAtIndex:indexPath.row];
    }else{
        if([[secondArray objectAtIndex:indexPath.row] isEqualToString:@"No any route!"]){
            return;
        }
        delegate.routeTitle = [secondArray objectAtIndex:indexPath.row];
        delegate.pathText = [secondDataArray objectAtIndex:indexPath.row];
        delegate.checkpointText = [secondCheckpointArray objectAtIndex:indexPath.row];
        routeid = [secondIdArray objectAtIndex:indexPath.row];
    }
    //[self.navigationController popViewControllerAnimated:YES];
    viewRoute *view_route = [[[viewRoute alloc] initWithNibName:@"viewRoute" bundle:nil] autorelease];
    view_route.title = delegate.routeTitle;
    view_route.view_route_id = [routeid intValue];
    [self.navigationController pushViewController:view_route animated:YES];

}

@end
