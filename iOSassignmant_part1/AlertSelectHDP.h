//
//  AlertSelectHDP.h
//  iOSassignmant_part1
//
//  Created by Lion User on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AlertSelectHDP : UIAlertView 
{
    UISwitch *uiSwitch_HDP;
}
@property (nonatomic, retain) UISwitch *uiSwitch_HDP;
@property (readonly) bool value_HDP;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okButtonTitle;
@end