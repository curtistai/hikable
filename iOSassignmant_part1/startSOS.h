//
//  startSOS.h
//  partthree
//
//  Created by a1 on 18/05/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface startSOS : UIViewController
{
    IBOutlet UITextView *SOSMessage;
    IBOutlet UIButton *call999;
    IBOutlet UIButton *sendMessage;
    IBOutlet UIButton *sosBuzzer;
    IBOutlet UIButton *stopSosBuzzer;

    AVAudioPlayer *audioPlayer;
}
- (IBAction)sendSOSMessage:(id)sender;
- (IBAction)call999:(id)sender;
- (IBAction)sosBuzzer:(id)sender;
- (IBAction)stopSosBuzzer:(id)sender;

@end
