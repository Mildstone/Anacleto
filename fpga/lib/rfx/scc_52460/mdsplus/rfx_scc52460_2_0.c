#include <math.h>
#include <stdio.h>
#include <string.h>
#include "scc52460_2.h"

// TODO: WIN
#include <linux/types.h>

static struct rfx_scc52460 *chan_list = NULL;


struct rfx_scc52460 *find_chan_by_name(const char *name, struct rfx_scc52460 *list);
int append_chan(struct rfx_scc52460 *el, struct rfx_scc52460 **list);
int initialize(const char *name, const char *devfile, int postTriggerSamples);
int acquire(const char *name, int32_t *chan1, int32_t *chan2);


struct rfx_scc52460 *find_chan_by_name(const char *name, struct rfx_scc52460 *list) {
    if(!list) return NULL;
    struct rfx_scc52460 *el = list;
    while(el) {
        if( el->name && strcmp(name,el->name)==0 ) return el;
        el=el->next;
    }
    return NULL;
}

int append_chan(struct rfx_scc52460 *el, struct rfx_scc52460 **list) {
    int i=0;
    if(!*list) {
        *list = el;
        el->next = NULL;
        el->prev = NULL;
    } else {
        struct rfx_scc52460 *lpos = *list;
        while (lpos && lpos->next) { lpos=lpos->next; ++i; }
        lpos->next = el;
        el->prev = lpos;
        el->next = NULL;
    }
    return i;
}

int initialize(const char *name, const char *devfile, int postTriggerSamples) {
    int status;
    struct rfx_scc52460 *ch = find_chan_by_name(name,chan_list);
    if(!ch) {
        ch = (struct rfx_scc52460*)malloc(sizeof (struct rfx_scc52460));
        ch->name = name;
        ch->fd = 0;
        ch->prets = 0;
        ch->posts = 0;
        append_chan(ch,&chan_list);
    }
    ch->posts = postTriggerSamples;
    ch->fd = open(devfile, O_RDWR | O_SYNC);
    if(ch->fd < 0) {
        printf(" ERROR: failed to open device file %s error: %d\n",devfile,ch->fd);
        return 1;
    }
    status = ioctl(ch->fd, RFX_SCC52460_RESET, 0);
    return status;
}

int acquire(const char *name, int32_t *chan1, int32_t *chan2) {
    int status,i,size;
    (void)chan2;
    struct rfx_scc52460 *ch = find_chan_by_name(name,chan_list);
    if (!ch)  return -1;
    size = ch->posts;
    status = ioctl(ch->fd, RFX_SCC52460_CLEAR, 0);
    for(i=0;i<size;) {
        // TODO: should poll for device here //
        int rb = read(ch->fd,&chan1[i],(size-i)*sizeof(int32_t));
        i += rb/sizeof(int32_t);
    }
    return i;
}
















