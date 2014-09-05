// -*- Mode: vala; indent-tabs-mode: nil; tab-width: 4 -*-
/*-
 * Copyright (c) 2013-2014 Foto Developers (http://launchpad.net/foto)
 *
 * This software is licensed under the GNU General Public License
 * (version 3 or later). See the COPYING file in this distribution.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this software; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 *
 * Authored by: Erasmo Marín <erasmo.marin@gmail.com>
 */

/* Tag is a VO object that represent a tag row in the database. 
 * It is used with TagDAO, PictureDAO and Photo. VO objects are for moving
 * information between the application layers. No extra operations
 * should be added.
 * Keep it simple.
 */
public class Tag : GLib.Object{

    public int? id;
    public string? tag;

    public Tag.with_values(int? id, string? tag) {
        this.id = id;
        this.tag = tag;
    }

}