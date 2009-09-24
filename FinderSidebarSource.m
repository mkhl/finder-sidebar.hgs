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
@end

@implementation FinderSidebarSource

- (id)initWithConfiguration:(NSDictionary *)configuration
{
  self = [super initWithConfiguration:configuration];
  if (self == nil)
    return nil;
  if ([self loadResultsCache])
    [self recacheContentsAfterDelay:10.0];
  else
    [self recacheContents];
  return self;
}

- (void)recacheContents
{
  [self clearResultIndex];
  NSDictionary *settings = [[NSUserDefaults standardUserDefaults]
                            persistentDomainForName:kSidebarBundleIdentifier];
  for (NSDictionary *item in [settings valueForKeyPath:kSidebarItemsKey]) {
    NSData *alias = [item valueForKey:kSidebarItemAliasKey];
    NSString *path = [[NSFileManager defaultManager]
                      gtm_pathFromAliasData:alias];
    [self indexItemAtPath:path];
  }
  [self recacheContentsAfterDelay:60.0];
}

- (void)recacheContentsAfterDelay:(NSTimeInterval)delay
{
  [self performSelector:@selector(recacheContents)
             withObject:nil
             afterDelay:delay];
}

- (void)indexResultAtPath:(NSString *)path
{
  [self indexResult:[HGSResult resultWithFilePath:path
                                           source:self
                                       attributes:nil]];
}

- (void)indexItemAtPath:(NSString *)path
{
  [self indexResultAtPath:path];
  NSFileManager *manager = [NSFileManager defaultManager];
  for (NSString *subpath in [manager directoryContentsAtPath:path])
    if (![subpath hasPrefix:@"."])
      [self indexResultAtPath:[path stringByAppendingPathComponent:subpath]];
}

@end
