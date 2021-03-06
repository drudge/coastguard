//
//  Coast_GuardAppDelegate.m
//  Coast Guard
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

@synthesize preferencesWindow, statusItem, menu, lastMetadata, apiFilePath;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[GrowlApplicationBridge setGrowlDelegate:self];

    self.statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength] retain];
	[self.statusItem setImage:[NSImage imageNamed:@"gs16.png"]];
	[self.statusItem setEnabled:YES];
	[self.statusItem setMenu:self.menu];
	[self.statusItem setTarget:self];
	
	self.apiFilePath = [@"~/Documents/Grooveshark/currentSong.txt" stringByExpandingTildeInPath];
	
	[[UKKQueue sharedFileWatcher] addPath:self.apiFilePath];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(fsHandler:) name:UKFileWatcherWriteNotification object:nil];
	[[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(groovesharkDidQuit:) name:NSWorkspaceDidTerminateApplicationNotification object:nil];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
	[self removeIMStatus];
}

-(void)groovesharkDidQuit:(NSNotification *)notif
{
	if ([[[notif userInfo] objectForKey:@"NSApplicationName"] isEqualToString:@"Grooveshark"]) {
		[self removeIMStatus];
	}
}

- (void)removeIMStatus
{
	if ([self isApplicationRunning:@"iChat"])
		[self setiChatStatus:@""];
		
	if ([self isApplicationRunning:@"Adium"])
		[self setAdiumStatus:@""];
}

-(void)fsHandler:(NSNotification *)notif
{
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:UKFileWatcherWriteNotification];
	
	NSArray *metadata = [[NSString stringWithContentsOfFile:self.apiFilePath encoding:NSUTF8StringEncoding error:nil] componentsSeparatedByString:@"\t"];
	NSRange theRange = NSMakeRange(0, ([metadata count] -1));
	NSArray *newData = [metadata subarrayWithRange:theRange];
	
	if ([[metadata objectAtIndex:STATUS_KEY] isEqualToString:@"playing"] && ![newData isEqualToArray:self.lastMetadata]) {
		[GrowlApplicationBridge notifyWithTitle:[metadata objectAtIndex:TRACK_KEY] description:[NSString stringWithFormat:@"%@ (on \"%@\")", [metadata objectAtIndex:ARTIST_KEY], [metadata objectAtIndex:ALBUM_KEY]] notificationName:@"Song Changed" iconData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"gs128" ofType:@"png"]] priority:0 isSticky:NO clickContext:[NSArray array]];
		[self setiChatStatus:[NSString stringWithFormat:@"%@ - %@", [metadata objectAtIndex:ARTIST_KEY], [metadata objectAtIndex:TRACK_KEY]]];
		[self setAdiumStatus:[NSString stringWithFormat:@"%@ - %@", [metadata objectAtIndex:ARTIST_KEY], [metadata objectAtIndex:TRACK_KEY]]];
		
		self.lastMetadata = newData;
	} else if (([[metadata objectAtIndex:STATUS_KEY] isEqualToString:@"stopped"] || [[metadata objectAtIndex:STATUS_KEY] isEqualToString:@"paused"]) && ![newData isEqualToArray:self.lastMetadata]) {
		[self removeIMStatus];
		
		self.lastMetadata = nil;
	} else if([metadata count] == 0) {
		[self removeIMStatus];
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
	self.apiFilePath = nil;
	
	[[UKKQueue sharedFileWatcher] removePathFromQueue:self.apiFilePath];
	[[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];

	[super dealloc];
}

- (IBAction)showGrooveshark:(id)sender
{
	NSRunningApplication *gsApp = [self grooveSharkApplication];
		
	if (gsApp) {
		[gsApp unhide];
		[gsApp activateWithOptions:NSApplicationActivateIgnoringOtherApps];
	}
}

- (void)setiChatStatus:(NSString *)message
{
	if ([self isApplicationRunning:@"iChat"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"iChat\" to set status message to \"%@\"", message]];
		[run executeAndReturnError:nil];	
		[run release];
	}
}

- (void)setAdiumStatus:(NSString *)message
{
    if ([self isApplicationRunning:@"Adium"]) {
		NSAppleScript *run = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"Adium\" to set status message of every account to \"%@\"", message]];
		[run executeAndReturnError:nil];	
		[run release];
	}
}

- (IBAction)showPreferences:(id)sender
{
	//[self.preferencesWindow orderFront:sender];
}

- (BOOL)isApplicationRunning:(NSString *)appName
{
	for (NSDictionary *appDict in [[NSWorkspace sharedWorkspace] launchedApplications]) {
		if ([[appDict valueForKey:@"NSApplicationName"] isEqualToString:appName]) {
			return YES;
		}
	}
	
	return NO;
}

- (NSRunningApplication *)grooveSharkApplication
{
	for (NSDictionary *appDict in [[NSWorkspace sharedWorkspace] launchedApplications]) {
		if ([[appDict valueForKey:@"NSApplicationName"] isEqualToString:@"Grooveshark"]) {
			pid_t pid = [[appDict objectForKey:@"NSApplicationProcessIdentifier"] intValue];
						
			return [NSRunningApplication runningApplicationWithProcessIdentifier:pid];
		}
	}
	
	return nil;
}

@end
