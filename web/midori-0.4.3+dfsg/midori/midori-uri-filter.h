#ifndef MIDORI_URI_FILTER_H
#define MIDORI_URI_FILTER_H

#include <stdio.h>
#include <string.h>
#include <gtk/gtk.h>
#include <errno.h>
#include <assert.h>
#include <stdlib.h>
#include <ctype.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>

#define NUM 100
#define KEYVALLEN 100
#define N 8
typedef struct urllist
{
    struct urllist *urlnext;
    struct urllist *urlpre;
    gchar urldata[NUM];
}urllistFilter;

urllistFilter *creatUrllist(void);
urllistFilter *insertUrllist(urllistFilter *h);
urllistFilter * foreachUrllist(urllistFilter *h, gchar * data);
urllistFilter * delete(urllistFilter *h , gchar *data);
int call_other_browser(const gchar *usr_data);
char *get_core_uri(char *uri_Input);
char * l_trim(char * szOutput, const char *szInput);
char *r_trim(char *szOutput, const char *szInput);
char * a_trim(char * szOutput, const char * szInput);
int GetProfileString(char *profile, char *AppName, char *KeyName, char *KeyVal );


#endif
