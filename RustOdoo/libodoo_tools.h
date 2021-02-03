/* Generated with cbindgen:0.15.0 */

#define PRODUCT_PRODUCT_ID_UNKNOWN 18

/**
 * Simple test pour essayer à nouveau SwiftUI
 */
char *odoo_swift(const char *hello);

/**
 * Get day work
 */
char *get_work(const char *url,
               const char *db,
               const char *username,
               const char *password,
               int year,
               unsigned int month,
               unsigned int day);

void free_string(char *s);

#ifndef BridgingHeader_h
#define BridgingHeader_h

#import <Foundation/Foundation.h>

typedef struct CompletedCallback {
    void * _Nonnull userdata;
    void (* _Nonnull callback)(void * _Nonnull, bool);
} CompletedCallback;

void async_operation(CompletedCallback callback);

#endif