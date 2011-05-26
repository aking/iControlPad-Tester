//
//  ButtonStates.m
//  TextEditing
//
//  Created by Infinite Sands on 3/25/11.
//

#import "iControlPadReaderView.h"
#import "ButtonStates.h"

@implementation iControlPadReaderView

- (id)initWithFrame:(CGRect)frame 
{
    self = [super initWithFrame:frame];
    
    // Place the text field slightly offscreen (to hide the cursor)
    textField = [[UITextField alloc] initWithFrame:CGRectMake(-5, 10, 50, 10)];
    [textField setDelegate:self];
    [self addSubview:textField];
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    [textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [textField becomeFirstResponder];
    
    [ButtonStates reset];

    return self;
}

- (BOOL)canBecomeFirstResponder 
{ 
    return NO; 
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //NSLog(@"textField:%@", string);
    for(int i=0; i<[string length]; i++)
    {
        [ButtonStates handle:[string characterAtIndex:i]];
    }
    
    if([string length] > 1)
        NSLog(@"LONG STRING:%d %@", [string length], string);
    
    [self setNeedsDisplay];

    return NO;
}

@end