//
//  Coast_GaurdAppDelegate.h
//  Coast Gaurd
//
//  Created by Nicholas Penree on 5/18/10.
//  Copyright 2010 Conceited Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/Growl.h>

@protocol GrowlApplicationBridgeDelegate;

@interface GSAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate> {
    NSWindow *preferencesWindow;
	NSMenu *menu;
	NSStatusItem *statusItem;
	
	/*NSString *lastArtist;
	NSString *lastAlbum;
	NSString *last*/
	NSArray *lastMetadata;
}

@property (assign) IBOutlet NSWindow *preferencesWindow;
@property (assign) IBOutlet NSMenu *menu;
@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSArray *lastMetadata;

- (IBAction)showGrooveshark:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (NSDictionary *)registrationDictionaryForGrowl;
- (void)growlNotificationWasClicked:(id)clickContext;

@end
