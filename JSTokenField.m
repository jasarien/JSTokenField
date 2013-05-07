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

NSString * const JSZeroWidthSpaceString = @"\u200B";


@interface JSTokenField ()

@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, readwrite, retain) UITextField *textField;
@property (nonatomic, readwrite, retain) UIScrollView *scrollView;

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
	self.clipsToBounds = TRUE;
    [self setBackgroundColor:[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]];
	
    CGRect frame = self.frame;
	
	UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
	self.scrollView = scrollView;
	[self addSubview:scrollView];
	
	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 3.0, 8.0, 3.0);
	self.tokenPadding = CGSizeMake(5, 5);
	self.contentInsets = contentInsets;
	
    frame.size.height -= contentInsets.top + contentInsets.bottom;
	
	
	UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
    textField.delegate = self;
	textField.text = JSZeroWidthSpaceString;
	
    [scrollView addSubview:textField];
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
	self.scrollView.frame = self.bounds;
	
	CGRect currentRect = CGRectMake(_contentInsets.left, 0.0, 0.0, 0.0);
	
	for(UIButton *token in self.tokens) {
		CGRect tokenFrame = [token frame];
		
		if((currentRect.origin.x + tokenFrame.size.width) > self.frame.size.width - _contentInsets.right)
			currentRect.origin = CGPointMake(_contentInsets.left, (currentRect.origin.y + tokenFrame.size.height + _tokenPadding.height));
		
		tokenFrame.origin.x = currentRect.origin.x;
		tokenFrame.origin.y = currentRect.origin.y + _contentInsets.top - 1;
		token.frame = tokenFrame;
		
		if(![token superview])
			[self.scrollView addSubview:token];
		
		currentRect.origin.x += tokenFrame.size.width + _tokenPadding.width;
		currentRect.size = tokenFrame.size;
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
	
	self.scrollView.contentSize = CGSizeMake(self.frame.size.width, CGRectGetMaxY(currentRect) + 30.0 + _contentInsets.bottom + _tokenPadding.height);
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
	
    self.textField.text = JSZeroWidthSpaceString;
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
	
	[self scrollToBottom];
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
	
	if(![text hasPrefix:JSZeroWidthSpaceString]) {
		[text insertString:JSZeroWidthSpaceString atIndex:0];
		self.textField.text = text;
	}
	
	[self scrollToBottom];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if([string isEqualToString:@""]
		&& (NSEqualRanges(range, NSMakeRange(0, 0))
		|| [[self.textField.text substringWithRange:range] isEqualToString:JSZeroWidthSpaceString]))
	{
        JSTokenButton *token = [self.tokens lastObject];
        [token becomeFirstResponder];
		return NO;
	}
	
	[self scrollToBottom];
	return YES;
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	[self askDelegateToTokenizeText];
	[self scrollToBottom];

	return FALSE;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self askDelegateToTokenizeText];
	[self scrollToBottom];
	
    if([self.delegate respondsToSelector:@selector(tokenFieldDidEndEditing:)])
        [self.delegate tokenFieldDidEndEditing:self];
}


- (void)scrollToBottom
{
	UIScrollView *scrollView = self.scrollView;
	
	CGFloat height = 10.0;
	CGSize contentSize = [scrollView contentSize];
	CGRect scrollRect = CGRectMake(0.0, contentSize.height + _contentInsets.top + _contentInsets.bottom + 20.0, contentSize.width, height);
	
	[CATransaction begin];
	[CATransaction setValue:[NSNumber numberWithBool:TRUE] forKey:kCATransactionDisableActions];
	[scrollView scrollRectToVisible:scrollRect animated:FALSE];
	[CATransaction commit];
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


