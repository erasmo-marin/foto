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

using Foto.Widgets;

namespace Foto.Dialogs{

    public class AddToAlbumDialog : Gtk.Popover {

        private Gtk.ListBox list_box;
        private PictureCollection collection;

        public AddToAlbumDialog(PictureCollection collection, Gtk.Widget relative_to) {
            set_relative_to(relative_to);
            this.collection = collection;

            //listbox
            list_box = new Gtk.ListBox();
            AlbumDAO albumdao = AlbumDAO.get_instance();
            AlbumCollection albums = albumdao.get_all();
            foreach (Album album in albums) {
                add_row(album);
            }
            var scrolled = new Gtk.ScrolledWindow(null, null);
            scrolled.add_with_viewport(list_box);
            scrolled.set_size_request(250, 150);

            //buttons
            var cancel_button = new Gtk.Button.with_mnemonic  (_("_Cancel"));
            var add_button = new Gtk.Button.with_mnemonic  (_("_Add to Album"));

            cancel_button.clicked.connect (() => {this.destroy();});
            add_button.clicked.connect (save);

            //buttonbox
            var button_box = new Gtk.ButtonBox (Gtk.Orientation.HORIZONTAL);
            button_box.set_layout (Gtk.ButtonBoxStyle.END);
            button_box.pack_end (cancel_button);
            button_box.pack_end (add_button);

            //main box
            var box = new Gtk.Box(Gtk.Orientation.VERTICAL, 30);
            box.pack_start(scrolled);
            box.pack_end(button_box);
            box.margin = 20;

            this.add(box);
            this.show_all();
        }

        private void add_row(Album album) {
            list_box.insert(new AlbumRow(album), -1);
        }

        private void save() {

            PictureDAO picdao = PictureDAO.get_instance();
            Album album = (list_box.get_selected_row().get_child() as AlbumRow).album;
            picdao.set_album_to_collection(collection, album);
            this.destroy();
        }

        private class AlbumRow : Gtk.Box {

            public Album album;

            public AlbumRow(Album album) {
                //GLib.Object(Gtk.Orientation.HORIZONTAL);
                this.album = album;
                var label = new Gtk.Label(album.album_name);
                label.set_ellipsize (Pango.EllipsizeMode.END);
                Gdk.Pixbuf pic = ColorRow.get_color_dot_from_hex (RowPalette.unserialize((int)album.color), 16, 16);
                var image = new Gtk.Image.from_pixbuf (pic);
                label.halign = Gtk.Align.START;
                image.halign = Gtk.Align.START;
                this.pack_start(label, false, false, 0);
                this.pack_end(image, false, true, 0);
            }
        }


    }
}