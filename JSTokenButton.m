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


#import "JSTokenButton.h"
#import "JSTokenField.h"
#import <QuartzCore/QuartzCore.h>


@implementation JSTokenButton


+ (JSTokenButton *)tokenWithLabel:(NSString *)labelText forIdentifier:(id)identifier
{
	JSTokenButton *token = (JSTokenButton *)[self buttonWithType:UIButtonTypeCustom];
	token.identifier = identifier;
	token.active = FALSE;
	
	// Set the background appearance
	token.adjustsImageWhenHighlighted = FALSE;
	token.normalBackgroundImage = [[UIImage imageNamed:@"tokenNormal.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
	token.highlightedBackgroundImage = [[UIImage imageNamed:@"tokenHighlighted.png"] stretchableImageWithLeftCapWidth:14 topCapHeight:0];
	
	// Style the buttons appearance
	[token setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[token.titleLabel setFont:[UIFont fontWithName:@"Helvetica Neue" size:15]];
	[token.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
	[token setTitleEdgeInsets:UIEdgeInsetsMake(2, 10, 0, 10)];
	[token setTitle:labelText forState:UIControlStateNormal];
	
	// Adjust the tokens frame
	[token sizeToFit];
	
	CGRect frame = [token frame];
	frame.size.width += 20;
	frame.size.height = 25;
	token.frame = frame;
	
	[token updateAppearance];
	
	return token;
}

- (void)setActive:(BOOL)active
{
	_active = active;
	
	[self updateAppearance];
}


- (void)updateAppearance
{
	if([self isActive]) {
		[self setBackgroundImage:self.highlightedBackgroundImage forState:UIControlStateNormal];
		[self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	} else {
		[self setBackgroundImage:self.normalBackgroundImage forState:UIControlStateNormal];
		[self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	}
}


- (BOOL)canBecomeFirstResponder
{
    return YES;
}


- (BOOL)becomeFirstResponder
{
	BOOL shouldBecomeFirstResponder = [super becomeFirstResponder];
	if(shouldBecomeFirstResponder)
		self.active = TRUE;
	
    return shouldBecomeFirstResponder;
}


- (BOOL)resignFirstResponder
{
	BOOL shouldResignFirstResponder = [super resignFirstResponder];
	if(shouldResignFirstResponder)
		self.active = FALSE;
	
    return shouldResignFirstResponder;
}



#pragma mark - UIKeyInput

- (void)deleteBackward
{
	[self.parentField becomeFirstResponder];
	[self.parentField removeTokenForIdentifier:self.identifier];
}


- (BOOL)hasText
{
    return NO;
}


- (void)insertText:(NSString *)text
{
}



@end
