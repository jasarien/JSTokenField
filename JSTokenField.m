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

NSString *const JSTokenFieldFrameDidChangeNotification = @"JSTokenFieldFrameDidChangeNotification";
NSString *const JSTokenFieldNewFrameKey = @"JSTokenFieldNewFrameKey";
NSString *const JSTokenFieldOldFrameKey = @"JSTokenFieldOldFrameKey";
NSString *const JSDeletedTokenKey = @"JSDeletedTokenKey";

#define HEIGHT_PADDING 3
#define WIDTH_PADDING 3

#define DEFAULT_HEIGHT 31
#define ZERO_WIDTH_SPACE_STRING @"\u200B"


@interface JSTokenField ()
@property (nonatomic, readwrite) UITextField *textField;

- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)obj;
- (void)deleteActiveToken;

@end


@implementation JSTokenField
@synthesize tokens = _tokens;
@synthesize label = _label;
@synthesize delegate = _delegate;



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
	_tokens = [[NSMutableArray alloc] init];
	
	
	// Setup the fields appearance views
    [self setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	
    CGRect frame = self.frame;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, frame.size.height)];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setTextColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0]];
    [label setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
    [self addSubview:label];
	self.label = label;
    
    frame.origin.y += HEIGHT_PADDING;
    frame.size.height -= HEIGHT_PADDING * 2;
	
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
	for(JSTokenButton *token in _tokens) {
		[token resignFirstResponder];
	}
	
	[self.textField resignFirstResponder];
	
	return TRUE;
}



#pragma mark - Managing tokens


- (void)addTokenWithTitle:(NSString *)tokenTitle representedObject:(id)representedObject
{
	tokenTitle = [tokenTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    [self.textField setText:ZERO_WIDTH_SPACE_STRING];
    
	if([tokenTitle length]) {
		JSTokenButton *token = [self tokenWithString:tokenTitle representedObject:representedObject];
        token.parentField = self;
		[_tokens addObject:token];
		
		if ([self.delegate respondsToSelector:@selector(tokenField:didAddToken:representedObject:)])
			[self.delegate tokenField:self didAddToken:tokenTitle representedObject:representedObject];
		
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
	[_tokens removeObject:tokenToRemove];
	
	if([self.delegate respondsToSelector:@selector(tokenField:didRemoveToken:representedObject:)]) {
		NSString *tokenName = [tokenToRemove titleForState:UIControlStateNormal];
		[self.delegate tokenField:self didRemoveToken:tokenName representedObject:tokenToRemove.representedObject];
	}
	
	[self setNeedsLayout];
}


- (void)removeTokenForString:(NSString *)string
{
	for(JSTokenButton *token in _tokens) {
		if([[token titleForState:UIControlStateNormal] isEqualToString:string]) {
			[self removeToken:token];
			break;
		}
	}
}


- (void)removeTokenWithRepresentedObject:(id)representedObject
{
	for(JSTokenButton *token in _tokens) {
		if([[token representedObject] isEqual:representedObject]) {
			[self removeToken:token];
			break;
		}
	}
}


- (void)deleteActiveToken
{
	JSTokenButton *tokenToDelete = nil;
	
	for(JSTokenButton *token in _tokens) {
		if([token isActive]) {
			tokenToDelete = token;
			break;
		}
	}
	
	if(tokenToDelete) {
		[tokenToDelete removeFromSuperview];
		[_tokens removeObject:tokenToDelete];
		
		if ([self.delegate respondsToSelector:@selector(tokenField:didRemove:representedObject:)]) {
			NSString *tokenName = [tokenToDelete titleForState:UIControlStateNormal];
			[self.delegate tokenField:self didRemoveToken:tokenName representedObject:tokenToDelete.representedObject];
		}
		
		[self setNeedsLayout];
	}
}


- (JSTokenButton *)tokenWithString:(NSString *)string representedObject:(id)object
{
	JSTokenButton *token = [JSTokenButton tokenWithString:string representedObject:object];
	
	CGRect frame = [token frame];
	if(frame.size.width > self.frame.size.width)
		frame.size.width = self.frame.size.width - (WIDTH_PADDING * 2);
	
	[token setFrame:frame];
	[token addTarget:self action:@selector(selectToken:) forControlEvents:UIControlEventTouchUpInside];
	
	return token;
}



- (void)layoutSubviews
{
	[_label sizeToFit];
	[_label setFrame:CGRectMake(WIDTH_PADDING, HEIGHT_PADDING, [_label frame].size.width, [_label frame].size.height + 3)];
	
	CGRect currentRect = CGRectZero;
	currentRect.origin.x += _label.frame.size.width + _label.frame.origin.x + WIDTH_PADDING;
	
	for(UIButton *token in _tokens) {
		CGRect frame = [token frame];
		
		if((currentRect.origin.x + frame.size.width) > self.frame.size.width)
			currentRect.origin = CGPointMake(WIDTH_PADDING, (currentRect.origin.y + frame.size.height + HEIGHT_PADDING));
		
		frame.origin.x = currentRect.origin.x;
		frame.origin.y = currentRect.origin.y + HEIGHT_PADDING;
		[token setFrame:frame];
		
		if(![token superview])
			[self addSubview:token];
		
		currentRect.origin.x += frame.size.width + WIDTH_PADDING;
		currentRect.size = frame.size;
	}
	
	
	CGRect textFieldFrame = [self.textField frame];
	textFieldFrame.origin = currentRect.origin;
	
	if((self.frame.size.width - textFieldFrame.origin.x) >= 60) {
		textFieldFrame.size.width = self.frame.size.width - textFieldFrame.origin.x;
	} else {
		textFieldFrame.size.width = self.frame.size.width;
        textFieldFrame.origin = CGPointMake(WIDTH_PADDING * 2, (currentRect.origin.y + currentRect.size.height + HEIGHT_PADDING));
	}
	
	textFieldFrame.origin.y += HEIGHT_PADDING;
	self.textField.frame = textFieldFrame;
}


- (void)selectToken:(JSTokenButton *)tokenToSelect
{
	for(JSTokenButton *token in _tokens) {
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
    if ([string isEqualToString:@""]
		&& (NSEqualRanges(range, NSMakeRange(0, 0))
		|| [[self.textField.text substringWithRange:range] isEqualToString:ZERO_WIDTH_SPACE_STRING]))
	{
        JSTokenButton *token = [_tokens lastObject];
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
	if([self.delegate respondsToSelector:@selector(tokenField:tokensForText:)]) {
		// Create any new tokens
		NSArray *newTokenStrings = [self.delegate tokenField:self tokensForText:self.textField.text];
		
		for(NSString *tokenString in newTokenStrings) {
			if([tokenString isKindOfClass:[NSString class]] && [tokenString length])
				[self addTokenWithTitle:tokenString representedObject:tokenString];
		}
	}
}


@end
