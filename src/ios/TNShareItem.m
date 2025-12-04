#import "TNShareItem.h"

@interface TNShareItem ()
@property(nonatomic, readonly, copy) NSString *combinedText;
@end

@implementation TNShareItem

- (instancetype)initWithText:(NSString *)text
                    urlString:(NSString *)urlString
                 previewImage:(UIImage *)previewImage {
  self = [super init];
  if (self) {
    // Сохраняем исходные значения, очищая NSNull, чтобы избежать падений на ранних версиях iOS
    _text = (text != (id)[NSNull null]) ? text : nil;
    _url = [TNShareItem urlFromString:urlString];
    _previewImage = previewImage;

    // Собираем строку только для отображения превью (не для финального сообщения)
    if (_text != nil && _url != nil) {
      _combinedText = [NSString stringWithFormat:@"%@\n%@", _text, _url.absoluteString];
    } else if (_text != nil) {
      _combinedText = _text;
    } else if (_url != nil) {
      _combinedText = _url.absoluteString;
    } else {
      _combinedText = @"";
    }
  }
  return self;
}

- (instancetype)init {
  return [self initWithText:nil urlString:nil previewImage:nil];
}

#pragma mark - UIActivityItemSource

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
  // Плейсхолдер совпадает по типу с финальным элементом, чтобы iOS не скрывала превью
  return self.combinedText != nil ? self.combinedText : @"";
}

- (id)activityViewController:(UIActivityViewController *)activityViewController
        itemForActivityType:(UIActivityType)activityType {
  // Возвращаем минимальный контент: текст для поддерживаемых клиентов или ссылку, если текста нет
  if (self.text != nil && [self.text length] > 0) {
    return @""; // сам текст будет вторым элементом в activityItems
  }
  if (self.url != nil) {
    return self.url.absoluteString;
  }
  return @"";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController
               subjectForActivityType:(UIActivityType)activityType {
  // Тема совпадает с текстом (если есть)
  return self.text;
}

- (LPLinkMetadata *)activityViewControllerLinkMetadata:(UIActivityViewController *)activityViewController
    API_AVAILABLE(ios(13.0)) {
  // Настраиваем превью: иконка приложения + ссылка без перезаписи текста «Image»
  LPLinkMetadata *metadata = [[LPLinkMetadata alloc] init];
  metadata.title = (self.text != nil && [self.text length] > 0) ? self.text : self.url.absoluteString;

  if (self.url != nil) {
    metadata.originalURL = self.url;
    metadata.URL = self.url;
  }

  if (self.previewImage != nil) {
    NSItemProvider *iconProvider = [[NSItemProvider alloc] initWithObject:self.previewImage];
    metadata.iconProvider = iconProvider;
    metadata.imageProvider = iconProvider;
  }

  return metadata;
}

#pragma mark - Helpers

+ (NSURL *)urlFromString:(NSString *)urlString {
  if (urlString == (id)[NSNull null] || urlString == nil || [urlString length] == 0) {
    return nil;
  }

  // Не делаем дополнительный энкодинг, чтобы мессенджеры могли подтянуть превью по исходному URL
  NSURL *rawUrl = [NSURL URLWithString:urlString];
  if (rawUrl != nil) {
    return rawUrl;
  }

  NSString *escaped = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]];
  return [NSURL URLWithString:escaped];
}

@end
