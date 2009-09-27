//
//  FinderSidebarSource.m
//
//  Copyright (c) 2009  Martin Kuehl <purl.org/net/mkhl>
//  Licensed under the MIT License.
//

#import <Vermilion/Vermilion.h>
#import <GTM/GTMNSFileManager+Carbon.h>

static NSString *const kSidebarBundleIdentifier = @"com.apple.sidebarlists";
static NSString *const kSidebarItemsKey = @"useritems.CustomListItems";
static NSString *const kSidebarItemAliasKey = @"Alias";

@interface FinderSidebarSource : HGSMemorySearchSource
- (void)recacheContents;
- (void)recacheContentsAfterDelay:(NSTimeInterval)delay;
- (void)indexItemAtPath:(NSString *)path;
- (void)indexResultAtPath:(NSString *)path;
@end

@implementation FinderSidebarSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self) {
    if ([self loadResultsCache]) {
      [self recacheContentsAfterDelay:10.0];
    } else {
      [self recacheContents];
    }
  }
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSDictionary *dict = [defaults persistentDomainForName:kSidebarBundleIdentifier];
  for (NSDictionary *item in [dict valueForKeyPath:kSidebarItemsKey]) {
    NSData *alias = [item valueForKey:kSidebarItemAliasKey];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *path = [manager gtm_pathFromAliasData:alias];
    [self indexItemAtPath:path];
  }
  [self recacheContentsAfterDelay:60.0];
}

- (void)recacheContentsAfterDelay:(NSTimeInterval)delay
{
  SEL action = @selector(recacheContents);
  [self performSelector:action withObject:nil afterDelay:delay];
}

- (void)indexItemAtPath:(NSString *)path
{
  [self indexResultAtPath:path];
  NSFileManager *manager = [NSFileManager defaultManager];
  for (NSString *subpath in [manager directoryContentsAtPath:path]) {
    if (![subpath hasPrefix:@"."]) {
      [self indexResultAtPath:[path stringByAppendingPathComponent:subpath]];
    }
  }
}

- (void)indexResultAtPath:(NSString *)path
{
  [self indexResult:[HGSResult resultWithFilePath:path
                                           source:self
                                       attributes:nil]];
}

@end
