#import <Foundation/Foundation.h>
#import <LinkPresentation/LinkPresentation.h>
#import <UIKit/UIKit.h>

// Источник элементов для UIActivityViewController, отвечающий за кастомное превью
@interface TNShareItem : NSObject<UIActivityItemSource>

@property(nonatomic, readonly, copy) NSString *text;
@property(nonatomic, readonly, strong) NSURL *url;
@property(nonatomic, readonly, strong) UIImage *previewImage;

- (instancetype)initWithText:(NSString *)text
                    urlString:(NSString *)urlString
                 previewImage:(UIImage *)previewImage NS_DESIGNATED_INITIALIZER;

+ (NSURL *)urlFromString:(NSString *)urlString;

@end
