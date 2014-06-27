//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneAnimationsDemo.h"

@implementation LHSceneAnimationsDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/officerLevel.plist"];
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
        [label setText:@"Animations Test"];
        [label setFontColor:[SKColor whiteColor]];
        [label setColor:[SKColor whiteColor]];
        [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [[self uiNode] addChild:label];
        
        float txtOffset = 70;
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This test demonstrate a character animation,"];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"the POSITION of the character is PER DEVICE."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"Change the device (iPhone/iPad) to see that the police officer is placed in a different position."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"The background is using a standalone image (not a sprite sheet) and its also different on each device."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
        }
        
    }
    
    return self;
}

@end
