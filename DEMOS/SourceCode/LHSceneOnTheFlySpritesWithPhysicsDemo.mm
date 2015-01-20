//
//  LHSceneOnTheFlySpritesWithPhysicsDemo.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneOnTheFlySpritesWithPhysicsDemo.h"

@implementation LHSceneOnTheFlySpritesWithPhysicsDemo

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"PUBLISH_FOLDER/emptyLevel.lhplist"];
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    
    if(self = [super initWithContentOfFile:levelPlistFile])
    {
        /*INIT YOUR CONTENT HERE*/
        
        {
            CGSize size = [self size];
            [LHSceneDemo createMultilineLabelAtPosition:CGPointMake(size.width*0.5, size.height - 150)
                                          asChildOfNode:[self uiNode]
                                               withText:@"ON THE FLY SPRITES DEMO\nClick to create a sprite with a physics body as defined in the\nLevelHelper 2 Sprite Packer & Physics Editor tool."];

        }
    }
    
    return self;
}

#if TARGET_OS_IPHONE
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];

    [self createSpriteAtLocation:location];
    
    //dont forget to call super
    [super touchesBegan:touches withEvent:event];
}

#else

-(void)mouseDown:(NSEvent *)theEvent{
    
    CGPoint location = [theEvent locationInNode:self];
    
    [self createSpriteAtLocation:location];
    
    [super mouseDown:theEvent];
}

#endif

-(void)createSpriteAtLocation:(CGPoint)location
{
    location = [self convertPoint:location toNode:[self gameWorldNode]];
    
    LHSprite* sprite = [LHSprite createWithSpriteName:@"carBody"
                                            atlasFile:@"carParts.atlasc"
                                               folder:@"PUBLISH_FOLDER/"
                                               parent:[self gameWorldNode]];
    
    
    NSLog(@"Did create %@ %p\n", [sprite name], sprite);
    if(sprite){
        [sprite setPosition:location];
    }

}


@end
