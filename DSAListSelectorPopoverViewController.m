/*
   Project: DSA-SpielHelfer

   Copyright (C) 2024 Free Software Foundation

   Author: Sebastian Reitenbach

   Created: 2024-11-03 22:21:34 +0100 by sebastia

   This application is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This application is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU General Public
   License along with this library; if not, write to the Free
   Software Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111 USA.
*/

#import "DSAListSelectorPopoverViewController.h"

#import "DSAListSelectorPopoverViewController.h"

@implementation DSAListSelectorPopoverViewController

- (instancetype)init {
    NSLog(@"DSAListSelectorPopoverViewController init started!");    
    self = [super init];
    if (self) {
        NSLog(@"DSAListSelectorPopoverViewController inited!");
        // No popover initialization here
    }
    return self;
}

- (void)loadView {
    // Create the main view with a scrollable table view for the location list
    NSLog(@"DSAListSelectorPopoverViewController loadView called");
    NSView *view = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 150)];
    self.view = view;

    // Set up the scroll view
    self.scrollView = [[NSScrollView alloc] initWithFrame:view.bounds];
    self.scrollView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable;
    self.scrollView.hasVerticalScroller = YES;
    [view addSubview:self.scrollView];

    // Set up the table view
    self.tableView = [[NSTableView alloc] initWithFrame:view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    // Create a single column for location names
    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"LocationColumn"];
    column.title = @"Locations";
    column.width = view.bounds.size.width;
    [self.tableView addTableColumn:column];

    // Embed the table view in the scroll view
    self.scrollView.documentView = self.tableView;
    
    NSLog(@"DSAListSelectorPopoverViewController loadView done");
}

#pragma mark - NSTableView DataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.locations.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    // Create and configure the text field for each row
    NSTextField *textField = (NSTextField *)[tableView makeViewWithIdentifier:@"LocationCell" owner:self];
    if (![textField isKindOfClass:[NSTextField class]]) {
        textField = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, tableColumn.width, 20)];
        textField.identifier = @"LocationCell";
        textField.editable = NO;
        textField.bordered = NO;
        textField.backgroundColor = [NSColor clearColor];
    }
    NSDictionary *location = self.locations[row];
    textField.stringValue = location[@"name"];
    return textField;
}

#pragma mark - NSTableView Delegate

- (void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSInteger selectedRow = self.tableView.selectedRow;
    if (selectedRow >= 0 && selectedRow < self.locations.count) {
        NSDictionary *selectedLocation = self.locations[selectedRow];
        if (self.locationSelected) {
            self.locationSelected(selectedLocation); // Call the selection handler
        }
    }
}

@end