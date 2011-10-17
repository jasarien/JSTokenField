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
#import "JSTokenField.h"

@implementation DemoViewController

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_toRecipients release], _toRecipients = nil;
	[_toField release], _toField = nil;
	
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
	
	_toRecipients = [[NSMutableArray alloc] init];
	
	_toField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 0, 320, 31)];
	[[_toField label] setText:@"To:"];
	[_toField setDelegate:self];
	[self.view addSubview:_toField];
    
    UIView *separator1 = [[[UIView alloc] initWithFrame:CGRectMake(0, _toField.bounds.size.height-1, _toField.bounds.size.width, 1)] autorelease];
    [separator1 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_toField addSubview:separator1];
    [separator1 setBackgroundColor:[UIColor lightGrayColor]];
	
	_ccField = [[JSTokenField alloc] initWithFrame:CGRectMake(0, 31, 320, 31)];
	[[_ccField label] setText:@"CC:"];
	[_ccField setDelegate:self];
	[self.view addSubview:_ccField];
    
    UIView *separator2 = [[[UIView alloc] initWithFrame:CGRectMake(0, _ccField.bounds.size.height-1, _ccField.bounds.size.width, 1)] autorelease];
    [separator2 setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
    [_ccField addSubview:separator2];
    [separator2 setBackgroundColor:[UIColor lightGrayColor]];

}

- (void)viewDidUnload
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[_toRecipients release], _toRecipients = nil;
	[_toField release], _toField = nil;
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
#pragma mark JSTokenFieldDelegate

- (void)tokenField:(JSTokenField *)tokenField didAddToken:(NSString *)title representedObject:(id)obj
{
	NSDictionary *recipient = [NSDictionary dictionaryWithObject:obj forKey:title];
	[_toRecipients addObject:recipient];
	NSLog(@"Added token for < %@ : %@ >\n%@", title, obj, _toRecipients);

}

- (void)tokenField:(JSTokenField *)tokenField didRemoveTokenAtIndex:(NSUInteger)index
{	
	[_toRecipients removeObjectAtIndex:index];
	NSLog(@"Deleted token %d\n%@", index, _toRecipients);
}

- (BOOL)tokenFieldShouldReturn:(JSTokenField *)tokenField {
    NSMutableString *recipient = [NSMutableString string];
	
	NSMutableCharacterSet *charSet = [[[NSCharacterSet whitespaceCharacterSet] mutableCopy] autorelease];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
    NSString *rawStr = [[tokenField textField] text];
	for (int i = 0; i < [rawStr length]; i++)
	{
		if (![charSet characterIsMember:[rawStr characterAtIndex:i]])
		{
			[recipient appendFormat:@"%@",[NSString stringWithFormat:@"%c", [rawStr characterAtIndex:i]]];
		}
	}
    
    if ([rawStr length])
	{
		[tokenField addTokenWithTitle:rawStr representedObject:recipient];
	}
    
    return NO;
}

- (void)handleTokenFieldFrameDidChange:(NSNotification *)note
{
	if ([[note object] isEqual:_toField])
	{
		[UIView animateWithDuration:0.0
						 animations:^{
							 [_ccField setFrame:CGRectMake(0, [_toField frame].size.height + [_toField frame].origin.y, [_ccField frame].size.width, [_ccField frame].size.height)];
						 }
						 completion:nil];
	}
}

@end
