//
//  WGLVideoPlayerGesturer.h
//  WGLVideoPlayerGesturer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//
/**
 这是一个通过屏幕手势来控制视频播放器的音量、亮度、进度的控件
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, WGLGestureDirection) {
    WGLGestureDirectionLeftOrRight,     //左右划动
    WGLGestureDirectionUpOrDown,        //上下划动
    WGLGestureDirectionNone             //无方向
};

typedef NS_ENUM(NSUInteger, WGLAjustType) {
    WGLAjustTypeNone,               //无调节
    WGLAjustTypeVolume,             //调节音量
    WGLAjustTypeBrightness,         //调节亮度
    WGLAjustTypeVideoRate,          //调节进度
};

typedef void(^WGLVideoPlayerGesturerCallback)(WGLAjustType ajustType, CGFloat value);

@interface WGLVideoPlayerGesturer : NSObject

@property (nonatomic, assign) BOOL isFullScreen;        //屏幕是全屏还是竖屏
@property (nonatomic, assign) WGLGestureDirection direction;
@property (nonatomic, assign) CGFloat startVB;          //音量、亮度初始值
@property (nonatomic, assign) CGFloat startVideoRate;   //进度初始值
@property (nonatomic, assign) CGFloat endVB;            //音量、亮度最终值
@property (nonatomic, assign) CGFloat endVideoRate;     //进度最终值
@property (nonatomic, assign) uint64_t currentPlaybackTime; //当前播放进度
@property (nonatomic, assign) uint64_t duration;        //视频总时长

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(UIView *)aView callback:(WGLVideoPlayerGesturerCallback)callback;

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(UIView *)aView callback:(WGLVideoPlayerGesturerCallback)callback;

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(UIView *)aView callback:(void(^)(void))callback;

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event inView:(UIView *)aView callback:(void(^)(void))callback;

@end
