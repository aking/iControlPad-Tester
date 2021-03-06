//
//  ButtonStates.m
//  TextEditing
//
//  Created by Infinite Sands on 3/25/11.
//  Modified by Adam King (adding NUB controls)
//

#import "ButtonStates.h"


@implementation ButtonStates

static int LEFT_BYTE[] = {BUTTON_UP, BUTTON_RIGHT, BUTTON_LEFT, BUTTON_DOWN, BUTTON_L, BUTTON_SELECT};
static int RIGHT_BYTE[] = {BUTTON_START, BUTTON_Y, BUTTON_A, BUTTON_X, BUTTON_B, BUTTON_R};
static NSString* names[] = {@"LEFT", @"UP", @"RIGHT", @"DOWN", @"SELECT", @"START", @"A", @"Y", @"B", @"X", @"L", @"R"};

static int buttons[256];
static char buffer[256];
static int pos = 0;

+ (void) reset
{
    NSLog(@"[ButtonStates:init] Called");
    memset(buttons, 0, sizeof(int)*256);
    memset(buffer, 0, sizeof(char)*256);
    pos = 0;
    
    // set the nub values to '0' (internally, offset by 64)
    [ButtonStates setState:NUB_LEFT value:(0x4040)];
    [ButtonStates setState:NUB_RIGHT value:(0x4040)];
}

+ (int) getState:(int)button
{
    return buttons[button];
}

+ (void) setState:(int)button value:(int)value
{
    buttons[button] = value;
}

BOOL areValidNubValues(char* _vals)
{
    for(int i=0; i<4; i++)
    {
        if(_vals[i] < 0 || _vals[i] > 96)
        {
            if(_vals[i] == 97)  // 'Bug' in BT module can't pass 96, so uses 97 instead.
                _vals[i] = 96;  // Convert the 97 to a 96 and continue.
            else
                return NO;
        }
    }
    
    return YES;
}

+ (void) handle:(char)c
{
    char left;
    char right;
    
    buffer[pos++] = c;
    
    // Handle nub input
    if(pos > 4 && buffer[0] == 'w')
    {
        // validate that the next 4 values are 'valid'.  If not, skip over
        // till the next known marker (ie: 'm', 'w').  Note: we can't really
        // test the first two values (for left nub), then the next two values
        // (for the right nub) as I was originally doing as a left nub value 
        // might have dropped and it'd end up with a value from each nub - bad

        if(areValidNubValues(buffer+1))
        {
            // Left NUB
            // Store Y in upper 8 bytes
            int nubValue = 0;
            nubValue = (buffer[2]<<8)|buffer[1];
            [ButtonStates setState:NUB_LEFT value:nubValue];

            // Right NUB   
            nubValue = (buffer[4]<<8)|buffer[3];
            [ButtonStates setState:NUB_RIGHT value:nubValue];

            for(int i=5; i<pos; i++) buffer[i-5] = buffer[i];
            
            pos -= 5;
        }
        else
        {
            // We don't have 4 clean values, so skip ahead to the next valid marker
            for(int i=1; i<pos; i++)
            {
                if(buffer[i] == 'm' || buffer[i] == 'w')
                {
                    for(int j=i; j<pos; j++) buffer[j-i] = buffer[j];                    
                    pos -= i;
                    break;
                }
            }
        }
    }
        
    // handles button presses
    if(pos > 2 && buffer[0] == 'm')
    {
        left = buffer[1] - 32;
        right = buffer[2] - 32;
        
        for(int i=0; i<6; i++)
        {
            [ButtonStates setState:LEFT_BYTE[i] value:(left & 0x01)];
            left >>= 1;
        }
        
        for(int i=0; i<6; i++)
        {
            [ButtonStates setState:RIGHT_BYTE[i] value:(right & 0x01)];
            right >>= 1;
        }
        
        for(int i=3; i<pos; i++) buffer[i-3] = buffer[i];
        
        pos -= 3;
    }
    
    // the next valid char _must_ be a valid marker.  If not, sync up to one
    if(pos > 0 && (buffer[0] != 'm' && buffer[0] != 'w'))
    {
        BOOL found = NO;
        for(int i=1; i<pos; i++)
        {
            if(buffer[i] == 'm' || buffer[i] == 'w')
            {
                for(int j=i; j<pos; j++) buffer[j-i] = buffer[j];                    
                pos -= i;
                found = YES;
                break;
            }
        }
        
        // hmm.. no valid tag found.  Nuke it all
        if(!found)
        {
            NSLog(@"WARNING: No valid markers found. Dumping current character stack:%d", pos);
            for(int i=0; i<pos; i++)
            {
                NSLog(@"%d ", buffer[i]);
            }
            pos = 0;
        }
    }

    if(pos > 20) NSLog(@"Possible error - %i characters queued!", pos);
    if(pos >= 256) pos = 0;
}

+ (NSString*) getName:(int)button
{
    return names[button];
}

@end
