//
//  startSOS.m
//  partthree
//
//  Created by a1 on 18/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "startSOS.h"
#import "part1AppDelegate.h"

@implementation startSOS
- (IBAction)sendSOSMessage:(id)sender
{
    NSLog(@"sendSOSMessage");
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    SOSMessage.text = delegate.SOSMessage;
    
    // Check and retrieve authorization information
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        delegate.facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        delegate.facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    if (![delegate.facebook isSessionValid]){
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_likes", 
                                @"read_stream",
                                @"publish_stream",
                                nil];
        [delegate.facebook authorize:permissions];
        [permissions release];
        
    }
    NSMutableString *facebookMessage = [NSMutableString stringWithString:@"[Only for HomeWork Testing Purpose.It is not real. Thank You]"];
    [facebookMessage appendString: [NSMutableString stringWithFormat:delegate.SOSMessage]];
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"386913861360420", @"app_id",
                                   [NSString stringWithFormat:@"http://maps.google.com.hk/?ll=%f,%f",delegate.location.coordinate.latitude, delegate.location.coordinate.longitude], @"link",
                                   @"", @"picture",
                                   @"My Location is Here.", @"name",
                                   //@"Reference Documentation", @"caption",
                                   @"Testing from IOS Assignment", @"description",
                                   facebookMessage,  @"message",
                                   nil];
    //                                   @"http://maps.google.com/maps/api/staticmap?&zoom=14&size=512x512&maptype=roadmap&path=color:0xff0000ff|weight:5|37.785834,-122.406417|37.790833,-122.401421|37.795834,-122.396423|37.800835,-122.391426&markers=|37.785834,-122.406417|37.790833,-122.401421|37.795834,-122.396423|37.800835,-122.391426&sensor=false&format=png", @"link",

    [delegate.facebook requestWithGraphPath:@"me/feed" 
                         andParams:params
                     andHttpMethod:@"POST"
                       andDelegate:nil];
}
- (IBAction)call999:(id)sender
{
    NSLog(@"call 999");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tel://999"]];

}
- (IBAction)sosBuzzer:(id)sender
{
    NSLog(@"sosBuzzer");
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"SOS_morse_code" ofType:@"mp3"]];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [audioPlayer setNumberOfLoops:-1];
    [audioPlayer play];

}
- (IBAction)stopSosBuzzer:(id)sender
{
    [audioPlayer pause];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
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
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
    part1AppDelegate *delegate = (part1AppDelegate *)[[UIApplication sharedApplication] delegate];
    SOSMessage.text = delegate.SOSMessage;

    [super viewWillAppear:animated];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


@end
