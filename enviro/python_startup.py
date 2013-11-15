# -*- coding: utf-8 -*-
"""
/***************************************************************************
 OSGeo4Mac Python startup script to strip /Library/Frameworks
 and /Library/Python site-packages
                              -------------------
        begin    : 2013-09-20
        copyright: (C) 2013 Larry Shaffer
        email    : larrys@dakotacarto.com
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
"""
import sys

sys.path[:] = (pth for pth in sys.path if not pth.startswith('/Library'))
