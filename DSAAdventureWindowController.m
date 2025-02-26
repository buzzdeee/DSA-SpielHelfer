/* All rights reserved */

#import "DSAAdventureWindowController.h"

@implementation DSAAdventureWindowController

- (DSAAdventureWindowController *)init
{
  NSLog(@"DSAAdventureWindowController: init called");    
  self = [super init];
  if (self)
    {
    }
  return self;
}

- (void)dealloc {
    NSLog(@"DSAAdventureWindowController is being deallocated.");
}


- (DSAAdventureWindowController *)initWithWindowNibName:(NSString *)nibNameOrNil
{
  NSLog(@"DSAAdventureWindowController initWithWindowNibName %@", nibNameOrNil);
  self = [super initWithWindowNibName:nibNameOrNil];
  if (self)
    {
      NSLog(@"DSAAdventureWindowController initialized with nib: %@", nibNameOrNil);
    }
  else
    {
      NSLog(@"DSAAdventureWindowController had trouble initializing");
    }
    
  return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"DSAAdventureWindowController: awakeFromNib called");
}


- (void)windowDidLoad
{
  [super windowDidLoad];
  // Perform additional setup after loading the window
  NSLog(@"DSAAdventureWindowController: windowDidLoad called");
  
}


@end
