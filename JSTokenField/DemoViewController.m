//
//	Copyright 2011 James Addyman (JamSoft). All rights reserved.
//	
//	Redistribution and use in source and binary forms, with or without modification, are
//	permitted provided that the following conditions are met:
//	
//		1. Redistributions of source code must retain the above copyright notice, this list of
//			conditions and the following disclaimer.
//
//		2. Redistributions in binary form must reproduce the above copyright notice, this list
//			of conditions and the following disclaimer in the documentation and/or other materials
//			provided with the distribution.
//
//	THIS SOFTWARE IS PROVIDED BY JAMES ADDYMAN (JAMSOFT) ``AS IS'' AND ANY EXPRESS OR IMPLIED
//	WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
//	FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL JAMES ADDYMAN (JAMSOFT) OR
//	CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
//	ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
//	NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
//	ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
//	The views and conclusions contained in the software and documentation are those of the
//	authors and should not be interpreted as representing official policies, either expressed
//	or implied, of James Addyman (JamSoft).
//

#import "DemoViewController.h"
#import "JSTokenFieldViewController.h"

@implementation DemoViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_recipients release], _recipients = nil;
	[_tokenFieldViewController release], _tokenFieldViewController = nil;
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleTokenFieldFrameDidChange:)
												 name:JSTokenFieldFrameDidChangeNotification
											   object:nil];
	
	_recipients = [[NSMutableArray alloc] init];
	
	_tokenFieldViewController = [[JSTokenFieldViewController alloc] init];
	[_tokenFieldViewController setDelegate:self];
	[self.tableView setTableHeaderView:_tokenFieldViewController.view];
	[_tokenFieldViewController.tokenField setDelegate:self];
}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_recipients release], _recipients = nil;
	[_tokenFieldViewController release], _tokenFieldViewController = nil;
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

#pragma mark -
#pragma mark UITableViewControllerDelegate/DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

#pragma mark -
#pragma mark JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
	NSDictionary *recipient = [NSDictionary dictionaryWithObject:obj forKey:title];
	[_recipients addObject:recipient];
	NSLog(@"Added token for < %@ : %@ >\n%@", title, obj, _recipients);

}

- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{	
	[_recipients removeObjectAtIndex:index];
	NSLog(@"Deleted token %d\n%@", index, _recipients);
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
	CGRect frame = [[_tokenFieldViewController view] frame];
	CGRect newFrame = [[[note userInfo] objectForKey:JSTokenFieldFrameKey] CGRectValue];
	
	[UIView beginAnimations:nil context:nil];
	
	if (newFrame.size.height > 44)
	{	
		frame.size.height = newFrame.size.height + 9;
		[[_tokenFieldViewController view] setFrame:frame];
		[_tokenFieldViewController.separator setFrame:CGRectMake(0, frame.size.height-1, 320, 1)];
	}
	else
	{
		frame.size.height = 44;
		[[_tokenFieldViewController view] setFrame:frame];	
		[_tokenFieldViewController.separator setFrame:CGRectMake(0, frame.size.height-1, 320, 1)];
	}
	
	CGRect addButtonFrame = [_tokenFieldViewController.addContactButton frame];
	addButtonFrame.origin = CGPointMake((newFrame.origin.x + newFrame.size.width + 4), ((newFrame.origin.y + newFrame.size.height) - addButtonFrame.size.height - 4));
	[_tokenFieldViewController.addContactButton setFrame:addButtonFrame];
	
	[UIView commitAnimations];
	
	[self.tableView setTableHeaderView:[_tokenFieldViewController view]];
	
	if (![[note userInfo] objectForKey:JSDeletedTokenKey])
	{
		[self.tableView scrollRectToVisible:_tokenFieldViewController.view.frame animated:YES];
	}
}


#pragma mark -
#pragma mark ABPeoplePickerNavigationControllerDelegate

- (void)addContact
{
	ABPeoplePickerNavigationController *peoplePicker = [[[ABPeoplePickerNavigationController alloc] init] autorelease];
	[peoplePicker setPeoplePickerDelegate:self];
	[self presentModalViewController:peoplePicker animated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
	return YES;
}

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
	[self dismissModalViewControllerAnimated:YES];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{		
	[self dismissModalViewControllerAnimated:YES];
	
	ABMultiValueRef multiValue = ABRecordCopyValue(person, property);
	NSString *phoneNumber = (NSString *)ABMultiValueCopyValueAtIndex(multiValue, ABMultiValueGetIndexForIdentifier(multiValue, identifier));
	[phoneNumber autorelease];
	CFRelease(multiValue);
	
	NSString *firstName = (NSString *)ABRecordCopyValue(person,kABPersonFirstNameProperty);
	NSString *lastName = (NSString *)ABRecordCopyValue(person,kABPersonLastNameProperty);
	
	[firstName autorelease];
	[lastName autorelease];
	
	NSString *displayName = nil;
	
	if([firstName length] && [lastName length]){
		displayName = [NSString stringWithFormat:@"%@ %@",firstName,lastName];
	}else if([firstName length]){
		displayName = [NSString stringWithFormat:@"%@",firstName];
	}else if([lastName length]){
		displayName = [NSString stringWithFormat:@"%@",lastName];
	}
	
	if ([displayName length] == 0)
	{
		displayName = phoneNumber;
	}
	
	[_tokenFieldViewController.tokenField addTokenWithTitle:displayName representedObject:phoneNumber];
	
	return NO;
}

@end
