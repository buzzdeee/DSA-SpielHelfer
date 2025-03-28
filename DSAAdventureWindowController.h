/* All rights reserved */

#ifndef DSAAdventureWindowController_H_INCLUDE
#define DSAAdventureWindowController_H_INCLUDE

#import <AppKit/AppKit.h>
@class DSACharacterPortraitView;
@class DSAClockAnimationView;

@interface DSAAdventureWindowController : NSWindowController <NSWindowDelegate>
@property (weak) IBOutlet NSTextField *fieldLogs;

@property (strong) IBOutletCollection(NSImageView) NSArray *partyMemberImages;

@property (weak) IBOutlet DSACharacterPortraitView *imagePartyMember0;
@property (weak) IBOutlet DSACharacterPortraitView *imagePartyMember1;
@property (weak) IBOutlet DSACharacterPortraitView *imagePartyMember2;
@property (weak) IBOutlet DSACharacterPortraitView *imagePartyMember3;
@property (weak) IBOutlet DSACharacterPortraitView *imagePartyMember4;
@property (weak) IBOutlet DSACharacterPortraitView *imagePartyMember5;
@property (weak) IBOutlet DSACharacterPortraitView * imagePartyNPC0;
@property (weak) IBOutlet DSACharacterPortraitView * imagePartyNPC1;
@property (weak) IBOutlet DSACharacterPortraitView * imagePartyNPC2;
@property (weak) IBOutlet NSImageView * imageMain;
@property (weak) IBOutlet NSImageView * imageLogo;
@property (weak) IBOutlet DSAClockAnimationView *clockAnimationView;
@property (weak) IBOutlet NSImageView * imageActionIcon0;
@property (weak) IBOutlet NSImageView * imageActionIcon1;
@property (weak) IBOutlet NSImageView * imageActionIcon2;
@property (weak) IBOutlet NSImageView * imageActionIcon3;
@property (weak) IBOutlet NSImageView * imageActionIcon4;
@property (weak) IBOutlet NSImageView * imageActionIcon5;
@property (weak) IBOutlet NSImageView * imageActionIcon6;
@property (weak) IBOutlet NSImageView * imageActionIcon7;
@property (weak) IBOutlet NSImageView * imageActionIcon8;
@property (weak) IBOutlet NSImageView * imageHorizontalRuler0;
@property (weak) IBOutlet NSImageView * imageHorizontalRuler1;
@property (weak) IBOutlet NSImageView * imageVerticalRuler0;

- (void) updatePartyPortraits;

@end

#endif // DSAAdventureWindowController_H_INCLUDE
