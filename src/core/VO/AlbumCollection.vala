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

public class AlbumCollection : Gee.ArrayList<Album> {

    public signal void collection_changed();
    public signal void item_added(Album item);
    public signal void item_removed(Album item);

    public AlbumCollection() {
    }

    public new void add(Album item) {
        base.add(item);
        item_added(item);
    }

    public new void remove(Album item) {
        base.remove(item);
        item_removed(item);
    }
}