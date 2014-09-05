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

public class ItemSearchBar : Gtk.SearchBar {

    Gtk.SearchEntry search_entry;

    public signal void search_changed(string search_str);

    public ItemSearchBar () {

        set_show_close_button(false);

        search_entry = new Gtk.SearchEntry();
        search_entry.set_placeholder_text (_("Search"));
        search_entry.halign = Gtk.Align.START;

        var box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        box.pack_start(search_entry);

        add(box);
        connect_entry(search_entry);

        search_entry.search_changed.connect(()=>{
            search_changed(search_entry.get_text());
        });

        this.show_all();
    }

    public string get_text() {
        return search_entry.get_text();
    }


}