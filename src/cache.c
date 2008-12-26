/* -*- Mode: C; tab-width: 8; indent-tabs-mode: nil; c-basic-offset: 8 -*- */

/*  Monkey HTTP Daemon
 *  ------------------
 *  Copyright (C) 2001-2008, Eduardo Silva P.
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU Library General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#include <pthread.h>
#include "iov.h"
#include "cache.h"
#include "request.h"

#include <stdio.h>
#include <stdlib.h>

/* This function is called when a thread is created */
void mk_cache_thread_init()
{
        struct mk_iov *cache_iov_log;
        struct mk_iov *cache_iov_header;
        struct header_toc *cache_header_toc;

        /* Cache iov log struct */
        cache_iov_log = mk_iov_create(25, 0);
        pthread_setspecific(mk_cache_iov_log, (void *) cache_iov_log);

        /* Cache iov header struct */
        cache_iov_header = mk_iov_create(45, 0);
        pthread_setspecific(mk_cache_iov_header, (void *) cache_iov_header);

        /* Cache header toc, monkey just search for 11 headers in request */
        cache_header_toc = mk_mem_malloc(sizeof(struct header_toc)*11);
        pthread_setspecific(mk_cache_header_toc, (void *) cache_header_toc);
}