/* Copyright 2010-2013 Yorba Foundation
 *
 * This software is licensed under the GNU Lesser General Public License
 * (version 2.1 or later).  See the COPYING file in this distribution.
 */

string? chomp_chug (string? str) {
    if(str == null)
        return null;
    return str.normalize().strip();
}