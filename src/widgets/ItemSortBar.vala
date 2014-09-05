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

public class ItemSortBar : Gtk.SearchBar {

    public signal void search_mode_changed(bool mode);
    public Gtk.Box box;

    public ItemSortBar () {

        //FIXME:an invisible search entry. Not packing the entry causes an error
        //so, a custom container with a Gtk.Revealer should be used instead of 
        //Gtk.Searchbar
        var search_entry = new Gtk.SearchEntry();
        connect_entry(search_entry);

        set_show_close_button(true);
        box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 10);
        box.expand = true;
        var label = new Gtk.Label(_("Sort by: "));
        label.valign = Gtk.Align.CENTER;
        box.pack_start(label, false, false, 10);
        add(box);

        this.show_all();
    }

    public new void set_search_mode(bool mode) {
        base.set_search_mode(mode);
        search_mode_changed(mode);
    }

    public Gtk.Button add_sort_button(string label) {
        var button = new Gtk.Button.with_label(label);
        button.valign = Gtk.Align.CENTER;
        box.pack_end(button, false, false, 10);
        return button;
    }



}