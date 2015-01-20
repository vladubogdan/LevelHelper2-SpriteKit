//
//  LHSprite.m
//  LevelHelper2-SpriteKit
//
//  Created by Bogdan Vladu on 24/03/14.
//  Copyright (c) 2014 GameDevHelper.com. All rights reserved.
//

#import "LHSprite.h"
#import "LHUtils.h"
#import "LHScene.h"
#import "NSDictionary+LHDictionary.h"
#import "LHAnimation.h"
#import "LHConfig.h"
#import "LHGameWorldNode.h"


@interface LHScene (LH_SCENE_NODES_PRIVATE_UTILS)
-(NSString*)currentDeviceSuffix;
-(LHDevice*)currentDevice;

-(void)setEditorBodyInfoForSpriteName:(NSString*)sprName
                                atlas:(NSString*)atlasPlist
                             bodyInfo:(NSDictionary*)bodyInfo;
-(NSDictionary*)getEditorBodyInfoForSpriteName:(NSString*)sprName
                                         atlas:(NSString*)atlasPlist;
-(BOOL)hasEditorBodyInfoForImageFilePath:(NSString*)atlasImgFile;

@end

@implementation LHSprite
{
    LHNodeProtocolImpl*         _nodeProtocolImp;
    LHNodeAnimationProtocolImp* _animationProtocolImp;
    LHNodePhysicsProtocolImp*   _physicsProtocolImp;
    
    __unsafe_unretained SKTextureAtlas* atlas;
    
    NSString* _imageFilePath;
    NSString* _spriteFrameName;
}

-(void)dealloc{

    atlas = nil;
    LH_SAFE_RELEASE(_physicsProtocolImp);
    LH_SAFE_RELEASE(_nodeProtocolImp);
    LH_SAFE_RELEASE(_animationProtocolImp);
    
    LH_SAFE_RELEASE(_imageFilePath);
    LH_SAFE_RELEASE(_spriteFrameName);
    
    LH_SUPER_DEALLOC();
}

-(NSString*)imageFilePath{
    return _imageFilePath;
}
-(NSString*)spriteFrameName{
    return _spriteFrameName;
}

-(void)cacheSpriteFramesInfo:(NSString*)imagePath scene:(LHScene*)scene
{
    NSString* atlasName = [[imagePath lastPathComponent] stringByDeletingPathExtension];
    atlasName = [[scene relativePath] stringByAppendingPathComponent:atlasName];

    if(false == [scene hasEditorBodyInfoForImageFilePath:imagePath])
    {
        NSString* plistAtlasPath = [atlasName stringByAppendingPathExtension:@"atlasc"];
        plistAtlasPath = [plistAtlasPath stringByAppendingPathComponent:[atlasName lastPathComponent]];
        plistAtlasPath = [[NSBundle mainBundle] pathForResource:plistAtlasPath ofType:@"plist"];
        
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:plistAtlasPath];
        
        NSArray* images = [dict objectForKey:@"images"];
        for(NSDictionary* imageInf in images)
        {
            NSString* imgPath = [imageInf objectForKey:@"path"];
            imgPath = [imgPath stringByDeletingPathExtension];
            
            if([images count] == 1 || [imgPath hasSuffix:[[scene currentDevice] suffix]])
            {
                NSArray* subImages = [imageInf objectForKey:@"subimages"];
                
                for(NSDictionary* subImgInf in subImages){
                    NSDictionary* bodyInfo = [subImgInf objectForKey:@"body"];
                    NSString* spriteFrameName = [subImgInf objectForKey:@"name"];
                    
                    if(bodyInfo)
                    {
                        [scene setEditorBodyInfoForSpriteName:spriteFrameName atlas:imagePath bodyInfo:bodyInfo];
                    }
                }
            }
        }
    }
    
    atlas = [scene textureAtlasWithImagePath:atlasName];
}

+ (instancetype)createWithSpriteName:(NSString*)spriteFrameName
                           atlasFile:(NSString*)imageFile
                              folder:(NSString*)folder
                              parent:(SKNode*)prnt
{
    return LH_AUTORELEASED([[self alloc] initWithSpriteName:spriteFrameName
                                                  atlasFile:imageFile
                                                     folder:folder
                                                     parent:prnt]);
}

-(instancetype)initWithSpriteName:(NSString*)spriteFrameName
                        atlasFile:(NSString*)imageFile
                           folder:(NSString*)folder
                           parent:(SKNode*)prnt
{
    if(self = [super initWithColor:[SKColor whiteColor] size:CGSizeZero]){
        
        [prnt addChild:self];
        
        LHScene* scene = (LHScene*)[self scene];
        NSString* imagePath = [LHUtils imagePathWithFilename:imageFile
                                                      folder:folder
                                                      suffix:[scene currentDeviceSuffix]];
        
        SKTexture* texture = nil;
        
        if(spriteFrameName){
            
            [self cacheSpriteFramesInfo:imagePath scene:scene];
            texture = [atlas textureNamed:spriteFrameName];
            
            _spriteFrameName = [[NSString alloc] initWithString:spriteFrameName];
            
        }
        else{
            texture = [scene textureWithImagePath:imagePath];
        }
        
        if(texture){
            [self setTexture:texture];
            [self setSize:texture.size];
        }
        
        [self setName:spriteFrameName];
        
        _imageFilePath = [[NSString alloc] initWithString:imagePath];
        
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:nil
                                                                                    node:self];
        
        if(texture){
            [self setSize:texture.size];
        }
        
        //scale is handled by physics protocol because of diferences between spritekit and box2d handling
        _imageFilePath = [[NSString alloc] initWithString:imagePath];
        NSDictionary* phyInfo = [scene getEditorBodyInfoForSpriteName:spriteFrameName atlas:imagePath];
        
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:phyInfo
                                                                                                node:self
                                                                                               scale:CGPointMake(1, 1)];
        
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:nil
                                                                                                      node:self];
    }
    return self;
}


+ (instancetype)nodeWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{
    return LH_AUTORELEASED([[self alloc] initWithDictionary:dict
                                                               parent:prnt]);
}


- (instancetype)initWithDictionary:(NSDictionary*)dict
                            parent:(SKNode*)prnt{

    
    if(self = [super initWithColor:[SKColor whiteColor] size:CGSizeZero]){
        
        [prnt addChild:self];
        
        LHScene* scene = (LHScene*)[self scene];
        NSString* imagePath = [LHUtils imagePathWithFilename:[dict objectForKey:@"imageFileName"]
                                                      folder:[dict objectForKey:@"relativeImagePath"]
                                                      suffix:[scene currentDeviceSuffix]];
        
        SKTexture* texture = nil;
        
        NSString* spriteName = [dict objectForKey:@"spriteName"];
        if(spriteName){
            
            [self cacheSpriteFramesInfo:imagePath scene:scene];
            texture = [atlas textureNamed:spriteName];
        
            _spriteFrameName = [[NSString alloc] initWithString:spriteName];
        }
        else{
            texture = [scene textureWithImagePath:imagePath];
        }
        
        
        if(texture){
            [self setTexture:texture];
            [self setSize:texture.size];
        }

        _imageFilePath = [[NSString alloc] initWithString:imagePath];
                
        _nodeProtocolImp = [[LHNodeProtocolImpl alloc] initNodeProtocolImpWithDictionary:dict
                                                                                    node:self];

        [self setColor:[dict colorForKey:@"colorOverlay"]];

        if(texture){
            [self setSize:texture.size];
        }

        //scale is handled by physics protocol because of diferences between spritekit and box2d handling

        CGPoint scl = [dict pointForKey:@"scale"];
        _physicsProtocolImp = [[LHNodePhysicsProtocolImp alloc] initPhysicsProtocolImpWithDictionary:[dict objectForKey:@"nodePhysics"]
                                                                                                node:self
                                                                                               scale:scl];
                
    
        [LHNodeProtocolImpl loadChildrenForNode:self fromDictionary:dict];
        
        _animationProtocolImp = [[LHNodeAnimationProtocolImp alloc] initAnimationProtocolImpWithDictionary:dict
                                                                                                      node:self];
        
    }
    return self;
}

-(void)setSpriteFrameWithName:(NSString*)spriteFrame{
    if(atlas){
        SKTexture* texture = [atlas textureNamed:spriteFrame];
        if(texture){
            [self setTexture:texture];
            
            float xScale = [self xScale];
            float yScale = [self yScale];
            
            [self setXScale:1];
            [self setYScale:1];
            
            [self setSize:texture.size];
            
            [self setXScale:xScale];
            [self setYScale:yScale];
            
            LH_SAFE_RELEASE(_spriteFrameName);
            _spriteFrameName = [[NSString alloc] initWithString:spriteFrame];
        }
    }
}

#pragma mark - Box2D Support
#if LH_USE_BOX2D
LH_BOX2D_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION
#endif //LH_USE_BOX2D


#pragma mark - Common Physics Engines Support
LH_COMMON_PHYSICS_PROTOCOL_METHODS_IMPLEMENTATION


#pragma mark LHNodeProtocol Required
LH_NODE_PROTOCOL_METHODS_IMPLEMENTATION


- (void)update:(NSTimeInterval)currentTime delta:(float)dt
{
    [_physicsProtocolImp update:currentTime delta:dt];
    [_nodeProtocolImp update:currentTime delta:dt];
    [_animationProtocolImp update:currentTime delta:dt];
}

#pragma mark - LHNodeAnimationProtocol Required
LH_ANIMATION_PROTOCOL_METHODS_IMPLEMENTATION

@end
