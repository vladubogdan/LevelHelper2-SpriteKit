//
//  LHSceneSubclass.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneSubclass.h"

@implementation LHSceneSubclass

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"LH2-Published/example.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        CGSize size = [self size];
        
        {
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            [label setName:@"InfoLabel"];
            [label setFontSize:40];
            [label setZPosition:60];
            [label setText:@"Welcome to"];
            [label setFontColor:[SKColor blackColor]];
            [label setColor:[SKColor whiteColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height*0.5+120)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
            
        }
        {
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            [label setName:@"InfoLabel"];
            [label setFontSize:80];
            [label setZPosition:60];
            [label setText:@"LevelHelper 2"];
            [label setFontColor:[SKColor blackColor]];
            [label setColor:[SKColor whiteColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height*0.5+60)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
        }
        
        {
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            [label setName:@"InfoLabel"];
            [label setFontSize:20];
            [label setZPosition:60];
            [label setText:@"Run the DEMOS targets for examples."];
            [label setFontColor:[SKColor blackColor]];
            [label setColor:[SKColor whiteColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height*0.5-60)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
        }

        {
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            [label setName:@"InfoLabel"];
            [label setFontSize:20];
            [label setZPosition:60];
            [label setText:@"Check LHSceneSubclass.mm to learn how to load a level."];
            [label setFontColor:[SKColor blackColor]];
            [label setColor:[SKColor whiteColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height*0.5-80)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
        }

        {
            SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica"];
            [label setName:@"InfoLabel"];
            [label setFontSize:20];
            [label setZPosition:60];
            [label setText:@"Visit www.gamedevhelper.com for more learn resources."];
            [label setFontColor:[SKColor blackColor]];
            [label setColor:[SKColor whiteColor]];
            [label setPosition:CGPointMake(size.width*0.5, size.height*0.5-100)];
            [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
            [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
            [[self uiNode] addChild:label];
        }
                
    }
    
    return self;
}


@end
