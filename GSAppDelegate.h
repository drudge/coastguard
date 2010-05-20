//
//  Coast_GaurdAppDelegate.h
//  Coast Guard
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
	NSArray *lastMetadata;
	NSString *apiFilePath;
}

@property (assign) IBOutlet NSWindow *preferencesWindow;
@property (assign) IBOutlet NSMenu *menu;
@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSArray *lastMetadata;
@property (retain, nonatomic) NSString *apiFilePath;

- (void)removeIMStatus;
-(void)groovesharkDidQuit:(NSNotification *)notif;

- (IBAction)showGrooveshark:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (void)setiChatStatus:(NSString *)message;
- (void)setAdiumStatus:(NSString *)message;

- (NSDictionary *)registrationDictionaryForGrowl;
- (void)growlNotificationWasClicked:(id)clickContext;

@end
