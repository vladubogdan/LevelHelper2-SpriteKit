//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneParallaxDemo.h"

@implementation LHSceneParallaxDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/parallaxTest.plist"];
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
        [label setText:@"Parallax Test + Camera Following Node"];
        [label setFontColor:[SKColor redColor]];
        [label setColor:[SKColor whiteColor]];
        [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [[self uiNode] addChild:label];
        
        float txtOffset = 70;
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This test demonstrate a parallax which will give an illusion of depth,"];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"The parallax node follows the camera."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"The camera follows the candy sprite."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This text is added as UI element so it won't move with the camera."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
    }
    
    return self;
}

@end
