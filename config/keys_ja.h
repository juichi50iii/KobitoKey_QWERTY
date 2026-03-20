/*
 * Copyright (c) 2024 The ZMK Contributors
 *
 * SPDX-License-Identifier: MIT
 */

#pragma once

#include <dt-bindings/zmk/keys.h>

/* Japanese (JIS) layout keycode aliases */

/* Basic symbols */
#define JA_MINUS MINUS     // -
#define JA_CARET EQUAL     // ^
#define JA_YEN   INT3      // ¥
#define JA_AT    LBKT      // @
#define JA_LBRC  RBKT      // [
#define JA_SEMI  SEMI      // ;
#define JA_COLON SQT       // :
#define JA_RBRC  BSLH      // ]
#define JA_COMMA COMMA     // ,
#define JA_DOT   DOT       // .
#define JA_SLASH SLASH     // /
#define JA_RO    INT1      // \ (Backslash / Ro)

/* Shifted symbols */
#define JA_EXCL    LS(N1)    // !
#define JA_DQUOT   LS(N2)    // "
#define JA_HASH    LS(N3)    // #
#define JA_DLLR    LS(N4)    // $
#define JA_PRCNT   LS(N5)    // %
#define JA_AMPS    LS(N6)    // &
#define JA_SQT     LS(N7)    // '
#define JA_LPAR    LS(N8)    // (
#define JA_RPAR    LS(N9)    // )
#define JA_EQUAL   LS(MINUS) // =
#define JA_TILDE   LS(EQUAL) // ~
#define JA_PIPE    LS(INT3)  // |
#define JA_GRAVE   LS(LBKT)  // `
#define JA_LBRACE  LS(RBKT)  // {
#define JA_RBRACE  LS(BSLH)  // }
#define JA_ASTER   LS(SQT)   // *
#define JA_PLUS    LS(SEMI)  // +
#define JA_LT      LS(COMMA) // <
#define JA_GT      LS(DOT)   // >
#define JA_QMARK   LS(SLASH) // ?
#define JA_UNDER   LS(INT1)  // _
