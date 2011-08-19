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

#import "JSTokenFieldViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation JSTokenFieldViewController

@synthesize tokenField = _tokenField;
@synthesize addContactButton = _addContactButton;
@synthesize delegate = _delegate;
@synthesize separator = _separator;

- (void)loadView
{	
	self.view = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 44)] autorelease];
	[self.view setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	
	UIView *_backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y-300, self.view.frame.size.width, 300)] autorelease];
	[_backgroundView setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	[self.view addSubview:_backgroundView];
	
	UILabel *toLabel = [[[UILabel alloc] initWithFrame:CGRectMake(5, 6, 30, 30)] autorelease];
	[toLabel setBackgroundColor:[UIColor clearColor]];
	[toLabel setOpaque:NO];
	[toLabel setTextColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
	[toLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:17.0]];
	[toLabel setText:@"To: "];
	[self.view addSubview:toLabel];
	
	self.tokenField = [[[JSTokenField alloc] initWithFrame:CGRectMake(36, 8, 248, 30)] autorelease];
	[self.view addSubview:self.tokenField];
	
	self.addContactButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
	[self.addContactButton addTarget:self
							  action:@selector(addContact)
					forControlEvents:UIControlEventTouchUpInside];
	CGRect frame = [self.addContactButton frame];
	frame.origin = CGPointMake(288, 8);
	[self.addContactButton setFrame:frame];
	[self.view addSubview:self.addContactButton];
	
	_separator = [[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-1, 320, 1)] autorelease];
	[self.view addSubview:_separator];
	[_separator setBackgroundColor:[UIColor lightGrayColor]];
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	self.tokenField = nil;
	self.addContactButton = nil;
	
    [super dealloc];
}

- (void)addContact
{
	if ([self.delegate respondsToSelector:@selector(addContact)])
	{
		[self.delegate addContact];
	}
}

@end
