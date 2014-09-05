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

using Gtk;

namespace Foto.Widgets {

    public class ButtonGroup : Gtk.Box {

        public signal void button_added (int index, Gtk.Widget widget);
        public signal void button_removed (int index, Gtk.Widget widget);
        public signal void button_clicked (Gtk.Widget widget);

        public uint n_items {
            get { return get_children ().length (); }
        }

        public ButtonGroup () {
            homogeneous = true;
            spacing = 0;
            can_focus = false;

            var style = get_style_context ();
            style.add_class (Gtk.STYLE_CLASS_LINKED);
            style.add_class ("raised"); // needed for toolbars
        }

		//create and append a button with a pixbuf
        public Gtk.Button append_button_with_pixbuf (Gdk.Pixbuf pixbuf) {
        	var button = new Gtk.Button();
        	button.add(new Gtk.Image.from_pixbuf (pixbuf));
        	append_button (button);
            return button;
        }

		//create and append a button with text
        public Gtk.Button append_button_with_label (string text) {
        	var button = new Gtk.Button();
        	button.set_label(text);
        	append_button (button);
            return button;
        }

		//create and append a button with an icon
        public Gtk.Button append_button_with_icon (string icon_name, Gtk.IconSize size) {
            var button = new Gtk.Button();
        	button.add (new Gtk.Image.from_icon_name (icon_name, size));
        	append_button (button);
            return button;
        }

		//append just a button
        public void append_button (Gtk.Button button) {
            button.can_focus = false;
            add (button);
            button.show_all ();
        }

		//create and append a toggle button with a pixbuf
        public Gtk.ToggleButton append_togglebutton_with_pixbuf (Gdk.Pixbuf pixbuf) {
        	var button = new Gtk.ToggleButton();
        	button.add(new Gtk.Image.from_pixbuf (pixbuf));
        	append_togglebutton (button);
            return button;
        }

		//create and append a toggle button with text
        public Gtk.ToggleButton append_togglebutton_with_label (string text) {
        	var button = new Gtk.ToggleButton();
        	button.set_label(text);
        	append_togglebutton (button);
            return button;
        }

		//create and append a toggle button with an icon
        public Gtk.ToggleButton append_togglebutton_with_icon (string icon_name, Gtk.IconSize size) {
            var button = new Gtk.ToggleButton();
        	button.add (new Gtk.Image.from_icon_name (icon_name, size));
        	append_togglebutton (button);
            return button;
        }

		//append just a toggle button
        public void append_togglebutton (Gtk.ToggleButton button) {
            button.can_focus = false;
            add (button);
            button.show_all ();
        }


        public void set_item_visible (int index, bool val) {
            var children = get_children ();
            return_if_fail (index >= 0 && index < children.length ());

            var item = children.nth_data (index);

            if (item != null) {
                item.no_show_all = !val;
                item.visible = val;
            }
        }

        public void clear_children () {
            foreach (weak Gtk.Widget button in get_children ()) {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }
        }
    }



    public class ToolButtonGroup : Gtk.ToolItem {

        public signal void button_added (int index, Gtk.Widget widget);
        public signal void button_removed (int index, Gtk.Widget widget);
        public signal void button_clicked (Gtk.Widget widget);

        public Gtk.Box box;

        public uint n_items {
            get { return get_children ().length (); }
        }

        public ToolButtonGroup () {
            box = new Gtk.Box(Gtk.Orientation.HORIZONTAL,0);
            box.homogeneous = true;
            box.can_focus = false;
            this.add(box);

            var style = box.get_style_context ();
            style.add_class (Gtk.STYLE_CLASS_LINKED);
            style.add_class ("raised"); // needed for toolbars
        }

		//create and append a button with a pixbuf
        public Gtk.Button append_button_with_pixbuf (Gdk.Pixbuf pixbuf) {
        	var button = new Gtk.Button();
        	button.add(new Gtk.Image.from_pixbuf (pixbuf));
            append_button (button);
            return button;
        }

		//create and append a button with text
        public Gtk.Button append_button_with_label (string text) {
        	var button = new Gtk.Button();
        	button.set_label(text);
        	append_button (button);
            return button;
        }

		//create and append a button with an icon
        public Gtk.Button append_button_with_icon (string icon_name, Gtk.IconSize size) {
            var button = new Gtk.Button();
        	button.add (new Gtk.Image.from_icon_name (icon_name, size));
        	append_button (button);
            return button;
        }

		//append just a button
        public void append_button (Gtk.Button button) {
            button.can_focus = false;
            box.add (button);
            button.show_all ();
        }

		//create and append a toggle button with a pixbuf
        public Gtk.ToggleButton append_togglebutton_with_pixbuf (Gdk.Pixbuf pixbuf) {
        	var button = new Gtk.ToggleButton();
        	button.add(new Gtk.Image.from_pixbuf (pixbuf));
        	append_togglebutton (button);
            return button;
        }

		//create and append a toggle button with text
        public Gtk.ToggleButton append_togglebutton_with_label (string text) {
        	var button = new Gtk.ToggleButton();
        	button.set_label(text);
        	append_togglebutton (button);
            return button;
        }

		//create and append a toggle button with an icon
        public Gtk.ToggleButton append_togglebutton_with_icon (string icon_name, Gtk.IconSize size) {
            var button = new Gtk.ToggleButton();
        	button.add (new Gtk.Image.from_icon_name (icon_name, size));
        	append_togglebutton (button);
            return button;
        }

		//append just a toggle button
        public void append_togglebutton (Gtk.ToggleButton button) {
            button.can_focus = false;
            box.add (button);
            button.show_all ();
        }


        public void set_item_visible (int index, bool val) {
            var children = box.get_children ();
            return_if_fail (index >= 0 && index < children.length ());

            var item = children.nth_data (index);

            if (item != null) {
                item.no_show_all = !val;
                item.visible = val;
            }
        }

        public void clear_children () {
            foreach (weak Gtk.Widget button in box.get_children ()) {
                button.hide ();
                if (button.get_parent () != null)
                    base.remove (button);
            }
        }
    }

}