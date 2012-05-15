//
//  AlertSelectHDP.m
//  iOSassignmant_part1
//
//  Created by Lion User on 19/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AlertSelectHDP.h"
#import "part1AppDelegate.h"

@implementation AlertSelectHDP
@synthesize uiSwitch_HDP;
@synthesize value_HDP;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    message = @"\n";
    if (self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil])
    {
        part1AppDelegate* delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
        
        UILabel *uiLabel_HDP = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 45.0, 175.0, 25.0)];
        [uiLabel_HDP setBackgroundColor:[[UIColor alloc] initWithWhite:0 alpha:0]];
        [uiLabel_HDP setTextColor:[UIColor whiteColor]];
        [uiLabel_HDP setText:@"Distance Post"];
        [self addSubview:uiLabel_HDP];
        [uiLabel_HDP release];
        
        UISwitch *temp_uiSwitch_HDP = [[UISwitch alloc] initWithFrame:CGRectMake(192.0, 45.0, 60.0, 25.0)];
        [self addSubview:temp_uiSwitch_HDP];
        [temp_uiSwitch_HDP setOn:delegate.displayHDP];
        self.uiSwitch_HDP = temp_uiSwitch_HDP;
        [temp_uiSwitch_HDP release];
        CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 0.0); 
        [self setTransform:translate];
    }
    return self;
}
- (void)show
{
    [uiSwitch_HDP becomeFirstResponder];
    [super show];
}
- (bool)value_HDP
{
    return uiSwitch_HDP.isOn;
}
- (void)dealloc
{
    [uiSwitch_HDP release];
    [super dealloc];
}
@end
