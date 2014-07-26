//
//  MyScene.m
//  SpriteKitAPI-DEVELOPMENT
//
//  Created by Bogdan Vladu on 16/05/14.
//  Copyright (c) 2014 VLADU BOGDAN DANIEL PFA. All rights reserved.
//

#import "LHSceneSubclass.h"

@implementation LHSceneSubclass

+(id)scene
{
    return [[self alloc] initWithContentOfFile:@"DEMO_PUBLISH_FOLDER/officerLevel.lhplist"];
    
}

-(id)initWithContentOfFile:(NSString *)levelPlistFile{
    self = [super initWithContentOfFile:levelPlistFile];
    
    if(self){
        
        /*INIT YOUR CONTENT HERE*/
        
    }
    
    return self;
}

#if TARGET_OS_IPHONE
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{

    //don't forget to call super
    [super touchesBegan:touches withEvent:event];
}
#else

-(void)mouseDown:(NSEvent *)theEvent{
    [super mouseDown:theEvent];
}

#endif

@end
