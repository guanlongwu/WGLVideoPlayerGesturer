//
//  WGLVideoPlayerGesturer.m
//  WGLVideoPlayerGesturer
//
//  Created by wugl on 2019/2/27.
//  Copyright © 2019年 WGLKit. All rights reserved.
//

#import "WGLVideoPlayerGesturer.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WGLVideoPlayerGesturer ()
@property (assign, nonatomic) CGPoint startPoint;
@end

@implementation WGLVideoPlayerGesturer

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(UIView *)aView callback:(WGLVideoPlayerGesturerCallback)callback {
    
    //记录首次触摸坐标
    self.startPoint = [[touches anyObject] locationInView:aView];
    
    WGLAjustType type = WGLAjustTypeNone;
    
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是亮度，右边是音量
    CGFloat intervalX = self.isFullScreen ? 100 : 50;
    if (self.startPoint.x <= (aView.frame.size.width / 2.0 - intervalX)) {
        //亮度
        self.startVB = [UIScreen mainScreen].brightness;
        type = WGLAjustTypeBrightness;
    } else if (self.startPoint.x >= (aView.frame.size.width / 2.0 + intervalX)) {
        //音量
        self.startVB = [self.class getSystemVolumValue];
        type = WGLAjustTypeVolume;
    }
    //方向置为无
    self.direction = WGLGestureDirectionNone;
    
    //播放进度
    self.startVideoRate = self.currentPlaybackTime / self.duration;
    
    if (callback) {
        callback(type, self.startVB);
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(UIView *)aView callback:(WGLVideoPlayerGesturerCallback)callback {
    CGPoint point = [[touches anyObject] locationInView:aView];
    
    //得出手指在Button上移动的距离
    CGPoint panPoint = CGPointMake(point.x - self.startPoint.x, point.y - self.startPoint.y);
    //分析出用户滑动的方向
    if (self.direction == WGLGestureDirectionNone) {
        if (panPoint.x >= 30 || panPoint.x <= -30) {
            //进度
            self.direction = WGLGestureDirectionLeftOrRight;
        }
        else if (panPoint.y >= 30 || panPoint.y <= -30) {
            //音量和亮度
            self.direction = WGLGestureDirectionUpOrDown;
        }
    }
    
    if (self.direction == WGLGestureDirectionNone) {
        return;
    }
    else if (self.direction == WGLGestureDirectionUpOrDown) {
        
        CGFloat intervalX = self.isFullScreen ? 100 : 50;
        
        //音量和亮度
        if (self.startPoint.x <= (aView.frame.size.width / 2.0 - intervalX)) {
            
            //调节亮度
            CGFloat brightnessValue = [UIScreen mainScreen].brightness;
            if (panPoint.y < 0) {
                //增加亮度
                brightnessValue = self.startVB + (-panPoint.y / 200.0);
            } else {
                //减少亮度
                brightnessValue = self.startVB - (panPoint.y / 200.0);
            }
            [[UIScreen mainScreen] setBrightness:brightnessValue];
            
            if (callback) {
                callback(WGLAjustTypeBrightness, brightnessValue);
            }
            
        }
        else if (self.startPoint.x >= (aView.frame.size.width / 2.0 + intervalX)) {
            
            //调节音量
            CGFloat volumeValue = [self.class getSystemVolumValue];
            if (panPoint.y < 0) {
                //增大音量
                volumeValue = self.startVB + (-panPoint.y / 200.0);
            } else {
                //减少音量
                volumeValue = self.startVB - (panPoint.y / 200.0);
            }
            [self.class setSystemVolumWithValue:volumeValue];
            
            if (callback) {
                callback(WGLAjustTypeVolume, volumeValue);
            }
            
        }
    }
    else if (self.direction == WGLGestureDirectionLeftOrRight) {
        
        //定时器关闭
//        [aView removeTimer];
        
        //调节进度
        CGFloat rate = self.startVideoRate + (panPoint.x / (aView.frame.size.width * 2));
        if (rate > 1) {
            rate = 1;
        } else if (rate < 0) {
            rate = 0;
        }
        self.endVideoRate = rate;
        
        if (callback) {
            callback(WGLAjustTypeVideoRate, rate);
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event inView:(UIView *)aView callback:(void(^)(void))callback {
    if (callback) {
        callback();
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event inView:(UIView *)aView callback:(void(^)(void))callback {
    if (callback) {
        callback();
    }
}

#pragma mark - 音量

/*
 *获取系统音量大小
 */
+ (CGFloat)getSystemVolumValue {
    return [[self getSystemVolumSlider] value];
}

/*
 *设置系统音量大小
 */
+ (void)setSystemVolumWithValue:(double)value {
    UISlider *sysVolumeSlider = [self getSystemVolumSlider];
    [sysVolumeSlider setValue:value animated:YES];
    
    if (value - sysVolumeSlider.value >= 0.1) {
        [sysVolumeSlider setValue:0.1 animated:NO];
        [sysVolumeSlider setValue:value animated:YES];
    }
}

/*
 *获取系统音量滑块
 */
+ (UISlider *)getSystemVolumSlider {
    static UISlider *volumeViewSlider = nil;
    if (volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectMake(10, 50, 200, 4)];
        
        for (UIView *newView in volumeView.subviews) {
            if ([newView.class.description isEqualToString:@"MPVolumeSlider"]){
                volumeViewSlider = (UISlider*)newView;
                break;
            }
        }
    }
    return volumeViewSlider;
}

@end
