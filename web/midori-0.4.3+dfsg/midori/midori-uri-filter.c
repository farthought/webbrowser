#include "midori-uri-filter.h"

/*   删除左边的空格   */
char * l_trim(char * szOutput, const char *szInput)
{
    assert(szInput != NULL);
    assert(szOutput != NULL);
    assert(szOutput != szInput);
    for   (NULL; *szInput != '\0' && isspace(*szInput); ++szInput){
        ;
    }
    return strcpy(szOutput, szInput);
}

/*   删除右边的空格   */
char *r_trim(char *szOutput, const char *szInput)
{
    char *p = NULL;
    assert(szInput != NULL);
    assert(szOutput != NULL);
    assert(szOutput != szInput);
    strcpy(szOutput, szInput);
    for(p = szOutput + strlen(szOutput) - 1; p >= szOutput && isspace(*p); --p){
        ;
    }
    *(++p) = '\0';
    return szOutput;
}

/*   删除两边的空格   */
char * a_trim(char * szOutput, const char * szInput)
{
    char *p = NULL;
    assert(szInput != NULL);
    assert(szOutput != NULL);
    l_trim(szOutput, szInput);
    for   (p = szOutput + strlen(szOutput) - 1;p >= szOutput && isspace(*p); --p){
        ;
    }
    *(++p) = '\0';
    return szOutput;
}
/*获得配置文件中的内容*/
int GetProfileString(char *profile, char *AppName, char *KeyName, char *KeyVal )
{
    char appname[32],keyname[32];
    char *buf,*c;
    char buf_i[KEYVALLEN], buf_o[KEYVALLEN];
    FILE *fp;
    int found=0; /* 1 AppName 2 KeyName */
    if( (fp=fopen( profile,"r" ))==NULL ){
        printf( "openfile [%s] error [%s]\n",profile,strerror(errno) );
        return(-1);
    }
    fseek( fp, 0, SEEK_SET );
    memset( appname, 0, sizeof(appname) );
    sprintf( appname,"[%s]", AppName );

    while( !feof(fp) && fgets( buf_i, KEYVALLEN, fp )!=NULL ){
        l_trim(buf_o, buf_i);
        if( strlen(buf_o) <= 0 )
            continue;
        buf = NULL;
        buf = buf_o;

        if( found == 0 ){
            if( buf[0] != '[' ) {
                continue;
            } else if ( strncmp(buf,appname,strlen(appname))==0 ){
                found = 1;
                continue;
            }

        } else if( found == 1 ){
            if( buf[0] == '#' ){
                continue;
            } else if ( buf[0] == '[' ) {
                break;
            } else {
                if( (c = (char*)strchr(buf, '=')) == NULL )
                    continue;
                memset( keyname, 0, sizeof(keyname) );

                sscanf( buf, "%[^=|^ |^\t]", keyname );
                if( strcmp(keyname, KeyName) == 0 ){
                    sscanf( ++c, "%[^\n]", KeyVal );
                    char *KeyVal_o = (char *)malloc(strlen(KeyVal) + 1);
                    if(KeyVal_o != NULL){
                        memset(KeyVal_o, 0, sizeof(KeyVal_o));
                        a_trim(KeyVal_o, KeyVal);
                        if(KeyVal_o && strlen(KeyVal_o) > 0)
                            strcpy(KeyVal, KeyVal_o);
                        free(KeyVal_o);
                        KeyVal_o = NULL;
                    }
                    found = 2;
                    break;
                } else {
                    continue;
                }
            }
        }
    }
    fclose( fp );
    if( found == 2 )
        return(0);
    else
        return(-1);
}
/* get_core_uri
 * 提取浏览器导航栏搜索框uri内容
 * @uri_Input：搜索框中输入的uri
 * 返回提取之后的uri*/
char *get_core_uri(char *uri_Input)
{
    char uri_Old[NUM];
    char * uri_New;
    const char *delim = "/.";

    strcpy(uri_Old, uri_Input);
    uri_New = strtok(uri_Old, delim);
    if(!strcmp(uri_New, "http:") || !strcmp(uri_New, "https:"))
    {
        uri_New = strtok(NULL, delim);
        if(!strcmp(uri_New, "www"))
        {
            uri_New = strstr(uri_Input, ".");
            uri_New++;
        }
        else
            uri_New = strstr(uri_Input, uri_New);
    }
    else if(!strcmp(uri_New, "www"))
    {
        uri_New = strstr(uri_Input, ".");
        uri_New++;
    }
    else
        uri_New = strstr(uri_Input, uri_New);
    
    return uri_New;

}
/* creanUrllist:
 * 用于创建链表
 * 返回创建的链表头*/
urllistFilter *creatUrllist(void)
{
    urllistFilter *head;
    head = (urllistFilter *)malloc(sizeof(urllistFilter));
    head->urlnext = head;
    head->urlpre = head;
    return head;
}
/* insertUrllist:
 * 将配置文件isoft.conf中需要筛选的网址内容插入链表
 * @h：将要插入的链表
 * 返回插入之后的链表*/
urllistFilter *insertUrllist(urllistFilter *h)
{
    urllistFilter *s;
    gchar http[NUM];
    gchar uri[NUM];
    int i, j;
    gchar filter_n[N];
    
    GetProfileString("/etc/isoft.conf","http_jump","n", filter_n);
    j = atoi(filter_n);
    
    for(i=1;i<=j;i++)
    {
        sprintf(http, "http%d", i);
        GetProfileString("/etc/isoft.conf","http_jump", http, uri);
        if(i==1)
        {
            strcpy(h->urldata, uri);
            continue;
        }
        else
        {
            s = (urllistFilter *) malloc(sizeof(urllistFilter));
            s->urlnext = h->urlnext;
            s->urlnext->urlpre = s;
            s->urlpre = h;
            h->urlnext = s;
            strcpy(s->urldata, uri);
        }

    }
    return h;
}
/* urilistFilter
 * 用于遍历链表，并筛选uri
 * @h：用于遍历的链表
 * @data：需要筛选的uri
 * 成功筛选到uri，返回链表指针，否则返回NULL*/
urllistFilter * foreachUrllist(urllistFilter *h, gchar * data)
{
    urllistFilter *list;
    list = h;
    const gchar *data1, *data2;
    size_t size1, size2, size3;
    do
    {
        data1 = get_core_uri(list->urldata);
        data2 = get_core_uri(data);
        size1 = strlen(data1);
        size2 = strlen(data2);
        size3 = size1 >= size2 ? size1:size2;
        if(!strncmp(data1,data2,(size3-1)))
            return list;
        list = list->urlnext;
    }while(list != h);
    return NULL;
}
/* delete:
 * 根据data删除链表某个节点
 * @h：要执行删除操作的链表
 * @data：需要删除的链表节点的数据
 * 删除特定节点之后的链表*/
urllistFilter * delete(urllistFilter *h , gchar *data)
{
    urllistFilter *list;
    list = foreachUrllist(h, data);
    if(list != NULL)
    {
        list->urlpre->urlnext = list->urlnext;
        list->urlnext->urlpre = list->urlpre;
        free(list);
    }
    return h;
}

/* myststem:
 * 该函数用于重写system，执行一条shell命令，因为system
 * 调用，父进程会等待子进程结束，才能操作，重写之后，
 * 父子进程相对独立，均能操作。
 * */
int mysystem(const char *cmdstring)
{
    pid_t pid;
    int status;
    if(cmdstring == NULL)
    {
        return (1);
    }
    if((pid = fork())<0)
    {
        status = -1;
    }
    else if(pid == 0)
    {
        execl("/bin/sh", "sh", "-c", cmdstring, (char *)0);
        _exit(127);
    }
    else
    {
        signal(SIGCHLD, SIG_IGN);
    }
    return status;
}
/* call_other_browser：
 * 如果输入的网址和配置文件中筛选的网址相同，则用特定的浏览器打开网址
 * @usr_data:输入的网址*/
int call_other_browser(const gchar *usr_data)
{
    gchar data[NUM];
    
    urllistFilter *h = creatUrllist();
    insertUrllist(h);
    sprintf(data,"%s", usr_data);
    if (foreachUrllist(h, data))
    {
        gchar buf[NUM];
        gchar browser[NUM];
        GetProfileString("/etc/isoft.conf", "browser_use", "browser", browser);
        sprintf(buf, "%s %s", browser, data);
        mysystem(buf);
        return 0;
    }
}

