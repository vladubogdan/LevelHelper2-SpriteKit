//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCameraDemo.h"

#import "LHSceneCameraFollowNodeDemo.h"

@implementation LHSceneCameraDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/cameraAnimationTest.plist"];
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
        [label setText:@"Camera Animation Test"];
        [label setFontColor:[SKColor redColor]];
        [label setColor:[SKColor whiteColor]];
        [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [[self uiNode] addChild:label];
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This test demonstrate using a camera,"];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-70)];
            [[self uiNode] addChild:labelLine];
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"that is moved by an animation."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-90)];
            [[self uiNode] addChild:labelLine];
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This text is added to the uiNode and as such it will not move with the camera."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-110)];
            [[self uiNode] addChild:labelLine];
        }
        
    }
    
    return self;
}

-(void)previousDemo{
    
}

-(void)nextDemo{
    [[self view] presentScene:[LHSceneCameraFollowNodeDemo scene]];
}

@end
