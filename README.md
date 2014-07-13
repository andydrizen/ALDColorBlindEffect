Using this very simple class, you can quickly get an idea of what your color-blind users will experience when they use your App. This is achieved by converting the colors and acuity of your App in real-time.

## Demonstration Video

You can download the demo App contained within this repository or watch the following video.

[![ScreenShot](https://raw.github.com/andydrizen/ALDColorBlindEffect/master/VideoDemoScreenshot.png)](http://youtu.be/wvHwPBX0wVk)

## Integration

`ALDColorBlindEffect` simulates how a given `UIView` will be experienced by users with the most common types color-blindness and varying degrees of visual acuity. To get started, you simply need to set the `view` property of the `[ALDColorBlindEffect sharedInstance]`.

If you would like to simulate color-blindness across your whole App, you just need to add one line of code to your `application:didFinishLaunchingWithOptions` method, like this:

```
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [ALDColorBlindEffect sharedInstance].view = self.window;

    return YES;
}
```

## Creating an Effect

### Color

To see how your App looks to your colourblind users, you can set the `type` property to§ any one of the following effects:

```
ALDColorBlindEffectTypeNone
ALDColorBlindEffectTypeProtanopia
ALDColorBlindEffectTypeDeuteranopia
ALDColorBlindEffectTypeTritanopia
ALDColorBlindEffectTypeRodMonochromacy
ALDColorBlindEffectTypeConeMonochromacyLRed
ALDColorBlindEffectTypeConeMonochromacyMGreen
ALDColorBlindEffectTypeConeMonochromacySBlue
ALDColorBlindEffectTypeDog
```

For example, to simulate Deuteranopia, you would need to add the following line of code:

```
[ALDColorBlindEffect sharedInstance].type = ALDColorBlindEffectTypeDeuteranopia;
```

### Adding Blur

As well as altering the colors of your App, you may also like to simulate the experience of those users with varying degrees of visual acuity. This can range from minor blurred vision to total loss of sight. To simulate this, give the `blurAmount` property any value between 0 (i.e. no blurriness) and 1 (complete blurriness). For example, for a small amount of blur, you would need to add the following line of code:

```
[ALDColorBlindEffect sharedInstance].blurAmount = 0.03;
```

## Advanced Features

### Animations

By default, UIView animations will not animate whilst you are simulating color-blindness. This is because doing so can crash your App, e.g. if you have a `UIWebView` in your view hierarchy (radar: 17653298). 

Should you wish to override this behaviour, you can enable animations by setting the `shouldRenderPresentationLayer` to `YES`.

### Quality

Should you find that performance is suffering whilst you are simulating color-blindness, you can reduce the quality of the effect by setting the `quality` property to any of the following:

```
ALDColorBlindEffectQualityLow,
ALDColorBlindEffectQualityMedium,
ALDColorBlindEffectQualityHigh
``` 

The default is `ALDColorBlindEffectQualityHigh`.

## Case Study: Tube Tracker

This video demonstrates how you could integrate this class into your project using the Settings.bundle.

Notice how a tester will be *forced* to use other means (e.g. VoiceOver) to navigate around the App when the blur is sufficiently high.

[![ScreenShot](https://raw.github.com/andydrizen/ALDColorBlindEffect/master/VideoCaseStudyScreenshot.png)](http://youtu.be/Tb8TGJvYOx4)

## CocoaPods

You can also add this project to yours by using CocoaPods. To do this, add the following line to your Podfile:

```
pod 'ALDColorBlindEffect`, '~>1.0.0'
```
