//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneCameraFollowNodeDemo.h"

@implementation LHSceneCameraFollowNodeDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/cameraFollowNodeTest.plist"];
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
        [label setText:@"Camera Follow Node Test"];
        [label setFontColor:[SKColor redColor]];
        [label setColor:[SKColor whiteColor]];
        [label setPosition:CGPointMake(size.width*0.5, size.height-50)];
        [label setVerticalAlignmentMode:SKLabelVerticalAlignmentModeCenter];
        [label setHorizontalAlignmentMode:SKLabelHorizontalAlignmentModeCenter];
        [[self uiNode] addChild:label];
        
        float txtOffset = 70;
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This test demonstrate using a camera,"];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"that will follow a node - in this case the candy."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"The camera is also restricted inside the game world rectangle."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"As such it will not display anything outside the game world rectangle."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"Click to change gravity direction."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }

        {
            SKLabelNode* labelLine = [label copy];
            [labelLine setText:@"This text is added to the uiNode and as such it will not move with the camera."];
            [labelLine setPosition:CGPointMake(size.width*0.5, size.height-txtOffset)];
            [[self uiNode] addChild:labelLine];
            txtOffset += 20;
        }
        
    }
    
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint gravity = [self globalGravity];
    
    NSLog(@"Changing gravity direction %f %f.", gravity.x, gravity.y);

    [self setGlobalGravity:CGPointMake(gravity.x, -gravity.y)];
    
    
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}

@end
