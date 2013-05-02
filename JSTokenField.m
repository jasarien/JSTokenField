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

#import "JSTokenField.h"
#import "JSTokenButton.h"
#import <QuartzCore/QuartzCore.h>

#define ZERO_WIDTH_SPACE_STRING @"\u200B"


@interface JSTokenField ()

@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, readwrite, retain) UITextField *textField;
@property (nonatomic, readwrite, retain) UILabel *label;

@end



@implementation JSTokenField


- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if(self) {
		[self setup];
    }
	
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
    if(self) {
        [self setup];
    }
	
    return self;
}


- (void)setup
{
	self.tokens = [[NSMutableArray alloc] init];
	
	// Setup the fields appearance views
    [self setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	
    CGRect frame = self.frame;
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(3, 3, 3, 3);
	self.tokenPadding = CGSizeMake(5, 5);
	self.contentInsets = contentInsets;
	
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
    [label setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [self addSubview:label];
	self.label = label;
    
    frame.origin.y += contentInsets.top;
    frame.size.height -= contentInsets.top + contentInsets.bottom;
	
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField setDelegate:self];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    [textField setText:ZERO_WIDTH_SPACE_STRING];
    [self addSubview:textField];
	self.textField = textField;
	
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTextDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
}



#pragma mark - UIResponder methods


- (BOOL)canBecomeFirstResponder
{
	return TRUE;
}


- (BOOL)canResignFirstResponder
{
	return TRUE;
}


- (BOOL)becomeFirstResponder
{
	return [self.textField becomeFirstResponder];
}


- (BOOL)resignFirstResponder
{
	[super resignFirstResponder];
	[self.textField resignFirstResponder];
	
	for(JSTokenButton *token in self.tokens) {
		[token resignFirstResponder];
	}
	
	return TRUE;
}


- (void)layoutSubviews
{
	[_label sizeToFit];
	
	CGRect labelFrame = CGRectMake(_contentInsets.left, _contentInsets.top, [_label frame].size.width, [_label frame].size.height + 3);
	_label.frame = labelFrame;
	
	CGRect currentRect = CGRectZero;
	currentRect.origin.x += labelFrame.size.width + labelFrame.origin.x + _tokenPadding.width;
	
	for(UIButton *token in self.tokens) {
		CGRect frame = [token frame];
		
		if((currentRect.origin.x + frame.size.width) > self.frame.size.width)
			currentRect.origin = CGPointMake(_contentInsets.left, (currentRect.origin.y + frame.size.height + _tokenPadding.height));
		
		frame.origin.x = currentRect.origin.x;
		frame.origin.y = currentRect.origin.y + _contentInsets.top - 1;
		[token setFrame:frame];
		
		if(![token superview])
			[self addSubview:token];
		
		currentRect.origin.x += frame.size.width + _tokenPadding.width;
		currentRect.size = frame.size;
	}
	
	
	CGRect textFieldFrame = [self.textField frame];
	textFieldFrame.origin = currentRect.origin;
	
	if((self.frame.size.width - textFieldFrame.origin.x) >= 60) {
		textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x - _contentInsets.right;
	} else {
		textFieldFrame.size.width = self.frame.size.width - _contentInsets.right;
        textFieldFrame.origin = CGPointMake(_contentInsets.left, (currentRect.origin.y + currentRect.size.height + _contentInsets.top));
	}
	
	textFieldFrame.origin.y += _contentInsets.top;
	self.textField.frame = textFieldFrame;
}



#pragma mark - Managing tokens


- (NSArray *)allTokens
{
	return [self.tokens copy];
}


- (void)addTokenIdentifiers:(NSArray *)tokenIdentifiers
{
	for(id identifiers in tokenIdentifiers) {
		NSString *labelText = [self labelForTokenIdentifier:identifiers];
		
		[self addTokenWithLabel:labelText forIdentifier:identifiers];
	}
}


- (void)removeAllTokens
{
	for(JSTokenButton *token in [self allTokens]) {
		[self removeToken:token];
	}
}


- (void)addTokenWithLabel:(NSString *)labelText forIdentifier:(id)identifier
{
	if([labelText length] == 0)
		return;
	
    [self.textField setText:ZERO_WIDTH_SPACE_STRING];
	labelText = [labelText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
	if([labelText length]) {
		JSTokenButton *token = [JSTokenButton tokenWithLabel:labelText forIdentifier:identifier];
        token.parentField = self;
		
		CGRect frame = [token frame];
		
		if(frame.size.width > self.frame.size.width)
			frame.size.width = self.frame.size.width - _contentInsets.left - _contentInsets.right;
		
		token.frame = frame;
		[token addTarget:self action:@selector(selectToken:) forControlEvents:UIControlEventTouchUpInside];
		[self.tokens addObject:token];
		
		if([self.delegate respondsToSelector:@selector(tokenField:didAddTokenWithIdentifier:)])
			[self.delegate tokenField:self didAddTokenWithIdentifier:identifier];
		
		[self setNeedsLayout];
	}
}


- (void)removeToken:(JSTokenButton *)tokenToRemove
{
	if(!tokenToRemove)
		return;
    
	if([tokenToRemove isFirstResponder])
		[self.textField becomeFirstResponder];
	
	[tokenToRemove removeFromSuperview];	
	[self.tokens removeObject:tokenToRemove];
	
	if([self.delegate respondsToSelector:@selector(tokenField:didRemoveTokenWithIdentifier:)])
		[self.delegate tokenField:self didRemoveTokenWithIdentifier:tokenToRemove.identifier];
	
	[self setNeedsLayout];
}


- (void)removeTokenForIdentifier:(id)identifier
{
	if(!identifier)
		return;
	
	for(JSTokenButton *token in self.tokens) {
		if([token.identifier isEqual:identifier]) {
			[self removeToken:token];
			break;
		}
	}
}


- (void)deleteActiveToken
{
	for(JSTokenButton *token in self.tokens) {
		if([token isActive]) {
			[self removeToken:token];
			break;
		}
	}
}


- (void)selectToken:(JSTokenButton *)tokenToSelect
{
	for(JSTokenButton *token in self.tokens) {
		token.active = FALSE;
	}
	
	tokenToSelect.active = TRUE;
	[tokenToSelect becomeFirstResponder];
}



#pragma mark -
#pragma mark Interacting with the delegate


- (void)handleTextDidChange:(NSNotification *)note
{
	// Ensure there's always a space at the beginning
	NSMutableString *text = self.textField.text.mutableCopy;
	
	if(![text hasPrefix:ZERO_WIDTH_SPACE_STRING]) {
		[text insertString:ZERO_WIDTH_SPACE_STRING atIndex:0];
		self.textField.text = text;
	}
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@""]
		&& (NSEqualRanges(range, NSMakeRange(0, 0))
		|| [[self.textField.text substringWithRange:range] isEqualToString:ZERO_WIDTH_SPACE_STRING]))
	{
        JSTokenButton *token = [self.tokens lastObject];
        [token becomeFirstResponder];
		return NO;
	}
	
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self askDelegateToTokenizeText];
	return FALSE;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self askDelegateToTokenizeText];
	
    if([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)])
        [self.delegate tokenFieldDidEndEditing:self];
}


- (void)askDelegateToTokenizeText
{
	NSString *untokenizedText = self.textField.text;
	NSArray *newTokenIdentifiers = nil;
	
	if([self.delegate respondsToSelector:@selector(tokenField:tokenIdentifiersForString:)]) {
		// Ask the delegate to tokenize the given string
		newTokenIdentifiers = [self.delegate tokenField:self tokenIdentifiersForString:untokenizedText];
	} else {
		// Otherwise treat tokens as any characters seperated by a space
		newTokenIdentifiers = [untokenizedText componentsSeparatedByString:@" "];
	}
	
	for(id tokenIdentifier in newTokenIdentifiers) {
		if([tokenIdentifier length] == 0)
			continue;
		
		NSString *labelText = [self labelForTokenIdentifier:tokenIdentifier];
		[self addTokenWithLabel:labelText forIdentifier:tokenIdentifier];
	}
}


- (NSString *)labelForTokenIdentifier:(id)identifier
{
	NSString *labelText = nil;
	
	if([self.delegate respondsToSelector:@selector(tokenField:labelForIdentifier:)])
		labelText = [self.delegate tokenField:self labelForIdentifier:identifier];
	
	// Otherwise if its a string use the tokenIdentifier for the tokens label
	if(!labelText)
		labelText = identifier;
	
	// Make sure that the label is a string
	if([labelText isKindOfClass:[NSString class]] && [labelText length] > 0)
		return labelText;
	
	return nil;
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end


