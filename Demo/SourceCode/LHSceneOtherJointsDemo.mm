//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneOtherJointsDemo.h"

@implementation LHSceneOtherJointsDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/otherJointsTest.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        

        CGSize size = [[self scene] size];
        
        SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
        [label setName:@"InfoLabel"];
        [label setFontSize:16];
        [label setZPosition:60];
        [label setText:@"Other Joints Test"];
        [label setFontColor:[SKColor magentaColor]];
        [label setColor:[SKColor whiteColor]];
        [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [[self uiNode] addChild:label];
        
        float txtOffset = 70;
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This test demonstrate other joint types."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"Click to remove joints."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
        }
    }
    
    return self;
}

#if TARGET_OS_IPHONE
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}

#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    [super mouseDown:theEvent];
}
#endif
@end
