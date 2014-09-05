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

namespace Foto.Widgets {

    public class RowPalette {

        public static const string[] colors = { //tango color palette
            "fce94f", "edd400", "c4a000", //butter
            "fcaf3e", "f57900", "ce5c00", //orange
            "e9b96e", "c17d11", "8f5902", //chocolate
            "8ae234", "73d216", "4e9a06", //chameleon
            "729fcf", "3465a4", "204a87", //sky blue
            "ad7fa8", "75507b", "5c3566", //plum
            "ef2929", "cc0000", "a40000", //scarlet red
            "eeeeec", "d3d7cf", "babdb6", //aluminium
            "888a85", "555753", "2e3436"
        };


        public static int serialize(string color) {

            for(int i=1; i<=27; i++) {
                if(color == colors[i])
                    return i;
            }
            return -1;
        }

        public static string? unserialize(int i) {
            if(i<1 || i>27)
                return null;
            return colors[i];        
        }

    }
    
    public class ColorRow : Gtk.Box {

        private Gtk.Image[] images;
        private int size = 16;      
        private string _color;
        
        public static Gdk.Pixbuf get_color_dot_from_hex (string colorhex, int w, int h) {
            Gdk.RGBA c = {};
            c.parse ("#"+colorhex);
            
            return get_color_dot (c.red, c.green, c.blue, w, h);
        }
        
        public static Gdk.Pixbuf get_color_dot (double r, double g, double b,int w, int h) {
            var surface = new Granite.Drawing.BufferSurface(w,h);
            Cairo.Context cr = surface.context;
            cr.set_source_rgba(r, g, b, 0.5);
            cr.translate(w/2, h/2);
            cr.arc(0, 0, (w/2)-2 , 0, 2*GLib.Math.PI);
            cr.fill_preserve();
            cr.set_line_width(1);
            cr.set_source_rgb(r, g, b);
            cr.stroke();
            return surface.load_to_pixbuf ();
        }

        public unowned string color_string {
            get { return _color; }
            set {_color = value; current.pixbuf = this.get_color_dot_from_hex (_color, this.size, this.size); }
        }
        
        public Gdk.Color color {
            private set { color = value; }
            get {
                Gdk.Color c;
                Gdk.Color.parse ("#"+color_string, out c);
                return c;
            }
        }
        
        Gtk.Image current;
        
        public ColorRow (int show=8) {
            
            var menu  = new Gtk.Menu ();
            var arrow = new Gtk.EventBox ();
            
            arrow.add (new Gtk.Arrow (Gtk.ArrowType.DOWN, Gtk.ShadowType.NONE));
            
            this._color  = RowPalette.colors[0];
            this.current = new Gtk.Image.from_pixbuf (this.get_color_dot_from_hex (_color, this.size, this.size));
            this.current.margin_right = 6;
            
            this.pack_start (current, false);
            this.images = new Gtk.Image [RowPalette.colors.length];
            
            for (var i=0;i<this.images.length;i++)
                this.images[i] = new Gtk.Image.from_pixbuf (this.get_color_dot_from_hex (RowPalette.colors[i], 
                    this.size, this.size));

            /*fill the box*/
            for (var i=0;i<show;i++) {
                var e = new Gtk.EventBox ();
                e.add (this.images [i]);
                this.pack_start (e, false);
                var idx = i;
                e.button_press_event.connect ( () => {
                    this.color_string = RowPalette.colors[idx];
                    return false;
                });
            }
            this.pack_start (arrow, false, false);
            /*fill the menu*/
            for (var i=show;i<this.images.length;i++) {
                var m = new Gtk.MenuItem ();
                m.add (this.images[i]);
                menu.append (m);
                var idx = i;
                m.activate.connect ( () => {
                    this.color_string = RowPalette.colors[idx];
                });
            }
            
            arrow.button_press_event.connect ( (e) => {
                menu.popup (null, null, (m, x, y, push_in) => {x=0;y=0;push_in=true;}, e.button, e.time);
                return true;
            });
            menu.attach_to_widget (arrow, (w,m) => {});
            menu.show_all ();
        }
    }
}