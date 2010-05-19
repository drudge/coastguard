//
//  Coast_GaurdAppDelegate.m
//  Coast Gaurd
//
//  Created by Nicholas Penree on 5/18/10.
//  Copyright 2010 Conceited Software. All rights reserved.
//

#define ARTIST_KEY 2
#define ALBUM_KEY 1
#define TRACK_KEY 0
#define STATUS_KEY 3
#define SONG_LINK 4

#import "GSAppDelegate.h"

#import "UKKQueue.h"
#import <Growl/Growl.h>

@implementation GSAppDelegate

@synthesize preferencesWindow, statusItem, menu, lastMetadata;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
	[GrowlApplicationBridge setGrowlDelegate:self];

    self.statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[self.statusItem setImage:[NSImage imageNamed:@"gs16.png"]];
	[self.statusItem setEnabled:YES];
	[self.statusItem setMenu:self.menu];
	[self.statusItem setTarget:self];
	
	[[UKKQueue sharedFileWatcher] addPath:[@"~/Documents/Grooveshark/currentSong.txt" stringByExpandingTildeInPath]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherWriteNotification object:nil];
	
}

-(void)fsHandler:(NSNotification *)notif
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
	
	NSArray *metadata = [[NSString stringWithContentsOfFile:[@"~/Documents/Grooveshark/currentSong.txt" stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\t"];
	NSRange theRange = NSMakeRange(0, ([metadata count] -1));
	NSArray *newData = [metadata subarrayWithRange:theRange];
	NSArray *oldData = [self.lastMetadata subarrayWithRange:theRange];

	if ([[metadata objectAtIndex:STATUS_KEY] isEqualToString:@"playing"] && ![newData isEqualToArray:oldData]) {
		[GrowlApplicationBridge notifyWithTitle:[metadata objectAtIndex:TRACK_KEY] description:[NSString stringWithFormat:@"%@ (on \"%@\")", [metadata objectAtIndex:ARTIST_KEY], [metadata objectAtIndex:ALBUM_KEY]] notificationName:@"Song Changed" iconData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gs128" ofType:@"png"]] priority:0 isSticky:NO clickContext:[NSArray array]];
		self.lastMetadata = metadata;
	}

	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherWriteNotification object:nil];
}

- (NSDictionary *)registrationDictionaryForGrowl
{
	NSArray *growlNotifications = [NSArray arrayWithObjects:@"Song Changed", nil];

	return [NSDictionary dictionaryWithObjectsAndKeys: growlNotifications, GROWL_NOTIFICATIONS_ALL, growlNotifications, GROWL_NOTIFICATIONS_DEFAULT, nil];
}

- (void)growlNotificationWasClicked:(id)clickContext
{
	[self showGrooveshark:self];
}

- (void)dealloc
{
	self.statusItem = nil;
	self.lastMetadata = nil;
	
	[[[UKKQueue sharedFileWatcher] removePathFromQueue:[@"~/Documents/Grooveshark/currentSong.txt" stringByExpandingTildeInPath]]];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

	[super dealloc];
}

- (IBAction)showGrooveshark:(id)sender
{
	NSDictionary *error;
	NSAppleScript *run = [[NSAppleScript alloc] initWithSource:@"tell application \"Grooveshark\" to activate"];
	[run executeAndReturnError:&error];
	
	if (error) NSLog(@"Error: %@", error);
	[run release];
}

- (IBAction)showPreferences:(id)sender
{
	[self.preferencesWindow orderFront:sender];
}

@end
